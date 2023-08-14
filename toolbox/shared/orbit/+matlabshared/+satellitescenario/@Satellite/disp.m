function disp(sat)





    doubleSpace="  ";
    quadrupleSpace="    ";
    header="<a href=""matlab:doc('matlabshared.satellitescenario.Satellite')"">Satellite</a>";


    isLoose=strcmp(matlab.internal.display.formatSpacing,'loose');
    if isLoose
        looseLine=newline;
    else
        looseLine="";
    end

    if numel(sat.Handles)==1&&~isvalid(sat.Handles{1})

        fprintf(doubleSpace+"handle to deleted "+header+newline+looseLine);
        return
    end


    props=[...
    "           Name",...
    "             ID",...
    " ConicalSensors",...
    "        Gimbals",...
    "   Transmitters",...
    "      Receivers",...
    "       Accesses",...
    "    GroundTrack",...
    "          Orbit",...
    "OrbitPropagator",...
    "    MarkerColor",...
    "     MarkerSize",...
    "      ShowLabel",...
    " LabelFontColor",...
    "  LabelFontSize"];


    if numel(sat.Handles)==1
        fprintf(doubleSpace+header+" with properties:"+newline+looseLine);
    else
        sizeString=getSizeString(size(sat.Handles));
        fprintf(doubleSpace+sizeString+" "+header+" array with properties:"+newline+looseLine);
    end


    if numel(sat.Handles)==1




        fprintf(quadrupleSpace+props(1)+":  "+sat.Name+newline);


        fprintf(quadrupleSpace+props(2)+":  "+sat.ID+newline);


        sizeString=getSizeString(size(sat.ConicalSensors));
        fprintf(quadrupleSpace+props(3)+":  ["+sizeString+" matlabshared.satellitescenario.ConicalSensor]"+newline);


        sizeString=getSizeString(size(sat.Gimbals));
        fprintf(quadrupleSpace+props(4)+":  ["+sizeString+" matlabshared.satellitescenario.Gimbal]"+newline);


        sizeString=getSizeString(size(sat.Transmitters));
        fprintf(quadrupleSpace+props(5)+":  ["+sizeString+" satcom.satellitescenario.Transmitter]"+newline);


        sizeString=getSizeString(size(sat.Receivers));
        fprintf(quadrupleSpace+props(6)+":  ["+sizeString+" satcom.satellitescenario.Receiver]"+newline);


        sizeString=getSizeString(size(sat.Accesses));
        fprintf(quadrupleSpace+props(7)+":  ["+sizeString+" matlabshared.satellitescenario.Access]"+newline);


        sizeString=getSizeString(size(sat.GroundTrack));
        fprintf(quadrupleSpace+props(8)+":  ["+sizeString+" matlabshared.satellitescenario.GroundTrack]"+newline);


        sizeString=getSizeString(size(sat.Orbit));
        fprintf(quadrupleSpace+props(9)+":  ["+sizeString+" matlabshared.satellitescenario.Orbit]"+newline);


        fprintf(quadrupleSpace+props(10)+":  "+sat.OrbitPropagator+newline);


        fmt=getFloatFormat(class(sat.MarkerColor));
        r=getFormattedNumber(sat.MarkerColor(1),fmt);
        g=getFormattedNumber(sat.MarkerColor(2),fmt);
        b=getFormattedNumber(sat.MarkerColor(3),fmt);
        fprintf(quadrupleSpace+props(11)+":  ["+r+" "+g+" "+b+"]"+newline);


        fmt=getFloatFormat(class(sat.MarkerSize));
        s=getFormattedNumber(sat.MarkerSize,fmt);
        fprintf(quadrupleSpace+props(12)+":  "+s+newline);


        fprintf(quadrupleSpace+props(13)+":  "+sat.ShowLabel+newline);


        fmt=getFloatFormat(class(sat.LabelFontColor));
        r=getFormattedNumber(sat.LabelFontColor(1),fmt);
        g=getFormattedNumber(sat.LabelFontColor(2),fmt);
        b=getFormattedNumber(sat.LabelFontColor(3),fmt);
        fprintf(quadrupleSpace+props(14)+":  ["+r+" "+g+" "+b+"]"+newline);


        fmt=getFloatFormat(class(sat.LabelFontSize));
        s=getFormattedNumber(sat.LabelFontSize,fmt);
        fprintf(quadrupleSpace+props(15)+":  "+s+newline);
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