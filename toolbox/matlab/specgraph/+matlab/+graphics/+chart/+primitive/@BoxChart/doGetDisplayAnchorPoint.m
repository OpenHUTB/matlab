function pt=doGetDisplayAnchorPoint(hObj,index,~)







    ngrp=hObj.XNumGroups;
    if index>ngrp

        verts=hObj.OutlierVertexData;


        pt=[verts(index-ngrp,:),0];
    else

        y=hObj.GroupStatistics.WhiskerUpper(index);
        x=hObj.XDataCacheCategories(index);
        x=getGroupPositionAndWidth(hObj,x);
        pt=[x,y,0];


        if strcmp(hObj.Orientation,'horizontal')
            pt([1,2])=pt([2,1]);
        end
    end


    pt=matlab.graphics.shape.internal.util.SimplePoint(pt);
end
