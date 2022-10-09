SynthDef(\sinswarm, {
    | out, sustain=1, decay=0, freq=440, speed=1, begin=0, end=1, pan, accelerate, offset|
var env = EnvGen.ar(Env.pairs([[0,0],[0.05,1],[0.2,1-decay],[0.95,1-decay],[1,0]], -3), timeScale:sustain, doneAction:2);
  var osc = DynKlang.ar(`[
    Array.rand(3, freq - 10, freq + 10),
    Array.with(3, 1),
    Array.rand(3, 0, pi)
  ]);
  OffsetOut.ar(out, DirtPan.ar(osc, ~dirt.numChannels, pan, env));
}).add;


SynthDef(\sin, {
    | out, sustain=1, decay=0, freq=440, speed=1, begin=0, end=1, pan, accelerate, offset|
  var env = EnvGen.ar(Env.pairs([[0,0],[0.05,1],[0.2,1-decay],[0.95,1-decay],[1,0]], -3), timeScale:sustain, doneAction:2);
  var osc = SinOsc.ar(freq);
  OffsetOut.ar(out, DirtPan.ar(osc, ~dirt.numChannels, pan, env));
}).add;
