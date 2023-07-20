function hObj=doloadobj(hObj)







    if isscalar(hObj.Title_I)&&isvalid(hObj.Title_I)
        hObj.DecorationContainer.addNode(hObj.Title_I);
        addlistener(hObj.Title_I,'MarkedDirty',@(h,e)hObj.MarkDirty('all'));
        addlistener(hObj.Title_I,'ObjectBeingDestroyed',@(h,e)hObj.MarkDirty('all'));
    end
end
