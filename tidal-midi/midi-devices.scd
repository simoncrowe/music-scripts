(
var mappings;

mappings = [
     [\midi, "SuperCollider", 0, 0.0]
];

mappings.do { |mapping|
    var synthName, deviceName, portName, latency, midiOut;

    #synthName, deviceName, portName, latency = mapping;
    midiOut = if (deviceName == "SuperCollider") {
        MIDIOut(portName.asInteger);
    } {
        MIDIOut.newByName(deviceName, portName);
    };

    midiOut.latency = latency;
    ~dirt.soundLibrary.addMIDI(synthName, midiOut);
    ("Registered MIDI target " ++ synthName.asString ++ " -> " ++ deviceName ++ " / " ++ portName).postln;
};

if (mappings.isEmpty) {
    "No MIDI targets configured in midi-devices.scd yet.".warn;
};
)
