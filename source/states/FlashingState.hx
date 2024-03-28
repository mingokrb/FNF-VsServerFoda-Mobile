package states;

import flixel.FlxSubState;

import flixel.effects.FlxFlicker;
import lime.app.Application;
import flixel.addons.transition.FlxTransitionableState;
import flixel.addons.display.FlxBackdrop;

class FlashingState extends MusicBeatState
{
	public static var leftState:Bool = false;

	var bg:FlxBackdrop;
	var ni:Alphabet;
	var warnText:FlxText;
	override function create()
	{
		super.create();

		bg = new FlxBackdrop(Paths.getSharedPath('backdrop.png')); //new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		bg.alpha = 0.2;
		bg.updateHitbox();
		bg.screenCenter(X);
		add(bg);

		ni = new Alphabet(0, 100, 'Cuidado!', true);
		ni.screenCenter(X);
		add(ni);
		var guh:String = 'Este mod contém algumas luzes piscantes!\n
		Aperte A/ENTER para desativá-las ou ir para o Menu de Opções.\n
		Aperte B/ESC para ignorar essa mensagem.\n
		Você foi avisado(a)!';

		controls.isInSubstate = false; // qhar I hate it
		warnText = new FlxText(0, FlxG.height * 0.25, FlxG.width, guh, 16);
		warnText.setFormat(Paths.font('comicsans.ttf'), 32, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		//warnText.updateHitbox();
		warnText.screenCenter(X);
		add(warnText);

		FlxG.sound.playMusic(Paths.music('offsetSong'), 0.7, true);
		addVirtualPad('NONE', 'A_B');
	}

	override function update(elapsed:Float)
	{
		if(!leftState) {
			// https://gamebanana.com/tuts/15426
			bg.x += .3*(elapsed/(1/120));
			bg.y -= 0.2 / (ClientPrefs.data.framerate / 60); 

			var back:Bool = controls.BACK;
			if (controls.ACCEPT || back) {
				//FlxG.sound.music.fadeOut(0.5, 0, function(twn:FlxTween) {
					//FlxG.sound.playMusic(Paths.music('freakyMenu'), 0);
				//});
				leftState = true;
				FlxTransitionableState.skipNextTransIn = true;
				FlxTransitionableState.skipNextTransOut = true;
				if(!back) {
					ClientPrefs.data.flashing = false;
					ClientPrefs.saveSettings();
					FlxG.sound.play(Paths.sound('confirmMenu'));
					FlxTween.tween(bg, {alpha: 0}, 1);
					FlxTween.tween(ni, {alpha: 0}, 1.1);
					FlxFlicker.flicker(warnText, 1, 0.1, false, true, function(flk:FlxFlicker) {
						new FlxTimer().start(0.2, function (tmr:FlxTimer) {
							FlxG.sound.playMusic(Paths.music('freakyMenu'), 0);
							MusicBeatState.switchState(new TitleState());
						});
					});
				} else {
					FlxG.sound.play(Paths.sound('cancelMenu'));
					FlxTween.tween(bg, {alpha: 0}, 0.65);
					FlxTween.tween(ni, {alpha: 0}, 0.7);
					FlxTween.tween(warnText, {alpha: 0}, 0.6, {
						ease: FlxEase.quadOut,
						onComplete: function (twn:FlxTween) {
							FlxG.sound.playMusic(Paths.music('freakyMenu'), 0);
							MusicBeatState.switchState(new TitleState());
						}
					});
				}
			}
		}
		super.update(elapsed);
	}
}
