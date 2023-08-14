function[out_fontname,index]=findMatchingFont(obj,fontname)

















    available=obj.allowedValues;

    assert(~isempty(available));
    assert(iscellstr(available));


    [index,out_fontname]=i_find_font_index(fontname,available);
    if index>0
        return;
    end



    out_fontname=MG2.Font.getClosestFontName(fontname);
    [index,out_fontname]=i_find_font_index(out_fontname,available);
    assert(index>0)

end


function[index,fontname]=i_find_font_index(fontname,available)

    match=strcmpi(fontname,available);
    if any(match)
        index=find(match);


        fontname=available{index};
    else
        index=0;
    end
end


