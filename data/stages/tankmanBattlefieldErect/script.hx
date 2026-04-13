import funkin.objects.Bopper;
import funkin.game.shaders.DropShadowShader;
import funkin.data.Chart;
import funkin.objects.stageobjects.TankmenBG;

import haxe.ds.ArraySort;

var bg:FlxSprite;
var sniper:FlxSprite;
var guy:FlxSprite;
var tankBricks:FlxSprite;

//
var anims:Array<String> = ['shoot1', 'shoot2', 'shoot3', 'shoot4'];
var otisAnims:Array<CrowdAnim> = [];
var chart:Song = null;

typedef CrowdAnim =
{
	var time:Float;
	var data:Int;
	var length:Int;
}

function onLoad()
{
	bg = new FlxSprite(-985, -805);
	bg.loadGraphic(Paths.image("backgrounds/tank/erect/bg"));
	bg.scale.set(1.15, 1.15);
	bg.scrollFactor.set(1, 1);
	bg.antialiasing = true;
	add(bg);
	
	sniper = new Bopper(-300, 200).loadAtlas('backgrounds/tank/erect/sniper');
	sniper.addAnimByPrefix("idle", "Idle", 24, false);
	sniper.addAnimByPrefix("sip", "Sip", 24, false);
	sniper.animation.play("idle");
	sniper.scale.set(1.15, 1.15);
	sniper.scrollFactor.set(1, 1);
	sniper.antialiasing = true;
	add(sniper);
	
	tankmanRun = new FlxTypedGroup();
	add(tankmanRun);
	
	// guy = new Bopper(-50, -150).loadAtlas('backgrounds/tank/erect/rando');
	// guy.addAnimByPrefix("idle", "rando", 24, true);
	// guy.animation.play("idle");
	// guy.scale.set(1.15, 1.15);
	// guy.scrollFactor.set(1, 1);
	// guy.antialiasing = true;
	// add(guy);
	
	tankBricks = new FlxSprite(465, 760);
	tankBricks.loadGraphic(Paths.image("backgrounds/tank/erect/bricksGround"));
	tankBricks.scale.set(1.15, 1.15);
	tankBricks.scrollFactor.set(1, 1);
	tankBricks.flipX = true;
	tankBricks.antialiasing = true;
	add(tankBricks);
	
	bg.zIndex = 10;
	sniper.zIndex = 20;
	tankmanRun.zIndex = 30;
	tankBricks.zIndex = 101;
}

function makeRimForSpr(spr, angle:Float = 0)
{
	if (spr.animateAtlas != null) spr.animateAtlas.useRenderTexture = true;
	
	rim = new DropShadowShader();
	rim.setAdjustColor(-46, -38, -25, -20);
	rim.color = 0xFFDFEF3C;
	rim.angle = angle;
	rim.attachedSprite = spr;
	spr.shader = rim;
	
	return rim;
}

function onCreatePost()
{
	var dadrim = makeRimForSpr(dad, 25);
	dadrim.threshold = 0.3;
	
	var bfRim = makeRimForSpr(boyfriend, 90);
	
	var gfRim = makeRimForSpr(gf, 90);
	rim.loadAltMask(Paths.image('backgrounds/tank/erect/masks/neneTankmen_mask'));
	rim.maskThreshold = 0.4;
	rim.useAltMask = true;
	
	for (i in [dad, gf, boyfriend])
	{
		i.shader.distance = 0;
		FlxTween.tween(i.shader, {distance: 15}, 1);
	}
	
	chart = Chart.fromPath(Paths.json('stress-(pico-mix)/charts/picospeaker'));
	if (chart != null)
	{
		for (section in chart.notes)
		{
			for (note in section.sectionNotes)
			{
				otisAnims.push(
					{
						time: note[0],
						data: Math.floor(note[1] % 4),
						length: note[2]
					});
			}
		}
	}
	
	ArraySort.sort(otisAnims, (a, b) -> {
		if (a.time < b.time) return -1;
		else if (a.time > b.time) return 1;
		return 0;
	});
	
	if (!ClientPrefs.lowQuality)
	{
		var firstTank:TankmenBG = new TankmenBG(20, 500, true);
		firstTank.resetShit(-200, 600, true);
		firstTank.strumTime = 10;
		firstTank.visible = false;
		tankmanRun.add(firstTank);
		
		for (i in 0...otisAnims.length)
		{
			final goingRight = otisAnims[i].data < 2;
			
			if (FlxG.random.bool(20))
			{
				var tankBih = tankmanRun.recycle(TankmenBG);
				tankBih.strumTime = otisAnims[i].time;
				tankBih.setScale(1, 1);
				tankBih.resetShit(0, 130, goingRight);
				tankBih.endingOffset = goingRight ? 160 : 10;
				tankBih.endAnimOffset = goingRight ? [300, 200] : [270, 200];
				tankBih.visible = true;
				
				var rim = makeRimForSpr(tankBih, 90);
				rim.distance = 10;
				tankBih.animation.onFrameChange.add(() -> {
					rim.updateFrameInfo(tankBih.frame);
				});
				
				tankmanRun.add(tankBih);
			}
		}
	}
}

function updateOtisCharts()
{
	if (otisAnims.length != 0 && otisAnims[0].time <= Conductor.songPosition)
	{
		var data = otisAnims[0];
		
		var animToPlay:String = anims[data.data];
		gf.holdTimer = 0;
		gf.playAnim(animToPlay, true);
		var holdingTime = Conductor.songPosition - data.time;
		if (data.length == 0 || data.length < holdingTime) otisAnims.shift();
	}
}

function onUpdate(elapsed)
{
	updateOtisCharts();
}

var can = false;

function onStartCountdown()
{
	if (can)
	{
		camHUD.alpha = 0;
		
		var anim = new Bopper(-320, -885).loadAtlas('cutscenes/stress-pico-mix');
		anim.addAnimByPrefix('play', 'full scene ', 24, false);
		anim.playAnim('play');
		anim.zIndex = 99999;
		// anim.angularVelocity = 200;
		stage.add(anim);
		
		var rim = makeRimForSpr(anim, 90);
		rim.threshold = 0.3;
		rim.distance = 0;
		
		dadGroup.visible = boyfriendGroup.visible = gfGroup.visible = false;
		
		snapCamToPos(getCharacterCameraPos(dad).x + 440, getCharacterCameraPos(dad).y, true);
		
		anim.onAnimationFrameChange.add((anim, frame) -> {
			switch (frame)
			{
				case 151:
					cameraSpeed = 2;
					
					FlxTween.tween(camGame, {zoom: 1.2}, 0.5, {ease: FlxEase.quartInOut});
					FlxTween.tween(camFollow, {y: camFollow.y - 120}, 0.2, {ease: FlxEase.quartIn});
				case 205:
					camFollow.x -= 40;
				case 270:
					cameraSpeed = 0.3;
					
					FlxTween.tween(camGame, {zoom: 0.74}, 2.8, {ease: FlxEase.quartInOut});
					FlxTween.tween(camFollow, {y: camFollow.y - 200}, 1.2, {ease: FlxEase.quartIn});
				case 326:
					cameraSpeed = 1;
					
					FlxTween.cancelTweensOf(camGame);
					FlxTween.tween(camGame, {zoom: 0.9125}, 0.4, {ease: FlxEase.bounceOut});
					camFollow.setPosition(getCharacterCameraPos(boyfriend).x, getCharacterCameraPos(boyfriend).y);
				case 579:
					FlxTween.cancelTweensOf(camGame);
					FlxTween.tween(camGame, {zoom: 0.8}, 0.7, {ease: FlxEase.quartInOut});
					FlxTween.tween(camFollow, {x: getCharacterCameraPos(dad).x, y: camFollow.y - 50}, 0.4, {ease: FlxEase.circInOut});
				case 669:
					camFollow.x -= 30;
					camGame.shake(0.05, 0.01);
				case 750:
					final pos = getCharacterCameraPos(dad);
					
					FlxTween.cancelTweensOf(camGame);
					FlxTween.tween(camGame, {zoom: 0.7}, 0.7, {ease: FlxEase.quadInOut});
					FlxTween.tween(camFollow, {x: pos.x + 440, y: pos.y}, 0.4, {ease: FlxEase.circIn});
				case 790:
					FlxTween.tween(camHUD, {alpha: 1}, 0.6);
					can = false;
					startCountdown();
			}
		});
		
		anim.onAnimationFinish.add(() -> {
			anim.visible = false;
			dadGroup.visible = boyfriendGroup.visible = gfGroup.visible = true;
			
			for (i in [dad, gf, boyfriend])
			{
				i.shader.distance = 0;
				
				FlxTween.tween(i.shader, {distance: 15}, 1);
			}
		});
		
		FlxG.sound.play(Paths.sound('stressPicoCutscene'));
		
		return ScriptConstants.STOP_FUNC;
	}
}
