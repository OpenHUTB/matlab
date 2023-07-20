function disp(gim)





    doubleSpace="  ";
    quadrupleSpace="    ";
    header="<a href=""matlab:doc('matlabshared.satellitescenario.Gimbal')"">Gimbal</a>";


    isLoose=strcmp(matlab.internal.display.formatSpacing,'loose');
    if isLoose
        looseLine=newline;
    else
        looseLine="";
    end

    if numel(gim.Handles)==1&&~isvalid(gim.Handles{1})

        fprintf(doubleSpace+"handle to deleted "+header+newline+looseLine);
        return
    end


    props=[...
    "            Name",...
    "              ID",...
    "MountingLocation",...
    "  MountingAngles",...
    "  ConicalSensors",...
    "    Transmitters",...
    "       Receivers"];


    if numel(gim.Handles)==1
        fprintf(doubleSpace+header+" with properties:"+newline+looseLine);
    else
        sizeString=getSizeString(size(gim.Handles));
        fprintf(doubleSpace+sizeString+" "+header+" array with properties:"+newline+looseLine);
    end


    if numel(gim.Handles)==1




        fprintf(quadrupleSpace+props(1)+":  "+gim.Name+newline);


        fprintf(quadrupleSpace+props(2)+":  "+gim.ID+newline);


        fmt=getFloatFormat(class(gim.MountingLocation));
        mountingLocation=getFormattedNumber(gim.MountingLocation,fmt);
        fprintf(quadrupleSpace+props(3)+":  ["+mountingLocation(1)+"; "+...
        mountingLocation(2)+"; "+mountingLocation(3)+"] meters"+newline);


        fmt=getFloatFormat(class(gim.MountingAngles));
        mountingAngles=getFormattedNumber(gim.MountingAngles,fmt);
        fprintf(quadrupleSpace+props(4)+":  ["+mountingAngles(1)+"; "+...
        mountingAngles(2)+"; "+mountingAngles(3)+"] degrees"+newline);


        sizeString=getSizeString(size(gim.ConicalSensors));
        fprintf(quadrupleSpace+props(5)+":  ["+sizeString+" matlabshared.satellitescenario.ConicalSensor]"+newline);


        sizeString=getSizeString(size(gim.Transmitters));
        fprintf(quadrupleSpace+props(6)+":  ["+sizeString+" satcom.satellitescenario.Transmitter]"+newline);


        sizeString=getSizeString(size(gim.Receivers));
        fprintf(quadrupleSpace+props(7)+":  ["+sizeString+" satcom.satellitescenario.Receiver]"+newline);
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