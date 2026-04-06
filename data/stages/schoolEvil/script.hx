var bgGhouls:BGSprite;

function onLoad()
{
	var posX = 400;
	var posY = 300;
	if (!ClientPrefs.lowQuality)
	{
		var bg:BGSprite = new BGSprite('backgrounds/weeb/animatedEvilSchool', posX, posY, 0.8, 0.9, ['background 2'], true);
		bg.scale.set(6, 6);
		bg.antialiasing = false;
		add(bg);
		
		bgGhouls = new BGSprite('backgrounds/weeb/bgGhouls', -100, posY, 0.9, 0.9, ['BG freaks glitch instance'], false);
		bgGhouls.setGraphicSize(Std.int(bgGhouls.width * 6));
		bgGhouls.updateHitbox();
		bgGhouls.visible = false;
		bgGhouls.antialiasing = false;
		add(bgGhouls);
	}
	else
	{
		var bg:BGSprite = new BGSprite('backgrounds/weeb/animatedEvilSchool_low', posX, posY, 0.8, 0.9);
		bg.scale.set(6, 6);
		bg.antialiasing = false;
		add(bg);
	}
}

function onCreatePost()
{
	initScript('data/scripts/pixelUI');
}

function onUpdate(elapsed)
{
	if (!ClientPrefs.lowQuality && bgGhouls.animation.curAnim.finished)
	{
		bgGhouls.visible = false;
	}
}

function onEvent(eventName, value1, value2)
{
	if (eventName == 'Trigger BG Ghouls')
	{
		bgGhouls.dance(true);
		bgGhouls.visible = true;
	}
}

var a = false;

function onStartCountdown()
{
	if (!a && PlayState.isStoryMode)
	{
		a = true;
		if (Paths.sanitize(PlayState.SONG.song) == 'roses') FlxG.sound.play(Paths.sound('ANGRY'));
		
		camHUD.alpha = 0;
		
		var path = Paths.getPath('data/dialogue/' + songName + '/' + songName + 'Dialogue.txt', null, true);
		dialogueBox = new DialogueBox(false, CoolUtil.coolTextFile(path));
		dialogueBox.scrollFactor.set();
		dialogueBox.camera = camOther;
		dialogueBox.finishThing = startCountdown;
		
		schoolIntro(dialogueBox);
		
		return Function_Stop;
	}
	else if (a)
	{
		FlxTween.tween(camHUD, {alpha: 1}, 2);
	}
}

function schoolIntro(dialogueBox)
{
	inCutscene = true;
	snapCamToPos(600, 550);
	
	var black:FlxSprite = new FlxSprite(-100, -100).makeScaledGraphic(FlxG.width * 2, FlxG.height * 2, FlxColor.BLACK);
	black.scrollFactor.set();
	black.cameras = [camHUD];
	add(black);
	
	var red:FlxSprite = new FlxSprite(-100, -100).makeScaledGraphic(FlxG.width * 2, FlxG.height * 2, 0xFFff1b31);
	red.cameras = [camOther];
	red.scrollFactor.set();
	
	var senpaiEvil:FlxSprite = new FlxSprite();
	senpaiEvil.frames = Paths.getSparrowAtlas('backgrounds/weeb/senpaiCrazy');
	senpaiEvil.animation.addByPrefix('idle', 'Senpai Pre Explosion', 24, false);
	senpaiEvil.setGraphicSize(Std.int(senpaiEvil.width * 6));
	senpaiEvil.scrollFactor.set();
	senpaiEvil.updateHitbox();
	senpaiEvil.screenCenter();
	senpaiEvil.cameras = [camOther];
	senpaiEvil.antialiasing = false;
	senpaiEvil.x += 300;
	
	var songName:String = Paths.sanitize(PlayState.SONG.song);
	if (songName == 'roses' || songName == 'thorns')
	{
		remove(black);
		
		if (songName == 'thorns')
		{
			add(red);
			camHUD.visible = false;
		}
	}
	
	new FlxTimer().start(0.3, function(tmr:FlxTimer) {
		black.alpha -= 0.15;
		
		if (black.alpha > 0)
		{
			tmr.reset(0.3);
		}
		else
		{
			if (dialogueBox != null)
			{
				if (Paths.sanitize(PlayState.SONG.song) == 'thorns')
				{
					add(senpaiEvil);
					senpaiEvil.alpha = 0;
					new FlxTimer().start(0.3, function(swagTimer:FlxTimer) {
						senpaiEvil.alpha += 0.15;
						if (senpaiEvil.alpha < 1)
						{
							swagTimer.reset();
						}
						else
						{
							senpaiEvil.animation.play('idle');
							FlxG.sound.play(Paths.sound('Senpai_Dies'), 1, false, null, true, function() {
								// Just incase...
								senpaiEvil.alpha = 0.001;
								red.alpha = 0.001;
								
								remove(senpaiEvil);
								remove(red);
								camOther.fade(FlxColor.WHITE, 0.01, true, function() {
									add(dialogueBox);
									camHUD.visible = true;
								}, true);
							});
							new FlxTimer().start(3.2, function(deadTime:FlxTimer) {
								camOther.fade(FlxColor.WHITE, 1.6, false);
							});
						}
					});
				}
				else
				{
					add(dialogueBox);
				}
			}
			else startCountdown();
			
			remove(black);
		}
	});
}
