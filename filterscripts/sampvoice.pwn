// =====================================================================================
// libs
// =====================================================================================
#include <a_samp>
#include <sampvoice>

// =====================================================================================
// PVarInts (to use on GM and Filterscript)
// =====================================================================================
// `hasVoiceOnClient`:
// to checks player voice status
// new hasVoiceOnClient = GetPVarInt(playerid,"hasVoiceOnClient");
// 0- no samp voice plugin
// 2- with plugin, but no microphone
// 1- with plugin and with microphone

// `talkStats`:
// so player can switch speak mode to radio/local
// if(GetPVarInt(playerid,"talkStats") == 3)
// SetPVarInt(playerid,"talkstats",3);
// SetPVarInt(playerid,"talkstats",0);
// 3- radio mode


// =====================================================================================
// global variables
// =====================================================================================
// local
new SV_LSTREAM:local_stream[MAX_PLAYERS] = { SV_NULL, ... };
// phone
new voice_phonecall_targetid[MAX_PLAYERS];
new SV_GSTREAM:phone_stream[MAX_PLAYERS] = { SV_NULL, ... };
// radio
#define MAX_VOICE_RADIO 9999 // same then GM (#define MAX_RADIOS)
new voice_radiocall_radioid[MAX_PLAYERS];
new SV_GSTREAM:radio_stream[MAX_VOICE_RADIO] = { SV_NULL, ... };

// =====================================================================================
// key press
// =====================================================================================
public SV_VOID:OnPlayerActivationKeyPress(SV_UINT:playerid, SV_UINT:keyid) 
{
    if (keyid == 0x42) {
        if(GetPVarInt(playerid,"talkStats") != 3) {
            // phone
            new callid = voice_phonecall_targetid[playerid];
            if(callid != 65535) {
                if(phone_stream[playerid]) {
                    if(!SvHasSpeakerInStream(phone_stream[playerid], playerid))
                    {
                        SvAttachSpeakerToStream(phone_stream[playerid], playerid);
                    }
                }
            }
            // local
            else if(local_stream[playerid]) {
                if(!SvHasSpeakerInStream(local_stream[playerid], playerid))
                {
                    SvAttachSpeakerToStream(local_stream[playerid], playerid);
                }
            }
        }
        // radio
        else if(GetPVarInt(playerid,"talkStats") == 3) {
            new radioid = voice_radiocall_radioid[playerid];
            if(radioid != 0) {
                if(radio_stream[radioid]) {
                    if(!SvHasSpeakerInStream(radio_stream[radioid], playerid))
                    {
                        SvAttachSpeakerToStream(radio_stream[radioid], playerid);
                    }
                }
            }
        }
    }
}
public SV_VOID:OnPlayerActivationKeyRelease(SV_UINT:playerid, SV_UINT:keyid)
{
    if (keyid == 0x42) {
        // phone
        new callid = voice_phonecall_targetid[playerid];
        if(callid != 65535) {
            if(phone_stream[playerid]) {
                if(SvHasSpeakerInStream(phone_stream[playerid], playerid))
                {
                    SvDetachSpeakerFromStream(phone_stream[playerid], playerid);
                }
            }
        }
        // local
        if(local_stream[playerid]) {
            if(SvHasSpeakerInStream(local_stream[playerid], playerid))
            {
                SvDetachSpeakerFromStream(local_stream[playerid], playerid);
            }
        }
        // radio
        new radioid = voice_radiocall_radioid[playerid];
        if(radioid != 0) {
            if(radio_stream[radioid]) {
                if(SvHasSpeakerInStream(radio_stream[radioid], playerid))
                {
                    SvDetachSpeakerFromStream(radio_stream[radioid], playerid);
                }
            }
        }
    }
}
// =====================================================================================
// player connect and disconnect
// =====================================================================================
public OnPlayerConnect(playerid) {
    // -----------------------------------
    // Checking for plugin availability
    // -----------------------------------
    // Could not find plugin sampvoice.
    if (SvGetVersion(playerid) == SV_NULL)
    {
        SetPVarInt(playerid, "hasVoiceOnClient", 0);
    }
    // Checking for a microphone
    else if (SvHasMicro(playerid) == SV_FALSE)
    {
        // The microphone could not be found.
        SetPVarInt(playerid, "hasVoiceOnClient", 2);
    }
    // Create a local stream with an audibility distance of 40.0, an unlimited number of listeners
    // and the name 'Local' (the name 'Local' will be displayed in red in the players' speakerlist)
    else if ((local_stream[playerid] = SvCreateDLStreamAtPlayer(40.0, SV_INFINITY, playerid, 0xff0000ff, "Local")))
    {
        // B (assign microphone activation keys to the player)
        SvAddKey(playerid, 0x42);
        // Find plugin sampvoice and microphone
        SetPVarInt(playerid, "hasVoiceOnClient", 1);
    }
    // reset phone call
    voice_phonecall_targetid[playerid] = 65535;
    // reset radio call
    voice_radiocall_radioid[playerid] = 0;
}
public OnPlayerDisconnect(playerid, reason) {
    // Removing the player's local stream after disconnecting
    if (local_stream[playerid])
    {
        SvDeleteStream(local_stream[playerid]);
        local_stream[playerid] = SV_NULL;
    }
    // phone - remove listener if has call
    LeavePrivateVoiceChannel(playerid);
    // radio - remove listener if has call
    LeaveGroupVoiceChannel(playerid);
}
// =====================================================================================
// server open and close
// =====================================================================================
public OnFilterScriptInit() {
    new string[128];
    // phone calls
    for(new i = 0; i < MAX_PLAYERS; i++)
    {
        format(string, sizeof(string), "phone_call-%i", i);
        phone_stream[i] = SvCreateGStream(0xffff0000, string);
    }
    // radio calls
    for(new i = 0; i < MAX_VOICE_RADIO; i++)
    {
        format(string, sizeof(string), "radio_freq-%i", i);
        radio_stream[i] = SvCreateGStream(0xffff0000, string);
    }
}
public OnFilterScriptExit() {
    // phone calls
    for(new i = 0; i < MAX_PLAYERS; i++)
    {
        if (phone_stream[i]) SvDeleteStream(phone_stream[i]);
    }
    // radio calls
    for(new i = 0; i < MAX_VOICE_RADIO; i++)
    {
        if (radio_stream[i]) SvDeleteStream(radio_stream[i]);
    }
}

// =====================================================================================
// Remote Functions to be called on GameMode
// =====================================================================================
forward JoinPrivateVoiceChannel(playerid, targetid);
forward LeavePrivateVoiceChannel(playerid);
public JoinPrivateVoiceChannel(playerid, targetid)
{
    // remover listener do antigo
    LeavePrivateVoiceChannel(playerid);
    // adicionar listener pro novo
    if (phone_stream[targetid]) {
        if(!SvHasListenerInStream(phone_stream[targetid], playerid)) {
            SvAttachListenerToStream(phone_stream[targetid], playerid);
        }
    }
    // mudar valor da variavel de controle
    voice_phonecall_targetid[playerid] = targetid;
    return 1;
}
public LeavePrivateVoiceChannel(playerid)
{
    new oldchannelid = voice_phonecall_targetid[playerid];
    if (oldchannelid != 65535 && phone_stream[oldchannelid]) {
        // remove speaker
        if(SvHasSpeakerInStream(phone_stream[oldchannelid], playerid))
        {
            SvDetachSpeakerFromStream(phone_stream[oldchannelid], playerid);
        }
        // remove listener
        if(SvHasListenerInStream(phone_stream[oldchannelid], playerid))
        {
            SvDetachListenerFromStream(phone_stream[oldchannelid], playerid);
        }
    }
    return 1;
}



forward JoinGroupVoiceChannel(playerid, frequency_id);
forward LeaveGroupVoiceChannel(playerid);
public JoinGroupVoiceChannel(playerid, frequency_id)
{
    // remover listener do antigo
    LeaveGroupVoiceChannel(playerid);
    // adicionar listener pro novo
    if (radio_stream[frequency_id]) {
        if(!SvHasListenerInStream(radio_stream[frequency_id], playerid)) {
            SvAttachListenerToStream(radio_stream[frequency_id], playerid);
        }
    }
    // mudar valor da variavel de controle
    voice_radiocall_radioid[playerid] = frequency_id;
    return 1;
}
public LeaveGroupVoiceChannel(playerid)
{
    new oldchannelid = voice_radiocall_radioid[playerid];
    if (oldchannelid != 0 && radio_stream[oldchannelid]) {
        // remove speaker
        if(SvHasSpeakerInStream(radio_stream[oldchannelid], playerid))
        {
            SvDetachSpeakerFromStream(radio_stream[oldchannelid], playerid);
        }
        // remove listener
        if(SvHasListenerInStream(radio_stream[oldchannelid], playerid))
        {
            SvDetachListenerFromStream(radio_stream[oldchannelid], playerid);
        }
    }
}