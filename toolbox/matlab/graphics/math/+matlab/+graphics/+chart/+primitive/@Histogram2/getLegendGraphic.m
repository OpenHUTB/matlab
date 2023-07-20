function graphic=getLegendGraphic(hObj)




    graphic=matlab.graphics.primitive.world.Group;

    face=matlab.graphics.primitive.world.Quadrilateral;

    face.VertexData=single([0,0,1,1;0,1,1,0;0,0,0,0]);
    face.VertexIndices=[];
    face.StripData=[];
    face.ColorBinding='object';
    face.ColorType='truecoloralpha';
    if strcmp(hObj.FaceColor,'flat')

        values=hObj.Values;
        if strcmp(hObj.ShowEmptyBins,'off')
            values=values(values>0);
        end
        [~,index]=max(values(:));



        if strcmp(hObj.DisplayStyle,'tile')&&~isempty(hObj.BrushValues)
            brushvalues=hObj.BrushValues;
            if strcmp(hObj.ShowEmptyBins,'off')
                brushvalues=brushvalues(hObj.Values>0);
            end
            if brushvalues(index)>0

                index=index-sum(~(brushvalues(1:index-1)>0));
                face.ColorData=hObj.BrushFace.ColorData(:,index);
            else
                index=index-sum(brushvalues(1:index-1)>0);
                face.ColorData=hObj.Face.ColorData(:,index);
            end
        else



            if isempty(hObj.Face.ColorData)
                face.ColorData=[];
                face.ColorBinding='none';
            else
                rindex=numel(values)-index;
                face.ColorData=hObj.Face.ColorData(:,end-rindex);
            end
        end
    else

        face.ColorData=max(hObj.Face.ColorData,[],2);
    end
    face.Visible=hObj.Face.Visible;
    face.Parent=graphic;

    edge=matlab.graphics.primitive.world.LineLoop('LineJoin','miter',...
    'AlignVertexCenters','on');
    edge.LineWidth=hObj.Edge.LineWidth;
    edge.LineStyle=hObj.Edge.LineStyle;

    edge.VertexData=face.VertexData;
    edge.VertexIndices=[];
    edge.StripData=uint32([1,5]);
    edge.ColorBinding='object';
    edge.ColorType='truecoloralpha';
    edge.ColorData=hObj.Edge.ColorData;
    edge.Visible=hObj.Edge.Visible;
    edge.Parent=graphic;
end
