function out=convert2HTMLStr(in)



    charMap={'&','&amp;';
    '<','&lt;';
    '>','&gt;';
    };

    out=in;
    for idx=1:size(charMap,1)
        out=regexprep(out,charMap{idx,1},charMap{idx,2});
    end
end
