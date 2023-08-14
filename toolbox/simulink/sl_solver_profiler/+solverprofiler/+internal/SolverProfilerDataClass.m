classdef SolverProfilerDataClass<handle




    properties(SetAccess=private)
Model
ProfileTime
SortedPD
TimerTag
TabSelected
ZCTableRowSelected
ResetTableRowSelected
ResetTableColumnSelected
ExceptionTableRowSelected
ExceptionTableColumnSelected
JacobianTableRowSelected
SscStiffTableRowSelected
StatisticsTableRowSelected
InaccurateStateTableRowSelected
ExceptionTableIndexList
ZCTableIndexList
JacobianTableIndexList
ResetTableIndexList
InaccurateStateTableIndexList
FigureTimeRange
HilitePath
FileInfo
TopTableName
OverallDiag
StatesExplorer
ZCExplorer
SPRule
NeedToClearStreamedStates

        HiliteTraceBlock;




UIStatusAtSim
    end

    methods


        function SPData=SolverProfilerDataClass(mdl)
            import solverprofiler.internal.SolverProfilerRuleClass;
            import solverprofiler.internal.SortedProfilerDataClass;
            SPData.Model=mdl;
            SPData.ProfileTime=0;
            SPData.SortedPD=SortedProfilerDataClass();
            SPData.TimerTag=[];
            SPData.TabSelected=SPData.DAGetString('Statistics');
            SPData.ZCTableRowSelected=[];
            SPData.ResetTableRowSelected=[];
            SPData.ResetTableColumnSelected=[];
            SPData.ExceptionTableRowSelected=[];
            SPData.JacobianTableRowSelected=[];
            SPData.SscStiffTableRowSelected=[];
            SPData.ExceptionTableColumnSelected=[];
            SPData.StatisticsTableRowSelected=[];
            SPData.InaccurateStateTableRowSelected=[];
            SPData.ExceptionTableIndexList=[];
            SPData.ZCTableIndexList=[];
            SPData.JacobianTableIndexList=[];
            SPData.ResetTableIndexList=[];
            SPData.InaccurateStateTableIndexList=[];
            SPData.FigureTimeRange=[];
            SPData.HilitePath=[];
            SPData.FileInfo=[];
            SPData.OverallDiag=[];
            SPData.StatesExplorer=[];
            SPData.ZCExplorer=[];
            SPData.TopTableName=[];
            SPData.HiliteTraceBlock=[];
            SPData.SPRule=SolverProfilerRuleClass(mdl);
            SPData.NeedToClearStreamedStates=true;
        end


        function delete(obj)
            if~isempty(obj.StatesExplorer)&&isvalid(obj.StatesExplorer)
                obj.StatesExplorer.delete;
            end
            if~isempty(obj.ZCExplorer)&&isvalid(obj.ZCExplorer)
                obj.ZCExplorer.delete;
            end
            if~isempty(obj.SPRule)&&isvalid(obj.SPRule)
                obj.SPRule.delete;
            end
            if~isempty(obj.SortedPD)&&isvalid(obj.SortedPD)
                if obj.NeedToClearStreamedStates
                    obj.SortedPD.deleteStreamedStateFile();
                end
                obj.SortedPD.delete;
            end
        end


        function dest=releaseSortedPD(obj)
            dest=obj.SortedPD;
            obj.SortedPD=[];
        end


        function value=getData(SPData,name)
            value=SPData.(name);
        end

        function setData(SPData,name,value)
            try
                SPData.(name)=value;
            catch
            end
        end


        function status=isSameModel(SPData,oldModel)
            status=strcmp(SPData.Model,oldModel);
        end


        function status=isZCTabSelected(SPData)
            status=strcmp(SPData.TabSelected,SPData.DAGetString('Zerocrossing'));
        end

        function status=isExceptionTabSelected(SPData)
            status=strcmp(SPData.TabSelected,SPData.DAGetString('Solverexception'));
        end

        function status=isJacobianTabSelected(SPData)
            status=strcmp(SPData.TabSelected,SPData.DAGetString('JacobianAnalysis'));
        end

        function status=isSscStiffTabSelected(SPData)
            status=strcmp(SPData.TabSelected,SPData.DAGetString('SscStiff'));
        end

        function status=isResetTabSelected(SPData)
            status=strcmp(SPData.TabSelected,SPData.DAGetString('Solverreset'));
        end

        function status=isStatisticsTabSelected(SPData)
            status=strcmp(SPData.TabSelected,SPData.DAGetString('Statistics'));
        end

        function status=isInaccurateStateTableSelected(SPData)
            status=strcmp(SPData.TabSelected,SPData.DAGetString('InaccurateState'));
        end

        function status=isStepSizeTabSelected(SPData)
            status=strcmp(SPData.TabSelected,SPData.DAGetString('Stepsize'));
        end


        function initializeSortedPD(SPData,spidata)
            tout=[];
            if spidata.isprop('tout')
                tout=get(spidata,'tout');
            end
            pd=[];
            if spidata.isprop('pd')
                pd=get(spidata,'pd');
            end
            simlog=[];
            if spidata.isprop('simlog')
                simlog=get(spidata,'simlog');
            end
            SPData.ProfileTime=spidata.SimulationMetadata.TimingInfo.ExecutionElapsedWallTime;

            SPData.SortedPD.initializeWithData(SPData.Model,tout,pd,...
            simlog,spidata.SimulationMetadata,SPData.ProfileTime);
        end


        function getModelDiagnosticsAndTableIndex(SPData,spidata)
            tout=get(spidata,'tout');
            try
                ruleSet=SPData.SPRule.getRuleSet();
                SPData.OverallDiag=...
                solverprofiler.util.getDiagnositics(...
                SPData.Model,SPData.SortedPD,ruleSet);
            catch
                SPData.OverallDiag='';
            end
            SPData.ExceptionTableIndexList=SPData.SortedPD.getRankedFailureStateList();
            SPData.ZCTableIndexList=SPData.SortedPD.getBlockListWithZcEvents();
            SPData.FigureTimeRange=[tout(1)-32*eps,tout(end)+32*eps];
        end


        function stateIdx=getSelectedStateIdxFromExceptionTable(SPData)
            stateIdx=SPData.ExceptionTableIndexList(SPData.ExceptionTableRowSelected);
        end


        function stateIdx=getSelectedStateIdxFromJacobianTable(SPData)
            stateIdx=SPData.JacobianTableIndexList(SPData.JacobianTableRowSelected);
        end


        function status=isDataReady(SPData)
            if~isvalid(SPData.SortedPD)
                status=false;
            else
                status=SPData.SortedPD.isDataReady();
            end
        end

        function list=getRankedFailureStateList(SPData)
            list=SPData.SortedPD.getRankedFailureStateList();
        end

        function list=getBlockListWithZcEvents(SPData)
            list=SPData.SortedPD.getBlockListWithZcEvents();
        end

        function tout=getTout(SPData)
            tout=SPData.SortedPD.getData('Tout');
        end

        function zcInfo=getZcInfo(obj)
            zcInfo=obj.SortedPD.getData('ZcInfo');
        end

        function hmax=getHmax(SPData)
            hmax=SPData.SortedPD.getHmax();
        end

        function jacobianTime=getJacobianUpdateTime(SPData)
            jacobianTime=SPData.SortedPD.getJacobianUpdateTime();
        end

        function status=isThereAnyZCEvent(SPData)
            status=SPData.SortedPD.zcEventsDetected();
        end

        function status=isThereAnyException(SPData)
            status=~isempty(SPData.SortedPD.getRankedFailureStateList());
        end

        function status=isThereAnyReset(SPData)
            status=~isempty(SPData.SortedPD.getRankedResetBlockList());
        end

        function zcMatrix=getAllZCEvents(SPData)
            zcMatrix=SPData.SortedPD.getAllZCEvents();
        end

        function zcMatrix=getZCEventsFromSelectedBlock(SPData)
            index=SPData.ZCTableRowSelected;
            blockIdx=SPData.ZCTableIndexList(index);
            zcMatrix=SPData.SortedPD.getZCEventsFromSelectedBlock(blockIdx);
        end

        function exceptionMatrix=getFailureMatrixForSelectedState(SPData,type)
            rowNumber=SPData.ExceptionTableRowSelected;
            stateIdx=SPData.ExceptionTableIndexList(rowNumber);
            exceptionMatrix=SPData.SortedPD.getFailureMatrixForState(stateIdx,type);
        end

        function exceptionMatrix=getTotalFailureMatrix(SPData,type)
            exceptionMatrix=SPData.SortedPD.getTotalFailureMatrix(type);
        end

        function resetMatrix=getResetMatrixForSelectedSource(SPData,type)
            rowNumber=SPData.ResetTableRowSelected;
            blockIdx=SPData.ResetTableIndexList(rowNumber);
            resetMatrix=SPData.SortedPD.getResetMatrixForSource(blockIdx,type);
        end

        function resetMatrix=getTotalResetMatrix(SPData,type)
            resetMatrix=SPData.SortedPD.getTotalResetMatrix(type);
        end

        function tableContent=getStatisticsTableContent(SPData)
            tableContent=SPData.SortedPD.getStatisticsTableContent();
        end

        function tableContent=getJacobianTableContent(SPData)
            [tableContent,SPData.JacobianTableIndexList]=...
            SPData.SortedPD.updateJacobianTableContent(SPData.FigureTimeRange);
        end

        function tableContent=getSscStiffTableContent(SPData)
            tableContent=SPData.SortedPD.getSscStiffTableContent();
        end

        function tableContent=getZeroCrossingTableContent(SPData)
            [tableContent,SPData.ZCTableIndexList]=...
            SPData.SortedPD.updateZeroCrossingTableContent(SPData.FigureTimeRange);
        end

        function tableContent=getResetTableContent(SPData)
            [tableContent,SPData.ResetTableIndexList]=...
            SPData.SortedPD.getResetTableContent(SPData.FigureTimeRange);
        end

        function tableContent=getInaccurateStateTableContent(SPData)
            [tableContent,SPData.InaccurateStateTableIndexList]=...
            SPData.SortedPD.getInaccurateStateTableContent();
        end

        function tableContent=getExceptionTableContent(SPData,type)
            [tableContent,SPData.ExceptionTableIndexList]=...
            SPData.SortedPD.updateExceptionTableContent(...
            SPData.FigureTimeRange,type);
        end

        function nodeName=getSimscapeNodeNameForBlock(SPData,blockName)
            nodeName=SPData.SortedPD.getSimscapeNodeNameForBlock(blockName);
        end

        function blockName=getSelectedBlockNameFromJacobianLst(SPData)
            rowSelected=SPData.JacobianTableRowSelected;
            stateIdx=SPData.JacobianTableIndexList(rowSelected);
            blockName=SPData.SortedPD.getBlockNameFromStateIdx(stateIdx);
        end

        function blockName=getSelectedBlockNameFromSscStiffData(SPData)
            rowSelected=SPData.SscStiffTableRowSelected;
            blockName=SPData.SortedPD.getBlockNameFromSscStiffData(rowSelected);
        end

        function fileInfo=getSelectedFileInfoFromSscStiffData(SPData)
            rowSelected=SPData.SscStiffTableRowSelected;
            fileInfo=SPData.SortedPD.getFileInfoFromSscStiffData(rowSelected);
        end

        function blockName=getSelectedBlockNameFromResetLst(SPData)
            rowSelected=SPData.ResetTableRowSelected;
            blockIdx=SPData.ResetTableIndexList(rowSelected);
            if isempty(blockIdx)||blockIdx==-1
                blockName='';
            else
                blockName=SPData.SortedPD.getBlockNameFromBlockIdx(blockIdx);
            end
        end

        function blockName=getSelectedBlockNameFromZCLst(SPData)
            rowSelected=SPData.ZCTableRowSelected;
            if(~isempty(rowSelected))
                blockIdx=SPData.ZCTableIndexList(rowSelected);
                blockName=SPData.SortedPD.getBlockNameFromBlockIdx(blockIdx);
            else
                blockName='';
            end
        end

        function blockName=getSelectedBlockNameFromExceptionLst(SPData)
            rowSelected=SPData.ExceptionTableRowSelected;
            stateIdx=SPData.ExceptionTableIndexList(rowSelected);
            blockName=SPData.SortedPD.getBlockNameFromStateIdx(stateIdx);
        end

        function blockName=getSelectedBlockNameFromInaccurateStateLst(SPData)
            rowSelected=SPData.InaccurateStateTableRowSelected;
            stateIdx=SPData.InaccurateStateTableIndexList(rowSelected);
            blockName=SPData.SortedPD.getBlockNameFromStateIdx(stateIdx);
        end

        function simlog=getSimlog(SPData)
            simlog=SPData.SortedPD.getData('Simlog');
        end

        function setSimlog(SPData,simlog)
            SPData.SortedPD.setSimlog(simlog);
        end

        function setDiscDriContblkList(SPData,value)
            SPData.SortedPD.setDiscDriContblkList(value);
        end




        function fillStateValue(SPData,arg)
            if~isempty(arg)
                if~ischar(arg)
                    if arg.isprop('pd')
                        pd=get(arg,'pd');
                        if~isempty(pd)
                            SPData.SortedPD.fillStateValue(pd.continuousStateValue);
                        end
                    end
                else
                    SPData.SortedPD.fillStateValue(arg);
                end
            end
        end

        function setStateRange(SPData,spidata)
            if spidata.isprop('pd')
                pd=get(spidata,'pd');
                if~isempty(pd)&&~isempty(pd.continuousStateValue)
                    SPData.SortedPD.setStateRange(pd.continuousStateValue);
                end
            end
        end

        function fillZeroCrossingInfo(SPData,spidata)
            if spidata.isprop('pd')
                pd=get(spidata,'pd');
                SPData.SortedPD.fillZeroCrossingInfo(pd);
            end
        end

        function fillResetInfo(SPData,spidata)
            if spidata.isprop('pd')
                pd=get(spidata,'pd');
                SPData.SortedPD.fillResetInfo(pd);
            end
        end

        function fillFailureInfo(SPData,spidata)
            if spidata.isprop('pd')
                pd=get(spidata,'pd');
                SPData.SortedPD.fillFailureInfo(pd);
            end
        end

        function getOverview(SPData)
            SPData.SortedPD.getOverview();
        end

        function simplifiedOverview=getSimplifiedOverview(SPData)
            simplifiedOverview=SPData.SortedPD.getSimplifiedOverview();
        end

        function analyzeModelJacobian(SPData,spidata)
            if spidata.isprop('pd')
                pd=get(spidata,'pd');
                SPData.SortedPD.analyzeModelJacobian(pd);
            end
        end

        function setSimscapeStiff(SPData)
            try
                data=simscape.internal.get_stiffness(SPData.Model);
                SPData.SortedPD.setSimscapeStiff(data);
            catch
            end
        end


        function fHandle=getRuleFigHandle(SPData)
            fHandle=SPData.SPRule.getRuleFigHandle();
        end

        function openRuleWindow(SPData)
            SPData.SPRule.openRuleWindow();
        end

        function ruleSet=getRuleSet(SPData)
            ruleSet=SPData.SPRule.getRuleSet();
        end

        function setRuleSet(SPData,ruleSet)
            SPData.SPRule.setRuleSet(ruleSet);
        end

        function updateWindow(SPData)
            SPData.SPRule.updateWindow();
        end

        function flag=hasZCValue(obj)
            flag=obj.SortedPD.hasZCValue();
        end

        function isStreamed=isStateStreamed(SPData)
            isStreamed=SPData.SortedPD.isStateStreamed();
        end

        function isValid=isStateObjectValid(SPData)
            isValid=SPData.SortedPD.isStateObjectValid();
        end

        function attachStateData(SPData,xout)
            SPData.SortedPD.attachStateData(xout);
        end

        function copyFileToLocation(SPData,destination)
            SPData.SortedPD.copyFileToLocation(destination)
        end
    end

    methods(Static)

        function value=DAGetString(key)
            value=DAStudio.message(['Simulink:solverProfiler:',key]);
        end

    end

end
