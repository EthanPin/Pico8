pico-8 cartridge // http://www.pico-8.com
version 41
__lua__
function _init()
	make_player()
end

function _update()
	 move_player()
	 --bullet handeling
	 if(btnp(❎) and p.dir) newbullet(p.x+14,p.y+8,4,4,2,0.1,not p.dir)  --sets bullet start
  if(btnp(❎) and not p.dir)  newbullet(p.x-6,p.y+8,4,4,-2,0.1,not p.dir)  --sets bullet physics & start
  local i,j=1,1               --to properly support objects being deleted, can't use del() or deli()
  while(objs[i]) do           --if we used a for loop, adding new objects in object updates would break
    if objs[i]:update() then
      if(i!=j) objs[j]=objs[i] objs[i]=nil --shift objects if necessary
      j+=1
    else objs[i]=nil end       --remove objects that have died or timed out
    i+=1                       --go to the next object (including just added objects)
  end
 --end bullet handeling
end

function _draw()
	 cls()

 	--draw the map from tile 0,0
 	--at screen coordinate 0,0 and
 	--draw 16 tiles wide and tall
 	map(0,0,0,0,64,64)

 	--draw the player's sprite at
 	--p.x,p.y
 	camera(p.x - 56, p.y - 80)
	 spr(p.sprite,p.x,p.y,2,2,not p.dir,false)
	 --bullets draw
  for o in all(objs) do o:draw() end
end

function make_player()
	 p={}  --create empty table

	 p.x=24 --player's exact pixel
 	p.y=80 --position on screen
 	p.clm = p.x/8	 --collumn
 	p.row = p.y/8  --row

 	--p.gnd	 = true 	--on ground?
 	p.dir	 = true		--direction true = >>>
 	p.runfrm  = 0		--run anim sprites
	 p.dash = false	--am i dashin
	 p.jump = false	--am i jumpin
	 p.rise = 30				--jmp distance

	 p.sprite=032 --player sprite
end

function walk()
  --use  <= instead of ==
		if (p.runfrm >= 9 and p.runfrm < 12) then
		  p.sprite = 044
		  p.runfrm = 0
		elseif (p.runfrm >= 6 and p.runfrm < 9) then
		  p.sprite = 046
		  p.runfrm += 1
		elseif (p.runfrm >= 3 and p.runfrm < 6) then
		  p.sprite = 044
		  p.runfrm += 1
		else
    p.sprite = 042
    p.runfrm += 1
  end
end

function move_player()
	 --depending on which buttons
	 --are pressed
	 --left
 	if (btn(⬅️)) then
		--get the tile and check the flag to the left
		  if --(fget(mget(((p.x-1)/8),((p.y)/8))) != 001) and
		    (fget(mget(((p.x-1)/8),((p.y-1)/8)+1)) != 001) and
		  		(fget(mget(((p.x-1)/8),((p.y-1)/8)+2)) != 001) then
						p.x-=1
						walk()
				else
						p.sprite = 034 --hit a wall
		  end
		  p.clm = p.x/8  --update player collumn
		  if (not btn(❎)) then p.dir = false end
	end --left
	 --right
	 if (btn(➡️)) then
		  --get the tile and check the flag 2 tiles 2 the right
		  if --(fget(mget((p.x/8)+2,((p.y)/8))) != 001) and
		  		(fget(mget((p.x/8)+2,((p.y-1)/8)+1)) != 001) and
		  		(fget(mget((p.x/8)+2,((p.y-1)/8)+2)) != 001)then
				  p.x+=1
				  walk()
				else
						p.sprite = 034  --hit a wall
		  end
		  p.clm = p.x/8  --update player collumn
		  if (not btn(❎)) then p.dir = true end
	 end --right
	 --dash	
	 if (btnp(🅾️) and btn(⬇️)) then --not jump
		  if (p.dir) then --check direction
			   p.x+=6
			   p.dash = true
		  else
			   p.x-=6
			   p.dash = true
		  end
	 end --dash
	 --gravity
	 --if in the air
	 if (fget(mget(((p.x-1)/8)+2,((p.y)/8)+2)) != 001) and --in air
	 		(fget(mget(((p.x-1)/8)+1,((p.y)/8)+2)) != 001) and --in air
	 		(fget(mget(((p.x)/8),((p.y)/8)+2)) != 001) then --in air
				--holding jump
				if (btn(🅾️) and not btn(⬇️) and p.rise > 0) then
  				--if you hit the ceiling
  				if (fget(mget(((p.x-3)/8)+2,((p.y)/8))) == 001) or --ceiling
	 		    (fget(mget(((p.x-1)/8)+1,((p.y)/8))) == 001) or --ceiling
	 		    (fget(mget(((p.x+3)/8),((p.y)/8))) == 001) then
  				  p.rise -= 10
  				  p.sprite = 036
  				  sfx(0,-1,3,4)
  				--you are holding jump
  				else
  				  p.rise -= 1
  				  p.y -= 1
  				  p.sprite = 038
  				end
  		--then you are just falling		
  		else 
  				p.y += 1
  				p.rise = 0
  				p.sprite = 040
  		end
		--if on ground		
		else 
				--standing still
				if (not btn(➡️) and not btn(⬅️)) then
						p.sprite = 032
				end
				--start jump
				if (btnp(🅾️) and not btn(⬇️)) then
    		p.rise = 30
    		p.y -= 2
    		p.sprite = 038--jump frame
    		p.jump = true
    		sfx(0,-1,0,2)
  		end
  end
end
-->8
--bullet settings--
objs = {}                    --a list of all the objects in the game (starts empty)
function objdraw(o)          --a basic function for drawing objects,
  spr(o.spr,o.x,o.y,1,1,o.dir)            --as long as those objects have spr, x, and y values inside
end
function bulletupdate(b)     --a function for moving bullets a little bit at a time
  b.x += b.dx                 --x moves by the change in x every frame (dx)
  b.y += b.dy                 --y moves by the change in y every frame (dy)
  b.time -= 1                 --if bullets have existed for too long, erase them
  --bullet hits wall
  if (fget(mget(((b.x)/8),((b.y)/8))) == 001) then
    return false
  end
  --bullet hits sappling
  if (fget(mget(((b.x)/8),((b.y)/8))) >= 002) then
    b.spr = 011
    mset(b.x/8,b.y/8,009) --changes sappling to a flower
  end
  return b.time > 0           --returns true if still alive, false if it needs to be removed
end
function newbullet(x,y,w,h,dx,dy,dir)  --bullets have position x,y, width, height, and move dx,dy each frame
  local b = {                 --only use the b table inside this function, it's "local" to it
    x=x,y=y,dx=dx,dy=dy,       --the x=x means let b.x = the value stored in newbullet()'s x variable
    w=w,h=h,dir=dir,                   --b.w and b.h are also set to the function's w and h args
    time=26,                   --this is how long a bullet will last before disappearing
    update=bulletupdate,       --you can put functions in tables just like any other value
    spr=010,draw=objdraw         --bullets don't have special drawing code, so re-use a basic object draw
  }
  add(objs,b)                 --now we can manage all bullets in a list
  return b                    --and if some are special, we can adjust them a bit outside of this function
end


__gfx__
0000000064404564bbbbbbbb000000000000000055555555c7c77cc71cccc1cc0000000006770000000000c000000000eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
0000000004046445333bb333000000000000000066766666cccccccccc1ccc1c00000000007606760000c00000000c00eeeeeee333eeeeeeeeeeeee333eeeeee
007007004454404463333337000000000000000066666767ccccccccccc1c1cc000000007706a6770c11cccccccc0000eee33337773eeeeeeee33337773eeeee
00077000646464545f3333f6000000000000000067666666cccc7ccccccccccc00676000760030670c0cccc001c1ccc0ee3777377703eeeeee3777377073eeee
0007700046540540f6ff6f5f000000000000000066676666cc7ccccccccccccc007a7000777030000000c0000cccc1c0e37770377773eeeee37770377773eeee
0070070050446454f65f76f6000000000000000067666676cccccccccc1ccccc006bb0000000300000c00000c1cc0000ee37777377733eeeee37777377733eee
00000000446054647ffff5f5000000000000000066676666cccccc7cffffffff0003300000033000000000000c0000c0ee33777333333eeeee33777333333eee
00000000445446405f7f6f7f000000000000000055555555cccccccc44444444bbbbbbbbbbbbbbbb000000000000c000eee33333333333eeeee33333333333ee
0000000000000000000000000000000000000000000000002e3333ee0033330000333300003333000033330000333300eeee333333333333eeee333333333333
000000000000000000000000000000000000000000000000e703370e0703370007033700070337000703370007033700eee33333bbb33333eee33333b8b33333
0000000000000000000000000000000000000000000000003703370e3703370037733770377337703703370037033700eeee33338333333eeeee3333b8b3333e
000000000000000000000000000000000000000000000000333333333333333333333334333333343333333333333333eeee3333333333eeeeee3333bb3333ee
000000000000000000000000000000000000000000000000333bb333333bb333333bb343333bb343333bb333333bb333eeeee333333333eeeeeee333333333ee
000000000000000000000000000000000000000000000000e33834440338344403383440033834400338344303383443eeeee44333344eeeeeeeee3333333eee
000000000000000000000000000000000000000000000000ee33434e0033434000333400003334000033334400333344eeee4444ee4444eeeeeeee33eee33eee
000000000000000000000000000000000000000000000000ee3ee3ee0330033000300300033003300030030403300334eeee4444ee4444eeeeeeee33eee33eee
0000000666000000a000a006655555500a0006655000a0a000000660000000000000066000000000000000000000000000000000000000000000000000000000
00066660566000000000000600055555000655005550000000000066500000000000006650000000000006600000000000000600000000000000000550000000
000055605556000000a0066555555771a06005505555000066666000555000006666600055500000000000655000000000000660000000000000066055500000
0000055600560000a00006000555577100000055557500a000055600571500000005560057750000665550005550000000000065500000000055500055550000
00000055555000000000000000771771000000055555500000000555577500000000055557150000000005005555000066555000555000000060050057150000
0000055557150000a000000cc5771555000000055555700000000005555550000000000555555000000000555715000000000505555500000060005555555000
000005571715000000a0000cc5555575000000555550700000000005555570000000000555557000000000055555500000000055571550000000000555555000
00000057155000000000069cc5555070000005ccc550000000000055555070000000005555507000000000055555700000000005555570000000000555557000
0000005555700000a000069cc5555500000005ccccaaa990000005ccc5500000000005ccc5500000000000555550700000000555555070000000005555507000
000ccccccaaaaa9900000a9c556655560000059999900000000005ccccaaa990000005ccccaaa990000005ccc5500000000005ccc5500000000005ccc5500000
000ccc99999956000007009a56665556000705556a00000000000599999000000000059999900000000005ccccaaa990000005ccccaaa990000005ccccaaa990
00005556455550000007755a566555500007555555000000000705556a000000000705556a000000000005999990000000000599999000000000759999900000
07055555555550000007755a55555500000075500556000000075555550000000007555555000000000705556a000000000005556a000000000775556a000000
07755555550000000000055905555000000005560000000000007550055600000000755005560000000755555500000000750555550000000007555555000000
07555555555000000006555965550000000000000000000000000556000000000000055600000000000075555000000000075555500000000000705555000000
00005555555556000006660066600000000000000000000000000000000000000000000000000000000005555560000000007555560000000000000056000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
bb0b000bb00330000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0b0b00bb0000e0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
eb3bb00b000030000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
b330b33330bbb0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0b003300b3b0003b0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00b33e3003b000300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000003030b000bb00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000b00b0b00b000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000b0bb0bbeb000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000bbb0bb000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000004400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000004400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000004400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000044440000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000444444000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__gff__
0001010000010000020000000000000000000000000100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
0505050000000000050505050505050505050505050505050505050505000000000000000000000000000005000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0500000000000005050505050505050505050505050505050505050000050500000000000000000000000005000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0500000000000000000000000000000005050500000005050505050500000005050000000000000000000005000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0500000000000505000000000000000000000505000000000000000505050500000505000000000000000005000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0500000000000500000000000000000502021405000000000000000000000005050000050500000000000005000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0500000000050500000000000000000000000005050000000000000000000000050500000500000000000005000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0500000000000000000000000008000000000000050000000000000000000000000505000005000000000005000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0505050200000000000000000005050000000000000000000000000000000000010005050005000000000005000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0501010500000000000800050205050000000000000000000000000000000000010000000005000000000005000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0500000000000000000101010101010001000000000000000001000000000001010101000005000000000005000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0500000000000000050505050505050505050500000505000005050505050505050505050505050505050505050505050505050505050505050505050505050505050505050505050505050505050505050505050505050505050505050505050505050505050505050505050505050505050505050000000000000000000000
0500000000000000000000000000000000000000000000000000000000000000000000000005000000000005000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000050505050000000000000000
0500000000000000000000000000000000000000000000000000000000000000000000000105000000000005000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000050505000000000000
0502010205020606060208000000000500000800000000000000080000000800000000010105000000000005000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000005050000000000
0500000001010101010101000000000500000202020000000000080000000800000001010005000000000005000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000050000000000
0500000000000000000000020000000000000000000000000000080000000800000000000005000000000005000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000050500000000
0500000000000000000000000000000000000000000000000000080000000100000000000005000000000005000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000500000000
0500000008000000000000000000000000000000000000000000080000000800000000000005000000000005000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000505050000
0501010101000008000800000000000008000000000008000000080000000808000000000005000000000005000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000050505
0500000001010101010101000000010101010000000001010501010101010101010101000005000000000005000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000005
0505000000000000000000010101000000000000000001000500000000000000000000000005000000000005000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000005
0505000000000000000000000000000000000000000101000500000000000000000000000005000000000005000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000005
0505000000000000000000000000000000000000010100000500000000000000000000000005000000000005000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000005
0505000000000000000000000101010101010101010000000500000000000000000000000005000000000005000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000005
0505000000000000000001010000000000000000000000000500000000000000000000000005000000000005000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000500
0505010100000000010101000000000000000000000000000500000000000000000000000005000000000005000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000050500
0505000001000000000000000000000000000000000000000500000000000000000000000005000000000005000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000050000
0505000000010000000000000000000000000000000000000505000000000000000000000005000000000005000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000005050000
0505000000000100000000000000000000000000000000000505000000000000000000000005050000000005000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000005000000
0500000000000001000000000000000000000101000000000500000000000000000000000005050000000005000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000505000000
0500000000000000010001010101010101010100000000000500000000000000000000000000050500000005000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000505000000
0500000000000000000100000000000000000000000000050500000000000000000000000000000500000005000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000050500000000
__sfx__
000700002f520325203b5200b7500375005200092000060016700036001b0002600029000047002b5001a50032500187001e7002070032700233000470025400274002840029400294003c400000000000000000
