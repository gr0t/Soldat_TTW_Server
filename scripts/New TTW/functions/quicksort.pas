procedure quicksort(var t: array of integer; l,r:integer; asc: boolean);
var 
   pivot,b,i,j:integer;
begin 
	if l < r then
	begin
		pivot := t[random(l+1, r+1)];
		//pivot:=t[(l+r) div 2 + 1];
		i := l-1;
		j := r+1;
		repeat
			if asc then begin
				repeat i := i+1 until pivot <= t[i];
				repeat j := j-1 until pivot >= t[j];
			end else begin
				repeat i := i+1 until pivot >= t[i];
				repeat j := j-1 until pivot <= t[j];
			end;
			b:=t[i]; t[i]:=t[j]; t[j]:=b
		until i >= j;
		t[j]:=t[i]; t[i]:=b;
		quicksort(t,l,i-1, asc);
		quicksort(t,i,r, asc);
	end;
end;
