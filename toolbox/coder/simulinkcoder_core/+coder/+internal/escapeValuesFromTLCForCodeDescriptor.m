function outStr=escapeValuesFromTLCForCodeDescriptor(varargin)




    if nargin==1
        outStr=doEscape(varargin{1});
    else
        outStr=cellfun(@doEscape,varargin,'UniformOutput',false);
    end

end


function outStr=doEscape(inStr)
    escapedStr=inStr;
    escapedStr=strrep(escapedStr,'\','\\');
    escapedStr=strrep(escapedStr,'''','''''');
    escapedStr=strrep(escapedStr,'%','%%');
    escapedStr=strrep(escapedStr,sprintf('\a'),'\a');
    escapedStr=strrep(escapedStr,sprintf('\b'),'\b');
    escapedStr=strrep(escapedStr,sprintf('\f'),'\f');
    escapedStr=strrep(escapedStr,sprintf('\t'),'\t');
    escapedStr=strrep(escapedStr,sprintf('\r'),'\r');
    escapedStr=strrep(escapedStr,sprintf('\v'),'\v');
    escapedStr=strrep(escapedStr,newline,'\n');
    outStr=sprintf('sprintf(''%s'')',escapedStr);
end
