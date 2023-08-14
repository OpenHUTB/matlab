function brushPrimitiveArray=getBrushPrimitivesForTesting(hObj)






    brushPrimitiveArray={};
    if~isempty(hObj.BrushHandles)
        brushPrimitiveArray=hObj.BrushHandles.getBrushPrimitivesForTesting;
    end
