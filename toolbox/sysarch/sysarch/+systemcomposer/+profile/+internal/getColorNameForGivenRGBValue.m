function name=getColorNameForGivenRGBValue(value)



    if isequal(value,uint32([172,221,242,255]))||isequal(value,uint32([206,232,246,255]))
        name='Blue';
    elseif isequal(value,uint32([180,215,144,255]))||isequal(value,uint32([210,228,184,255]))
        name='Green';
    elseif isequal(value,uint32([244,172,176,255]))||isequal(value,uint32([242,203,205,255]))
        name='Red';
    elseif isequal(value,uint32([248,165,133,255]))||isequal(value,uint32([244,198,177,255]))
        name='Orange';
    elseif isequal(value,uint32([131,164,253,255]))||isequal(value,uint32([177,196,252,255]))
        name='Violet';
    elseif isequal(value,uint32([251,214,132,255]))||isequal(value,uint32([249,228,177,255]))
        name='Yellow';
    elseif isequal(value,uint32([220,133,151,255]))||isequal(value,uint32([225,178,187,255]))
        name='Pink';
    elseif isequal(value,uint32([198,147,201,255]))||isequal(value,uint32([213,187,220,255]))
        name='Purple';
    elseif isequal(value,uint32([210,210,210,255]))
        name='Generic';
    end
end