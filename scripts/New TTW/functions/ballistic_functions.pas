const
	//Ballistic functions
   g_ = 0.135; // soldat's default acceleration of gravity in pixels/tick^2
   k_ = 0.01; // air resistance factor
   e = 2.71828182846;

type
	tVector = record
		x, y, vx, vy: single;
		t: word;
	end;

function arctan2(X, Y: single): single;
begin
  if X < 0 then Result := arctan(Y/X) + Pi else
  if X > 0 then Result := arctan(Y/X) else
  if Y > 0 then Result := 2.3562 else
  Result := -0.7854;
end;

// returns time in ticks of bullet's flight
// sx - x component of distance beetween start position and destination
// vx - x component of velocity of a bullet
function ProjectileTime(sx, vx: single): single;
begin
   Result := -LogN(e, 1 - k_*sx/vx) / k_;
end;

// x1, y1: poistion of bullet's start
// x2, y2: position of bullet's destination
// v: velocity of a bullet
// gravity: current server's gravity (default is 0.06)
// target_in_range: boolean returned via reference, tells us if destination is in bullet's range
// returns angle which the bullet should be shot with
function BallisticAim(x1, y1, x2, y2, v, gravity: single; var target_in_range: boolean): single;
var x, y, sine, cosine, diff, last_diff, y3, g2, a, a2: single; dir, last_dir: boolean;
   kx_v, g_k_v, g_k2: single;
   i: byte;
begin
	x := x2 - x1;
	y := y1 - y2; // inverted y axis
	if x1 < x2 then begin // direction increasement angle
		a := ANGLE_45;
		a2 := -0.3;
	end else begin
		a := Pi-ANGLE_45;
		a2 := 0.3;
	end;
	diff := 10e6;
	kx_v := k_*x/v; // calculate constants
	g2 := g_ * gravity / 0.06;
	g_k_v := g2/k_/v;
	g_k2 := g2/k_/k_;
	repeat
		i := i + 1;
		sine := sin(a); cosine := cos(a);
		// y(x) = (tan(a) + g/k/v/cos(a))*x  + g/k^2*ln(1 - k*x/v/cos(a))
		y3 := (sine/cosine + g_k_v/cosine)*x + g_k2*LogN(e, 1 - kx_v/cosine);
		if ((y3 = 0) or (y3 < y)) and ((a = ANGLE_45) or (a = Pi-ANGLE_45))  then begin // if NAN is returned - target is out of range
			Result := -Result;
			exit;
		end;
		last_diff := diff;
		diff := abs(y3-y);
		if diff < last_diff then Result := a;
		WriteLn(floattostr(diff));
		if (diff < 5) and (diff <> 0) then break; // if found the angle
		last_dir := dir;
		dir := (y3 > y) and (y3 <> 0);
		if (dir) xor (last_dir) then begin // if passed the proper angle, change direction and increase accuracy
			a2 := a2/-2;
		end;
		a := a + a2;
		if (a < ANGLE_45) or (a > Pi-ANGLE_45) then begin
			Result := -Result;
			exit;
		end;
	until i = 20;
	Result := -Result; // invert angle due to inverted y axis
	target_in_range := true;
end;

function BallisticAim2(x1, y1, x2, y2, ang, gravity: single): single;
var x, y, tan, cosine, diff, last_diff, y3, g2, v, v2: single; dir, last_dir: boolean;
   kx_cos, g_k_cos, g_k2: single;
begin
	x := abs(x2 - x1);
	y := y1 - y2; // inverted y axis
	v2 := 50;
	diff := 10e6;
	g2 := g_ * gravity / 0.06;
	cosine := cos(ang);
	tan := sin(ang)/cosine
	g_k_cos := g2/k_/cosine;
	g_k2 := g2/k_/k_;
	kx_cos := k_*x/cosine;
	repeat
		// y(x) = (tan(a) + g/k/v/cos(a))*x  + g/k^2*ln(1 - k*x/v/cos(a))
		y3 := (tan + g_k_cos/v)*x + g_k2*LogN(e, 1 - kx_cos/v);
		last_diff := diff;
		diff := abs(y3-y);
		if diff < last_diff then Result := v;
 		if (diff < 5) and (diff <> 0) then break; // if found the angle and diff not NaN (NaN = 0)
		last_dir := dir;
		dir := (y3 > y) and (y3 <> 0);
		if dir <> last_dir then
			v2 := v2/2;
		if dir then
			v := v - v2
		else
			v := v + v2;
	until false;
end;
 
// returns coordinates, velocity and time to collision of a bullet
// returns true if bullet doesn't collide with a poligon on it's way
const ik_ = 1 - k_;
function BallisticCast(x, y, g: single; var vec: tVector): boolean;
var x2, y2, rd: single; dist: word;
begin
   if abs(vec.vy) < 13.5 then rd := 13.5 else rd := vec.vy;
   dist := Trunc(1 + Sqrt(vec.vx*vec.vx + rd*rd));
   g := g_ * g / 0.06;
   while vec.t > 0 do begin
      vec.t := vec.t - 1;
      x2 := x;
      x := x + vec.vx;
      vec.vx := vec.vx * ik_;
      vec.vy := vec.vy + g;
      y2 := y;
      y := y + vec.vy;
      vec.vy := vec.vy * ik_;
      if not RayCast(x, y, x2, y2, rd, dist) then begin
         vec.X := x2;
         vec.Y := y2;
         exit;
      end;
   end;
   vec.X := x2;
   vec.Y := y2;
   Result := true;
end;
