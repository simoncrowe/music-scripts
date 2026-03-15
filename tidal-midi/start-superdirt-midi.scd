(
var pieceDir;
var midiSetupPath;

pieceDir = PathName(thisProcess.nowExecutingPath).pathOnly;
midiSetupPath = pieceDir +/+ "midi-devices.scd";

SuperDirt.start;
MIDIClient.init;

"Available MIDI destinations:".postln;
MIDIClient.destinations.do { |endpoint, index|
    [index, endpoint.device, endpoint.name].postln;
};

s.waitForBoot({
    ("Loading MIDI bindings from " ++ midiSetupPath).postln;
    midiSetupPath.load;
});
)

