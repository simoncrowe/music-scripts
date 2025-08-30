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


SynthDef(\chainsaw, {
    | out=0, sustain=1, freq=55, pan=0 |

    var line = Line.ar(0, 1, sustain, doneAction: 2);
    var env = IEnvGen.ar(Env.adsr(0.005, 0.15, 0.4, 0.2, 1, -4), line);

    var detune = [0.99, 1.0, 1.01];
    var saws = Mix(detune.collect { |d| Saw.ar(freq * d) }) * 0.3;
    var sub  = LFTri.ar(freq/2, 0, 0.5);
    var voice = saws + sub;

    var cutoffBase = 200;
    var cutoffEnvAmt = 1000;
    var lfo = SinOsc.kr(0.2).range(-200, 200);
    var cutoff = (cutoffBase + (env * cutoffEnvAmt) + lfo).clip(40, 12000);
    voice = RLPF.ar(voice, cutoff, 0.3);

    voice = distort(voice * 3); // warm drive

    voice = voice * env * 0.8;

    OffsetOut.ar(out, DirtPan.ar(voice, ~dirt.numChannels, pan));
}).add;


SynthDef(\grind, {
    | out=0, sustain=5, freq=55, pan=0 |

    var line = Line.ar(0, 1, sustain, doneAction: 2);
    var env = IEnvGen.ar(Env.adsr(0.5, 0.2, 0.4, 0.5, 1, -4), line);

    var detune = [0.98, 1.0, 1.02];
    var sub = Mix(detune.collect { |d| SinOsc.ar((freq) * d) }) * 0.3;
	
	var noise = GrayNoise.ar(0.02);

    var x = LFNoise1.kr(0.1).range(0, 5);
    var y = LFNoise1.kr(0.15).range(0, 5);
    var z = Line.kr(0, 10, 60); // slow drift
    var perlin = Perlin3.ar(x, y, z) * 0.3;

	var pulse = LFPulse.ar(freq, 0, perlin, 0.5);

	var voice = sub + noise + pulse;
	
    var cutoffBase = 200;
    var cutoffEnvAmt = 1000;
	var cutoffPerlinAmt = 500;
    var cutoff = (cutoffBase + (env * cutoffEnvAmt) - (perlin * cutoffPerlinAmt)).clip(40, 12000);
    voice = RLPF.ar(voice, cutoff, 0.3);

    voice = voice * env * 0.8;

    OffsetOut.ar(out, DirtPan.ar(voice, ~dirt.numChannels, pan));
}).add;


SynthDef(\cthulu, {
    | out=0, sustain=10, freq=45, pan=0 |

    var line, env, detune, sub, noise, dripTrig, drips, slime,
        x, y, z, perlin, cutoffBase, cutoffEnvAmt, cutoffPerlinAmt, cutoff,
        voice;

    line = Line.ar(0, 1, sustain, doneAction: 2);
    env  = IEnvGen.ar(Env.adsr(0.4, 0.3, 0.5, 1.5, 1, -4), line);

    // Cavern drift (Perlin)
    x = LFNoise1.kr(0.05).range(0, 4);
    y = LFNoise1.kr(0.08).range(0, 4);
    z = Line.kr(0, 20, sustain);
    perlin = Perlin3.ar(x, y, z);

    // Growly core
    detune = [0.75, 1.0, 1.25];
    sub = Mix(detune.collect { |d| Formant.ar(freq, 
	                                          XLine.kr((freq * d * perlin)/4, freq * d * perlin * 64, sustain),
											  freq * d * 4
											  , 0.125) } ) * 0.3;

    // Wind + drips 
    noise    = Crackle.ar(1.9) * 0.05 + PinkNoise.ar(0.03);
    dripTrig = Dust2.ar(0.25);
    drips    = Decay2.ar(dripTrig, 0.01, 0.2) * SinOsc.ar(freq * 4, 0, 0.4);
    slime    = BPF.ar(noise, LFNoise1.kr(0.3).range(300, 2000), 0.2) + drips;

    // Filter motion
    cutoffBase      = 150;
    cutoffEnvAmt    = 800;
    cutoffPerlinAmt = 600;
    cutoff = (cutoffBase + env * cutoffEnvAmt + perlin * cutoffPerlinAmt).clip(40, 8000);

    voice = sub + (slime * 0.2);
    voice = RLPF.ar(voice, cutoff, 0.25);

    // Cavern verb (tame levels a bit)
    voice = voice + (GVerb.ar(voice, 100, 6, 0.2, 0.5, 15, 0.6, 0.3, 0.2) * 0.25);

    // Final shaping
    voice = LeakDC.ar(voice * env * 0.9); 

    OffsetOut.ar(out, DirtPan.ar(voice, ~dirt.numChannels, pan));
}).add;
