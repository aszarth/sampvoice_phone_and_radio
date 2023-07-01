// change talk voice stats to radio
CMD:radio(playerid) {
  SetPVarInt(playerid,"talkstats",3);
  return true;
}
// change talk voice stats to local
CMD:local(playerid) {
  SetPVarInt(playerid,"talkstats",0);
  return true;
}
// connect to call global on private with other player
CMD:call(playerid, params[]) {
  new targetid;
  if(sscanf(params,"u", targetid)) {
    SendClientMessage(playerid, -1, "Use: /call [player-id]");
    SendClientMessage(playerid, -1, "65535 to turn off");
  }
  if(targetid == 0) {
    CallRemoteFunction("LeavePrivateVoiceChannel", "i", playerid);
  }
  else {
    CallRemoteFunction("JoinPrivateVoiceChannel", "ii", playerid, targetid);
    CallRemoteFunction("JoinPrivateVoiceChannel", "ii", targetid, playerid);
  }
}
// connect to call global on radio frequency
CMD:frequency(playerid, params[]) {
  new frequency_id;
  if(sscanf(params,"i", frequency_id)) {
    SendClientMessage(playerid, -1, "Use: /frequency [frequency-id]");
    SendClientMessage(playerid, -1, "0 to turn off");
  }
  if(frequency_id == 0) {
    CallRemoteFunction("LeaveGroupVoiceChannel", "i", playerid);
  }
  else {
    CallRemoteFunction("JoinGroupVoiceChannel", "ii", playerid, frequency_id);
  }
}