import funkin.objects.stageobjects.ABotVis;
import funkin.backend.Conductor;
import funkin.utils.SortUtil;

import animate.FlxAnimateFrames;
import animate.FlxAnimate;

var abotSpeaker:FlxAnimate;
var pupil:FlxAnimate;
var abotVis:ABotVis;
var abot:FlxSpriteGroup;
var started = false;

function makeAdjustShader(_brightness, _hue, _contrast, _saturation)
{
	var shader = newShader('adjustColor');
	shader.setFloat('brightness', _brightness);
	shader.setFloat('hue', _hue);
	shader.setFloat('contrast', _contrast);
	shader.setFloat('saturation', _saturation);
	
	return shader;
}

function onCreatePost()
{
	dadGroup.zIndex += 1;
	boyfriendGroup.zIndex += 1;
	gfGroup.zIndex += 1;
	
	aBot = new FlxSpriteGroup();
	
	eyeWhites = new FlxSprite(-120, 200).makeGraphic(160, 60, FlxColor.WHITE);
	
	stereoBG = new FlxSprite(-20, -20).loadGraphic(Paths.image('characters/abot/stereoBG'));
	
	pupil = new FlxAnimate(-125, 190);
	pupil.frames = FlxAnimateFrames.fromAnimate((Paths.textureAtlas('characters/abot/systemEyes')));
	pupil.anim.addBySymbol('left', 'abot eyes 2', 24, false);
	pupil.anim.addBySymbol('right', 'abot eyes', 24, false);
	pupil.anim.addBySymbolIndices('lookin left', 'a bot eyes lookin', [5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17], 24, false);
	pupil.anim.addBySymbolIndices('lookin right', 'a bot eyes lookin', [22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35], 24, false);
	pupil.anim.play('lookin left');
	pupil.antialiasing = true;
	
	abotSpeaker = new FlxAnimate(-175, -50);
	abotSpeaker.frames = FlxAnimateFrames.fromAnimate((Paths.textureAtlas('characters/abot/abotSystem')));
	abotSpeaker.anim.addBySymbol('sys', 'Abot System', 24, false);
	abotSpeaker.anim.play('sys');
	abotSpeaker.antialiasing = true;
	abotSpeaker.useRenderTexture = true;
	
	abotVis = new ABotVis(audio.inst, false);
	abotVis.x += 30;
	abotVis.y += 35;
	
	aBot.setPosition(gf.x + 275, gf.y + 480);
	aBot.zIndex = gfGroup.zIndex - 1;
	// add(aBot);
	// stage.add(aBot);
	gfGroup.add(aBot);
	
	aBot.zIndex = 0;
	gf.zIndex = 1;
	
	gfGroup.sort(SortUtil.sortByZ);
	
	var adjust = makeAdjustShader(-40, -20, -40, -25);
	var vizAdjust = makeAdjustShader(-12, -30, 0, -10);
	
	for (spr in [pupil, abotSpeaker, stereoBG, eyeWhites])
		spr.shader = adjust;
	for (spr in abotVis.members)
		spr.shader = vizAdjust;
		
	aBot.add(eyeWhites);
	aBot.add(stereoBG);
	aBot.add(pupil);
	aBot.add(abotVis);
	
	aBot.add(abotSpeaker);
	
	tempAnalyzer();
}

var shit = [5, 4, 3, 2, 1, 0, 1, 2, 3, 4, 5];

function tempAnalyzer()
{
	if (started) return;
	
	var fuck = -1;
	for (i in abotVis.members)
	{
		fuck += 1;
		i.visible = true;
		i.animation.curAnim.curFrame = shit[fuck];
	}
	
	shit = shiftRight(shit);
	
	FlxTimer.wait(0.045, tempAnalyzer);
}

function shiftRight(arr)
{
	if (arr.length <= 1) return arr;
	
	var last = arr.pop(); // remove last element
	arr.unshift(last); // add it to the front
	
	return arr;
}

function onSongStart()
{
	started = true;
	
	if (ClientPrefs.streamedMusic) speakerBump();
	else
	{
		abotVis.snd = audio.inst;
		abotVis.initAnalyzer();
		abotVis.analyzer.fftN = 2048;
	}
}

function onDestroy()
{
	abotVis.dumpSound();
}

function onEndSong()
{
	abotVis.dumpSound();
}

var left = true;

function onBeatHit()
{
	if (abotSpeaker != null) abotSpeaker.anim.play('sys', true);
	
	if (ClientPrefs.streamedMusic) speakerBump();
}

var last = [];

function speakerBump()
{
	last = [];
	for (i in abotVis.members)
	{
		final choice = FlxG.random.int(0, 4, last);
		last = [choice];
		
		i.animation.curAnim.curFrame = choice;
		FlxTween.num(choice, 6, Conductor.stepCrotchet / 500,
			{
				onUpdate: (t) -> {
					i.animation.curAnim.curFrame = t.value;
				}
			});
	}
}

var prevSec = PlayState.SONG.notes[0];

function onSectionHit()
{
	if (pupil != null)
	{
		var sec = PlayState.SONG.notes[curSection];
		
		if (sec != null)
		{
			if (curSection > 0) prevSec = PlayState.SONG.notes[curSection - 1];
			if (sec.mustHitSection != prevSec.mustHitSection) pupil.anim.play('lookin ' + (sec.mustHitSection ? 'right' : 'left'));
		}
	}
}
