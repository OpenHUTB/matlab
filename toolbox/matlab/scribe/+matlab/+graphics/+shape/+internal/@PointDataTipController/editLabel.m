function editLabel(hTip)







    hFig=ancestor(hTip,'figure');
    if~isempty(hFig)
        hGraphicsTip=hTip.TipHandle;
        if isa(hGraphicsTip,'matlab.graphics.shape.internal.GraphicsTip')

            hTarget=hTip.Cursor.DataSource;
            if matlab.graphics.datatip.internal.DataTipTemplateHelper.isCustomizable(hTarget)


                hUpListener=addlistener(hFig,'WindowMouseRelease',@localUp);
                hMotionListener=addlistener(hFig,'WindowMouseMotion',@localMotion);
                hTextEditListener=[];
                hMouseScrollListener=[];
                hSizeChangedListener=[];
                hDelayedTextDeleteListener=[];
            end
        end
    end

    function localMotion(~,~)
        delete(hUpListener);
        delete(hMotionListener);
    end

    function localUp(~,evd)
        delete(hUpListener);
        delete(hMotionListener);

        eventPos=hgconvertunits(hFig,[evd.Point,0,0],get(hFig,'units'),'pixels',hFig);

        eventPos=brushing.select.translateToContainer(hGraphicsTip,eventPos(1:2));

        parentAxes=ancestor(hTip,'matlab.graphics.axis.AbstractAxes','node');



        if~isempty(parentAxes)&&isvalid(parentAxes)&&...
            isa(parentAxes,'matlab.graphics.axis.Axes')&&...
            numel(parentAxes.TargetManager.Children)>1

            parentAxes.processFigureHitObject(hTarget);
        end

        markerPos=matlab.graphics.chart.internal.convertDataSpaceCoordsToViewerCoords(hGraphicsTip,hGraphicsTip.Position.');




        [label,labelIndex,labelXPos,labelYPos]=getEditedLabel(markerPos,eventPos);




        if labelIndex~=0
            textObject=text('Parent',parentAxes,...
            'String',label,...
            'Position',hGraphicsTip.Position,...
            'FontSize',hTip.FontSize,...
            'Interpreter',hTip.Interpreter,...
            'BackgroundColor',[.98,.98,1],...
            'HandleVisibility','off');
            textObject.Units='pixels';
            textObject.Position(1)=textObject.Position(1)+labelXPos;
            textObject.Position(2)=textObject.Position(2)+labelYPos;

            prevString=textObject.String;

            textObject.Editing='on';


            hTextEditListener=event.proplistener(textObject,findprop(textObject,'Editing'),...
            'PostSet',@(e,d)commitTextEditing(textObject,labelIndex,prevString));
            hMouseScrollListener=addlistener(hFig,'WindowScrollWheel',@(e,d)commitTextEditing(textObject,labelIndex,prevString));


            hSizeChangedListener=[addlistener(parentAxes,'SizeChanged',@(e,d)commitTextEditing(textObject,labelIndex,prevString)),...
            addlistener(hFig,'SizeChanged',@(e,d)commitTextEditing(textObject,labelIndex,prevString))];
        end
    end



    function commitTextEditing(textObject,index,prevString)

        delete(hTextEditListener);
        delete(hMouseScrollListener);
        delete(hSizeChangedListener);



        textObject.Editing='off';

        if matlab.ui.internal.isUIFigure(hFig)


            drawnow;
            newString=textObject.String;








            set(textObject,'Visible','off');





            if~isempty(hGraphicsTip)&&isvalid(hGraphicsTip)
                hDelayedTextDeleteListener=addlistener(hGraphicsTip,'MarkedClean',@(e,d)delayedTextDeleteOnUIFigure(textObject));
            end
        else
            newString=textObject.String;
            delete(textObject);
        end
        if~isequal(newString,prevString)

            updateDataTipLabel(index,newString);
            matlab.graphics.datatip.internal.generateDataTipLiveCode(hTip,matlab.internal.editor.figure.ActionID.TEXT_EDITED);
        end
        function delayedTextDeleteOnUIFigure(textObject)
            delete(hDelayedTextDeleteListener);
            delete(textObject);
        end
    end


    function updateDataTipLabel(index,newString)




        newString=strjoin(deblank(string(newString)));
        hTarget.DataTipTemplate.DataTipRows(index).Label=newString;
    end

    function[editedLabel,labelIndex,labelXPos,labelYPos]=getEditedLabel(markerPos,eventPos)

        numLabels=numel(hTip.Cursor.getDataDescriptors);
        labelIndex=0;
        marginOffset=hGraphicsTip.Text.Margin;
        markerOffset=hGraphicsTip.LocatorSize/2;

        labelXPos=(marginOffset)*hGraphicsTip.TextFormatHelper.PixelsPerPoint;

        labelYPos=(hGraphicsTip.TextFormatHelper.TextSize(2)/numLabels)*hGraphicsTip.TextFormatHelper.PixelsPerPoint;
        editedLabel='';

        labelMaxHeight=labelYPos+(marginOffset/2*hGraphicsTip.TextFormatHelper.PixelsPerPoint);



        switch hGraphicsTip.Orientation
        case{'topright','topleft'}
            n=numLabels;
            for index=1:numLabels
                if(eventPos(2)-markerPos(2))<=labelMaxHeight*index
                    editedLabel=hTarget.DataTipTemplate.DataTipRows(n).Label;



                    labelMaxSize=(hGraphicsTip.TextFormatHelper.TipDescriptors(n).LabelSize(1)+marginOffset*2)*hGraphicsTip.TextFormatHelper.PixelsPerPoint;

                    if strcmp(hGraphicsTip.Orientation,'topleft')
                        labelXPos=-(hGraphicsTip.TextFormatHelper.TextSize(1)+...
                        marginOffset+markerOffset)*hGraphicsTip.TextFormatHelper.PixelsPerPoint;

                        if eventPos(1)-markerPos(1)>labelXPos+labelMaxSize
                            continue;
                        end
                    else

                        if eventPos(1)>markerPos(1)+labelMaxSize
                            continue;
                        end
                    end
                    labelYPos=labelYPos*index;
                    labelIndex=n;
                    break;
                end
                n=n-1;
            end
        case{'bottomright','bottomleft'}
            for index=1:numLabels
                if(markerPos(2)-eventPos(2))<=labelMaxHeight*index
                    editedLabel=hTarget.DataTipTemplate.DataTipRows(index).Label;
                    labelMaxSize=(hGraphicsTip.TextFormatHelper.TipDescriptors(index).LabelSize(1)+marginOffset*2)*hGraphicsTip.TextFormatHelper.PixelsPerPoint;



                    if strcmp(hGraphicsTip.Orientation,'bottomleft')
                        labelXPos=-(hGraphicsTip.TextFormatHelper.TextSize(1)+...
                        marginOffset+markerOffset)*hGraphicsTip.TextFormatHelper.PixelsPerPoint;

                        if eventPos(1)-markerPos(1)>labelXPos+labelMaxSize
                            continue;
                        end
                    else

                        if eventPos(1)>markerPos(1)+labelMaxSize
                            continue;
                        end
                    end
                    labelYPos=-(labelYPos*index);
                    labelIndex=index;
                    break;
                end
            end
        end
    end
end