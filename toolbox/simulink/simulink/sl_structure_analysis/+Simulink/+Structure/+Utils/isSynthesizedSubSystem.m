function y=isSynthesizedSubSystem(hBlk)




    if nargin>0
        hBlk=convertStringsToChars(hBlk);
    end

    y=false;

    oBlk=get_param(hBlk,'Object');

    if(strcmp(oBlk.BlockType,'SubSystem')&&oBlk.isSynthesized)
        y=true;
    end
end
