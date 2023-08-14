function disp(this)



    str=string(this);
    if isscalar(str)
        disp("    "+str+newline);
    else
        empty="";
        if isempty(str)
            empty=" empty";
        end
        disp("    "+matlab.internal.display.dimensionString(str)+empty+" unit array"+newline);
        s=formattedDisplayText(string(this));
        s=regexprep(s,'\"','');
        disp(s);
    end
end