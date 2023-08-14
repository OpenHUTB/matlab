function wasProcessed=onPropChangeEvent(h,~,e)


    src=e.Source;
    if isa(src,"DAStudio.DAObjectProxy")
        src=src.getMCOSObjectReference;
    end
    if isequal(src,h.daobject)||isequal(src,h)
        h.updateRefModels;
        wasProcessed=true;
    else
        wasProcessed=false;
    end

end


