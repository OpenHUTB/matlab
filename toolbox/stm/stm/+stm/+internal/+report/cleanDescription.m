function y = cleanDescription(instr)
%
% This is a temporary solution to remove html tags from input string, so 
% that it can be displayed in docx or pdf report.

% Copyright 2014 The MathWorks, Inc.
%
    
    exp1 = '<[^>]*>';
    exp2 = '<br[^>]*>';
    exp3 = '<li[^>]*>';
    exp4 = '</li[^>]*>';
    replaceWithLineBreak = newline;

    % add line breaks if there is <br />, <b>, <li>
    newStr = regexprep(instr,exp2,replaceWithLineBreak);
    newStr = regexprep(newStr,exp3,replaceWithLineBreak);
    newStr = regexprep(newStr,exp4,replaceWithLineBreak);

    replace = '';
    newStr = regexprep(newStr,exp1,replace);

    y = newStr;
    L = length(y);

    index = 0;
    for k = 1 : L
        if(int32(newStr(k)) == 10)
            if(index == 0)
                continue;
            elseif(int32(y(index)) == 10)
                continue;
            end
        end
        index = index + 1;
        y(index) =  newStr(k);
    end
    if(index > 0)
        y(index+1:end) = '';
    else
        y = '';
    end
end
