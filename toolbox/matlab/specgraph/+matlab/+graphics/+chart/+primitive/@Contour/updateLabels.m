function updateLabels(hObj,updateState,label_info)




    if~isempty(label_info)&&strcmp(hObj.Visible,'on')
        numLabels=numel(label_info);
        textPrims=reallocTextPrims(hObj,numLabels);
        textPointIter=matlab.graphics.axis.dataspace.XYZPointsIterator;
        plotIs2D=~strcmp(hObj.Is3D,'on');

        p=hObj.LabelTextProperties;
        if strcmp(hObj.Visible,'on')&&strcmp(p.Visible,'on')
            vis='on';
        else
            vis='off';
        end

        for k=1:numLabels
            textPointIter.XData=label_info(k).Position(1);
            textPointIter.YData=label_info(k).Position(2);
            textPointIter.ZData=label_info(k).Position(3);

            vd=TransformPoints(updateState.DataSpace,...
            updateState.TransformUnderDataSpace,...
            textPointIter);

            t=textPrims(k);
            t.Font=p.Font;
            t.String=label_info(k).String;
            t.VertexData=vd;
            t.HorizontalAlignment='center';
            t.VerticalAlignment='middle';
            t.Clipping='on';
            t.HitTest='off';
            t.Visible=vis;
            if plotIs2D
                t.Rotation=label_info(k).Rotation;
            else
                t.Rotation=0;
            end

            t.ColorData=p.ColorData;
            t.BackgroundColor=p.BackgroundColor;
            t.EdgeColor=p.EdgeColor;

            t.FontSmoothing=p.FontSmoothing;
            t.Interpreter=p.Interpreter;
            t.LineWidth=p.LineWidth;
            t.LineStyle=p.LineStyle;
            t.Margin=p.Margin;
        end
        hObj.TextPrims_I=textPrims;
    elseif strcmp(hObj.Visible,'off')
        set(hObj.TextPrims_I,'Visible','off');
    else
        if~isempty(hObj.TextPrims_I)
            delete(hObj.TextPrims_I);
            hObj.TextPrims_I=matlab.graphics.primitive.world.Text.empty;
        end
    end
end


function textprims=reallocTextPrims(hContourObj,numLabels)
    curr=hContourObj.TextPrims;
    numCurrent=numel(curr);
    if(numLabels>numCurrent)
        textprims=curr;
        textprims(numLabels,1)=gobjects(1);
        for k=(numCurrent+1):numLabels
            textprims(k,1)=matlab.graphics.primitive.world.Text('Internal',true);
        end
    elseif(numLabels<numCurrent)
        textprims=curr(1:numLabels);
        delete(curr((numLabels+1):end));
    else
        textprims=curr;
    end

    for k=1:numLabels



        textprims(k).Parent=[];
        hContourObj.addNode(textprims(k));
    end
end
