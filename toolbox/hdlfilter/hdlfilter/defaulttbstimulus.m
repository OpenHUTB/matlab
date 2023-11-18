function stimcell=defaulttbstimulus(Hb)

    if isa(Hb,'dsp.BiquadFilter')
        stimcell={'step','ramp','chirp'};
    else
        stimcell={'impulse','step','ramp','chirp','noise'};
    end



