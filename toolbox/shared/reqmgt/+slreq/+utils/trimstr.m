function outstr=trimstr(str,explength)








    outstr=strrep(str,newline,' ');

    outstr=regexprep(outstr,'\s+',' ');

    if nargin==2&&length(outstr)>explength
        outstr=outstr(1:explength);
        outstr=[outstr,'...'];
    end
end