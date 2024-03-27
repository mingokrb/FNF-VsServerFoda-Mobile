package states;

import flixel.FlxSubState;

import flixel.effects.FlxFlicker;
import lime.app.Application;
import flixel.addons.transition.FlxTransitionableState;

class FlashingState extends MusicBeatState
{
	public static var leftState:Bool = false;

	var warnText:FlxText;
	override function create()
	{
		super.create();

		var bg:FlxBackdrop = new FlxBackdrop(Paths.image('backdrop')); //new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		add(bg);

		var guh:String = "Cuidado!\n
		Este mod contém algumas luzes piscantes!\n
		Aperte A/ENTER para desativá-las ou ir para o Menu de Opções.\n
		Aperte B/ESC para ignorar essa mensagem.\n
		Você foi avisado(a)!";

		controls.isInSubstate = false; // qhar I hate it
		warnText = new FlxText(0, 0, FlxG.width, guh, 48);
		warnText.setFormat(Paths.font('comicsans.ttf'), 48, FlxColor.WHITE, CENTER);
		warnText.screenCenter(Y);
		add(warnText);

		addVirtualPad('NONE', 'A_B');
	}

	override function update(elapsed:Float)
	{
		if(!leftState) {
			var back:Bool = controls.BACK;
			if (controls.ACCEPT || back) {
				leftState = true;
				FlxTransitionableState.skipNextTransIn = true;
				FlxTransitionableState.skipNextTransOut = true;
				if(!back) {
					ClientPrefs.data.flashing = false;
					ClientPrefs.saveSettings();
					FlxG.sound.play(Paths.sound('confirmMenu'));
					FlxFlicker.flicker(warnText, 1, 0.1, false, true, function(flk:FlxFlicker) {
						new FlxTimer().start(0.5, function (tmr:FlxTimer) {
							MusicBeatState.switchState(new TitleState());
						});
					});
				} else {
					FlxG.sound.play(Paths.sound('cancelMenu'));
					FlxTween.tween(warnText, {alpha: 0}, 0.6, {
						ease: FlxEase.quadOut,
						onComplete: function (twn:FlxTween) {
							MusicBeatState.switchState(new TitleState());
						}
					});
				}
			}
		}
		super.update(elapsed);
	}
}
