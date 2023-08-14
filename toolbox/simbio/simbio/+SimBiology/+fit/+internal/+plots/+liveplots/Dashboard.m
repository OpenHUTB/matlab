








classdef Dashboard<handle

    properties(Access=private)

Figure
EstimatedParameterSubPlots
ParentFunctionSubPlots
HybridFunctionSubPlots
StopButton
PauseButton
ProgressBar


Controller


        Pause=false;
        Complete=false;
        ButtonDown=false;


        StartPoint=[];
Rectangle
CurrentSubPlot
        AllowSelection=false;
SelectedIndices
CurrentSelection


ClearSelectionMenu
ExportSelectionMenu


        IsZoomPressed=false;
        IsShiftDown=false;


        IsHybridFunctionDefined=false;


DataCursorMode


StartTime
EndTime
TimeText
InitializingText
    end

    properties(Access=public)

EstimatedParameters
ShowHistogram
NumGroups
FunctionName
HybridFunctionName
        StopEstimation=false;
Bounds
    end

    methods

        function obj=Dashboard(controller,functionName,hybridFunctionName,estimatedParameters,bounds,numGroups)
            obj.Controller=controller;
            obj.FunctionName=functionName;
            obj.HybridFunctionName=hybridFunctionName;
            obj.EstimatedParameters=estimatedParameters;
            obj.ShowHistogram=numGroups>1&&~obj.Controller.SingleFit;
            obj.NumGroups=numGroups;
            obj.Bounds=bounds;
            obj.IsHybridFunctionDefined=~isempty(hybridFunctionName);


            initializePlots(obj);


            addUIControls(obj);


            if isempty(obj.StartTime)
                obj.StartTime=datetime;

                obj.TimeText.String=sprintf('%s \\bf %s \\rm',getString(message('SimBiology:fitplots:LivePlots_FitStartTime')),obj.StartTime);
            end


            drawnow;
        end




        function init(obj,parallel)

            obj.InitializingText.Visible='off';


            if~parallel
                obj.PauseButton.Visible='on';
            end


            if~isempty(obj.ProgressBar)
                obj.ProgressBar.setVisible(true);
            end
        end


        function finishPlotting(obj)
            if~obj.Complete
                obj.Complete=true;


                obj.EndTime=datetime;
                startTimeStr=getString(message('SimBiology:fitplots:LivePlots_FitStartTime'));
                endTimeStr=getString(message('SimBiology:fitplots:LivePlots_FitEndTime'));
                elapsedTimeStr=getString(message('SimBiology:fitplots:LivePlots_ElapsedTime'));
                obj.TimeText.String=sprintf('%s \\bf %s \\rm   %s \\bf %s \\rm    %s \\bf %s \\rm',startTimeStr,obj.StartTime,endTimeStr,obj.EndTime,elapsedTimeStr,obj.EndTime-obj.StartTime);


                obj.cleanup();
                obj.PauseButton.Enable='off';
                obj.StopButton.Enable='off';
                obj.AllowSelection=~obj.IsZoomPressed;
                drawnow;
            end
        end


        function setExitFlag(obj,index,exitFlag)
            obj.ParentFunctionSubPlots.setPlotExitFlag(index,exitFlag);
            obj.EstimatedParameterSubPlots.setPlotExitFlag(index,exitFlag);

            if obj.IsHybridFunctionDefined
                obj.HybridFunctionSubPlots.setPlotExitFlag(index,exitFlag);
            end
        end


        function updatePlots(obj,plotInfo,isHybridFunction)
            if~obj.Complete
                switch plotInfo.State
                case 'init'
                    obj.updatePlotsForInit(plotInfo,isHybridFunction);

                case 'iter'
                    obj.updatePlotsForIter(plotInfo,isHybridFunction);

                case 'done'
                    obj.updatePlotsForDone(plotInfo,isHybridFunction);
                end
                drawnow limitrate;
            end
        end


        function closeFigure(obj)
            if ishandle(obj.Figure)
                delete(obj.Figure);
                obj.Controller.figureClosed();
            end
        end


        function notifyFitStarted(obj)
            if~isempty(obj.ProgressBar)
                obj.ProgressBar.addRunning();
            end
        end


        function notifyFitComplete(obj)
            if~isempty(obj.ProgressBar)
                obj.ProgressBar.addCompleted();
            end
        end
    end



    methods(Access=protected)
        function initializePlots(obj)
            if~obj.IsHybridFunctionDefined
                title=getString(message('SimBiology:fitplots:LivePlots_Title',obj.FunctionName));
            else
                title=getString(message('SimBiology:fitplots:LivePlots_Title_Hybrid',obj.FunctionName,obj.HybridFunctionName));
            end



            monitors=get(groot,'MonitorPositions');
            primary=monitors(monitors(:,1)==1,:);
            primary=primary(1,:);



            width=min(primary(3)-40,1500);
            height=min(primary(4)-40,1000);


            startX=(primary(3)-width)/2;
            startY=(primary(4)-height)/2;


            obj.Figure=figure('Name',title,'OuterPosition',[startX,startY,width,height],'HandleVisibility','off');
            obj.Figure.Tag='LIVE_PLOTS_DO_NOT_DOCK';


            createLivePlots(obj);


            obj.Figure.CloseRequestFcn=@(~,evtObj)obj.close_Callback();
            obj.Figure.WindowButtonMotionFcn=@(~,~)obj.mouseMotion_Callback();
            obj.Figure.WindowButtonUpFcn=@(~,~)obj.buttonUp_Callback();


            obj.Figure.SizeChangedFcn=@(hObject,callbackdata)obj.figureResized_Callback(hObject);


            dataCursor=datacursormode(obj.Figure);
            menuItems=dataCursor.UIContextMenu.Children;
            tags={menuItems.Tag};
            indices=cellfun(@(x)ismember(x,{'DataCursorSelectText','DataCursorEditText'}),tags);

            if~isempty(menuItems(indices))
                set(menuItems(indices),'Visible','off');
            end


            obj.addHitListener();


            set(obj.Figure,'DefaultAxesToolbarVisible','off');
            addToolbarExplorationButtons(obj.Figure);
            isShowHiddenHandles=get(groot,'showHiddenHandles');
            set(groot,'showHiddenHandles','on');
            allAxes=findobj(obj.Figure,'-class','matlab.graphics.axis.Axes');
            set(groot,'showHiddenHandles',isShowHiddenHandles);
            set(allAxes,'Toolbar',[]);
            arrayfun(@(ax)matlab.graphics.interaction.disableDefaultAxesInteractions(ax),allAxes);






        end

        function createLivePlots(obj)


            [numRows,numCols,spans,numParams]=getLayoutParameters(obj);

            rowIndex=1;


            obj.ParentFunctionSubPlots=addFunctionPlots(obj,obj.FunctionName,obj.Controller.SingleFit,numRows,numCols,rowIndex,spans);


            if obj.IsHybridFunctionDefined
                rowIndex=rowIndex+1;
                obj.HybridFunctionSubPlots=addFunctionPlots(obj,obj.HybridFunctionName,false,numRows,numCols,rowIndex,spans);


                for i=1:numel(obj.ParentFunctionSubPlots)
                    plotObj=obj.ParentFunctionSubPlots(i);
                    plotObj.Axes.Title.String=getString(message('SimBiology:fitplots:LivePlots_Function_Plots_Title',plotObj.Axes.Title.String,obj.FunctionName));
                end

                for i=1:numel(obj.HybridFunctionSubPlots)
                    plotObj=obj.HybridFunctionSubPlots(i);
                    plotObj.Axes.Title.String=getString(message('SimBiology:fitplots:LivePlots_Function_Plots_Title',plotObj.Axes.Title.String,obj.HybridFunctionName));
                end
            end


            rowIndex=rowIndex+1;
            columnIndex=0;


            showYLabel=true;
            obj.EstimatedParameterSubPlots=SimBiology.fit.internal.plots.liveplots.AbstractPlot.empty;
            for i=1:numParams
                columnIndex=columnIndex+1;
                if columnIndex>numCols
                    columnIndex=1;
                    rowIndex=rowIndex+1;
                    showYLabel=true;
                end
                showHistLabel=columnIndex==numCols||columnIndex==numParams;

                obj.EstimatedParameterSubPlots(end+1)=SimBiology.fit.internal.plots.liveplots.EstimatedParameterPlot(i,showYLabel,showHistLabel,obj,numRows,numCols,spans{rowIndex}{columnIndex},obj.Figure,{obj.FunctionName,obj.HybridFunctionName});
                showYLabel=false;
            end


            isShowHiddenHandles=get(groot,'showHiddenHandles');
            set(groot,'showHiddenHandles','on');
            allAxes=findobj(obj.Figure,'-class','matlab.graphics.axis.Axes');
            set(groot,'showHiddenHandles',isShowHiddenHandles);
            set(allAxes,'Toolbar',[]);
            arrayfun(@(ax)matlab.graphics.interaction.disableDefaultAxesInteractions(ax),allAxes);

        end

        function plotObjs=addFunctionPlots(obj,functionName,singleFit,numRows,numCols,rowIndex,spans)
            columnIndex=1;

            plotObjs=SimBiology.fit.internal.plots.liveplots.LogLikelihoodPlot(singleFit,functionName,numRows,numCols,spans{rowIndex}{columnIndex},obj.Figure);


            if ismember(functionName,{'lsqcurvefit','lsqnonlin','fmincon','fminunc'})

                columnIndex=columnIndex+1;
                plotObjs(end+1)=SimBiology.fit.internal.plots.liveplots.FirstOrderOptimalityPlot(numRows,numCols,spans{rowIndex}{columnIndex},obj.Figure);
            end


            if~obj.Controller.SingleFit&&~strcmp(functionName,obj.HybridFunctionName)
                columnIndex=columnIndex+1;
                plotObjs(end+1)=SimBiology.fit.internal.plots.liveplots.TerminationConditionHistogram(obj,numRows,numCols,spans{rowIndex}{columnIndex},obj.Figure);
            end


            isShowHiddenHandles=get(groot,'showHiddenHandles');
            set(groot,'showHiddenHandles','on');
            allAxes=findobj(obj.Figure,'-class','matlab.graphics.axis.Axes');
            set(groot,'showHiddenHandles',isShowHiddenHandles);
            set(allAxes,'Toolbar',[]);
            arrayfun(@(ax)matlab.graphics.interaction.disableDefaultAxesInteractions(ax),allAxes);
        end

        function addHitListener(obj)
            allPlots=[obj.ParentFunctionSubPlots,obj.HybridFunctionSubPlots,obj.EstimatedParameterSubPlots];
            for i=1:numel(allPlots)
                axes=allPlots(i).Axes;
                addlistener(axes,'Hit',@(~,evd)buttonDown_Callback(obj,allPlots(i),evd));
            end
        end

        function cleanup(obj)


            try
                obj.ParentFunctionSubPlots.cleanupPlots();
                obj.EstimatedParameterSubPlots.cleanupPlots();

                if obj.IsHybridFunctionDefined
                    obj.HybridFunctionSubPlots.cleanupPlots();
                end
            catch
            end
        end

        function setSelectedLines(obj,indices)
            obj.ParentFunctionSubPlots.setPlotSelectedLines(indices);
            obj.EstimatedParameterSubPlots.setPlotSelectedLines(indices);

            if obj.IsHybridFunctionDefined
                obj.HybridFunctionSubPlots.setPlotSelectedLines(indices);
            end
        end

        function clearSelectedLines(obj)
            obj.ParentFunctionSubPlots.clearPlotSelectedLines();
            obj.EstimatedParameterSubPlots.clearPlotSelectedLines();

            if obj.IsHybridFunctionDefined
                obj.HybridFunctionSubPlots.clearPlotSelectedLines();
            end
        end




        function updatePlotsForInit(obj,plotInfo,isHybridFunction)
            if~isHybridFunction

                obj.ParentFunctionSubPlots.addPlotContent(plotInfo);
                obj.EstimatedParameterSubPlots.addPlotContent(plotInfo);


                obj.ParentFunctionSubPlots.updatePlotContent(plotInfo);
                obj.EstimatedParameterSubPlots.updatePlotContent(plotInfo);

            else

                obj.HybridFunctionSubPlots.addPlotContent(plotInfo);
                obj.HybridFunctionSubPlots.updatePlotContent(plotInfo);
            end
        end




        function updatePlotsForIter(obj,plotInfo,isHybridFunction)
            if~isHybridFunction

                obj.ParentFunctionSubPlots.updatePlotContent(plotInfo);
                obj.EstimatedParameterSubPlots.updatePlotContent(plotInfo);
            else
                obj.HybridFunctionSubPlots.updatePlotContent(plotInfo);
                obj.EstimatedParameterSubPlots.updatePlotContent(plotInfo);
            end
        end




        function updatePlotsForDone(obj,plotInfo,isHybridFunction)
            if~isHybridFunction

                obj.ParentFunctionSubPlots.fadePlotContent(plotInfo);



                if~obj.IsHybridFunctionDefined
                    obj.EstimatedParameterSubPlots.fadePlotContent(plotInfo);
                end

            else

                obj.HybridFunctionSubPlots.fadePlotContent(plotInfo);
                obj.EstimatedParameterSubPlots.fadePlotContent(plotInfo);
            end
        end




        function out=tooltip_Callback(obj,eventObj)
            lineObj=eventObj.Target(1);
            userData=num2str(lineObj.UserData);
            if obj.Controller.SingleFit
                out=getString(message('SimBiology:fitplots:LivePlots_DataCursor_Label_Pooled',num2str(eventObj.Position(1)),num2str(eventObj.Position(2))));
            else
                out=getString(message('SimBiology:fitplots:LivePlots_DataCursor_Label_UnPooled',userData,num2str(eventObj.Position(1)),num2str(eventObj.Position(2))));
            end
        end

        function addUIControls(obj)
            stopString=getString(message('SimBiology:fitplots:LivePlots_Stop'));
            pauseString=getString(message('SimBiology:fitplots:LivePlots_Pause'));

            obj.StopButton=uicontrol('Style','pushbutton','String',stopString,'Position',[10,9,50,25],'Tag','LivePlots_StopButton','Parent',obj.Figure);
            obj.PauseButton=uicontrol('Style','pushbutton','String',pauseString,'Position',[60,9,50,25],'Visible','off','Tag','LivePlots_PauseButton','Parent',obj.Figure);

            obj.StopButton.Callback=@(button,eventdata,handles)stop_Callback(obj);
            obj.PauseButton.Callback=@(button,eventdata,handles)pause_Callback(obj);


            if feature('SimBioLivePlotsMenu')
                tools=uimenu('Label','Live Plot Tools','Parent',obj.Figure);
                obj.ClearSelectionMenu=uimenu(tools,'Label','Clear Selection','Callback',@(eventObj,eventData)clearSelection_Callback(obj),'Enable','off');
                obj.ExportSelectionMenu=uimenu(tools,'Label','Export Selected Groups','Callback',@(eventObj,eventData)exportSelection_Callback(obj),'Enable','off');
                uimenu(tools,'Label','Export Failed Groups','Callback',@(eventObj,eventData)exportFailed_Callback(obj));
            end



            pos=getpixelposition(obj.Figure);
            if~obj.Controller.SingleFit

                progressBarPosition=[pos(3)-250,3,175,55];

                obj.ProgressBar=SimBiology.fit.internal.plots.liveplots.ProgressBar(obj.Figure,'pixels',progressBarPosition,obj.NumGroups,[],'BaT');
                obj.ProgressBar.setVisible(false);
            end


            textPosition=[pos(3)-240,10,120,30];
            initializingString=getString(message('SimBiology:fitplots:LivePlots_Dashboard_Initializing'));
            obj.InitializingText=uicontrol('Style','text','String',initializingString,'FontSize',18,'FontAngle','italic','Position',textPosition,'Tag','LivePlots_InitializingTextField','Parent',obj.Figure);




            labelAxes=axes('Parent',obj.Figure,'Units','pixels','Position',[150,14,300,15],'Visible','off','Tag','LivePlots_EstimatedTime');
            labelAxes.XAxis.Visible='off';
            labelAxes.YAxis.Visible='off';
            labelAxes.Color=obj.Figure.Color;
            obj.TimeText=text(0,0.5,'','Parent',labelAxes,'Interpreter','tex','Tag','LivePlots_TimeText');


            cursorObj=datacursormode(obj.Figure);
            cursorObj.UpdateFcn=@(~,evtObj)obj.tooltip_Callback(evtObj);

            addToolbarExplorationButtons(obj.Figure);
            set(obj.Figure,'DefaultAxesToolbarVisible','off');


            h=findall(obj.Figure,'tag','FigureToolBar');
            btns=findall(h);
            zoomOut=findobj(btns,'flat','Tag','Exploration.ZoomOut');
            zoomOut.ClickedCallback=@(~,evtObj)obj.zoomCallback(evtObj,'zoomout');

            zoomIn=findobj(btns,'flat','Tag','Exploration.ZoomIn');
            zoomIn.ClickedCallback=@(~,evtObj)obj.zoomCallback(evtObj,'zoomin');

            brushing=findobj(btns,'flat','Tag','Exploration.Brushing');
            brushing.Enable='off';



            obj.Figure.WindowKeyPressFcn=@(h_obj,evt)obj.keyPress_Callback(evt.Key);
            obj.Figure.WindowKeyReleaseFcn=@(h_obj,evt)obj.keyRelease_Callback(evt.Key);
        end

        function close_Callback(obj)
            if~obj.Complete
                messageStr=getString(message('SimBiology:fitplots:LivePlots_Close_Figure_Message'));
                title=getString(message('SimBiology:fitplots:LivePlots_Close_Figure_Title'));
                yesStr=getString(message('SimBiology:fitplots:LivePlots_Dashboard_Yes'));
                noStr=getString(message('SimBiology:fitplots:LivePlots_Dashboard_No'));
                choice=questdlg(messageStr,title,yesStr,noStr,noStr);


                switch choice
                case 'Yes'
                    obj.closeFigure();
                case 'No'
                    return;
                end
            else
                obj.closeFigure();
            end
        end

        function stop_Callback(obj)
            obj.PauseButton.Enable='off';
            obj.StopButton.Enable='off';
            obj.StopEstimation=true;

            if~isempty(obj.Controller)
                stop(obj.Controller);
            end
        end

        function pause_Callback(obj)
            if obj.Pause

                obj.PauseButton.String=getString(message('SimBiology:fitplots:LivePlots_Pause'));
                obj.Pause=false;
            else

                obj.PauseButton.String=getString(message('SimBiology:fitplots:LivePlots_Resume'));
                obj.Pause=true;
            end



            while obj.Pause
                drawnow limitrate;
                pause(0.05);
                if obj.StopEstimation
                    break
                end
            end
        end

        function keyPress_Callback(obj,key)
            if strcmp(key,'shift')
                obj.IsShiftDown=true;
            end
        end

        function keyRelease_Callback(obj,key)
            if strcmp(key,'shift')
                obj.IsShiftDown=false;
            end
        end



        function buttonDown_Callback(obj,subplot,evd)
            if obj.AllowSelection

                if~obj.IsShiftDown
                    obj.clearSelection_Callback();
                end

                axes=subplot.Axes;
                obj.ButtonDown=true;
                obj.Rectangle=rectangle('Parent',axes,'Visible','off');
                obj.StartPoint=evd.IntersectionPoint(1:2);
                obj.CurrentSubPlot=subplot;


                axes.XLimMode='manual';
                axes.YLimMode='manual';



                cursorObj=datacursormode(obj.Figure);
                obj.DataCursorMode=cursorObj.Enable;
                cursorObj.Enable='off';
            end
        end


        function mouseMotion_Callback(obj)
            if obj.ButtonDown&&obj.AllowSelection&&~isempty(obj.CurrentSubPlot)


                cp=obj.CurrentSubPlot.Axes.CurrentPoint(1,1:2)';

                if isempty(obj.StartPoint)
                    obj.StartPoint=cp;
                end

                sp=obj.StartPoint;

                xmin=min([sp(1),cp(1)]);
                xmax=max([sp(1),cp(1)]);
                ymin=min([sp(2),cp(2)]);
                ymax=max([sp(2),cp(2)]);

                obj.Rectangle.Position=[xmin,ymin,xmax-xmin,ymax-ymin];
                obj.Rectangle.Visible='on';




                obj.CurrentSelection=obj.CurrentSubPlot.getLineIndexForSelection([xmin,xmax,ymin,ymax]);
                if~isempty(obj.CurrentSelection)
                    obj.setSelectedLines(horzcat(obj.SelectedIndices,obj.CurrentSelection));
                else
                    obj.setSelectedLines(horzcat(obj.SelectedIndices));
                end
            end
        end


        function buttonUp_Callback(obj)
            if obj.Complete
                obj.ButtonDown=false;
                obj.AllowSelection=true;

                if ishandle(obj.Rectangle)

                    if~isempty(obj.CurrentSelection)
                        obj.SelectedIndices=horzcat(obj.SelectedIndices,obj.CurrentSelection);
                        obj.setSelectedLines(obj.SelectedIndices);
                    end

                    obj.CurrentSelection=[];
                    delete(obj.Rectangle);
                end

                if~isempty(obj.SelectedIndices)

                    obj.ClearSelectionMenu.Enable='on';
                    obj.ExportSelectionMenu.Enable='on';
                else
                    obj.ClearSelectionMenu.Enable='off';
                    obj.ExportSelectionMenu.Enable='off';
                end

                if~isempty(obj.DataCursorMode)
                    cursorObj=datacursormode(obj.Figure);
                    cursorObj.Enable=obj.DataCursorMode;
                end
            end
        end


        function clearSelection_Callback(obj)
            if~isempty(obj.CurrentSubPlot)
                axes=obj.CurrentSubPlot.Axes;
                if~isempty(axes)&&~obj.isPlotZoomed(axes)
                    axes.XLimMode='auto';
                    axes.YLimMode='auto';
                end

                obj.StartPoint=[];
                obj.CurrentSubPlot=[];
                obj.SelectedIndices=[];
            end

            obj.ClearSelectionMenu.Enable='off';
            obj.ExportSelectionMenu.Enable='off';
            obj.clearSelectedLines();
        end

        function exportSelection_Callback(obj)

            assignin('base','groupNumbers',obj.SelectedIndices);
        end

        function exportFailed_Callback(obj)
            indices=obj.Controller.getFailedIndices();


            assignin('base','failedGroupNumbers',indices);
        end


        function figureResized_Callback(obj,hObject)
            if~isempty(obj.ParentFunctionSubPlots)
                obj.ParentFunctionSubPlots.notifyFigureResized(hObject);
            end

            if~isempty(obj.EstimatedParameterSubPlots)
                obj.EstimatedParameterSubPlots.notifyFigureResized(hObject);
            end

            if~isempty(obj.ProgressBar)
                obj.ProgressBar.figureResized(hObject);
            end

            if obj.IsHybridFunctionDefined&&~isempty(obj.HybridFunctionSubPlots)
                obj.HybridFunctionSubPlots.notifyFigureResized(hObject);
            end
        end
    end

    methods(Access=private)




        function[numRows,numCols,spans,numParams]=getLayoutParameters(obj)
            numParams=numel(obj.EstimatedParameters);

            numFunctionPlots=3;
            if~isempty(find(ismember({'fminsearch','patternsearch','ga','particleswarm','scattersearch'},obj.FunctionName),1))
                numFunctionPlots=2;
            end


            numHybridFunctionPlots=0;
            if obj.IsHybridFunctionDefined

                if~isempty(find(ismember({'fminsearch','patternsearch'},obj.HybridFunctionName),1))
                    numHybridFunctionPlots=1;
                else
                    numHybridFunctionPlots=2;
                end
            end


            if obj.Controller.SingleFit
                numFunctionPlots=numFunctionPlots-1;
            end




            maxPlotsPerRow=4;
            if obj.Controller.SingleFit
                maxPlotsPerRow=6;
            end

            numFuncRows=1;
            if obj.IsHybridFunctionDefined
                numFuncRows=2;
            end

            numRows=numFuncRows+ceil(numParams/maxPlotsPerRow);
            numCols=max(maxPlotsPerRow,max(numFunctionPlots,numHybridFunctionPlots));


            paramPlotsStartRow=2;
            if obj.IsHybridFunctionDefined
                paramPlotsStartRow=3;
            end


            spans=cell(numRows,1);
            for rowNumber=1:numRows
                if(rowNumber==1)
                    numPlots=numFunctionPlots;
                elseif rowNumber==2&&obj.IsHybridFunctionDefined
                    numPlots=numHybridFunctionPlots;
                else
                    numPlots=min(numParams-((rowNumber-paramPlotsStartRow)*maxPlotsPerRow),maxPlotsPerRow);
                end

                spans{rowNumber}=obj.getSpans(numCols,numPlots,rowNumber);
            end
        end





        function spans=getSpans(~,numCols,numPlots,rowNumber)
            spans=cell(1,numPlots);
            numSpansCalculated=0;
            spanOffset=((rowNumber-1)*numCols);
            spanStart=1;
            spaceAvailable=numCols;

            for i=1:numel(spans)
                spanWidth=ceil(spaceAvailable/(numPlots-numSpansCalculated));
                spanEnd=spanStart+spanWidth-1;
                spans{i}=[(spanStart+spanOffset),(spanEnd+spanOffset)];
                spaceAvailable=numCols-spanEnd;
                numSpansCalculated=numSpansCalculated+1;
                spanStart=spanEnd+1;
            end
        end

        function zoomCallback(obj,evtObj,zoomStr)
            zoomBtn=evtObj.Source;
            putdowntext(zoomStr,zoomBtn);
            if obj.Complete&&strcmp(zoomBtn.State,'off')
                obj.AllowSelection=true;
                obj.IsZoomPressed=false;
            else
                obj.AllowSelection=false;
                obj.IsZoomPressed=true;
            end
        end

        function isZoomed=isPlotZoomed(~,axes)
            origInfo=getappdata(axes,'zoom_zoomOrigAxesLimits');
            if isempty(origInfo)
                isZoomed=false;
            elseif isequal(get(axes,'XLim'),[origInfo(1),origInfo(2)])&&isequal(get(axes,'YLim'),[origInfo(3),origInfo(4)])&&isequal(get(axes,'ZLim'),[origInfo(5),origInfo(6)])
                isZoomed=false;
            else
                isZoomed=true;
            end
        end
    end
end

