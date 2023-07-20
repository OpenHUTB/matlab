function state=alg_v5_initialize(seed)


%#codegen




    coder.allowpcode('plain');

    eml_prefer_const(seed);

    state=[uint32(362436069);cast(seed,'uint32')];
    if state(2)==0
        state(2)=uint32(521288629);
    end

end
