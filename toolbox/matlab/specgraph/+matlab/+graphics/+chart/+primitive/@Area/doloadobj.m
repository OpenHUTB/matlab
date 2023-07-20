function hObj=doloadobj(hObj)






    hP=findobjinternal(hObj,'Type','patch');
    if~isempty(hP)&&~isempty(hObj.XData)
        hObj.CData=hP.FaceVertexCData(1);
    end


    matlab.graphics.chart.internal.deleteNonPrimitiveChildren(hObj);




    persistent numAreasLoaded peerID
    if isa(hObj.Face_I,'matlab.graphics.primitive.world.Quadrilateral')

        numpeers=getappdata(hObj,'NumPeers');
        if~isempty(numpeers)
            hObj.NumPeers=numpeers;
        end


        cdata=hObj.CCoords_I;
        if~isempty(cdata)
            hObj.CData=cdata;
        end


        hObj.Face_I=matlab.graphics.primitive.world.TriangleStrip;
        hObj.Face_I.Description_I='Area Face';
        hObj.Face_I.Internal=true;
        hObj.Face_I.Clipping_I=hObj.Clipping_I;











        if isempty(peerID)||isempty(numAreasLoaded)
            numAreasLoaded=0;
            peerID=matlab.graphics.chart.primitive.utilities.incrementPeerID;
        end


        hObj.AreaPeerID=peerID;



        numAreasLoaded=numAreasLoaded+1;
        if numAreasLoaded>=hObj.NumPeers
            numAreasLoaded=0;
            peerID=matlab.graphics.chart.primitive.utilities.incrementPeerID;
        end
    end


    if hObj.NumPeers>1
        addlistener(hObj,{'XData','YData','XDataMode','BaseValue'},'PostSet',@(~,~)hObj.markSeriesDirty);
    end

end
