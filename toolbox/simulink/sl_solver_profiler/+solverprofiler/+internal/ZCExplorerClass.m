classdef ZCExplorerClass<handle

    properties(SetAccess=private)













AppContainer
ToolStrip
Document
AppData
    end


    methods


        function obj=ZCExplorerClass(mdl,zcInfo,tSpan,tBound)
            import matlab.ui.internal.*
            import solverprofiler.internal.ZCExplorerToolstripClass;
            import solverprofiler.internal.ZCExplorerDocumentClass;
            import solverprofiler.internal.ZCExplorerDataClass;


            [~,randomName,~]=fileparts(tempname);
            appOptions.Tag=randomName;
            appOptions.Title=[obj.DAGetString('ZCExplorer'),': ',mdl,'- zero crossing signal'];
            obj.AppContainer=matlab.ui.container.internal.AppContainer(appOptions);


            obj.AppContainer.WindowBounds=[100,100,1200,800];





            arch=computer('arch');
            if strcmp(arch,'win32')||strcmp(arch,'win64')
                filename=fullfile(matlabroot,'toolbox','simulink',...
                'sl_solver_profiler','+solverprofiler','icons',...
                'spicon_states_explorer_16.ico');
            else
                filename=fullfile(matlabroot,'toolbox','simulink',...
                'sl_solver_profiler','+solverprofiler','icons',...
                'spicon_states_explorer_16.png');
            end





            obj.AppContainer.Icon=filename;




            obj.ToolStrip=ZCExplorerToolstripClass(obj.AppContainer,tSpan);


            obj.AppContainer.Visible=true;


            obj.Document=ZCExplorerDocumentClass(obj.AppContainer);


            obj.AppData=ZCExplorerDataClass(mdl,zcInfo,tSpan,tBound);


            obj.AppData.sortSignals();
            tableContent=obj.AppData.createTableContent();
            obj.Document.populate(tableContent,{'number','signal'});


            obj.ToolStrip.attachCallback('FromTextbox',...
            'ValueChangedFcn',@obj.fromCallback);
            obj.ToolStrip.attachCallback('ToTextbox',...
            'ValueChangedFcn',@obj.toCallback);
            obj.ToolStrip.attachCallback('ZoomInButton',...
            'ValueChangedFcn',@obj.zoomInCallback);
            obj.ToolStrip.attachCallback('ZoomOutButton',...
            'ValueChangedFcn',@obj.zoomOutCallback);
            obj.ToolStrip.attachCallback('PanButton',...
            'ValueChangedFcn',@obj.panCallback);
            obj.ToolStrip.attachCallback('EventCheckbox',...
            'ValueChangedFcn',@obj.eventCheckboxCallback);
            obj.ToolStrip.attachCallback('GoToFileButton',...
            'ButtonPushedFcn',@obj.goToFileCallback);
            obj.ToolStrip.attachCallback('HiliteButton',...
            'ButtonPushedFcn',@obj.highlightCallback);
            obj.ToolStrip.attachCallback('RemoveButton',...
            'ButtonPushedFcn',@obj.removeTraceCallback);
            obj.ToolStrip.attachCallback('TraceSrcButton',...
            'ButtonPushedFcn',@obj.traceCallback);
            obj.ToolStrip.attachCallback('NewPlotButton',...
            'ButtonPushedFcn',@obj.generateNewPlot);


            obj.Document.attachDataCursorCallback(@obj.dataCursorUpdateFcn);


            obj.Document.attachFigureZoomPanPostCallback(@obj.figureZoomPanCallback);


            obj.Document.attachUITableSelectionCallback(@obj.signalTableCallback);



            addlistener(obj.AppContainer,'StateChanged',@obj.appCloseCallback);


            obj.signalTableCallback(1);

        end


        function appCloseCallback(obj,~,~)
            if obj.AppContainer.State==...
                matlab.ui.container.internal.appcontainer.AppState.TERMINATED
                obj.delete();
            end
        end


        function delete(obj)
            obj.ToolStrip.delete;
            obj.Document.delete
            obj.AppData.delete;
            obj.AppContainer.delete;
        end


        function value=getData(obj,name)
            value=obj.(name);
        end


        function moveFocusToZCExplorer(obj)
            obj.AppContainer.bringToFront;
        end


        function refresh(obj,zcInfo,tSpan,tBound)

            obj.AppData.resetData(zcInfo,tSpan,tBound);


            obj.AppData.sortSignals();
            tableContent=obj.AppData.createTableContent();
            obj.Document.populate(tableContent,{'number','signal'});



            obj.Document.attachUITableSelectionCallback(@obj.signalTableCallback);


            obj.ToolStrip.setFromTime(tSpan(1));
            obj.ToolStrip.setToTime(tSpan(2));


            obj.signalTableCallback(1);
        end


        function signalTableCallback(obj,stateIdx,evt)
            import solverprofiler.util.*

            if(~isnumeric(stateIdx))
                if isempty(evt.DisplayIndices)
                    return;
                end
                stateIdx=evt.DisplayIndices(1);
            end

            if(stateIdx<=0)
                return;
            end


            if(obj.Document.isHighlightedRow(stateIdx))
                return;
            end

            obj.Document.highlightRow(stateIdx);


            obj.AppData.setData('SigSelected',stateIdx);


            TLeft=obj.AppData.getData('TLeft');
            TRight=obj.AppData.getData('TRight');
            if TLeft>=TRight,return;end

            blkName=obj.AppData.getBlockNameOfSelectedSignal();
            if utilIsBlockValidForTrace(blkName)
                obj.ToolStrip.enableTrace();
            else
                obj.ToolStrip.disableTrace();
            end

            fileLocation=obj.AppData.getLocationTagOfSelectedSignal();
            if(~isempty(fileLocation))
                tokens=textscan(fileLocation,'%s%d%d','Delimiter',',');
                fileName=tokens{1}{1};
                if exist(which(fileName),'file')
                    obj.ToolStrip.enableGoToFileButton();
                else
                    obj.ToolStrip.disableGoToFileButton();
                end
            else
                obj.ToolStrip.disableGoToFileButton();
            end


            hValueAxes=obj.Document.getValuePlot();
            sigName=obj.AppData.getSelectedSignalName();
            hVal=findobj(hValueAxes,'Tag','value');
            [time,value]=obj.AppData.getSelectedSignalValue();

            if isempty(time)

                if~isempty(hVal)
                    hVal.XData=[];
                    hVal.YData=[];
                end
                title(hFig,sigName)
            else
                if~isempty(hVal)
                    hVal.XData=time;
                    hVal.YData=value;
                    ylim(hValueAxes,'auto');
                else
                    hold(hValueAxes,'off');
                    plot(hValueAxes,time,value,'Tag','value');
                end
            end


            if obj.ToolStrip.isEventCheckboxSelected()
                obj.markZCPoints();
            end

            span=TRight-TLeft;
            xlim(hValueAxes,[TLeft-0.025*span,TRight+0.025*span]);
            ylabel(hValueAxes,obj.DAGetString('signalValue'));
            xlabel(hValueAxes,obj.DAGetString('plotXLabel'));
            grid(hValueAxes,'on');
            title(hValueAxes,texlabel(sigName,'literal'));


            hDensityAxes=obj.Document.getDensityPlot();
            [time,~]=obj.AppData.getSelectedSignalEvents();
            histogram(hDensityAxes,time);

            hDensityAxes.XLim=[TLeft-0.025*span,TRight+0.025*span];
            hDensityAxes.YLim(2)=hDensityAxes.YLim(2)+0.1*diff(hDensityAxes.YLim);
            obj.Document.updateDensityPlotBinWidth();
            ylabel(hDensityAxes,obj.DAGetString('eventDensity'));
            xlabel(hDensityAxes,obj.DAGetString('plotXLabel'));
            grid(hDensityAxes,'on');


            hValueAxes.Toolbar.Visible='off';
            hDensityAxes.Toolbar.Visible='off';
        end


        function markZCPoints(obj)
            hAxes=obj.Document.getValuePlot();
            [time,value]=obj.AppData.getSelectedSignalEvents();
            hEvt=findobj(hAxes,'Tag','events');

            if~isempty(time)
                if~isempty(hEvt)
                    hEvt.XData=time;
                    hEvt.YData=value;
                else
                    hold(hAxes,'on');
                    plot(hAxes,time,value,'r.','markersize',20,'Tag','events');
                    hold(hAxes,'off');
                end
            else
                obj.removeZCPoints();
            end
        end


        function removeZCPoints(obj)
            hAxes=obj.Document.getValuePlot();
            hEvt=findobj(hAxes,'Tag','events');
            if~isempty(hEvt)
                hEvt.XData=[];
                hEvt.YData=[];
            end
        end


        function generateNewPlot(obj,~,~)
            fig=obj.Document.getFigureHandle();



            menus=findall(fig,'Type','UIContextMenu');
            parents=[];
            for i=1:length(menus)
                parents(i)=menus(i).Parent;
                menus(i).Parent=[];
            end

            fnew=figure;
            copyobj(allchild(fig),fnew);


            for i=1:length(menus)
                menus(i).Parent=parents(i);
            end
        end


        function eventCheckboxCallback(obj,~,evt)
            if(evt.EventData.NewValue)
                obj.markZCPoints();
            else
                obj.removeZCPoints();
            end
        end


        function panCallback(obj,~,evt)
            if(evt.EventData.NewValue)
                obj.Document.turnOnPan();
                obj.ToolStrip.unselectZoomIn();
                obj.ToolStrip.unselectZoomOut();
            else
                obj.Document.turnOffPan();
                obj.Document.enableDataCursor()
            end
        end

        function zoomOutCallback(obj,~,evt)
            if(evt.EventData.NewValue)
                obj.Document.turnOnZoom('out');
                obj.ToolStrip.unselectPan();
                obj.ToolStrip.unselectZoomIn();
            else
                obj.Document.turnOffZoom();
                obj.Document.enableDataCursor()
            end
        end

        function zoomInCallback(obj,~,evt)
            if(evt.EventData.NewValue)
                obj.Document.turnOnZoom('in');
                obj.ToolStrip.unselectPan();
                obj.ToolStrip.unselectZoomOut();
            else
                obj.Document.turnOffZoom();
                obj.Document.enableDataCursor()
            end
        end


        function goToFileCallback(obj,~,~)
            fileLocation=obj.AppData.getLocationTagOfSelectedSignal();
            tokens=textscan(fileLocation,'%s%d%d','Delimiter',',');
            fileName=tokens{1}{1};
            fileRow=tokens{2};
            fileCol=tokens{3};
            opentoline(which(fileName),fileRow,fileCol);
        end


        function highlightCallback(obj,~,~)
            hilitePath=obj.AppData.getBlockNameOfSelectedSignal();
            if isempty(hilitePath)
                return;
            end


            obj.removeTraceCallback([],[]);


            obj.AppData.setData('HiliteTraceBlock',hilitePath);


            w=warning('query','Simulink:blocks:HideContents');
            oldWarnState=w.state;
            warning('off','Simulink:blocks:HideContents');


            indices=strfind(hilitePath,'|');
            if isempty(indices)
                hilite_system(hilitePath,'find');
            else
                try
                    indices=[0,indices,length(hilitePath)+1];
                    for i=1:length(indices)-1
                        currentPath=hilitePath(indices(i)+1:indices(i+1)-1);

                        nindices=strfind(currentPath,'/');
                        load_system(currentPath(1:nindices(1)-1));
                        hilite_system(hilitePath(indices(i)+1:indices(i+1)-1),'find')
                    end
                catch
                    try
                        hilite_system(hilitePath(1:indices(2)-1),'find');
                    catch
                        warning(oldWarnState,'Simulink:blocks:HideContents');
                    end
                end
            end

            warning(oldWarnState,'Simulink:blocks:HideContents');
            obj.ToolStrip.enableRemoveButton();
        end


        function removeTraceCallback(obj,~,~)

            blockName=obj.AppData.getData('HiliteTraceBlock');
            if isempty(blockName),return;end


            indices=strfind(blockName,'|');
            if~isempty(indices)
                indices=[0,indices,length(blockName)+1];
                for i=1:length(indices)-1
                    currentPath=blockName(indices(i)+1:indices(i+1)-1);
                    nindices=strfind(currentPath,'/');
                    load_system(currentPath(1:nindices(1)-1));
                    set_param(currentPath(1:nindices(1)-1),'HiliteAncestors','off');
                    bdHandle=get_param(currentPath(1:nindices(1)-1),'Handle');
                    Simulink.Structure.HiliteTool.AppManager.removeAdvancedHighlighting(bdHandle);
                end
            end

            set_param(obj.AppData.getData('Model'),'HiliteAncestors','off');
            bdHandle=get_param(obj.AppData.getData('Model'),'Handle');
            Simulink.Structure.HiliteTool.AppManager.removeAdvancedHighlighting(bdHandle);


            obj.AppData.setData('HiliteTraceBlock',[]);
            obj.ToolStrip.disableRemoveButton();
        end

        function traceCallback(obj,~,~)
            traceCallbackModelRefStudioReuse(obj);
        end

        function traceCallbackModelRefStudioReuse(obj,~,~)
            blockName=obj.AppData.getBlockNameOfSelectedSignal();
            if isempty(blockName)
                return;
            end


            hilitePath=blockName;
            bp=[];%#ok

            indices=strfind(blockName,'|');
            if~isempty(indices)
                indices=[0,indices,length(blockName)+1];
                numOfLevels=length(indices)-1;
                blockPathsToTargetBlock=cell(1,numOfLevels);
                for i=1:length(indices)-1
                    currentPath=blockName(indices(i)+1:indices(i+1)-1);
                    blockPathsToTargetBlock{i}=currentPath;
                end
                blockName=blockName(indices(end-1)+1:end);
                bp=Simulink.BlockPath(blockPathsToTargetBlock);
            else
                bp=Simulink.BlockPath(blockName);
            end
            blockHandle=get_param(blockName,'Handle');

            if~isempty(blockName)
                obj.removeTraceCallback([],[]);
            else
                return;
            end

            if~isempty(blockHandle)
                Simulink.Structure.HiliteTool.AppManager.HighlightFromBlock(bp);

                obj.AppData.setData('HiliteTraceBlock',hilitePath);
            end

            obj.ToolStrip.enableRemoveButton();
        end


        function fromCallback(obj,src,~)
            import solverprofiler.util.*
            toTextboxValue=obj.ToolStrip.getToTextboxValue();
            tBound=obj.AppData.getData('TBound');
            oldValue=obj.AppData.getData('TLeft');


            fromVal=utilGetScalarValue(src.Text);
            if~isnumeric(fromVal)
                src.Text=num2str(oldValue);
                utilPopWarnDlg(obj.DAGetString('rankRangeInvalid'),...
                'zcexplorer:rankRangeInvalid');
                return;
            end


            if fromVal<tBound(1)
                src.Text=num2str(tBound(1));
            end


            if fromVal>=toTextboxValue
                src.Text=num2str(oldValue);
                utilPopWarnDlg(obj.DAGetString('rankRangeInvalid'),...
                'zcexplorer:rankRangeInvalid');
                return;
            end

            obj.reSortSignalTable();
        end


        function toCallback(obj,src,~)
            import solverprofiler.util.*
            fromTextboxValue=obj.ToolStrip.getFromTextboxValue();
            tBound=obj.AppData.getData('TBound');
            oldValue=obj.AppData.getData('TRight');


            toVal=utilGetScalarValue(src.Text);
            if~isnumeric(toVal)
                src.Text=num2str(oldValue);
                utilPopWarnDlg(obj.DAGetString('rankRangeInvalid'),...
                'zcexplorer:rankRangeInvalid');
                return;
            end


            if toVal>tBound(2)
                src.Text=num2str(tBound(2));
            end


            if toVal<=fromTextboxValue
                src.Text=num2str(oldValue);
                utilPopWarnDlg(obj.DAGetString('rankRangeInvalid'),...
                'zcexplorer:rankRangeInvalid');
                return;
            end

            obj.reSortSignalTable();
        end


        function reSortSignalTable(obj)
            fromTextboxValue=obj.ToolStrip.getFromTextboxValue();
            toTextboxValue=obj.ToolStrip.getToTextboxValue();
            tBound=obj.AppData.getData('TBound');


            if fromTextboxValue>tBound(2)||toTextboxValue<tBound(1)||...
                fromTextboxValue>=toTextboxValue

                warndlg(obj.DAGetString('rankRangeInvalid'));
                return;
            end

            obj.AppData.setData('TLeft',fromTextboxValue);
            obj.AppData.setData('TRight',toTextboxValue);


            sigIdx=obj.AppData.getSelectedSignalIdx();


            obj.AppData.sortSignals();
            tableContent=obj.AppData.createTableContent();
            obj.Document.populate(tableContent,{'number','signal'});


            obj.Document.attachUITableSelectionCallback(@obj.signalTableCallback);


            index=obj.AppData.getRowIndexInRankedSignalIndexList(sigIdx);


            obj.signalTableCallback(index);
        end


        function txt=dataCursorUpdateFcn(obj,~,evt)
            pos=get(evt,'Position');
            time=pos(1);
            if strcmp(evt.Target.Tag,'events')
                type=obj.AppData.getSelectedCrossingType(time);
                txt={
                ['Time: ',num2str(pos(1))],...
                ['Type: ',type]
                };
            else
                txt={
                ['Time: ',num2str(pos(1))],...
                ['Value: ',num2str(pos(2))]
                };
            end
        end


        function figureZoomPanCallback(obj,~,~)
            obj.Document.updateDensityPlotBinWidth();
        end

    end


    methods(Static)
        function value=DAGetString(key)
            value=DAStudio.message(['Simulink:solverProfiler:',key]);
        end
    end

end
