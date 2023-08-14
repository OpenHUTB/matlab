function bool=getStatus(obj,input)




    if obj.initialized
        src=simulinkcoder.internal.util.getSource(input);
        studio=src.studio;
        flag=obj.getFlag(src.modelH,studio);
        bool=~isempty(flag);
    else
        bool=false;
    end


