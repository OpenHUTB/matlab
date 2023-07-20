function disp(ac)





    doubleSpace="  ";
    quadrupleSpace="    ";
    header="<a href=""matlab:doc('matlabshared.satellitescenario.Access')"">Access</a>";


    isLoose=strcmp(matlab.internal.display.formatSpacing,'loose');
    if isLoose
        looseLine=newline;
    else
        looseLine="";
    end

    if numel(ac.Handles)==1&&~isvalid(ac.Handles{1})

        fprintf(doubleSpace+"handle to deleted "+header+newline+looseLine);
        return
    end


    props=[...
    "Sequence",...
    "LineWidth",...
    "LineColor"];


    if numel(ac.Handles)==1
        fprintf(doubleSpace+header+" with properties:"+newline+looseLine);
    else
        sizeString=getSizeString(size(ac.Handles));
        fprintf(doubleSpace+sizeString+" "+header+" array with properties:"+newline+looseLine);
    end


    if numel(ac.Handles)==1




        fprintf(quadrupleSpace+props(1)+":  [");
        for idx=1:numel(ac.Sequence)
            fprintf('%.0f',ac.Sequence(idx));
            if idx~=numel(ac.Sequence)
                fprintf(' ');
            end
        end
        fprintf("]"+newline);


        fmt=getFloatFormat(class(ac.LineWidth));
        s=getFormattedNumber(ac.LineWidth,fmt);
        fprintf(quadrupleSpace+props(2)+":  "+s+newline);


        fmt=getFloatFormat(class(ac.LineColor));
        r=getFormattedNumber(ac.LineColor(1),fmt);
        g=getFormattedNumber(ac.LineColor(2),fmt);
        b=getFormattedNumber(ac.LineColor(3),fmt);
        fprintf(quadrupleSpace+props(3)+":  ["+r+" "+g+" "+b+"]"+newline);
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