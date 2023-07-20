function RGBValue=getRGBValueForGivenColorName(name)







    assert(isstring(name)|ischar(name));
    switch lower(string(name))
    case "blue"
        RGBValue=uint32([172,221,242]);
    case "green"
        RGBValue=uint32([180,215,144]);
    case "red"
        RGBValue=uint32([244,172,176]);
    case "orange"
        RGBValue=uint32([248,165,133]);
    case "violet"
        RGBValue=uint32([131,164,253]);
    case "yellow"
        RGBValue=uint32([251,214,132]);
    case "pink"
        RGBValue=uint32([220,133,151]);
    case "purple"
        RGBValue=uint32([198,147,201]);
    case "generic"
        RGBValue=uint32([210,210,210]);
    end
end
