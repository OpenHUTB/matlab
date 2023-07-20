function hSrc=getSourceObject(h)





    if~isempty(h.SourceObject)

        hSrc=h.SourceObject;
    else
        hSrc=h.up;
    end

