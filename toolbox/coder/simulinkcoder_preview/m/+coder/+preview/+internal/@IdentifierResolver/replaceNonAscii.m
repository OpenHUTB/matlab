function out=replaceNonAscii(~,text)




    nonAscii=text>127;
    if any(nonAscii)
        c=num2cell(text);
        c(nonAscii)=arrayfun(@(x)sprintf('&#%d;',x),...
        uint16(text(nonAscii)),'UniformOutput',false);
        out=[c{:}];
    else
        out=text;
    end
