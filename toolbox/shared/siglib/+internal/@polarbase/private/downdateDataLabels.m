function str=downdateDataLabels(str)





    if~iscell(str)
        str={str};
    end
    for i=1:numel(str)
        s_i=str{i};


        s_i=internal.polariCommon.xlatExtendedASCII(s_i,'reverse');


        str{i}=strtrim(internal.polariCommon.removeExtendedASCII(s_i));
    end

end
