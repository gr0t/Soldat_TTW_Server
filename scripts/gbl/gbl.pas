const
  BAN_REASON = 'You have been banned for cheating, check bans.soldat.rocks'; // ban reason
  BAN_TIME = -9000; // ban time, needs to be negative and unique
  BANLIST_URL = 'http://bans.soldat.rocks/'; // url to banlist
  UPDATE_INTERVAL = 60; // update interval in minutes
var
  BanListHW: TStringList;
  BanListIP: TStringList;

procedure AddBans;
var
  i: Integer;
begin
  for i := 0 to BanListHW.Count - 1 do
    if Game.BanLists.GetHWBanId(BanListHW.Strings[i]) = -1 then
      Game.BanLists.AddHWBan(BanListHW.Strings[i], BAN_REASON, BAN_TIME);

  for i := 0 to BanListIP.Count - 1 do
    if Game.BanLists.GetIPBanId(BanListIP.Strings[i]) = -1 then
      Game.BanLists.AddIPBan(BanListIP.Strings[i], BAN_REASON, BAN_TIME);
end;

procedure CleanupBans;
var
  i: Integer;
  BanHW: TBannedHW;
  BanIP: TBannedIP;
begin
  for i := 1 to Game.BanLists.BannedHWCount do
  begin
    BanHW := Game.BanLists.HW[i]; // workaround for https://github.com/Soldat/soldat/issues/5
    if BanHW.Time = BAN_TIME then
      Game.BanLists.DelHWBan(BanHW.HW);
  end;

  for i := 1 to Game.BanLists.BannedIPCount do
  begin
    BanIP := Game.BanLists.IP[i];
    if BanIP.Time = BAN_TIME then
      Game.BanLists.DelIPBan(BanIP.IP);
  end;
end;

procedure UpdateBans(Ticks: Integer);
var
  BanList: String;
  Res: TStringList;
begin
  WriteLn('[GBL] Updating global banlist.');
  Res := File.CreateStringList;
  try
    BanList := GetURL(BANLIST_URL + '/banlist?server=' + HTTPEncode(Game.ServerName));
    if BanList <> '' then
    begin
      SplitRegExpr('\@@@',BanList,Res); // splitting banlist into hwids and ips
      if Res.Count = 2 then
      begin
        BanListHW.Clear;
        BanListHW.SetText(Res.Strings[0]);
        BanListIP.Clear;
        BanListIP.SetText(Res.Strings[1]);
        CleanupBans;
        AddBans;
      end else WriteLn('[GBL] Failed to parse banlist.');
    end;
  except
    begin
      WriteLn('[GBL] Failed to fetch banlist.');
    end;
  end;

  Res.Free;
end;

begin
  BanListHW := File.CreateStringList();
  BanListIP := File.CreateStringList();

  Game.OnClockTick := @UpdateBans;
  Game.TickThreshold := UPDATE_INTERVAL * 3600;

  UpdateBans(0);
end.
