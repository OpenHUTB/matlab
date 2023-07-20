function disp(rx)





    doubleSpace="  ";
    quadrupleSpace="    ";
    header="<a href=""matlab:doc('satcom.satellitescenario.Receiver')"">Receiver</a>";


    isLoose=strcmp(matlab.internal.display.formatSpacing,'loose');
    if isLoose
        looseLine=newline;
    else
        looseLine="";
    end

    if numel(rx.Handles)==1&&~isvalid(rx.Handles{1})

        fprintf(doubleSpace+"handle to deleted "+header+newline+looseLine);
        return
    end


    props=[...
    "                       Name",...
    "                         ID",...
    "           MountingLocation",...
    "             MountingAngles",...
    "                    Antenna",...
    "                 SystemLoss",...
    "            PreReceiverLoss",...
    "GainToNoiseTemperatureRatio",...
    "               RequiredEbNo"];


    if numel(rx.Handles)==1
        fprintf(doubleSpace+header+" with properties:"+newline+looseLine);
    else
        sizeString=getSizeString(size(rx.Handles));
        fprintf(doubleSpace+sizeString+" "+header+" array with properties:"+newline+looseLine);
    end


    if numel(rx.Handles)==1




        fprintf(quadrupleSpace+props(1)+":  "+rx.Name+newline);


        fprintf(quadrupleSpace+props(2)+":  "+rx.ID+newline);


        fmt=getFloatFormat(class(rx.MountingLocation));
        mountingLocation=getFormattedNumber(rx.MountingLocation,fmt);
        fprintf(quadrupleSpace+props(3)+":  ["+mountingLocation(1)+"; "+...
        mountingLocation(2)+"; "+mountingLocation(3)+"] meters"+newline);


        fmt=getFloatFormat(class(rx.MountingAngles));
        mountingAngles=getFormattedNumber(rx.MountingAngles,fmt);
        fprintf(quadrupleSpace+props(4)+":  ["+mountingAngles(1)+"; "+...
        mountingAngles(2)+"; "+mountingAngles(3)+"] degrees"+newline);


        sizeString=getSizeString(size(rx.Antenna));
        antennaType=class(rx.Antenna);
        fprintf(quadrupleSpace+props(5)+":  ["+sizeString+" "+antennaType+"]"+newline);


        fmt=getFloatFormat(class(rx.SystemLoss));
        l=getFormattedNumber(rx.SystemLoss,fmt);
        fprintf(quadrupleSpace+props(6)+":  "+l+" decibels"+newline);


        fmt=getFloatFormat(class(rx.PreReceiverLoss));
        l=getFormattedNumber(rx.PreReceiverLoss,fmt);
        fprintf(quadrupleSpace+props(7)+":  "+l+" decibels"+newline);


        fmt=getFloatFormat(class(rx.GainToNoiseTemperatureRatio));
        l=getFormattedNumber(rx.GainToNoiseTemperatureRatio,fmt);
        fprintf(quadrupleSpace+props(8)+":  "+l+" decibels/Kelvin"+newline);


        fmt=getFloatFormat(class(rx.RequiredEbNo));
        l=getFormattedNumber(rx.RequiredEbNo,fmt);
        fprintf(quadrupleSpace+props(9)+":  "+l+" decibels"+newline);
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