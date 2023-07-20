function type=getBlockOrderCheckType(checkID)

    if(contains(checkID,'datastorecheck'))
        type='FEATUREONOFF';
    elseif(contains(checkID,'datastoresimrtwcmp'))
        type='SIMRTW';
    else
        assert(false,'Unknown execution order comparison type')
    end

end