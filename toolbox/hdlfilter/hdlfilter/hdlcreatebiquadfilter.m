function hF=hdlcreatebiquadfilter(hS)







    biquadStructure=hS.Structure;
    switch biquadStructure
    case 'Direct form I'
        hF=hdlfilter.df1sos;
    case 'Direct form I transposed'
        hF=hdlfilter.df1tsos;
    case 'Direct form II'
        hF=hdlfilter.df2sos;
    otherwise
        hF=hdlfilter.df2tsos;
    end

end

