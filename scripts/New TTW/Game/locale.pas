procedure LoadTranslations();
var
	i: byte;
	j: word;
begin
	if FileExists('/scripts/'+ScriptName+'/translations/DEF.loc') then
		translation[0] := Explode(ReadFile('/scripts/'+ScriptName+'/translations/DEF.loc'), #13#10);
	for i := 1 to COUNTRY_COUNT do
		if FileExists('/scripts/'+ScriptName+'/translations/'+CountryCodes[i]+'.loc') then begin
			Debug(11, 'Loaded '+CountryCodes[i]+' translation ('+IntToStr(i)+')');
			translation[i] := Explode(ReadFile('/scripts/'+ScriptName+'/translations/'+CountryCodes[i]+'.loc'), #13#10);
			for j := GetArrayLength(translation[i])-1 downto 0 do begin
				if translation[i][j] = '' then
					SetArrayLength(translation[i], j)
				else
					break;
			end;
		end;
end;

function t(ID: integer; Lang: byte; Text: string): string;
var
	i: word;
begin
	Result := Text;
	if (ID > 0) and (GetArrayLength(translation[Lang]) > 0) then begin
		try
			Result := translation[Lang][ID-1];
			if Result = '' then Result := translation[0][ID-1];
		except
		end;
	end	else if GetArrayLength(translation[0]) > 0 then begin
			for i := 0 to GetArrayLength(translation[0])-1 do
				if translation[0][i] = Text then
					Result := translation[Lang][i]
	end;
end;

procedure CreateDefaultTranslation();
var
	includes, translation: array of string;
	tempfile, output, funcstr, temptrans: string;
	i: byte;
	j, k, l: word;
	changed: boolean;
begin
	includes := Explode(ReadFile('/scripts/'+ScriptName+'/Includes.txt'), #13#10);
	k := 1;
	for i := 0 to GetArrayLength(includes)-1 do begin
		if (Copy(includes[i], 1, 2) = '//') or (includes[i] = '') or (Pos('locale.pas', includes[i]) > 0) then
			continue;
		tempfile := ReadFile('/scripts/'+ScriptName+'/'+includes[i]);
		j := Pos(' t(', tempfile);
		l := Pos(#9+'t(', tempfile);
		if ((l < j) and (l > 0)) or ((l > j) and (j = 0)) then
			j := Pos(#9+'t(', tempfile);
		changed := false;
		output := '';
		while j <> 0 do begin
			changed := true;
			SetArrayLength(translation, k);
			output := output + Copy(tempfile, 1, j+2);
			delete(tempfile, 1, j+2);
			j := Pos(''')', tempfile);
			funcstr := Copy(tempfile, 1, j-1);
			Delete(funcstr, 1, Pos(',', funcstr));
			temptrans := Copy(funcstr, Pos('''', funcstr)+1, Length(funcstr));
			l := Pos('''', temptrans);
			while l > 0 do begin
				delete(temptrans, l, 1);
				l := Pos('''''', temptrans);
			end;
			l := Pos(#9, temptrans);
			while l > 0 do begin
				insert('    ', temptrans, l+1);
				delete(temptrans, l, 1);
				l := Pos(#9, temptrans);
			end;
			for l := 0 to k-1 do
				if translation[l] = temptrans then begin
					//WriteLn('Found: '+IntToStr(l)+', '+temptrans+', '+translation[l]);
					break;
				end;
			if l = k then begin
				translation[k-1] := temptrans;
				k := k + 1;
			end else
				l := l + 1;
			//translation[k-1] := Copy(funcstr, Pos('''', funcstr)+1, Length(funcstr));
			funcstr := IntToStr(l)+','+funcstr;
			Delete(tempfile, 1, j-1);
			Insert(funcstr, tempfile, 1);
			j := Pos(' t(', tempfile);
			l := Pos(#9+'t(', tempfile);
			if ((l < j) and (l > 0)) or ((l > j) and (j = 0)) then
				j := Pos(#9+'t(', tempfile);
		end;
		if changed then begin
			output := output + tempfile;
			WriteFile('/scripts/'+ScriptName+'/'+includes[i], output);
		end;
	end;
	WriteFile('/scripts/'+ScriptName+'/translations/DEF.loc', '');
	tempfile := '';
	for j := 0 to k-2 do
		tempfile := tempfile + translation[j] + #13#10;
	WriteFile('/scripts/'+ScriptName+'/translations/DEF.loc', tempfile);
end;
