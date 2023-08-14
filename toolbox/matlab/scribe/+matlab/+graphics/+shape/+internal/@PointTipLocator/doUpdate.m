function doUpdate(obj,updateState)









    vis=obj.Visible;
    try


        iter=matlab.graphics.axis.dataspace.IndexPointsIterator('Vertices',obj.Position);
        TransformPoints(updateState.DataSpace,updateState.TransformUnderDataSpace,iter);
    catch

        vis='off';
    end



    hMarkerStyle=findprop(obj,'Marker');
    hMarkerSize=findprop(obj,'Size');
    if~strcmpi(hMarkerStyle.DefaultValue,obj.Marker)
        obj.Marker=hMarkerStyle.DefaultValue;
        obj.Size=hMarkerSize.DefaultValue;
    end





    obj.ScribeHost.Position=obj.Position;
    obj.ScribeHost.Visible=vis;