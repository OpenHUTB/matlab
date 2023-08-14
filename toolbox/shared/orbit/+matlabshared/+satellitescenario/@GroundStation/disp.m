function disp(gs)





    doubleSpace="  ";
    quadrupleSpace="    ";


    header="<a href=""matlab:doc('matlabshared.satellitescenario.GroundStation')"">GroundStation</a>";


    isLoose=strcmp(matlab.internal.display.formatSpacing,'loose');
    if isLoose
        looseLine=newline;
    else
        looseLine="";
    end

    if numel(gs.Handles)==1&&~isvalid(gs.Handles{1})

        fprintf(doubleSpace+"handle to deleted "+header+newline+looseLine);
        return
    end


    props=["             Name","               ID","         Latitude",...
    "        Longitude","         Altitude","MinElevationAngle",...
    "   ConicalSensors","          Gimbals","     Transmitters",...
    "        Receivers","         Accesses","      MarkerColor",...
    "       MarkerSize","        ShowLabel","   LabelFontColor",...
    "    LabelFontSize"];


    if numel(gs.Handles)==1
        fprintf(doubleSpace+header+" with properties:"+newline+looseLine);
    else
        sizeString=getSizeString(size(gs.Handles));
        fprintf(doubleSpace+sizeString+" "+header+" array with properties:"+newline+looseLine);
    end


    if numel(gs.Handles)==1




        fprintf(quadrupleSpace+props(1)+":  "+gs.Name+newline);


        fprintf(quadrupleSpace+props(2)+":  "+gs.ID+newline);


        fmt=getFloatFormat(class(gs.Latitude));
        lat=getFormattedNumber(gs.Latitude,fmt);
        fprintf(quadrupleSpace+props(3)+":  "+lat+" degrees"+newline);


        fmt=getFloatFormat(class(gs.Longitude));
        lon=getFormattedNumber(gs.Longitude,fmt);
        fprintf(quadrupleSpace+props(4)+":  "+lon+" degrees"+newline);


        fmt=getFloatFormat(class(gs.Altitude));
        alt=getFormattedNumber(gs.Altitude,fmt);
        fprintf(quadrupleSpace+props(5)+":  "+alt+" meters"+newline);


        fmt=getFloatFormat(class(gs.MinElevationAngle));
        el=getFormattedNumber(gs.MinElevationAngle,fmt);
        fprintf(quadrupleSpace+props(6)+":  "+el+" degrees"+newline);


        sizeString=getSizeString(size(gs.ConicalSensors));
        fprintf(quadrupleSpace+props(7)+":  ["+sizeString+" matlabshared.satellitescenario.ConicalSensor]"+newline);


        sizeString=getSizeString(size(gs.Gimbals));
        fprintf(quadrupleSpace+props(8)+":  ["+sizeString+" matlabshared.satellitescenario.Gimbal]"+newline);


        sizeString=getSizeString(size(gs.Transmitters));
        fprintf(quadrupleSpace+props(9)+":  ["+sizeString+" satcom.satellitescenario.Transmitter]"+newline);


        sizeString=getSizeString(size(gs.Transmitters));
        fprintf(quadrupleSpace+props(10)+":  ["+sizeString+" satcom.satellitescenario.Receiver]"+newline);


        sizeString=getSizeString(size(gs.Accesses));
        fprintf(quadrupleSpace+props(11)+":  ["+sizeString+" matlabshared.satellitescenario.Access]"+newline);


        fmt=getFloatFormat(class(gs.MarkerColor));
        r=getFormattedNumber(gs.MarkerColor(1),fmt);
        g=getFormattedNumber(gs.MarkerColor(2),fmt);
        b=getFormattedNumber(gs.MarkerColor(3),fmt);
        fprintf(quadrupleSpace+props(12)+":  ["+r+" "+g+" "+b+"]"+newline);


        fmt=getFloatFormat(class(gs.MarkerSize));
        s=getFormattedNumber(gs.MarkerSize,fmt);
        fprintf(quadrupleSpace+props(13)+":  "+s+newline);


        fprintf(quadrupleSpace+props(14)+":  "+gs.ShowLabel+newline);


        fmt=getFloatFormat(class(gs.LabelFontColor));
        r=getFormattedNumber(gs.LabelFontColor(1),fmt);
        g=getFormattedNumber(gs.LabelFontColor(2),fmt);
        b=getFormattedNumber(gs.LabelFontColor(3),fmt);
        fprintf(quadrupleSpace+props(15)+":  ["+r+" "+g+" "+b+"]"+newline);


        fmt=getFloatFormat(class(gs.LabelFontSize));
        s=getFormattedNumber(gs.LabelFontSize,fmt);
        fprintf(quadrupleSpace+props(16)+":  "+s+newline);
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