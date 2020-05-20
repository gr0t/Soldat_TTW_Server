procedure PushByteArray(var arr: array of byte; b: byte);
begin
	SetArrayLength(arr, GetArrayLength(arr)+1);
	arr[GetArrayLength(arr)-1] := b;
end;

procedure TakeByteArray(var arr: array of byte; b: byte);
var
	i: integer;
begin
	if GetArrayLength(arr) > 0 then
		for i := 0 to GetArrayLength(arr)-1 do
			if arr[i] = b then begin
				if i = GetArrayLength(arr)-1 then
					SetArrayLength(arr, GetArrayLength(arr)-1)
				else begin
					for i := i to GetArrayLength(arr)-2 do begin
						arr[i] := arr[i+1];
					end;
					SetArrayLength(arr, GetArrayLength(arr)-1);
				end;
				break;
			end;
end;

{
procedure PushIntArray(var arr: array of integer; int: integer);
begin
	SetArrayLength(arr, GetArrayLength(arr)+1);
	arr[GetArrayLength(arr)-1] := int;
end;
}