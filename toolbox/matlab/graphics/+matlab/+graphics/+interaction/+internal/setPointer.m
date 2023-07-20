function setPointer(f,newcursor)


    if strcmp(f.Pointer,newcursor)
        return;
    elseif any(strcmp(newcursor,{'arrow','rotate','datacursor','fleur'}))
        setptr(f,newcursor);
    else
        setCustomPointer(f,newcursor);
    end




    if isprop(f,'PointerMode')
        f.PointerMode='auto';
    end

    function setCustomPointer(f,icon)
        cdata=matlab.graphics.interaction.internal.getPointerCData(icon);
        if isempty(cdata)
            return;
        else
            f.Pointer='custom';
            f.PointerShapeHotSpot=[16,16];
            f.PointerShapeCData=cdata;
        end
