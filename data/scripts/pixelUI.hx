final pixelZoom:Float = 6.0;
final yAdjust = -50;

function onCreatePost()
{
	for (i in [boyfriendGroup, dadGroup])
	{
		for (j in i.members)
			j.camDisplacement = 10;
	}
	
	cameraSpeed = 4;
	FlxG.usePixelPerfectRendering = true;
	
	countdownPrefix = 'pixelUI/';
	
	playHUD.comboTween = false;
	
	playHUD.ratingPrefix = 'pixelUI/ratings/';
	playHUD.comboPrefix = 'pixelUI/combo/';
}

function onPopUpScorePost(note, ratingData, rating, numGroup)
{
	rating.antialiasing = false;
	rating.setScale(pixelZoom * 0.85, pixelZoom * 0.85);
	rating.updateHitbox();
	rating.y += yAdjust * 1.2;
	
	var daLoop = 0;
	for (numScore in playHUD.ratingNumGroup.members)
	{
		numScore.antialiasing = false;
		numScore.setScale(6, 6);
		numScore.y += yAdjust;
	}
}

function onCountdownTick(tick)
{
	if (tick >= 1 && tick <= 3)
	{
		final spr = switch (tick)
		{
			case 1:
				countdownReady;
			case 2:
				countdownSet;
			case 3:
				countdownGo;
		}
		spr.scale.set(6, 6);
		spr.updateHitbox();
		spr.screenCenter();
		spr.antialiasing = false;
	}
}
