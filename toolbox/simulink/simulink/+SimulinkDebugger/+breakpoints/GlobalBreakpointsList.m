classdef GlobalBreakpointsList<matlab.mixin.Copyable




    methods(Access=public)

        function this=GlobalBreakpointsList()
            this.mf_Model=mf.zero.Model;
            this.mf_breakpointsList=slbreakpoints.datamodel.GlobalBreakpointsList(this.mf_Model);
            this.closeListenerMap=containers.Map;
        end

        function addModelCloseListener(this,model)
            if bdIsLoaded(model)
                modelH=get_param(model,'Handle');
                if~isempty(modelH)&&~this.closeListenerMap.isKey(model)
                    this.closeListenerMap(model)=Simulink.listener(modelH,'CloseEvent',@(~,~)this.clearForModel(model));
                end
            end
        end

        function bplist=getBreakpoints(this)
            bplist=this.mf_breakpointsList;
        end

        function isEmptyBpList=containsNoBPs(this)
            isBlockBpListEmpty=~logical(this.mf_breakpointsList.blockBreakpoints.Size);
            isModelBpListEmpty=~logical(this.mf_breakpointsList.modelBreakpoints.Size);
            isEmptyBpList=isBlockBpListEmpty&&isModelBpListEmpty;
        end

        function clear(this)

            blockBreakpointsMap=this.mf_breakpointsList.blockBreakpoints;
            keys=blockBreakpointsMap.keys;
            for key=keys
                bp=blockBreakpointsMap{key{1}};
                blockPathForKey=bp.blockPath;
                SimulinkDebugger.breakpoints.removeBlockBreakpointBadge(blockPathForKey);
            end
            this.mf_breakpointsList.blockBreakpoints.clear();
            this.mf_breakpointsList.modelBreakpoints.clear();
            this.closeListenerMap=containers.Map;

            this.notify('RefreshBreakpointUI');
        end

        function clearForModel(this,model)

            blockBreakpointsMap=this.mf_breakpointsList.blockBreakpoints;
            blockBpKeys=blockBreakpointsMap.keys;
            for idx=1:numel(blockBpKeys)
                bp=blockBreakpointsMap{blockBpKeys{idx}};
                if strcmp(bp.modelName,model)
                    blockPathForKey=bp.blockPath;
                    SimulinkDebugger.breakpoints.removeBlockBreakpointBadge(blockPathForKey);
                    this.removeBlockBreakpoint(bp.BPID);
                end
            end


            modelBreakpointsMap=this.mf_breakpointsList.modelBreakpoints;
            modelBpKeys=modelBreakpointsMap.keys;
            for idx=1:numel(modelBpKeys)
                bp=modelBreakpointsMap{modelBpKeys{idx}};
                if strcmp(bp.modelName,model)
                    this.removeModelBreakpoint(bp.BPID);
                end
            end

            if this.closeListenerMap.isKey(model)
                remove(this.closeListenerMap,model);
            end

        end

        function callRefresh(this)
            this.notify('RefreshBreakpointUI')
        end

        function addBlockBreakpoint(this,modelName,blockPath,BPID,isEnabled)
            alreadyContainsBp=~isempty(this.mf_breakpointsList.blockBreakpoints{BPID});
            if~alreadyContainsBp
                blockBp=slbreakpoints.datamodel.BlockBreakpoint(...
                this.mf_Model,...
                struct('modelName',modelName,...
                'blockPath',['''',blockPath,''''],...
                'BPID',BPID,...
                'isEnabled',isEnabled));
                this.mf_breakpointsList.blockBreakpoints.add(blockBp);


                this.notify('RefreshBreakpointUI');


                SimulinkDebugger.breakpoints.addBlockBreakpointBadge(blockPath);


                this.addModelCloseListener(modelName);
            end
        end

        function bp=getBlockBreakpoint(this,BPID)
            blockBreakpointsMap=this.mf_breakpointsList.blockBreakpoints;
            bp=blockBreakpointsMap{BPID};
        end

        function removeBlockBreakpoint(this,bpId)
            bp=this.mf_breakpointsList.blockBreakpoints{bpId};
            SimulinkDebugger.breakpoints.removeBlockBreakpointBadge(bp.blockPath);
            this.mf_breakpointsList.blockBreakpoints.remove(bp);



            if~isempty(bp)
                if bdIsLoaded(bp.modelName)&&...
                    slInternal('sldebug',bp.modelName,'SldbgIsPausedInDebugLoop')

                    modelHandle=get_param(bp.modelName,'Handle');
                    SLM3I.SLCommonDomain.simulationDebugStep(modelHandle,['clear ',bp.blockPath])
                end
            end
        end

        function enableDisableBlockBreakpoint(this,bpId,enableBp)
            bp=this.mf_breakpointsList.blockBreakpoints{bpId};


            if isequal(enableBp,'1')
                enableBp=true;
            else
                enableBp=false;
            end

            if bdIsLoaded(bp.modelName)&&...
                slInternal('sldebug',bp.modelName,'SldbgIsPausedInDebugLoop')
                modelHandle=get_param(bp.modelName,'Handle');
                if enableBp
                    bp.isEnabled=true;
                    SLM3I.SLCommonDomain.simulationDebugStep(modelHandle,['break ',bp.blockPath]);
                else
                    bp.isEnabled=false;
                    SLM3I.SLCommonDomain.simulationDebugStep(modelHandle,['clear ',bp.blockPath])
                end
            else
                bp.isEnabled=enableBp;
            end
        end

        function addModelBreakpoint(this,modelName,bpType,isEnabled)
            BPID=this.createModelBPID(modelName,bpType);
            alreadyContainsBp=~isempty(this.mf_breakpointsList.modelBreakpoints{BPID});
            if~alreadyContainsBp
                modelBp=slbreakpoints.datamodel.ModelBreakpoint(...
                this.mf_Model,...
                struct('modelName',modelName,...
                'bpType',bpType,...
                'BPID',BPID,...
                'isEnabled',isEnabled));
                this.mf_breakpointsList.modelBreakpoints.add(modelBp);


                this.notify('RefreshBreakpointUI');


                this.addModelCloseListener(modelName);
            end
        end

        function removeModelBreakpoint(this,bpId)
            bp=this.mf_breakpointsList.modelBreakpoints{bpId};
            if~isempty(bp)
                this.mf_breakpointsList.modelBreakpoints.remove(bp);


                if bp.isEnabled&&bdIsLoaded(bp.modelName)&&...
                    slInternal('sldebug',bp.modelName,'SldbgIsPausedInDebugLoop')
                    modelHandle=get_param(bp.modelName,'Handle');
                    this.runModelBreakpointCmd(modelHandle,bp.bpType);
                end
            end
        end

        function enableDisableModelBreakpoint(this,bpId,enableBp)
            bp=this.mf_breakpointsList.modelBreakpoints{bpId};


            if ischar(enableBp)
                if isequal(enableBp,'0')
                    enableBp=false;
                else
                    enableBp=true;
                end
            end

            if~bdIsLoaded(bp.modelName)
                return;
            end

            simulationStatus=get_param(bp.modelName,'SimulationStatus');
            modelHandle=get_param(bp.modelName,'Handle');

            if slInternal('sldebug',bp.modelName,'SldbgIsPausedInDebugLoop')
                bp.isEnabled=enableBp;
                this.runModelBreakpointCmd(modelHandle,bp.bpType);
            elseif strcmp(simulationStatus,'stopped')
                bp.isEnabled=enableBp;
            end
        end

        function enableDisableModelBreakpointFromCommandLine(this,bpId,enableBp)


            bp=this.mf_breakpointsList.modelBreakpoints{bpId};
            bp.isEnabled=enableBp;
        end

        function status=getBreakpointsStatusForModel(this)



            model=this.getTopModel;
            status=0;


            blockBreakpointsMap=this.mf_breakpointsList.blockBreakpoints;
            blockBpKeys=blockBreakpointsMap.keys;
            for idx=1:numel(blockBpKeys)
                bp=blockBreakpointsMap{blockBpKeys{idx}};
                if strcmp(bp.modelName,model)
                    if~bp.isEnabled
                        status=1;
                        return;
                    end
                end
            end


            modelBreakpointsMap=this.mf_breakpointsList.modelBreakpoints;
            modelBpKeys=modelBreakpointsMap.keys;
            for idx=1:numel(modelBpKeys)
                bp=modelBreakpointsMap{modelBpKeys{idx}};
                if strcmp(bp.modelName,model)
                    if~bp.isEnabled
                        status=1;
                        return;
                    end
                end
            end
        end

        function enableDisableAllBreakpointsForModel(this,status)

            setToEnabled=logical(status);
            model=this.getTopModel;


            blockBreakpointsMap=this.mf_breakpointsList.blockBreakpoints;
            blockBpKeys=blockBreakpointsMap.keys;
            for idx=1:numel(blockBpKeys)
                bp=blockBreakpointsMap{blockBpKeys{idx}};
                if strcmp(bp.modelName,model)&&...
                    bp.isEnabled~=setToEnabled
                    this.enableDisableBlockBreakpoint(bp.BPID,setToEnabled);
                end
            end


            modelBreakpointsMap=this.mf_breakpointsList.modelBreakpoints;
            modelBpKeys=modelBreakpointsMap.keys;
            for idx=1:numel(modelBpKeys)
                bp=modelBreakpointsMap{modelBpKeys{idx}};
                if strcmp(bp.modelName,model)&&...
                    bp.isEnabled~=setToEnabled
                    this.enableDisableModelBreakpoint(bp.BPID,setToEnabled);
                end
            end
        end

        function hasBPs=hasBreakpointsInHierarchy(this,model)
            hasBPs=false;
            if this.containsNoBPs()
                return;
            end

            breakpoints=getBreakpointsInHierarchy(this,model);
            if~isempty(breakpoints.blockBreakpoints)||...
                ~isempty(breakpoints.modelBreakpoints)
                hasBPs=true;
            end
        end

        function swap(this,copyOfBpList)




            tmpBpList=SimulinkDebugger.breakpoints.GlobalBreakpointsList();
            SimulinkDebugger.breakpoints.GlobalBreakpointsList.copyBreakpoints(copyOfBpList,tmpBpList);
            SimulinkDebugger.breakpoints.GlobalBreakpointsList.copyBreakpoints(this,copyOfBpList);
            SimulinkDebugger.breakpoints.GlobalBreakpointsList.copyBreakpoints(tmpBpList,this);
        end

        function breakpoints=getBreakpointsInHierarchy(this,model)
            breakpoints.blockBreakpoints=cell(0);
            breakpoints.modelBreakpoints=cell(0);
            if this.containsNoBPs
                return
            end




            modelsInHierarchy=find_mdlrefs(model,'MatchFilter',@Simulink.match.internal.filterOutCodeInactiveVariantSubsystemChoices);
            blockBreakpointsMap=this.mf_breakpointsList.blockBreakpoints;
            keys=blockBreakpointsMap.keys;
            for idx=1:blockBreakpointsMap.Size
                bp=blockBreakpointsMap{keys{idx}};
                modelForKey=bp.modelName;
                if bp.isEnabled&&...
                    any(contains(modelsInHierarchy,modelForKey))
                    breakpoints.blockBreakpoints{end+1}=bp.blockPath;
                end
            end


            modelBreakpointsMap=this.mf_breakpointsList.modelBreakpoints;
            keys=modelBreakpointsMap.keys;
            for key=keys
                bp=modelBreakpointsMap{key{1}};
                modelForKey=bp.modelName;
                if bp.isEnabled&&...
                    any(contains(modelsInHierarchy,modelForKey))



                    breakpoints.modelBreakpoints{end+1}=int8(bp.bpType);
                end
            end
        end

        function intitalize(this,model)
            bps=this.getBreakpointsInHierarchy(model);
            for idx=1:numel(bps)
                bps.blockBreakpoints{idx}.hitCount=0;
            end
        end

        function bpTypes=getBpTypeOfRecentCmds(this)
            bpTypes=this.bpTypeOfRecentCmds;
        end

        function removeBpTypeOfRecentCmd(this,idxInRecentCmds)
            if numel(this.bpTypeOfRecentCmds)>1
                this.bpTypeOfRecentCmds(idxInRecentCmds)=[];
            else
                this.bpTypeOfRecentCmds=[];
            end
        end

    end

    methods(Access=private)
        function runModelBreakpointCmd(this,modelHandle,breakpointType)
            switch breakpointType
            case slbreakpoints.datamodel.ModelBreakpointType.ZeroCrossing
                cmd='zcbreak';
            case slbreakpoints.datamodel.ModelBreakpointType.StepSizeLimited
                cmd='xbreak';
            case slbreakpoints.datamodel.ModelBreakpointType.SolverError
                cmd='ebreak';
            case slbreakpoints.datamodel.ModelBreakpointType.NanValues
                cmd='nanbreak';
            otherwise

                assert(false);
            end
            this.bpTypeOfRecentCmds=[this.bpTypeOfRecentCmds,breakpointType];
            SLM3I.SLCommonDomain.simulationDebugStep(modelHandle,cmd);
        end
    end

    methods(Static)
        function BPID=createBlockBPID(mdl,blockPath)
            BPID=[mdl,'-',blockPath];
        end

        function BPID=createModelBPID(mdl,breakpointType)
            breakpointTypeStr=char(breakpointType);
            BPID=[mdl,'-',breakpointTypeStr];
        end

        function topModel=getTopModel
            editor=SLM3I.SLDomain.findLastActiveEditor();
            studio=editor.getStudio();
            topModel=get_param(studio.App.topLevelDiagram.handle,'Name');
        end

        function copyBreakpoints(src,dest)

            dest.clear();
            breakpoints=src.getBreakpoints();
            blockBreakpointsMap=breakpoints.blockBreakpoints;
            keys=blockBreakpointsMap.keys;
            for key=keys
                bp=blockBreakpointsMap{key{1}};
                dest.addBlockBreakpoint(bp.modelName,bp.blockPath,bp.BPID,bp.isEnabled);
            end

            modelBreakpointsMap=breakpoints.modelBreakpoints;
            keys=modelBreakpointsMap.keys;
            for key=keys
                bp=modelBreakpointsMap{key{1}};
                dest.addModelBreakpoint(bp.modelName,bp.bpType,bp.isEnabled);
            end
        end
    end

    properties(Access=private)
mf_breakpointsList
mf_Model
closeListenerMap
bpTypeOfRecentCmds
    end

    events
RefreshBreakpointUI
    end
end


