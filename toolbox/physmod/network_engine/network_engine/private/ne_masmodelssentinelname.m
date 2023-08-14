function sentinel=ne_masmodelssentinelname()




    persistent pSentinel;

    if isempty(pSentinel)
        pSentinel='TREAT_M_AS_MODELS';
    end

    sentinel=pSentinel;

end
