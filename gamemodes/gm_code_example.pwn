// control vars so player cant use two voips at the same time
new bool:isUsingRadioVoip[MAX_PLAYERS];
new bool:isUsingPhoneVoip[MAX_PLAYERS];
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
    // block radio + cellphone
    if(isUsingRadioVoip[playerid] == true) {
        SendClientMessage(playerid, -1, "player is already in radio voip");
        return true;
    }
    if(isUsingRadioVoip[targetid] == true) {
        SendClientMessage(playerid, -1, "target is already in radio voip");
        SendClientMessage(targetid, -1, "target is already in radio voip");
        return true;
    }
    // call remote function IF have plugin installed
    new callerHasVoiceOnClient = GetPVarInt(playerid,"hasVoiceOnClient");
    if(callerHasVoiceOnClient == 1) {
        isUsingPhoneVoip[playerid] = true;
        CallRemoteFunction("JoinPrivateVoiceChannel", "ii", playerid, targetid);
    }
    else {
        SendClientMessage(playerid, -1, "NO VOIP PLUGIN");
    }
    new calledHasVoiceOnClient = GetPVarInt(targetid,"hasVoiceOnClient");
    if(calledHasVoiceOnClient == 1) {
        isUsingPhoneVoip[targetid] = true;
        CallRemoteFunction("JoinPrivateVoiceChannel", "ii", targetid, playerid);
    }
    else {
        SendClientMessage(targetid, -1, "NO VOIP PLUGIN");
    }
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
    isUsingRadioVoip[playerid] = false;
  }
  else {
    if(isUsingRadioVoip[playerid] == true) {
        SendClientMessage(playerid, -1, "player is already in phone voip");
        return true;
    }
    CallRemoteFunction("JoinGroupVoiceChannel", "ii", playerid, frequency_id);
    isUsingRadioVoip[playerid] = true;
  }
}
// check player voip stats
CMD:voipstats(playerid) {
  new hasVoiceOnClient = GetPVarInt(playerid,"hasVoiceOnClient");
  if(hasVoiceOnClient == 0) {
      SendClientMessage(playerid, -1, "No plugin VOIP installed");
  }
  else if(hasVoiceOnClient == 2) {
      SendClientMessage(playerid, -1, "With plugin VOIP and NO MICRO");
  }
  else if(hasVoiceOnClient == 1) {
      SendClientMessage(playerid, -1, "With plugin VOIP and MICRO");
  }
  return true;
}