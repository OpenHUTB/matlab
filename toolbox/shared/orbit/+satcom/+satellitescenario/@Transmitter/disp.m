function disp(tx)





    doubleSpace="  ";
    quadrupleSpace="    ";
    header="<a href=""matlab:doc('satcom.satellitescenario.Transmitter')"">Transmitter</a>";


    isLoose=strcmp(matlab.internal.display.formatSpacing,'loose');
    if isLoose
        looseLine=newline;
    else
        looseLine="";
    end

    if numel(tx.Handles)==1&&~isvalid(tx.Handles{1})

        fprintf(doubleSpace+"handle to deleted "+header+newline+looseLine);
        return
    end


    props=[...
    "            Name",...
    "              ID",...
    "MountingLocation",...
    "  MountingAngles",...
    "         Antenna",...
    "      SystemLoss",...
    "       Frequency",...
    "         BitRate",...
    "           Power",...
    "           Links"];


    if numel(tx.Handles)==1
        fprintf(doubleSpace+header+" with properties:"+newline+looseLine);
    else
        sizeString=getSizeString(size(tx.Handles));
        fprintf(doubleSpace+sizeString+" "+header+" array with properties:"+newline+looseLine);
    end


    if numel(tx.Handles)==1




        fprintf(quadrupleSpace+props(1)+":  "+tx.Name+newline);


        fprintf(quadrupleSpace+props(2)+":  "+tx.ID+newline);


        fmt=getFloatFormat(class(tx.MountingLocation));
        mountingLocation=getFormattedNumber(tx.MountingLocation,fmt);
        fprintf(quadrupleSpace+props(3)+":  ["+mountingLocation(1)+"; "+...
        mountingLocation(2)+"; "+mountingLocation(3)+"] meters"+newline);


        fmt=getFloatFormat(class(tx.MountingAngles));
        mountingAngles=getFormattedNumber(tx.MountingAngles,fmt);
        fprintf(quadrupleSpace+props(4)+":  ["+mountingAngles(1)+"; "+...
        mountingAngles(2)+"; "+mountingAngles(3)+"] degrees"+newline);


        sizeString=getSizeString(size(tx.Antenna));
        antennaType=class(tx.Antenna);
        fprintf(quadrupleSpace+props(5)+":  ["+sizeString+" "+antennaType+"]"+newline);


        fmt=getFloatFormat(class(tx.SystemLoss));
        l=getFormattedNumber(tx.SystemLoss,fmt);
        fprintf(quadrupleSpace+props(6)+":  "+l+" decibels"+newline);


        fmt=getFloatFormat(class(tx.Frequency));
        l=getFormattedNumber(tx.Frequency,fmt);
        fprintf(quadrupleSpace+props(7)+":  "+l+" Hertz"+newline);


        fmt=getFloatFormat(class(tx.BitRate));
        l=getFormattedNumber(tx.BitRate,fmt);
        fprintf(quadrupleSpace+props(8)+":  "+l+" Mbps"+newline);


        fmt=getFloatFormat(class(tx.Power));
        l=getFormattedNumber(tx.Power,fmt);
        fprintf(quadrupleSpace+props(9)+":  "+l+" decibel-watts"+newline);


        sizeString=getSizeString(size(tx.Links));
        fprintf(quadrupleSpace+props(10)+":  ["+sizeString+" satcom.satellitescenario.Link]"+newline);
    else

        for idx=1:numel(props)
            fprintf(quadrupleSpace+strtrim(props(idx))+newline);
        end
    end


    fprintf(looseLine);
end

function sizeString=getSizeString(s)


    sizeString="";
    for idx=1:numel(s)
        if idx~=numel(s)
            sizeString=sizeString+s(idx)+"x";
        else
            sizeString=sizeString+s(idx);
        end
    end
end

function fmt=getFloatFormat(cls)



    switch lower(matlab.internal.display.format)
    case{'short','shortg','shorteng'}
        dblFmt='%.5g    ';
        snglFmt='%.5g    ';
    case{'long','longg','longeng'}
        dblFmt='%.15g    ';
        snglFmt='%.7g    ';
    case 'shorte'
        dblFmt='%.4e    ';
        snglFmt='%.4e    ';
    case 'longe'
        dblFmt='%.14e    ';
        snglFmt='%.6e    ';
    case 'bank'
        dblFmt='%.2f    ';
        snglFmt='%.2f    ';
    otherwise
        dblFmt='%.5g    ';
        snglFmt='%.5g    ';
    end

    if strcmpi(cls,'double')
        fmt=dblFmt;
    else
        fmt=snglFmt;
    end
end

function fNum=getFormattedNumber(n,fmt)



    fNum=strtrim(string(num2str(n,fmt)));
end