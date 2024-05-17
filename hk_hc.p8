pico-8 cartridge // http://www.pico-8.com
version 42
__lua__
--variables

--flag definitions:
--0 = 
--1 = 
--2 = player wall
--3 = critter wall

function _init()
  
  pause=0 
  camx=0
  camy=0
  w1=false
  
  player={}
    player.x=106
    player.y=376
    player.w=8
    player.h=8
    player.hp=3
    player.soul=0
    player.mp=2
    player.grav=2
    player.jump=-12
    player.ground=false

  critter={}
  
  addcrit(0,276,472)
  addcrit(0,376,472)
  addcrit(0,476,496)
  
  door={}

  adddoor(200,464)
  adddoor(248,464)
  adddoor(296,464)
  adddoor(408,464)
  
  
  --invisible walls that will turn visible only when player is going into them
  wall={}
  
  addwall(8,424,5,7)
  addwall(56,480,2,0)
  
end

function _draw()
 cls()
 map(0,0)
 spr(001,player.x,player.y)
 attack()
  
 --place hp on screen
 
 for i=1,player.hp do
	  spr(003,player.x-50+i*10,player.y-50)
	end 
  
 --place enemies
 
 for m in all(critter) do
   spr(064,m.x,m.y)
 end

 --place breakable doors
 --disappear when we go through
 for m in all(door) do
   if (abs(player.x-m.x)>4)
   then
     spr(024,m.x,m.y)
     spr(025,m.x+8,m.y)
     spr(040,m.x,m.y+8)
     spr(041,m.x+8,m.y+8)
   end
 end
 
 --place invisible walls
 --disappear when we go through
 
 for w in all(wall) do
   placewall(w)
 end
 
 --debug testing
 print("player.x",player.x+20,player.y-62)
 print(player.x,player.x+55,player.y-62)
 print("pause: ",player.x+7,player.y-55)
 print(pause,player.x+39,player.y-55)
end

function _update()

 if(pause>0)
 then
  pause-=1
 end
 
 if(pause==0)
 then 
  h_move()
  v_move()
 end 
 
 gravity() 
 
 cameraman()
  

 for m in all(critter) do
   critter_move(m)
 end 
 
end


-->8
--player movement

function collision(obj,dir,flg)
 --obj is a table w/ x,y,w,h
 local x=obj.x local y=obj.y
 local w=obj.w local h=obj.h
 
 --we need a dummy table for comp
 local x1=0 local x2=0  
 local y1=0 local y2=0
 
 if dir=="left" then
  x1=x-1   y1=y
  x2=x     y2=y+h-1
 
 elseif dir=="right" then
  x1=x+w+1 y1=y
  x2=x+w+2 y2=y+h-1
  
 elseif dir=="up" then
  x1=x+1   y1=y-1
  x2=x+w   y2=y
 
 elseif dir=="down" then
  x1=x+1   y1=y+h
  x2=x+w   y2=y+h
 end
 
 --pixels to tiles
 x1/=8 y1/=8
 x2/=8 y2/=8

 if fget(mget(x1,y1), flg)
 or fget(mget(x1,y2), flg)
 or fget(mget(x2,y1), flg)
 or fget(mget(x2,y2), flg)
 then return true
 else return false
 end
end


function gravity()
 --learn what's beneath player
 floor=collision(player,"down",1)
 --learn what's above player
 ciel=collision(player,"up",1)
 
 if (ciel==true)
 then
    player.grav=2
 end  
 if (player.grav!=2)
 then 
    player.grav+=2
 end  
 if ((floor==false) or (player.grav<0))
 then 
   player.y+=player.grav
   player.ground=false
 else
   player.ground=true
 end
end

function h_move()
  --if we press left
  if (btn(0) 
  --and there's nothing left
  and (not collision(player,"left",2)))
	 then 
	   player.x-=player.mp
	 --if we press right
	 elseif (btn(1)
	 --and there's nothing right
	 and (not collision(player,"right",2)))
	 then
				player.x+=player.mp
	 end
end

function v_move()
  --we only jump if on ground
  if ((player.ground==true) 
  --and if we're pressing jump
  and btn(5))
	 then 
    player.grav=player.jump
  end
end

function attack()
  --we will need to create a lingering attack and hitbox
  if btn(4)
  then 
    --we prioritize vertical attacks
    --attack up
    if btn(2)
    then
      spr(004,player.x,player.y-7,1,1,false,true)
    --attack down
    elseif (btn(3) and not player.ground)
    then
      spr(004,player.x,player.y+7,1,1,false,true)
    --attack right
    elseif btn(1)
    then
      spr(004,player.x+7,player.y+1)
    --attack left
    elseif btn(0)
    then
      spr(004,player.x-7,player.y+1,1,1,true,false)
    end
  end
end
-->8
--enemy ai

function addcrit(typ,mx,my)
  local m={
    id=typ,
    x=mx,
    y=my,
    w=8,
    h=7,
    mp=0.5,
    dir="left",
    ani={64,65},
    flp=false
    }
  
  add (critter,m)
end

function critter_move(obj)
  --need to identify how it moves
		if (obj.dir=="left") then
			 if ((obj.id==0) 
			 and (not collision(obj,"left",3)))
				then 
				  obj.x-=obj.mp	
				else
				  obj.dir="right"
				  obj.flp=true
			 end
		end
	  
	 if (obj.dir=="right") then
			 if ((obj.id==0) 
			 and (not collision(obj,"right",3)))
				then 
				  obj.x+=obj.mp	
				else
				  obj.dir="left"
				  obj.flp=false
			 end
		end
end
-->8
--environment

function adddoor(mx,my)
  local m={
    id=typ,
    x=mx,
    y=my,
    hp=1,
    flg=2,
    flp=false
    }
  
  add (door,m)
end

function addwall(mx,my,mw,mh)
  local w={
    x=mx,
    y=my,
    w=mw,
    h=mh,
    pass=false,
    }
  
  add (wall,w)
end 

function placewall(w)  
  --if the player isn't in the wall 
  if ((player.x-w.x-(w.w*8)>4)and w.pass==false)
  then
    for i=0,w.w do
      for j=0,w.h do  
        spr(058,w.x+(i*8),w.y+(j*8))
      end  
    end
  else
   w.pass=true
  end
end
-->8
--camera

function cameraman()

 --set x coord for camera. there are a few situations worth noting.
 --first is "have they entered secret areas" or "are they near map border

 --situation 1: nothing unusual
 --the camera normally should follow them 
 if player.x>64
 then
   --default left border: if they're in the starting area, the left side will not scroll to the secret
   if player.x<116 and w1==false
   then
     camx=50  
   else
     camx=player.x-64
   end
 --situation 2: they went left of starting area 
 --we have a check for w1, which represents the x that "starts" the secret area.
 --we assume they haven't entered it.
 else
   if player.x<64 and camx>0
   then
     camx-=2
   end 
   w1=true
 end
  
 
 --lock camera y coord
 if player.y<454
 then
  camy=player.y-64
 else
  camy=388
 end
 
 camera(camx,camy) 

end
__gfx__
00000000000000000000000000555500000000000000000000000000000000005111151551515115511511151151151551115151150000510000005115000000
00000000006000600000000005666650000000000000000000000000000000005111151551515115511511151151151551115151500000050000000550000000
00700700006666600000000056666665005500000000000000000000000000000511151551515115511511151151151505150505000000000000000000000000
00077000006060600000000056566565006650000000000000000000000000000051505051515115511511151151151500500000000000000000000000000000
00077000006666600000000056666665556665500000000000000000000000000005000051550515051511151151505000000000000000000000000000000000
00700700001101100000000005666650005550000000000000000000000000000000000005000515051511151505000000000000000000000000000000000000
00000000001000100000000000566500000000000000000000000000000000000000000000000515005051505000000000000000000000000000000000000000
0000000001d101d00000000000055000000000000000000000000000000000000000000000000050000005000000000000000000000000000000000000000000
11111111888888880000000000000000000000000000000000000000000000000055555000000000115000000000000000000005d55dd555d55dd55550000000
111111118888888800000000000000000000000000000000000000000000000005ddddd50000000015000000000000000000005d5dd55ddd5dd55dddd5000000
11111111888888880000000000000000000000000000000000000000000000005d66666d5000000015000000000000000000005d5dd5ddd5d5d5d5d5d5000000
1111111188888888000000000000000000000000000000000000000000000000561611165000000015000000000000000000005dd55d555ddd5ddd5dd5000000
1111111188888888000000000000000000000000000000000000000000000000511161115000000050000000000000000000005d5115ddd55515d5ddd5000000
11111111888888880000000000000000000000000000000000000000000000005116111150000000500000000000000000000005551155511111155550000000
1111111188888888000000000000000000000000000000000000000000000000516dddd150000000150000000000000000000005555111555551511115000000
11111111888888880000000000000000000000000000000000000000000000005d66666d50000000115500000000000000000051111511151115111515000000
22220222202222220000000000000000000000000000000000000000000000005611611650000000111155000000000000000051111551151115111515000000
22207022070222220000000000000000000000000000000000000000000000005111611150000000115115500000000000000051155155515551555115000000
22070222207022220000000000000000000000000000000000000000000000005111161150000000151111550000000000000051111511151111111550000000
220760000070222200000000000000000000000000000000000000000000000051dddd6150000000515111150000000000000051111111151111111550000000
22077777777022220000000000000000000000000000000000000000000000005d66666d50000000115111555000000000000051511551155115511515000000
22077007707022220000000000000000000000000000000000000000000000005661111650000000111111511500000000000051111555511111555115000000
22077007707022220000000000000000000000000000000000000000000000005116611150000000111551111500000000000005555111115551111115000000
22077777777022220000000000000000000000000000000000000000000000005111161150000000111511111155000000000005111111151111115515500000
22007777770022220000000000000000000000000000000000000005555555555000000005550055111111111111500000005551115555551155511115555555
22020000000222220000000000000000000000000000000000000000000000000000000000000000115111151111500055551115551111551500055551115511
20600110110222220000000000000000000000000000000000000000000000000000000005550055115115555551500011115551115555115000500055551155
22060100010222220000000000000000000000000000000000000000000000000000000050000000151115511151150055550005550000550005500051115500
22200100010222220000000000000000000000000000000000000000000000000000000000005500151111111111150000000000000000505555000005550055
22201110110222220000000000000000000000000000000000000000000000000000000000050000151111551551150000550005550005000000550000000000
2220dd101d0222220000000000000000000000000000000000000000000000000000000000500005555515115111115055005550005550000000005505550055
2220ddd0dd0222220000000000000000000000000000000000000000000000000000000050000550111111551115511500000000000000000000000050000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00555500000555500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
55dd5155555d51550000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
ddd51115ddd511150000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
d0d51151d0d511510000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
dddd5115dddd51150000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
55555555555555550000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
50505050050505050000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01000000000000000000000000000001110000000000000000000000000000110100000000000000000000000000000111000000000000000000000000000011
01000000000000000000000000000001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000c1e1d1e1f10000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000e0737373f000c1d1d1f1000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000e07373f0000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000c1d1f10000c1e1f100000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000e073f00000c2d2f200000000000000000000000000000000c2e2d2e2d2e2d2e2d2e2d2e2d2e2d2
e2d2e2d2e2d2e2d2e2d2000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000073f000000000000000000000000000000000c2d2e2d2e2d2e2d2e2d2e2d2e2d2e2
d2e2d2e2d2e2d2e2d2e2000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000c1d1f1000000000000000000000000000000000000c2e2d2e2d2e2d2e2d2e2d2e2d2e2d2
e2d2e2d2e2d2e2d2e2d2000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000e073f0000000000000000000000000000000000000c2d2e2d2e2d2e2d2e2d2e2d2e2d2e2
d2e2d2e2d2e2d2e2d2e2000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000c1d1f10000000000000000c1d1d1d1d1d1d1d1d1e1e1f100008090a0b08090a0b08090a0b08090
a0d2e2d2e2d2e2d2e2d2000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01000000000000000000000000000001110000c2e200000000e073f00000000000000000c2d2d2d2d2d2d2d2d2d2d2f200000000000000000000000000000000
0090d2e2d2e2d2e2d2e2000000000001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
11000000000000000000000000000011010000c2d2000000d1d1d1d1d1d1d1d1d1d1d1d1d1d2e2d2e2d2e2e2e2e2d2e1e1f10000000000000000000000000000
000090d2e2d2e2e2e2d2000000000011000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000c2e2d2e2d2e2d2d2e2d2e2d2e2d2e2d2e2d2e2d2e2d2e2d2d2d2d2e2d2d2f20000000000000000000000000000
00000090d2e2d2d2d2e2000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000c2d2e2d2e2d2e2e2d2e2d2e2d2e2d2e2d2e2d2e2d2e2d2e2e2e2d2e2d2e2e1e1e1f10000000000000000000000
000000c2e2d2d2d2e2d2000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000c2e2d2e2d2e2d2d2e2d2e2d2e2d2e2d2e2d2e2d2e2d2e2d2e2d2e2d2e2e2e2e2e2f200000000c1d1e1f1000000
000000c2d2e2e2e2d2e2000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000c2d2e2d2e2d2e2e2d2e2d2e2d2e2d2e2d2e2d2e2d2e2d2e2d2e2d2e2e2e2e2e2e2f2c1e1f100e0c0c0f0000000
000000c2e2d2e2d2e2d2000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
e2f2000000c2e2d2f200000000000000000000c2d2d2e2e2d2d2e2d2d2e2d2e2d2e2d2e2d2e2d2e2d2e2e2d2d2e2d2e2d2e2d2e2f2c2d2f20000000000000000
000000c2d2e2d2e2d2e2000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
e2f2000000c2d2a3f200000000000000000000c2d2e2d2d2e2d2e2d2e2d2e2d2e2d2e2d2e2d2e2d2e2d2e2d2e2d2e2d2e2d2d2e2f2008000000000000000c1d1
d1f100c2e2d2e2d2e2d2000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
e2f2000000c2e2d2f200000000000000000000c2d2e2d2e2d2d2e2e2d2e2d2e2b0c0d0809011a0b0c0d0c0d080d0c090a0b0d01100000000000000000000e0c0
c0f000c2d2e2d2e2d2e2000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
e2a090c2b0a0e2e2f200000000000000000000008090a0a0b01180c090a090110000000000110000000000000000000000000011000000000000000000000000
000000c2e2d2e2d2e2d2000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
e2f2000000c2e2e2a100000000000000000000000000000000110000000000110000000000110000000000000000000000000011000000000000c1d1e1f10000
000000c2d2e2d2e2d2e2000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
e2f2000000c2a3a3a2b2000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000c2d2e2f20000
000000c2d2d2d2d2d2d2e20000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
e2a1000000c2a3a3a3b300000000000000000000000000000000000000000020000000000020000000000000200000000000002000c1e1d1e1f1e0c0c0f00000
000000c2d2d2b0c0c090e20000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
e2e1d1e1d1e1d1e1d1e1d1e1d1e1d1e1d1e1d1e1d1e1d1e1d1e1d1e1d1e1d1e1d1e1d1e1d1e1d1e1d1e1f100c1d1d1e1d1e1d1e1f1e0737373f00000000000c1
d1e1f100a0b0000000c2d20000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
d2e2d2e2d2e2d2e2d2e2d2e2d2e2d2e2d2e2d2e2d2e2d2e2d2e2d2e2d2e2d2e2d2e2d2e2d2e2d2e2d2e2f200c2d2d2e2d2e2d2e2f200000000000000000000c2
d2e2f2000000000000c2e20000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
d3e3d3e3d3e3d3e3d3e3d3e3d3e3d3e3d3e3d3e3d3e3d3e3d3e3d3e3d3e3d3e3d3e3d3e3d3e3d3e3d3e3f3f3c3d3d3e3d3e3d3e3d1d1e1f100000000000000e0
7373f0c1d1e1e1d1e1e1d20000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000939393e3e2e2d1e1d1e1e1e1e1d1e1
e1d1e1d1d2d2e2d2d2e2e20000000011000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__gff__
00000808000000000000000000000000070700000000000007070000000f0f00000000000000000007070000000f0f000000000000000000000000000700000700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
1010100000000000000000101010101010101010101000000000000101010011100000000000000101003f3f000000101100000000000000000000000000001e10000000000000000000000000000010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000101000000000000000000000101000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000100000000000000000000000000000000000000101000000000000000000000100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000001000000000000000000000100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1000000000000000000000000000001011000000000000000000000000000011100000000000000000000000000000101100000000000000000000000000001110000000000000000000000000000010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1100000000000000000000000000001110000000000000000000000000000010110000000000000000000000000000111000000000000000000000000000001011000000000000000000000000000011000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1100000000000000000000000000001110000000000000000000000000000010110000000000000000000000000000111000000000000000000000000000001011000000000000000000000000000011000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
