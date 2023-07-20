classdef DatasetElementParser<Simulink.sdi.internal.import.VariableParser





    methods


        function ret=supportsType(~,obj)
            ret=...
            isa(obj,'Simulink.SimulationData.Element')&&...
            locHasProp(obj,'Values')&&...
            isscalar(obj);
        end


        function ret=getRootSource(this)
            ret=this.VariableName;
        end


        function ret=getTimeSource(~)
            ret='';
        end


        function ret=getDataSource(~)
            ret='';
        end


        function ret=getBlockSource(this)
            if locHasProp(this.VariableValue,'BlockPath')
                ret=Simulink.sdi.internal.import.DatasetElementParser.concatMdlRefBlockPath(...
                this.VariableValue.BlockPath);
            else
                ret='';
            end
        end


        function ret=getFullBlockPath(this)
            if locHasProp(this.VariableValue,'BlockPath')
                ret=this.VariableValue.BlockPath;
            else
                ret=Simulink.SimulationData.BlockPath();
            end
        end


        function ret=getSID(this)
            ret='';
            if locHasProp(this.VariableValue,'BlockPath')
                len=getLength(this.VariableValue.BlockPath);
                if len>0
                    startLoggingOpenModels(this.WorkspaceParser);
                    bpath=getBlock(this.VariableValue.BlockPath,len);
                    interface=Simulink.sdi.internal.Framework.getFramework();
                    try
                        ret=interface.getSID(bpath,true);
                    catch me %#ok<NASGU>
                        ret='';
                    end
                end
            end
        end


        function ret=getModelSource(this)
            import Simulink.SimulationData.BlockPath;


            ret='';
            if locHasProp(this.VariableValue,'BlockPath')
                len=getLength(this.VariableValue.BlockPath);
                if len>0
                    bpath=getBlock(this.VariableValue.BlockPath,1);
                    ret=BlockPath.getModelNameForPath(bpath);
                end
            end


            if isempty(ret)&&locHasProp(this.VariableValue,'DSMWriterBlockPaths')
                if~isempty(this.VariableValue.DSMWriterBlockPaths)
                    bpath=getBlock(this.VariableValue.DSMWriterBlockPaths(1),1);
                    ret=BlockPath.getModelNameForPath(bpath);
                end
            end
        end


        function ret=getSignalLabel(this)
            ret=char(this.VariableValue.Name);



            if locHasProp(this.VariableValue,'BlockPath')&&~isempty(this.VariableValue.BlockPath.SubPath)
                ret=this.VariableValue.BlockPath.SubPath;
            end



            if isempty(ret)&&locHasProp(this.VariableValue,'PropagatedName')
                ret=char(this.VariableValue.PropagatedName);
            end
        end


        function[logName,sigName,propName]=getCustomExportNames(this)




            logName=char(this.VariableValue.Name);
            sigName=char(this.VariableValue.Name);
            if locHasProp(this.VariableValue,'PropagatedName')
                propName=char(this.VariableValue.PropagatedName);
            else
                propName='';
            end
        end


        function ret=getPortIndex(this)
            if locHasProp(this.VariableValue,'PortIndex')
                ret=this.VariableValue.PortIndex;
            else
                ret=[];
            end
        end


        function ret=getHierarchyReference(~)
            ret='';
        end


        function ret=getTimeDim(~)
            ret=[];
        end


        function ret=getSampleDims(~)
            ret=[];
        end


        function ret=getInterpolation(~)
            ret='';
        end



        function ret=getDomainType(this)
            ret='';
            if isa(this.VariableValue,'Stateflow.SimulationData.State')
                ret='sf_state';
            elseif isa(this.VariableValue,'Stateflow.SimulationData.Data')
                ret='sf_data';
            elseif isa(this.VariableValue,'Simulink.SimulationData.DataStoreMemory')
                ret='dsm';
            elseif isa(this.VariableValue,'Simulink.SimulationData.State')
                ret='state';
            elseif isa(this.VariableValue,'sltest.Assessment')
                ret='slt_verify';
            elseif isa(this.VariableValue,'Simulink.SimulationData.Parameter')
                ret='param';
            elseif isa(this.VariableValue,'Simulink.SimulationData.Signal')
                if strcmpi(this.VariableValue.PortType,'inport')
                    ret='outport';
                end
            end
        end


        function ret=getUnit(~)
            ret='';
        end


        function ret=getMetaData(~)
            ret=[];
        end


        function ret=getTimeValues(~)
            ret=[];
        end


        function ret=getDataValues(~)
            ret=[];
        end


        function ret=isHierarchical(this)
            ret=~isempty(this.VariableValue.Values);
        end


        function ret=getChildren(this)

            var.VarName=[this.VariableName,'.Values'];
            var.VarValue=this.VariableValue.Values;
            ret=parseVariables(this.WorkspaceParser,var);



            overrideName=...
            isa(this.VariableValue,'Stateflow.SimulationData.Data')&&...
            isa(var.VarValue,'timeseries');


            forEachDims=getForEachParentDims(this);


            for idx=1:numel(ret)
                ret{idx}.Parent=this;
                if overrideName
                    ret{idx}.VariableValue.Name=this.VariableValue.Name;
                end
                if~isempty(forEachDims)
                    dimIdx=cell(size(forEachDims));
                    [dimIdx{:}]=ind2sub(forEachDims,idx);
                    ret{idx}.ForEachIter=cell2mat(dimIdx);
                end
            end
        end


        function ret=allowSelectiveChildImport(~)
            ret=true;
        end

        function ret=getForEachParentDims(this)
            ret=[];
            if isa(this.VariableValue.Values,'timeseries')&&...
                ~isscalar(this.VariableValue.Values)
                ret=size(this.VariableValue.Values);
            end
        end


        function ret=isVirtualNode(this)




            ret=isHierarchical(this)&&isempty(getForEachParentDims(this));
        end


        function ret=getRepresentsRun(~)
            ret=false;
        end


        function setRunMetaData(~,~,~)
        end


        function[type,writers]=getSharedMemoryInfo(this)
            type=0;
            writers={};
            if isa(this.VariableValue,'Simulink.SimulationData.DataStoreMemory')
                if strcmpi(this.VariableValue.Scope,'global')
                    type=1;
                else
                    type=2;
                end
                writers=cell(size(this.VariableValue.DSMWriterBlockPaths));
                for idx=1:numel(this.VariableValue.DSMWriterBlockPaths)
                    writers{idx}=this.VariableValue.DSMWriterBlockPaths(idx).convertToCell();
                end
            end
        end


        function ret=getTemporalMetaData(this)
            ret=struct.empty();
            if isa(this.VariableValue,'Simulink.SimulationData.DataStoreMemory')
                ret=struct('DSMWriters',this.VariableValue.DSMWriters);
            end
        end


        function ret=getExtendedSDIProperties(this,varargin)



            ret=struct();


            try
                md=this.VariableValue.getVisualizationMetadata();
            catch me %#ok<NASGU>
                md=struct();
            end


            idx=1;
            if~isempty(varargin)
                idx=getLeafIndex(this,varargin{1});
            end


            if iscell(md)&&idx<=numel(md)
                ret=md{idx};
            elseif isstruct(md)&&idx==1
                ret=md;
            end
        end


        function ret=getLeafIndex(this,leafPath)
            ret=1;
            children=this.getLeafPaths();
            pos=find(strcmp(children,leafPath));
            if~isempty(pos)
                ret=pos(1);
            end
        end


        function ret=isTopLevelDatasetElement(~)
            ret=true;
        end
    end


    methods(Static)


        function ret=concatMdlRefBlockPath(bpath)
            import Simulink.SimulationData.BlockPath;
            ret='';
            len=getLength(bpath);
            if len>0
                ret=getBlock(bpath,1);
                for idx=2:len
                    refPath=getBlock(bpath,idx);
                    mdl=BlockPath.getModelNameForPath(refPath);
                    newStart=length(mdl)+1;
                    ret=strcat(ret,refPath(newStart:end));
                end
            end
        end
    end
end


function ret=locHasProp(obj,pn)


    mc=metaclass(obj);
    ret=~isempty(findobj(mc.PropertyList,'-depth',0,'Name',pn));
end