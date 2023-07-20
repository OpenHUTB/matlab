function[xname,xunit]=xaxis(h,xparam,xformat)







    xname='';
    xunit='';
    xtype=xcategory(h,xparam);

    switch xtype
    case 'Frequency'
        [xname,xunit]=getfreqname(xformat);

    case 'Input Power'
        [xname,xunit]=getpowername(xformat);

    case 'AM'
        [xname,xunit]=getampmname(xformat);

    case 'Operating Condition'
        xname=upper(xparam);
        xunit='';
    end


    function[fname,funit]=getfreqname(format)

        fname='Freq';
        switch upper(format)
        case 'THZ'
            funit='[THz]';
        case 'GHZ'
            funit='[GHz]';
        case 'MHZ'
            funit='[MHz]';
        case 'KHZ'
            funit='[KHz]';
        case 'HZ'
            funit='[Hz]';
        otherwise
            funit='[Hz]';
        end


        function[pname,punit]=getpowername(xformat)

            pname='P_{in}';
            switch upper(xformat)
            case 'DBM'
                punit='[dBm]';
            case 'DBW'
                punit='[dBw]';
            case 'MW'
                punit='[mW]';
            case 'W'
                punit='[W]';
            otherwise
                punit='[dBm]';
            end


            function[pname,punit]=getampmname(xformat)

                pname='AM of Input';
                switch upper(xformat)
                case upper({'dB','Magnitude (decibels)'})
                    punit='[dB]';
                case upper({'Mag','Magnitude (linear)','None'})
                    punit='';
                otherwise
                    punit='[dB]';
                end
