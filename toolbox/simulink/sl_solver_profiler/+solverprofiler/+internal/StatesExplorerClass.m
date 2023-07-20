classdef StatesExplorerClass<handle

    properties(SetAccess=private)




















SEAppContainer
SEToolstrip
SEDocument
SEData
    end


    methods


        function SE=StatesExplorerClass(mdl,tout,xout,failureInfo,stats,tSpan,stateIdx)
            import solverprofiler.internal.StatesExplorerToolstripClass;
            import solverprofiler.internal.StatesExplorerDocumentClass;
            import solverprofiler.internal.StatesExplorerDataClass;
            import matlab.ui.internal.*


            [~,randomName,~]=fileparts(tempname);
            appOptions.Tag=randomName;
            appOptions.Title=[SE.DAGetString('Explorer'),': ',mdl];
            SE.SEAppContainer=matlab.ui.container.internal.AppContainer(appOptions);

            SE.SEAppContainer.WindowBounds=[100,100,1200,800];





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





            SE.SEAppContainer.Icon=filename;



            loc=[pwd,'/spinfo/'];
            try
                fileName=['rank_algorithm_table_for_',mdl];
                load([loc,fileName]);%#ok<LOAD>
            catch
                customAlg={};
            end


            SE.SEData=StatesExplorerDataClass(mdl,tout,xout,failureInfo,stats,tSpan,customAlg);

            SE.SEToolstrip=StatesExplorerToolstripClass(SE.SEAppContainer,tSpan,customAlg);

            SE.SEAppContainer.Visible=true;


            SE.SEDocument=StatesExplorerDocumentClass(SE.SEAppContainer);


            SE.SEData.sortStates();
            tableContent=SE.SEData.createTableContent();

            SE.SEDocument.populate(tableContent,...
            {SE.DAGetString('derivative'),SE.DAGetString('state')});


            SE.SEToolstrip.attachCallback('EditButton',...
            'ButtonPushed',@SE.openRankEditUI);
            SE.SEToolstrip.attachCallback('ZoomInButton',...
            'ValueChanged',@SE.zoomInCallback);
            SE.SEToolstrip.attachCallback('ZoomOutButton',...
            'ValueChanged',@SE.zoomOutCallback);
            SE.SEToolstrip.attachCallback('PanButton',...
            'ValueChanged',@SE.panCallback);
            SE.SEToolstrip.attachCallback('NewtonCheckbox',...
            'ValueChanged',@SE.newtonDAECheckboxCallback);
            SE.SEToolstrip.attachCallback('ErrorControlCheckbox',...
            'ValueChanged',@SE.errorControlCheckboxCallback);
            SE.SEToolstrip.attachCallback('HiliteButton',...
            'ButtonPushed',@SE.highlightCallback);
            SE.SEToolstrip.attachCallback('RemoveButton',...
            'ButtonPushed',@SE.removeTraceCallback);
            SE.SEToolstrip.attachCallback('TraceSrcButton',...
            'ButtonPushed',@SE.traceCallback);
            SE.SEToolstrip.attachCallback('NewPlotButton',...
            'ButtonPushed',@SE.generateNewPlot);
            SE.SEToolstrip.attachCallback('FromTextbox',...
            'ValueChanged',@SE.fromCallback);
            SE.SEToolstrip.attachCallback('ToTextbox',...
            'ValueChanged',@SE.toCallback);
            SE.SEToolstrip.attachCallback('RankPulldown',...
            'ValueChanged',@SE.rankCallback);


            SE.SEDocument.attachUItableSelectionCallback(@SE.stateTableCallback);


            SE.SEDocument.attachFigureZoomPanPostCallback(@SE.figureZoomPanCallback);



            addlistener(SE.SEAppContainer,'StateChanged',@SE.appCloseCallback);


            if stateIdx>0
                RankedStateIdx=SE.SEData.getData('RankedStateIdx');
                StateSelected=find(RankedStateIdx==stateIdx);
                SE.stateTableCallback(StateSelected);
                SE.SEData.setData('StateSelected',StateSelected);
            else
                SE.SEData.setData('StateSelected',1);
                SE.stateTableCallback(1);
            end

        end


        function delete(obj)
            obj.SEData.delete();
            obj.SEToolstrip.delete();
            obj.SEDocument.delete();
            obj.SEAppContainer.delete();
        end


        function appCloseCallback(obj,~,~)
            if obj.SEAppContainer.State==...
                matlab.ui.container.internal.appcontainer.AppState.TERMINATED
                obj.delete();
            end
        end


        function refresh(SE,tout,xout,failureInfo,stats,tSpan,stateIdx)
            SE.SEData.resetData(tout,xout,failureInfo,stats,tSpan);
            SE.SEToolstrip.setFromTime(tSpan(1));
            SE.SEToolstrip.setToTime(tSpan(2));
            SE.rankCallback();



            if stateIdx>0
                RankedStateIdx=SE.SEData.getData('RankedStateIdx');
                StateSelected=find(RankedStateIdx==stateIdx);
                SE.stateTableCallback(StateSelected);
                SE.SEData.setData('StateSelected',StateSelected);
            else
                SE.SEData.setData('StateSelected',1);
                SE.stateTableCallback(1);
            end
        end

        function moveFocusToStateExplorer(SE)
            SE.SEAppContainer.bringToFront;
        end


        function value=getData(SE,name)
            value=SE.(name);
        end


        function openRankEditUI(SE,~,~)
            SE.SEDocument.launchCustomRankWindow();
            tableContent=SE.SEData.getCustomRankTableContent();
            SE.SEDocument.populateCustomRankTable(tableContent);
            if isempty(tableContent)
                SE.SEDocument.disableRemoveRankButton();
            end
            SE.SEDocument.attachCustomRankAddButtonCallback(@SE.addRankingAlgorithm);
            SE.SEDocument.attachCustomRankRemoveButtonCallback(@SE.removeRankingAlgorithm);
        end


        function addRankingAlgorithm(SE,~,~)
            [filename,pathname]=uigetfile('*.m');

            if filename==0
                return;
            end

            if~strcmp(filename(end-1:end),'.m')
                strWrongFileType=SE.DAGetString('customRankWrongFileType');
                SE.popMsgBox('',strWrongFileType,'customRankWrongFileType');
                return;
            end

            addpath(pathname);
            SE.SEData.addAlg(pathname,filename(1:end-2));
            SE.SEToolstrip.addItemInPullDown(filename(1:end-2));


            tableContent=SE.SEData.getCustomRankTableContent();
            SE.SEDocument.populateCustomRankTable(tableContent);


            SE.SEDocument.enableRemoveRankButton();

            fileName=['rank_algorithm_table_for_',SE.SEData.getData('Model')];
            customAlg=SE.SEData.getData('CustomAlg');

            try
                if(exist('spinfo','dir')==0)
                    mkdir spinfo;
                end
                loc=[pwd,'/spinfo/'];
                save([loc,fileName],'customAlg');
            catch
            end
        end


        function removeRankingAlgorithm(SE,src,~)
            hFig=src.Parent;
            table=findobj(hFig,'Tag','customRankTable');
            inds=find([table.Data{:,1}]==1);


            customAlg=SE.SEData.getData('CustomAlg');
            for j=1:length(inds)
                fName=customAlg{inds(j),2};
                SE.SEToolstrip.removeItemInPullDown(fName);
            end


            SE.SEData.removeAlg(inds);


            customAlg=SE.SEData.getData('CustomAlg');
            fileName=['rank_algorithm_table_for_',SE.SEData.getData('Model')];
            try
                if(exist('spinfo','dir')==0)
                    mkdir spinfo;
                end
                loc=[pwd,'/spinfo/'];
                save([loc,fileName],'customAlg');
            catch
            end


            if isempty(customAlg)
                SE.SEDocument.disableRemoveRankButton();
            end


            tableContent=SE.SEData.getCustomRankTableContent();
            SE.SEDocument.populateCustomRankTable(tableContent);
        end


        function panCallback(SE,~,evt)

            SE.SEDocument.turnOffZoom();
            if(evt.Source.Value)
                SE.SEDocument.turnOnPan();
                SE.SEToolstrip.unselectZoomOut();
                SE.SEToolstrip.unselectZoomIn();
            else
                SE.SEDocument.turnOffPan();
            end
        end

        function zoomOutCallback(SE,~,evt)

            if(evt.Source.Value)
                SE.SEDocument.turnOnZoom('out');
                if SE.SEToolstrip.isZoomInSelected()
                    SE.SEToolstrip.unselectZoomIn();
                end
                if SE.SEToolstrip.isPanSelected()
                    SE.SEToolstrip.unselectPan();
                end
            else
                SE.SEDocument.turnOffZoom();
            end
        end

        function zoomInCallback(SE,~,evt)

            if(evt.Source.Value)
                SE.SEDocument.turnOnZoom('in');
                if SE.SEToolstrip.isZoomOutSelected()
                    SE.SEToolstrip.unselectZoomOut();
                end
                if SE.SEToolstrip.isPanSelected()
                    SE.SEToolstrip.unselectPan();
                end
            else
                SE.SEDocument.turnOffZoom();
            end
        end

        function newtonDAECheckboxCallback(SE,~,evt)
            if(evt.Source.Value)
                SE.markNewtonPointsOnPlot();
            else
                SE.removeNewtonPointsOnPlot();
            end
        end

        function errorControlCheckboxCallback(SE,~,evt)
            if(evt.Source.Value)
                SE.markErrorControlPointsOnPlot();
            else
                SE.removeOtherPointsOnPlot();
            end
        end

        function traceCallback(SE,~,~)
            traceCallbackModelRefStudioReuse(SE);
        end

        function traceCallbackModelRefStudioReuse(SE,~,~)
            blockName=SE.SEData.getBlockNameOfSelectedState();
            bp=[];%#ok
            indices=strfind(blockName,'|');
            if~isempty(indices)
                indices=[0,indices,length(blockName)+1];
                numOfLevels=length(indices)-1;
                blockPathsToTargetBlock=cell(1,numOfLevels);
                for i=1:numOfLevels
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
                SE.removeTraceCallback([],[]);
            else
                return;
            end

            if~isempty(blockHandle)
                Simulink.Structure.HiliteTool.AppManager.HighlightFromBlock(bp);

                SE.SEData.setData('HiliteTraceBlock',SE.SEData.getBlockNameOfSelectedState());
            end

            SE.SEToolstrip.enableRemoveButton;
        end

        function removeTraceCallback(SE,~,~)

            blockName=SE.SEData.getData('HiliteTraceBlock');
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

            set_param(SE.SEData.getData('Model'),'HiliteAncestors','off');
            bdHandle=get_param(SE.SEData.getData('Model'),'Handle');
            Simulink.Structure.HiliteTool.AppManager.removeAdvancedHighlighting(bdHandle);


            SE.SEData.setData('HiliteTraceBlock',[]);
            SE.SEToolstrip.disableRemoveButton;
        end

        function highlightCallback(SE,~,~)

            hilitePath=SE.SEData.getBlockNameOfSelectedState();
            if isempty(hilitePath)
                return;
            end


            SE.removeTraceCallback([],[]);


            SE.SEData.setData('HiliteTraceBlock',hilitePath);


            w=warning('query','Simulink:blocks:HideContents');
            oldWarnState=w.state;
            warning('off','Simulink:blocks:HideContents')


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
                        hilite_system(hilitePath(indices(i)+1:indices(i+1)-1),'find');
                    end
                catch
                    try
                        hilite_system(hilitePath(1:indices(2)-1),'find');
                    catch
                        warning(oldWarnState,'Simulink:blocks:HideContents');
                        return
                    end
                end
            end

            warning(oldWarnState,'Simulink:blocks:HideContents');
            SE.SEToolstrip.enableRemoveButton;
        end

        function rankCallback(obj,~,~)

            if~obj.SEData.isStateObjectValid()
                if obj.SEData.isStateStreamed()
                    obj.popMsgBox('',obj.DAGetString('xoutFileMissing'),'xoutFileMissing');
                end
                return;
            end

            fromTextboxValue=obj.SEToolstrip.getFromTextboxValue();
            toTextboxValue=obj.SEToolstrip.getToTextboxValue();
            tout=obj.SEData.getData('Tout');


            if fromTextboxValue>tout(end)||toTextboxValue<tout(1)||...
                fromTextboxValue>=toTextboxValue

                warndlg(obj.DAGetString('rankRangeInvalid'));
                return;
            end

            obj.SEData.setData('TLeft',fromTextboxValue);
            obj.SEData.setData('TRight',toTextboxValue);


            stateIdx=obj.SEData.getStateIdx();


            type=obj.SEToolstrip.getSelectedRankType();
            if type<=6
                switch type
                case 1
                    obj.SEData.setData('Mode','derivative');
                    colName={obj.DAGetString('derivative'),obj.DAGetString('state')};
                case 2
                    obj.SEData.setData('Mode','newton')
                    colName={obj.DAGetString('number'),obj.DAGetString('state')};
                    obj.SEToolstrip.selectNewtonCheckbox();
                case 3
                    obj.SEData.setData('Mode','state')
                    colName={obj.DAGetString('stateRange'),obj.DAGetString('state')};
                case 4
                    obj.SEData.setData('Mode','error')
                    colName={obj.DAGetString('number'),obj.DAGetString('state')};
                    obj.SEToolstrip.selectErrorControlCheckbox();
                case 5
                    obj.SEData.setData('Mode','path')
                    colName={obj.DAGetString('index'),obj.DAGetString('state')};
                otherwise
                    obj.SEData.setData('Mode','chatter')
                    colName={obj.DAGetString('derivative'),obj.DAGetString('state')};
                end

                obj.SEData.sortStates();
            else
                obj.SEData.setData('Mode','custom')
                colName={obj.DAGetString('number'),obj.DAGetString('state')};
                alg=obj.SEData.getData('CustomAlg');
                fcnName=alg{type-6,2};
                fcn=str2func(fcnName);

                customSD=obj.SEData.getCustomStatesData();
                try
                    [rankedStateIdx,stateScore]=fcn(customSD,fromTextboxValue,toTextboxValue);
                    obj.SEData.setData('RankedStateIdx',rankedStateIdx);
                    obj.SEData.setData('StateScore',stateScore);
                catch ME
                    obj.popMsgBox(obj.DAGetString('customRankFail'),ME.message,...
                    'customRankFail')
                    return;
                end
            end
            tableContent=obj.SEData.createTableContent();
            obj.SEDocument.populate(tableContent,colName);


            obj.SEDocument.attachUItableSelectionCallback(@obj.stateTableCallback);


            index=obj.SEData.getIndexInRankedStateIndexList(stateIdx);


            obj.SEData.setData('StateSelected',index);
            obj.stateTableCallback(index);
        end

        function fromCallback(obj,src,~)
            import solverprofiler.util.*
            toTextboxValue=obj.SEToolstrip.getToTextboxValue();
            tout=obj.SEData.getData('Tout');
            oldValue=obj.SEData.getData('TLeft');


            fromVal=utilGetScalarValue(src.Value);
            if~isnumeric(fromVal)
                src.Value=num2str(oldValue);
                warndlg(obj.DAGetString('rankRangeInvalid'));
                return;
            end


            if fromVal<tout(1)
                src.Value=num2str(tout(1));
            end


            if fromVal>=toTextboxValue
                src.Value=num2str(oldValue);
                warndlg(obj.DAGetString('rankRangeInvalid'));
                return;
            end

            obj.rankCallback([],[]);
        end

        function toCallback(obj,src,~)
            import solverprofiler.util.*
            fromTextboxValue=obj.SEToolstrip.getFromTextboxValue();
            tout=obj.SEData.getData('Tout');
            oldValue=obj.SEData.getData('TRight');


            toVal=utilGetScalarValue(src.Value);
            if~isnumeric(toVal)
                src.Value=num2str(oldValue);
                warndlg(obj.DAGetString('rankRangeInvalid'));
                return;
            end


            if toVal>tout(end)
                src.Value=num2str(tout(end));
            end


            if toVal<=fromTextboxValue
                src.Value=num2str(oldValue);
                warndlg(obj.DAGetString('rankRangeInvalid'));
                return;
            end

            obj.rankCallback([],[]);
        end

        function stateTableCallback(SE,stateIdx,event)
            import solverprofiler.util.*

            if(~isnumeric(stateIdx))
                if isempty(event.DisplayIndices)
                    return;
                end
                stateIdx=event.DisplayIndices(1);
            end

            if(stateIdx<=0)
                return;
            end


            if(SE.SEDocument.isHighlightedRow(stateIdx))
                return;
            end


            if~SE.SEData.isStateObjectValid()
                if SE.SEData.isStateStreamed()
                    SE.popMsgBox('',SE.DAGetString('xoutFileMissing'),'xoutFileMissing');
                end
                return;
            end


            SE.SEData.setData('StateSelected',stateIdx);


            TLeft=SE.SEData.getData('TLeft');
            TRight=SE.SEData.getData('TRight');

            if TLeft>=TRight
                return;
            end


            SE.SEDocument.tableHilightRow(stateIdx);



            stateID=SE.SEData.getStateIdx();

            blkName=SE.SEData.getBlockNameOfSelectedState();
            blkName=utilUnwrapBlockNameIfInModelRef(blkName);
            if utilIsBlockValidForTrace(blkName)
                SE.SEToolstrip.enableTrace();
            else
                SE.SEToolstrip.disableTrace();
            end


            h1=SE.SEDocument.getStatePlotHandle;
            h2=SE.SEDocument.getDerivPlotHandle;

            stateName=strrep(SE.SEData.getStateNameFromIdx(stateID),'_','\_');
            [stateValTime,stateValue,stateDerivTime,stateDerivValue]=...
            SE.SEData.getStateAndDerivValueForPlot(stateID);


            h1line=findobj(h1,'Tag','stateValue');
            h2line=findobj(h2,'Tag','derivValue');
            if isempty(stateValue)
                if~isempty(h1line)
                    h1line.XData=[];
                    h1line.YData=[];
                    h2line.XData=[];
                    h2line.YData=[];
                end
                title(h1,stateName);
                SE.popMsgBox('',SE.DAGetString('stateValEmpty'),'stateValEmpty');
                return;
            else
                if~isempty(h1line)
                    h1line.XData=stateValTime;
                    h1line.YData=stateValue;
                    ylim(h1,'auto');
                    title(h1,stateName);
                else
                    hold(h1,'off');
                    plot(h1,stateValTime,stateValue,'Tag','stateValue');
                    title(h1,stateName);
                end

                if~isempty(h2line)
                    if~isempty(stateDerivValue)
                        h2line.XData=stateDerivTime;
                        h2line.YData=stateDerivValue;
                        ylim(h2,'auto');
                    end
                else
                    if~isempty(stateDerivValue)
                        hold(h2,'off');
                        plot(h2,stateDerivTime,stateDerivValue,'Tag','derivValue');
                    end
                end
            end


            h1.Toolbar.Visible='off';
            h2.Toolbar.Visible='off';


            if SE.SEToolstrip.isNewtonCheckboxSelected()
                SE.removeNewtonPointsOnPlot()
                SE.markNewtonPointsOnPlot();
            end

            if SE.SEToolstrip.isErrorControlCheckboxSelected()
                SE.removeOtherPointsOnPlot()
                SE.markErrorControlPointsOnPlot();
            end

            strXLabel=SE.DAGetString('plotXLabel');
            span=TRight-TLeft;
            xlim(h1,[TLeft-0.025*span,TRight+0.025*span]);
            ylabel(h1,'x');
            xlabel(h1,strXLabel);
            grid(h1,'on');

            xlim(h2,[TLeft-0.025*span,TRight+0.025*span]);
            ylabel(h2,'\Delta x/\Delta t');
            xlabel(h2,strXLabel);
            grid(h2,'on');
        end

        function generateNewPlot(SE,~,~)
            fig=SE.SEDocument.getPlotHandle;
            fnew=figure;
            warning('off','MATLAB:copyobj:ObjectNotCopied');
            copyobj(allchild(fig),fnew);
            warning('on','MATLAB:copyobj:ObjectNotCopied');
        end


        function markNewtonPointsOnPlot(SE)

            stateIdx=SE.SEData.getStateIdx();
            allNewtonDAETime=SE.SEData.getStateNewtonDAEExceptionTime(stateIdx);

            if~isempty(allNewtonDAETime)
                [stateValTime,stateValue,stateDerivTime,stateDerivValue]=...
                SE.SEData.getStateAndDerivValueForPlot(stateIdx);

                h1=SE.SEDocument.getStatePlotHandle;
                h2=SE.SEDocument.getDerivPlotHandle;
                [~,indices,~]=intersect(stateValTime,unique(allNewtonDAETime));
                hold(h1,'on');
                plot(h1,stateValTime(indices),stateValue(indices),...
                'r.','markersize',20,'Tag','stateNewtonDAE');
                hold(h2,'on');
                plot(h2,allNewtonDAETime,...
                interp1(stateDerivTime,stateDerivValue,allNewtonDAETime),...
                'r.','markersize',20,'Tag','derivNewtonDAE');
            end
        end

        function markErrorControlPointsOnPlot(SE)

            stateIdx=SE.SEData.getStateIdx();
            allOtherTime=SE.SEData.getStateErrorControlExceptionTime(stateIdx);

            if~isempty(allOtherTime)
                [stateValTime,stateValue,stateDerivTime,stateDerivValue]=...
                SE.SEData.getStateAndDerivValueForPlot(stateIdx);

                h1=SE.SEDocument.getStatePlotHandle;
                h2=SE.SEDocument.getDerivPlotHandle;
                [~,indices,~]=intersect(stateValTime,allOtherTime);
                hold(h1,'on');
                plot(h1,stateValTime(indices),stateValue(indices),...
                'y.','markersize',20,'Tag','stateOther');
                hold(h2,'on');
                plot(h2,allOtherTime,...
                interp1(stateDerivTime,stateDerivValue,allOtherTime),...
                'y.','markersize',20,'Tag','derivOther');
            end
        end

        function removeNewtonPointsOnPlot(SE)
            h1=SE.SEDocument.getStatePlotHandle;
            h2=SE.SEDocument.getDerivPlotHandle;
            delete(findobj(h1,'Tag','stateNewtonDAE'));
            delete(findobj(h2,'Tag','derivNewtonDAE'));
        end

        function removeOtherPointsOnPlot(SE)
            h1=SE.SEDocument.getStatePlotHandle;
            h2=SE.SEDocument.getDerivPlotHandle;
            delete(findobj(h1,'Tag','stateOther'));
            delete(findobj(h2,'Tag','derivOther'));
        end


        function figureZoomPanCallback(obj,~,~)
            obj.SEDocument.updateDensityPlotBinWidth();
        end
    end


    methods(Static)

        function value=DAGetString(key)
            value=DAStudio.message(['Simulink:solverProfiler:',key]);
        end

        function popMsgBox(identifier,message,tag)
            if~isempty(identifier)
                hf=msgbox([identifier,'. ',message],identifier);
            else
                hf=msgbox(message);
            end
            set(hf,'tag',tag);
            setappdata(hf,'DisplayMessage',message);
        end
    end

end