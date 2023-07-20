function hCopy=copyElement(hSrc)



    hCopy=copyElement@matlab.graphics.primitive.world.Group(hSrc);





    if isscalar(hCopy.Title_I)&&isvalid(hCopy.Title_I)
        hCopy.DecorationContainer.addNode(hCopy.Title_I);
        addlistener(hCopy.Title_I,'MarkedDirty',@(h,e)doMethod(hCopy,'doMarkDirty','all'));
        addlistener(hCopy.Title_I,'ObjectBeingDestroyed',@(h,e)doMethod(hCopy,'doMarkDirty','all'));
    end

end
