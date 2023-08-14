classdef StructWithTimeParser<Simulink.sdi.internal.import.VariableParser



    properties
SignalIndex
    end


    methods


        function ret=supportsType(this,var)

            ret=...
            isscalar(var)...
            &&isstruct(var)...
            &&isfield(var,'signals')...
            &&isfield(var.signals,'values')...
            &&isfield(var.signals,'label')...
            &&isfield(var.signals,'dimensions');
            if ret
                ret=isfield(var,'time')&&~isempty(var.time);

                if~ret
                    this.TimeSourceRule='model based';
                    timeLen=length(this.WorkspaceParser.GlobalTimeVectorValue);
                    dataSz=size(var.signals(1).values);
                    if length(dataSz)==2
                        ret=timeLen==dataSz(1);
                    else
                        ret=timeLen==dataSz(end);
                    end
                end
            end

        end


        function ret=usingGlobalTime(this)
            ret=...
            strcmpi(this.TimeSourceRule,'model based')&&...
            ~isempty(this.WorkspaceParser.GlobalTimeVectorValue);
        end


        function ret=getRootSource(this)
            ret=this.VariableName;
        end


        function ret=getTimeSource(this)
            if usingGlobalTime(this)
                ret=this.WorkspaceParser.GlobalTimeVectorName;
            else
                ret=[this.VariableName,'.time'];
            end
        end


        function ret=getDataSource(this)
            if length(this.VariableValue.signals)==1
                ret=[this.VariableName,'.signals.values'];
            elseif isempty(this.SignalIndex)
                ret='';
            else
                ret=sprintf('%s.signals(%d).values',this.VariableName,this.SignalIndex);
            end
        end


        function ret=getBlockSource(this)
            ret='';
            if~isHierarchical(this)
                if isempty(this.SignalIndex)
                    sigIdx=1;
                else
                    sigIdx=this.SignalIndex;
                end


                if isfield(this.VariableValue,'blockName')
                    ret=this.VariableValue.blockName;
                elseif isfield(this.VariableValue.signals(sigIdx),'blockName')
                    ret=this.VariableValue.signals(sigIdx).blockName;
                end



                if isfield(this.VariableValue.signals(sigIdx),'inReferencedModel')&&...
                    this.VariableValue.signals(sigIdx).inReferencedModel
                    [~,remain]=strtok(ret,'|');
                    if~isempty(remain)
                        remain(1)='';
                        ret=remain;
                    end
                end
            end
        end


        function ret=getSID(this)
            ret='';
            bpath=getBlockSource(this);
            if~isempty(bpath)
                startLoggingOpenModels(this.WorkspaceParser);
                interface=Simulink.sdi.internal.Framework.getFramework();
                try
                    ret=interface.getSID(bpath,true);
                catch me %#ok<NASGU>
                    ret='';
                end
            end
        end


        function ret=getModelSource(this)
            ret='';
            bpath=getBlockSource(this);
            if~isempty(bpath)
                ret=Simulink.SimulationData.BlockPath.getModelNameForPath(bpath);
            end
        end


        function ret=getSignalLabel(this)
            ret=this.VariableName;
            if~isHierarchical(this)
                if isempty(this.SignalIndex)
                    sigIdx=1;
                else
                    sigIdx=this.SignalIndex;
                end


                ret=this.VariableValue.signals(sigIdx).label;



                if isfield(this.VariableValue.signals(sigIdx),'stateName')
                    if~isempty(strtrim(this.VariableValue.signals(sigIdx).stateName))
                        ret=this.VariableValue.signals(sigIdx).stateName;
                    else
                        bpath=getBlockSource(this);
                        [~,~,blkName]=locHelperSplitString(bpath);
                        ret=sprintf('%s:%s',blkName,ret);
                    end
                end
            end
        end


        function ret=getDomainType(this)
            ret='';

            if isempty(this.SignalIndex)
                sigIdx=1;
            else
                sigIdx=this.SignalIndex;
            end

            if isfield(this.VariableValue.signals(sigIdx),'stateName')
                ret='state';
            end
        end


        function ret=getPortIndex(~)
            ret=[];
        end


        function ret=getHierarchyReference(~)
            ret='';
        end


        function ret=getTimeDim(this)
            ret=[];
            if~isHierarchical(this)
                dims=getSampleDims(this);
                if isscalar(dims)
                    ret=1;
                else
                    ret=length(dims)+1;
                end
            end
        end


        function ret=getSampleDims(this)
            ret=[];
            if~isHierarchical(this)
                if isempty(this.SignalIndex)
                    sigIdx=1;
                else
                    sigIdx=this.SignalIndex;
                end
                ret=this.VariableValue.signals(sigIdx).dimensions;
            end
        end


        function ret=getInterpolation(this)
            ret='zoh';
            if~isHierarchical(this)
                if isempty(this.SignalIndex)
                    sigIdx=1;
                else
                    sigIdx=this.SignalIndex;
                end



                if isfield(this.VariableValue.signals(sigIdx),'stateName')
                    if strcmp(this.VariableValue.signals(sigIdx).label,'CSTATE')
                        ret='linear';
                    end
                end
            end
        end


        function ret=getUnit(~)
            ret='';
        end


        function ret=getMetaData(~)
            ret=[];
        end


        function ret=getTimeValues(this)
            if~isHierarchical(this)
                if usingGlobalTime(this)
                    ret=this.WorkspaceParser.GlobalTimeVectorValue;
                else
                    ret=this.VariableValue.time;
                end
            else
                ret=[];
            end
        end


        function ret=getDataValues(this)
            ret=[];
            if~isHierarchical(this)
                if isempty(this.SignalIndex)
                    sigIdx=1;
                else
                    sigIdx=this.SignalIndex;
                end
                ret=this.VariableValue.signals(sigIdx).values;
            end
        end


        function ret=isHierarchical(this)
            ret=isempty(this.SignalIndex)&&length(this.VariableValue.signals)>1;
        end


        function ret=getChildren(this)
            ret={};
            if isHierarchical(this)
                numSignals=length(this.VariableValue.signals);
                ret=cell(1,numSignals);
                for idx=1:numSignals
                    ret{idx}=Simulink.sdi.internal.import.StructWithTimeParser;
                    ret{idx}.Parent=this;
                    ret{idx}.VariableName=this.VariableName;
                    ret{idx}.VariableBlockPath=this.VariableBlockPath;
                    ret{idx}.VariableSignalName=this.VariableSignalName;
                    ret{idx}.VariableValue=this.VariableValue;
                    ret{idx}.SignalIndex=idx;
                    ret{idx}.TimeSourceRule=this.TimeSourceRule;
                    ret{idx}.WorkspaceParser=this.WorkspaceParser;
                end
                return
            end
        end


        function ret=allowSelectiveChildImport(~)
            ret=true;
        end


        function ret=isVirtualNode(~)
            ret=false;
        end


        function ret=getRepresentsRun(~)
            ret=false;
        end


        function setRunMetaData(~,~,~)
        end
    end
end


function[pieces2,tempBlkPath,blkName]=locHelperSplitString(blkPath)

    tempBlkPath=strrep(blkPath,'//','_dBl_sLaSh_');

    pieces2=regexp(tempBlkPath,'\/','split');

    pieces2=cellfun(@(x)strrep(x,'_dBl_sLaSh_','//'),pieces2,...
    'UniformOutput',false);
    blkName=pieces2{end};
end
