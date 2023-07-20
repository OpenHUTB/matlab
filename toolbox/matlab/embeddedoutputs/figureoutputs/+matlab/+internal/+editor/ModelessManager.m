classdef ModelessManager<handle





    properties(SetAccess=private,GetAccess=private)
        CodeGenerator matlab.internal.editor.CodeGenerator
        RegisterUndoRedoAddEditAction matlab.internal.editor.figure.RegisterUndoRedoAddEditAction
        RegisterUndoRedoClearAction matlab.internal.editor.figure.RegisterUndoRedoClearAction
AnnotationObjectBeingEdited

        UndoRedoManager matlab.internal.editor.figure.UndoRedoManager
    end

    properties
Figure
FigureID
    end

    methods
        function this=ModelessManager(cg,undoRedoManager)
            this.CodeGenerator=cg;
            this.UndoRedoManager=undoRedoManager;
        end

        function setFigure(this,hFig,figureID,serializedModeState)

            this.Figure=hFig;
            this.FigureID=figureID;



            if~isempty(serializedModeState)
                serializedModeState.deserialize(hFig,'Exploration.Datacursor');
            end

        end


        function figData=performCallback(this,clientEvent)
            import matlab.internal.editor.figure.FigureDataTransporter;
            if~isfield(clientEvent,'type')||isempty(clientEvent.type)
                return
            end
            switch clientEvent.type
            case{'WindowMouseClick','AnnotationSelection'}
                figData=this.processClick(this.Figure,clientEvent,this.FigureID);
            case 'LEGEND_EDITED'
                if(this.processLegendEdited(this.Figure,clientEvent))
                    figData=this.transportFigureData(this.Figure,this.FigureID);
                else





                    figData=transportFigureDataForRendering(this.Figure,this.FigureID);
                end
            case{'TITLE_EDITED','XLABEL_EDITED','YLABEL_EDITED'}
                if(this.processLabelEdited(this.Figure,clientEvent))
                    figData=this.transportFigureData(this.Figure,this.FigureID);
                else





                    figData=transportFigureDataForRendering(this.Figure,this.FigureID);
                end
            case 'ANNOTATION_EDITED'
                this.processAnnotationEdited(this.Figure,clientEvent);
                figData=this.transportFigureData(this.Figure,this.FigureID);
            case 'ANNOTATION_CLEARED'
                this.processClearAnnotation(this.Figure,clientEvent);
                figData=this.transportFigureData(this.Figure,this.FigureID);
            case 'CHART_INTERACTION'

                this.processChartInteraction(this.Figure,clientEvent);
                if strcmp(clientEvent.interaction,'WindowMouseMotion')&&~clientEvent.isDragEvent


                    noopFigureData=matlab.internal.editor.figure.FigureData;
                    noopFigureData.iFigureInteractionData=matlab.internal.editor.figure.FigureInteractionData;

                    figData=FigureDataTransporter.transportFigureData(this.FigureID,noopFigureData);
                else
                    figData=this.transportFigureDataForInteraction(this.FigureID,clientEvent);
                end
            end
        end
    end

    methods(Access=private)

        function figData=transportFigureDataForInteraction(this,figureId,clientEvent)



            import matlab.internal.editor.figure.FigureDataTransporter

            figureData=matlab.internal.editor.figure.FigureData;
            [generatedCode,isFakeCode]=this.CodeGenerator.generateCode;
            figureData.setCode(generatedCode);
            figureData.setFakeCode(isFakeCode);





            if strcmp(clientEvent.interaction,'WindowScrollWheel')

                figureData.iFigureInteractionData.iShowCode=~isempty(generatedCode);


                figureData.iFigureInteractionData.iClearCode=isempty(generatedCode);
            end
            figData=FigureDataTransporter.transportFigureData(figureId,figureData);
        end

        function processChartInteraction(this,hFig,clientEvent)

            hChart=[];

            figPosPixels=getpixelposition(hFig);

            oldUnits=hFig.Units;
            hFig.Units='pixels';


            hFig.CurrentPoint=[clientEvent.x*figPosPixels(3),clientEvent.y*figPosPixels(4)];

            allCharts=matlab.internal.editor.figure.ChartAccessor.getAllCharts(hFig);

            if~isempty(clientEvent.axesIndex)


                if clientEvent.axesIndex>-1

                    hChart=allCharts(clientEvent.axesIndex+1);
                end
            end

            if~isempty(hChart)&&isa(hChart,'matlab.graphics.axis.AbstractAxes')
                if~matlab.graphics.interaction.internal.isInteractivityEnabled(hChart)
                    if strcmp(hChart.InteractionContainerMode,'auto')







                        enableDefaultInteractivity(hChart);
                    else
                        return;
                    end
                end
            end



            synEvd=matlab.internal.editor.figure.ModelessInteractionEventData;
            synEvd.Point=hFig.CurrentPoint;

            sv=findobjinternal(hFig,'-isa','matlab.graphics.primitive.canvas.Canvas','-depth',1);
            hitObj=[];

            if~isempty(sv)
                ySv=figPosPixels(4)-hFig.CurrentPoint(2);
                hitObj=sv.hittest(hFig.CurrentPoint(1),ySv);
            end




            if isempty(hitObj)
                hitObj=hFig;
            end
            synEvd.HitObject=hitObj;


            evd=[];
            switch(clientEvent.interaction)
            case 'WindowScrollWheel'
                synEvd.wheelDelta=-clientEvent.wheelDelta;






                evd=matlab.internal.editor.figure.ScrollEventWrapper(synEvd,hChart);
                this.CodeGenerator.registerAction(hChart,matlab.internal.editor.figure.ActionID.PANZOOM);
                this.UndoRedoManager.registerUndoRedoAction(hChart,matlab.internal.editor.figure.ActionID.PANZOOM);
            case{'WindowMouseMotion','WindowMousePress','WindowMouseRelease'}


                if isa(hChart,'matlab.graphics.axis.AbstractAxes')
                    hChart.InteractionContainer.GObj=hChart;
                    hChart.InteractionContainer.Canvas=sv;
                    hChart.InteractionContainer.updateInteractions();
                end






                evd=matlab.internal.editor.figure.MouseEventWrapper(synEvd,hChart);
                if strcmp(clientEvent.interaction,'WindowMouseMotion')&&clientEvent.isDragEvent

                    if isa(hChart,'matlab.graphics.axis.AbstractAxes')&&~is2D(hChart)
                        this.CodeGenerator.registerAction(hChart,matlab.internal.editor.figure.ActionID.ROTATE);
                    else
                        this.CodeGenerator.registerAction(hChart,matlab.internal.editor.figure.ActionID.PANZOOM);





                        if isa(hChart,'matlab.graphics.chart.HeatmapChart')
                            this.UndoRedoManager.registerUndoRedoAction(hChart,matlab.internal.editor.figure.ActionID.PANZOOM);
                        end
                    end
                end
            case{'WindowMouseLeave'}




                sv.notify('ButtonExited');
                return;

            end
            hFig.notify(clientEvent.interaction,evd);
            hFig.Units=oldUnits;
        end

        function legendEdited=processLegendEdited(this,hFig,clientEvent)

            legendEdited=false;
            if~isfield(clientEvent,'legendAxesIndex')||...
                ~isfield(clientEvent,'newText')||...
                ~isfield(clientEvent,'entryIndex')||...
                isempty(clientEvent.entryIndex)
                return
            end



            allCharts=matlab.internal.editor.figure.ChartAccessor.getAllCharts(hFig);

            chartIndex=clientEvent.legendAxesIndex+1;

            if length(allCharts)>=chartIndex
                hChart=allCharts(chartIndex);


                if isempty(this.RegisterUndoRedoAddEditAction)
                    this.RegisterUndoRedoAddEditAction=matlab.internal.editor.figure.RegisterUndoRedoAddEditAction();
                end

                if~isempty(hChart.Legend)








                    newText=clientEvent.newText;
                    if iscellstr(hChart.Legend.String{clientEvent.entryIndex})
                        newText=string(newText);
                        newText=newText.split('\n');
                        newText=cellstr(newText);
                    end



                    warnstate=warning('off','MATLAB:handle_graphics:exceptions:SceneNode');
                    if~isempty(clientEvent.entryIndex)&&~isequal(hChart.Legend.String{clientEvent.entryIndex},newText)


                        existingLegendString=hChart.Legend.String{clientEvent.entryIndex};

                        backtracePrevState=warning('off','backtrace');
                        newLegendString=clientEvent.newText;
                        warning(backtracePrevState);
                        hChart.Legend.String{clientEvent.entryIndex}=strrep(newLegendString,'\n',newline);




                        this.RegisterUndoRedoAddEditAction.registerUndoToolstripActions(chartIndex,hFig,...
                        clientEvent.type,{clientEvent.entryIndex,existingLegendString},...
                        {clientEvent.entryIndex,newLegendString},this.UndoRedoManager,this.CodeGenerator);
                        legendEdited=true;
                        this.registerAction(hChart,matlab.internal.editor.figure.ActionID.LEGEND_EDITED);
                        drawnow update
                    end

                    warning(warnstate);
                end
            end
        end

        function labelEdited=processLabelEdited(this,hFig,clientEvent)

            labelEdited=false;
            if~isfield(clientEvent,'legendAxesIndex')||...
                ~isfield(clientEvent,'newText')
                return
            end

            labelcmd=string(clientEvent.type);
            labelcmd=char(labelcmd.replace('_EDITED','').lower());




            allCharts=matlab.internal.editor.figure.ChartAccessor.getAllCharts(hFig);
            chartIndex=clientEvent.legendAxesIndex+1;

            if length(allCharts)>=chartIndex
                hChart=allCharts(chartIndex);

                existingText='';
                label='';
                switch(labelcmd)
                case 'title'
                    label=matlab.internal.editor.figure.ChartAccessor.getTitleHandle(hChart);
                case 'xlabel'
                    label=matlab.internal.editor.figure.ChartAccessor.getXlabelHandle(hChart);
                case 'ylabel'
                    label=matlab.internal.editor.figure.ChartAccessor.getYlabelHandle(hChart);
                end

                if~isempty(label)
                    existingText=label.String;
                end

                actionID=matlab.internal.editor.figure.ActionID.(clientEvent.type);
                labelAddActionID=string(clientEvent.type).replace('_EDITED','_ADDED');

                if this.CodeGenerator.isActionRegistered(hChart,matlab.internal.editor.figure.ActionID.(labelAddActionID))
                    actionID=matlab.internal.editor.figure.ActionID.(labelAddActionID);
                end



                if isempty(this.RegisterUndoRedoAddEditAction)
                    this.RegisterUndoRedoAddEditAction=matlab.internal.editor.figure.RegisterUndoRedoAddEditAction();
                end

                newText=clientEvent.newText;





                if iscellstr(existingText)
                    newText=string(newText);
                    newText=newText.split('\n');
                    newText=cellstr(newText);
                end



                warnstate=warning('off','MATLAB:handle_graphics:exceptions:SceneNode');
                if~isempty(hChart)&&~isequal(existingText,newText)
                    backtracePrevState=warning('off','backtrace');
                    warning(backtracePrevState);
                    newText=strrep(clientEvent.newText,'\n',newline);
                    feval(labelcmd,hChart,newText);
                    labelEdited=true;




                    this.RegisterUndoRedoAddEditAction.registerUndoToolstripActions(chartIndex,hFig,...
                    actionID,existingText,newText,this.UndoRedoManager,this.CodeGenerator);
                    this.registerAction(hChart,actionID);
                    drawnow update
                end
                warning(warnstate);
            end
        end



        function processAnnotationEdited(this,hFig,clientEvent)

            coordinates=clientEvent.relativePosition;
            coordinates([2,4])=1-coordinates([2,4]);



            [x,y]=clipToFigure(coordinates([1,3]),coordinates([2,4]));


            prevText='';
            prevXPos=this.AnnotationObjectBeingEdited.X;
            prevYPos=this.AnnotationObjectBeingEdited.Y;


            if isequal(clientEvent.editType,'textarrow')
                prevText=this.AnnotationObjectBeingEdited.String;
                set(this.AnnotationObjectBeingEdited,'X',x,'Y',y,'Visible','on','String',clientEvent.editedText);
            else
                set(this.AnnotationObjectBeingEdited,'X',x,'Y',y,'Visible','on');
            end
            drawnow update

            if isempty(this.RegisterUndoRedoAddEditAction)
                this.RegisterUndoRedoAddEditAction=matlab.internal.editor.figure.RegisterUndoRedoAddEditAction();
            end





            this.RegisterUndoRedoAddEditAction.registerUndoToolstripActions(-1,hFig,clientEvent.type,...
            {this.AnnotationObjectBeingEdited,[prevXPos,prevYPos],prevText},...
            {this.AnnotationObjectBeingEdited,[x,y],clientEvent.editedText},this.UndoRedoManager,this.CodeGenerator);

            this.registerAction(hFig,matlab.internal.editor.figure.ActionID.ANNOTATION_EDITED);
            this.registerAction(this.AnnotationObjectBeingEdited,matlab.internal.editor.figure.ActionID.ANNOTATION_EDITED);
        end


        function processClearAnnotation(this,hFig,clientEvent)


            if isempty(this.RegisterUndoRedoClearAction)
                this.RegisterUndoRedoClearAction=matlab.internal.editor.figure.RegisterUndoRedoClearAction();
            end




            this.RegisterUndoRedoClearAction.registerUndoToolstripActions(-1,hFig,'clearannotation',...
            this.AnnotationObjectBeingEdited,'',this.UndoRedoManager,this.CodeGenerator);

            editType=lower(clientEvent.editType);
            switch editType
            case 'undo'
                this.AnnotationObjectBeingEdited.Visible='on';
            case 'delete'







                this.AnnotationObjectBeingEdited.Parent=[];
            end
            drawnow update
            this.registerAction(this.AnnotationObjectBeingEdited,matlab.internal.editor.figure.ActionID.ANNOTATION_REMOVED);
            this.registerAction(hFig,matlab.internal.editor.figure.ActionID.ANNOTATION_REMOVED);
        end


        function figData=transportFigureData(this,hFig,figureID)
            import matlab.internal.editor.figure.FigureDataTransporter
            [generatedCode,isFakeCode]=this.CodeGenerator.generateCode;
            mData=FigureDataTransporter.getFigureMetaData(hFig,generatedCode);

            mData.setFakeCode(isFakeCode);

            figData=FigureDataTransporter.transportFigureData(figureID,mData);
        end




        function registerAction(this,hObj,actionID)
            this.CodeGenerator.registerAction(hObj,actionID);
            this.UndoRedoManager.registerUndoRedoAction(hObj,actionID);
        end
    end

    methods(Hidden)

        function figureData=processClick(this,hFig,clientEvent,figureID)
            import matlab.internal.editor.*

            figureData=[];



            figPosPixels=getpixelposition(hFig);
            eventData.x=clientEvent.x*figPosPixels(3);
            eventData.y=clientEvent.y*figPosPixels(4);

            hFig.CurrentPoint=[eventData.x,eventData.y];
            sv=hg2gcv(hFig);
            drawnow update

            ySv=hFig.Position(4)-eventData.y;
            hitObj=sv.hittest(eventData.x,ySv);


            if isfield(clientEvent,'isInsideLegend')&&clientEvent.isInsideLegend&&...
                isa(hitObj,'matlab.graphics.illustration.Legend')


                pt=hgconvertunits(hFig,[0,0,hFig.CurrentPoint],hFig.Units,'points',hFig);
                figCurrentPoint=pt(3:4);
                [isHit,e]=doMethod(hitObj,'determineItemHitEventData',hFig,figCurrentPoint);

                if isHit&&strcmpi(e.Region,'Label')

                    hTextPrimitive=doMethod(hitObj,'getTextComponentFromItemHit',e);

                    if isempty(hTextPrimitive)
                        return
                    end



                    oldUnits=hTextPrimitive.Units;

                    hTextPrimitive.Units='normalized';
                    parentPos=hgconvertunits(hFig,hTextPrimitive.Parent.Position,hTextPrimitive.Parent.Units,'normalized',hFig);

                    pos=hTextPrimitive.Extent;
                    pos=pos.*[parentPos(3:4),parentPos(3:4)]+[parentPos(1:2),0,0];

                    str=hTextPrimitive.String;
                    if~all(pos(3:4))


                        pos(3:4)=0.01;
                        hTextPrimitive.String=' ';
                    end

                    hTextPrimitive.Units=oldUnits;

                    figureData=matlab.internal.editor.figure.FigureData;
                    figureData.setLegendTextPosition(pos);




                    figureData.setiLegendEntryIndex(e.Item.Index);



                    str=string(str);
                    str=str.join('\n');
                    figureData.setiLegendEntryString(char(str));


                    matlab.internal.editor.figure.FigureDataTransporter.updateModelessData(figureID,figureData);
                else





                    figureData=matlab.internal.editor.figure.FigureData;
                    figureData.setLegendTextPosition(-1*ones(1,4));

                    matlab.internal.editor.figure.FigureDataTransporter.updateModelessData(figureID,figureData);
                end
            elseif isfield(clientEvent,'isInsideAnnotation')&&clientEvent.isInsideAnnotation


                figureData=matlab.internal.editor.figure.FigureData;
                if isa(hitObj,'matlab.graphics.shape.internal.OneDimensional')


                    hitObj.Visible='off';
                    this.AnnotationObjectBeingEdited=hitObj;
                    figureData.setEditedAnnotationPosition([hitObj.X(1),1-hitObj.Y(1),hitObj.X(2),1-hitObj.Y(2)]);
                    figureData.setEditedAnnotationType(hitObj.Type);


                    if isa(hitObj,'matlab.graphics.shape.TextArrow')
                        figureData.setEditedAnnotationText(hitObj.String);
                    end

                    matlab.internal.editor.figure.FigureDataTransporter.updateModelessData(figureID,figureData);
                else






                    figureData.setEditedAnnotationType('');

                    matlab.internal.editor.figure.FigureDataTransporter.updateModelessData(figureID,figureData);
                end
            end
        end
    end
end

function figData=transportFigureDataForRendering(hFig,figureID)

    import matlab.internal.editor.figure.FigureDataTransporter
    figureData=FigureDataTransporter.getFigureMetaData(hFig);
    figData=FigureDataTransporter.transportFigureData(figureID,figureData);
end

function[x,y]=clipToFigure(x,y)




    if min(x)>=0&&max(x)<=1&&min(y)>=0&&max(y)<=1
        return
    end






    yintersect3=inf;
    yintersect1=inf;
    xintersect4=inf;
    xintersect2=inf;
    if abs(x(2)-x(1))>.01
        if any(x>1)
            yintersect3=y(1)+(y(2)-y(1))*(1-x(1))/(x(2)-x(1));
        elseif any(x<0)
            yintersect1=y(1)-(y(2)-y(1))*x(1)/(x(2)-x(1));
        end
    end
    if abs(y(2)-y(1))>.01
        if any(y<0)
            xintersect4=x(1)-(x(2)-x(1))*y(1)/(y(2)-y(1));
        elseif any(y>1)
            xintersect2=x(1)+(x(2)-x(1))*(1-y(1))/(y(2)-y(1));
        end
    end

    if yintersect3>=0&&yintersect3<=1
        I=x>1;
        y(I)=yintersect3;
        x(I)=1;
    end
    if yintersect1>=0&&yintersect1<=1
        I=x<0;
        y(I)=yintersect1;
        x(I)=0;
    end
    if xintersect2>=0&&xintersect2<=1
        I=y>1;
        y(I)=1;
        x(I)=xintersect2;
    end
    if xintersect4>=0&&xintersect4<=1
        I=y<0;
        y(I)=0;
        x(I)=xintersect4;
    end
end
