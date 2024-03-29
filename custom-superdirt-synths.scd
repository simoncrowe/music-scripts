SynthDef(\sins, {
    | out, sustain=1, decay=0, freq=440, speed=1, begin=0, end=1, pan, accelerate, offset|
var env = EnvGen.ar(Env.adsr, timeScale:sustain, doneAction:2);
  var osc = DynKlang.ar(`[
    [freq-2, freq-1, freq, freq+1, freq+2],
    [0.1, 0.2, 0.2, 0.2, 0.1],
    [0, 1.5, 0, 1.5, 0]
  ]);
  OffsetOut.ar(out, DirtPan.ar(osc, ~dirt.numChannels, pan, env));
}).add;


SynthDef(\sinswarm, {
    | out, sustain=1, decay=0, freq=440, speed=1, begin=0, end=1, pan, accelerate, offset|
  var env = EnvGen.ar(Env.adsr, timeScale:sustain, doneAction:2);
  var count = 48;
  var osc = DynKlang.ar(`[
    Array.interpolation(count, freq, freq*9/8),
    Array.rand(count, 0.25, 0.5),
    Array.fill(count, pi),
  ]);
  OffsetOut.ar(out, DirtPan.ar(osc, ~dirt.numChannels, pan, env));
}).add;



SynthDef(\acid309, {|out, sustain=1, pan, accelerate, freq |
	var env1, env2, son, midiNote, pitch, amp, gate;
	gate=1;
	amp = 0.5;
	midiNote = freq.cpsmidi;
	pitch = Lag.kr(midiNote, 0.12 * (1 - Trig.kr(gate, 0.001)) * gate);
	env1 = EnvGen.ar(Env.new([0, 1.0, 0, 0],
							 [0.001, 2.0, 0.04],
							 [0, -4, -4], 2), 
							 gate, amp, doneAction:2);
	env2 = EnvGen.ar(Env.adsr(0.001, 0.8, 0, 0.8, 70, -4), gate);
	son = LFPulse.ar(pitch.midicps, 0.0, 0.51, 2, -1);

	son = RLPF.ar(son, (pitch + env2).midicps, 0.3);

	OffsetOut.ar(out, DirtPan.ar(son, ~dirt.numChannels, pan, env1));
}).add;

