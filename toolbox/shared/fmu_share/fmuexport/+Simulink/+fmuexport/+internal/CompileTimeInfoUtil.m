

classdef(Hidden=true)CompileTimeInfoUtil<handle




    properties(SetAccess=private,GetAccess=public)

model

UID
    end

    methods(Access=public)
        function this=CompileTimeInfoUtil(model)


            this.model=model;
            try
                bd=fmudialog.createCompiledBlockDiagram(this.model);
                bd.init;
                bdCompObj=onCleanup(@()bd.term);
            catch ME
                rethrow(ME);
            end
            this.UID=Simulink.BlockDiagram.getChecksum(this.model);
            Simulink.fmuexport.internal.CompileTimeInfoUtil.createCompileTimeInfoObject(this.model);
            if~isempty(bdCompObj)&&bdCompObj.isvalid
                bdCompObj.delete;
            end
        end

        function delete(this)
            Simulink.fmuexport.internal.CompileTimeInfoUtil.cleanupCompileTimeInfoObject(this.model);
        end
    end

    methods(Static)
        function uMap=staticUnitMap(model,newUnitMap)
            persistent unitMap;
            if isempty(unitMap)
                unitMap=containers.Map('KeyType','char','ValueType','any');
            end
            if nargin>=2
                if isempty(newUnitMap)
                    if isKey(unitMap,model)
                        remove(unitMap,model);
                    end
                else
                    unitMap(model)=newUnitMap;
                end
            end
            if isKey(unitMap,model)
                uMap=unitMap(model);
            else
                uMap=containers.Map('KeyType','char','ValueType','char');
            end
        end

        function inports=staticInportsMap(model,newInports)
            persistent inportsMap;
            if isempty(inportsMap)
                inportsMap=containers.Map('KeyType','char','ValueType','any');
            end
            if nargin>=2
                if isempty(newInports)
                    if isKey(inportsMap,model)
                        remove(inportsMap,model);
                    end
                else
                    inportsMap(model)=newInports;
                end
            else
                if isKey(inportsMap,model)
                    inports=inportsMap(model);
                else
                    inports={};
                end
            end
        end

        function outports=staticOutportsMap(model,newOutports)
            persistent outportsMap;
            if isempty(outportsMap)
                outportsMap=containers.Map('KeyType','char','ValueType','any');
            end
            if nargin>=2
                if isempty(newOutports)
                    if isKey(outportsMap,model)
                        remove(outportsMap,model);
                    end
                else
                    outportsMap(model)=newOutports;
                end
            else
                if isKey(outportsMap,model)
                    outports=outportsMap(model);
                else
                    outports={};
                end
            end
        end

        function createCompileTimeInfoObject(model)
            unitMap=containers.Map('KeyType','char','ValueType','char');


            inports=find_system(model,...
            'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
            'SearchDepth','1',...
            'blocktype','Inport');
            inportlist=[];
            for i=1:length(inports)
                b=inports{i};
                p.blockPath=b;
                p.portNumber=get_param(b,'Port');
                p.graphicalName=get_param(b,'Name');
                p.sampleTimeRaw=get_param(b,'CompiledSampleTime');
                if iscell(p.sampleTimeRaw)
                    sampleTimeStrCell=cellfun(@(x)num2str(x,'%.16g '),sampletimeArray,'UniformOutput',false);
                    p.sampleTime=['[ [',sampleTimeStrCell{1},']'];
                    for j=2:length(sampleTimeStrCell)
                        p.sampleTime=[p.sampleTime,'; [',sampleTimeStrCell{j},'] '];
                    end
                    p.sampleTime=[p.sampleTime,']'];
                else
                    p.sampleTime=['[',num2str(p.sampleTimeRaw,'%.16g '),']'];
                end
                val=get_param(b,'CompiledPortDimensions');p.dimension=['[',num2str(val.Outport(2:end)),']'];p.dimRaw=val.Outport(2:end);
                val=get_param(b,'CompiledPortDataTypes');p.dataType=val.Outport{1};
                compiledUnit=get_param(b,'CompiledPortUnits');
                handle=get_param(b,'PortHandles');handle=handle.Outport(1);
                p.busType=get_param(handle,'CompiledBusType');
                unitStr='';
                if~isempty(compiledUnit)
                    unitStr=compiledUnit.Outport{1};
                end
                p.unit=unitStr;
                val=get_param(b,'CompiledPortComplexSignals');
                p.complex=val.Outport(1);
                val=get_param(b,'CompiledPortFrameData');
                p.frameData=val.Outport(1);
                p.dimMode=get_param(handle,'CompiledPortDimensionsMode');
                inportlist=[inportlist,p];
                unitMap(inports{i})=unitStr;
            end


            outports=find_system(model,...
            'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
            'SearchDepth','1',...
            'blocktype','Outport');
            outportlist=[];
            for i=1:length(outports)
                b=outports{i};
                p.blockPath=b;
                p.graphicalName=get_param(b,'Name');
                p.sampleTimeRaw=get_param(b,'CompiledSampleTime');
                if iscell(p.sampleTimeRaw)
                    sampleTimeStrCell=cellfun(@(x)num2str(x,'%.16g '),sampletimeArray,'UniformOutput',false);
                    p.sampleTime=['[ [',sampleTimeStrCell{1},']'];
                    for j=2:length(sampleTimeStrCell)
                        p.sampleTime=[p.sampleTime,'; [',sampleTimeStrCell{j},'] '];
                    end
                    p.sampleTime=[p.sampleTime,']'];
                else
                    p.sampleTime=['[',num2str(p.sampleTimeRaw,'%.16g '),']'];
                end
                p.portNumber=get_param(b,'Port');
                val=get_param(b,'CompiledPortDimensions');p.dimension=['[',num2str(val.Inport(2:end)),']'];p.dimRaw=val.Inport(2:end);
                val=get_param(b,'CompiledPortDataTypes');p.dataType=val.Inport{1};
                compiledUnit=get_param(b,'CompiledPortUnits');
                handle=get_param(b,'PortHandles');handle=handle.Inport(1);
                p.busType=get_param(handle,'CompiledBusType');
                unitStr='';
                if~isempty(compiledUnit)
                    unitStr=compiledUnit.Inport{1};
                end
                p.unit=unitStr;
                val=get_param(b,'CompiledPortComplexSignals');
                p.complex=val.Inport(1);
                val=get_param(b,'CompiledPortFrameData');
                p.frameData=val.Inport(1);
                p.dimMode=get_param(handle,'CompiledPortDimensionsMode');
                outportlist=[outportlist,p];
                unitMap(outports{i})=unitStr;
            end
            Simulink.fmuexport.internal.CompileTimeInfoUtil.staticUnitMap(model,unitMap);
            Simulink.fmuexport.internal.CompileTimeInfoUtil.staticInportsMap(model,inportlist);
            Simulink.fmuexport.internal.CompileTimeInfoUtil.staticOutportsMap(model,outportlist);
        end

        function cleanupCompileTimeInfoObject(model)
            emptyMap=containers.Map('KeyType','char','ValueType','any');
            Simulink.fmuexport.internal.CompileTimeInfoUtil.staticUnitMap(model,emptyMap);
            Simulink.fmuexport.internal.CompileTimeInfoUtil.staticInportsMap(model,emptyMap);
            Simulink.fmuexport.internal.CompileTimeInfoUtil.staticOutportsMap(model,emptyMap);
        end

        function obj=queryCompileTimeUnitMap(model)
            obj=Simulink.fmuexport.internal.CompileTimeInfoUtil.staticUnitMap(model);
        end

        function obj=queryCompileTimeInportList(model)
            obj=Simulink.fmuexport.internal.CompileTimeInfoUtil.staticInportsMap(model);
        end

        function obj=queryCompileTimeOutportList(model)
            obj=Simulink.fmuexport.internal.CompileTimeInfoUtil.staticOutportsMap(model);
        end

        function unit=queryCompiledUnit(unitMap,blockName)
            if isempty(unitMap)
                unit='';
                return;
            end

            try
                modelName=bdroot(blockName);
            catch ME



                if strcmp(ME.identifier,'Simulink:Engine:RTWNameUnableToLocateRootBlock')
                    unit='';
                    return;
                end
            end
            blockName=strrep(blockName,'<Root>',modelName);
            unit='';
            if isKey(unitMap,blockName)
                unit=unitMap(blockName);
            end
        end
    end
end

