

classdef(Hidden=true)ModelInfoUtilsBase<handle
    properties(SetAccess=protected,GetAccess=public)
ModelIdentifier
GUID
Author
Version
Copyright
Description
License
GenerationTool
GenerationDateAndTime
CompatibleRelease
requireMATLAB
FMUType

logCategory

StartTime
StopTime
FixedStepSize

graphicalNameMap

InportList
OutportList
BusNameList
BusObjectList

compileTimeUnitMap


ModelVariableList





UnitDefinitions

EnumTypeMap


TypeTable


TypeOutputTableIdx


TypeParamStartTableVr


DataTypeMap
SimulinkObjectCache


        WarningList cell
        ErrorList cell


        canBeInstantiatedOnlyOncePerProcessOverride(1,1)logical;
        initialUnknownDependenciesOverride(1,1)logical;
    end

    methods(Access=public)
        function this=ModelInfoUtilsBase(model)
            this.ModelIdentifier=model;
            sl_ver=ver('Simulink');
            this.GenerationTool=[sl_ver.Name,' ',sl_ver.Release];
            this.GenerationDateAndTime=datestr(datetime('now','TimeZone','UTC'),'yyyy-mm-ddTHH:MM:SSZ');

            this.logCategory=containers.Map;
            this.UnitDefinitions=containers.Map;
            this.EnumTypeMap=containers.Map;
            this.DataTypeMap=containers.Map;
            this.SimulinkObjectCache=containers.Map;
            this.TypeTable=struct('Real',[],'RealWithDTConv',[],'Integer',[],'IntegerWithDTConv',[],'Boolean',[],'String',[]);
            this.TypeOutputTableIdx=struct('Real',[],'Integer',[],'Boolean',[],'String',[]);
            this.TypeParamStartTableVr=struct('Real',[],'Integer',[],'Boolean',[],'String',[]);

        end

        function delete(this)
            this.reportCachedWarning();
        end
    end

    methods(Access=protected)
        function addToModelVariableList(this,gname,xmlname,cgname,scope,causality,datatype,dimensions,cont_state,is_derivative)
            try
                if strcmp(causality,'parameter')
                    signalProp=this.resolveSignalPropForParam(gname,scope);
                elseif strcmp(causality,'input')||strcmp(causality,'output')
                    signalProp=this.resolveSignalPropForPort(gname,scope);
                elseif strcmp(causality,'local')&&strcmp(this.FMUType,'CS')
                    signalProp=this.resolveSignalPropForInternal(gname);
                else
                    signalProp=struct('min','','max','','unit','','description','','startVal','');
                end
            catch ME
                this.WarningList{end+1}={'FMUExport:FMU:FMU2ExpCSParamAttributesNotExported',gname};
                signalProp=struct('min','','max','','unit','','description','','startVal','');
            end
            var.c_name=cgname;
            var.g_name=gname;
            var.xml_name=xmlname;
            var.causality=causality;
            var.is_cont_state=cont_state;
            var.is_derivative=is_derivative;
            var.dimensions=dimensions;
            var.unit=signalProp.unit;
            var.min=signalProp.min;
            var.max=signalProp.max;
            var.enumName='';
            var.tag='';
            var.elementAccess='';
            if~isempty(signalProp.description)
                var.description=signalProp.description;
            else
                var.description=gname;
            end

            var.orig_dt=datatype;

            var.doDataConversion=false;


            if strcmp(var.causality,'local')
                datatype=this.convertToFMUSupportedType(xmlname,var.orig_dt);


                if~strcmp(var.orig_dt,datatype)
                    var.doDataConversion=true;
                end
            end


            if strcmp(datatype,'double')
                var.variability='continuous';
            else
                var.variability='discrete';
            end
            var.start='';
            var.initial='';
            if strcmp(var.causality,'input')
                var.initial='';
                var.start=0;
            elseif strcmp(var.causality,'output')
                var.initial='calculated';
            elseif strcmp(var.causality,'parameter')
                var.initial='exact';
                var.variability='tunable';
                var.start=signalProp.startVal;
            elseif strcmp(var.causality,'local')
                var.initial='calculated';
                var.start=signalProp.startVal;
            else
            end


            if~isempty(var.unit)&&~this.UnitDefinitions.isKey(var.unit)&&strcmp(datatype,'double')
                this.UnitDefinitions(var.unit)=struct('name',var.unit);
            end
            fmiType=this.simulinkDataTypetoFMIType(datatype,xmlname);
            var.dt=fmiType;
            if startsWith(datatype,'enum:')
                enumName=datatype(6:end);
                assert(~isempty(enumName));
                var.enumName=enumName;
                if strcmp(var.dt,'Enumeration')&&strcmp(var.causality,'input')
                    enumObj=this.EnumTypeMap(enumName);
                    var.start=enumObj.Values(enumObj.DefaultMember);
                end
                var.start=num2str(int32(var.start));
            else
                var.start=eval(['num2str(',datatype,'(var.start));']);
                if strcmp(datatype,'double')
                    var.min=eval(['num2str(',datatype,'(var.min));']);
                    var.max=eval(['num2str(',datatype,'(var.max));']);
                else
                    var.min=eval(['num2str(',datatype,'(ceil(var.min)));']);
                    var.max=eval(['num2str(',datatype,'(floor(var.max)));']);
                end
            end
            tableType=var.dt;
            if strcmp(tableType,'Enumeration')
                tableType='Integer';
            end
            if~isfield(this.TypeTable,tableType)
                this.TypeTable.(tableType)=[];
                this.TypeOutputTableIdx.(tableType)=[];
            end
            var.vr=length(this.TypeTable.(tableType));
            this.ModelVariableList=[this.ModelVariableList;var];
            this.TypeTable.(tableType)=[this.TypeTable.(tableType);length(this.ModelVariableList)];

            if var.doDataConversion
                if strcmp(tableType,'Integer')
                    this.TypeTable.IntegerWithDTConv=[this.TypeTable.IntegerWithDTConv;length(this.ModelVariableList)];
                elseif strcmp(tableType,'Real')
                    this.TypeTable.RealWithDTConv=[this.TypeTable.RealWithDTConv;length(this.ModelVariableList)];
                end
            end
            if strcmp(var.causality,'output');this.TypeOutputTableIdx.(tableType)=[this.TypeOutputTableIdx.(tableType);length(this.TypeTable.(tableType))];end
        end

        function sglProp=resolveSignalPropForPort(this,g_name,flag)
            sglProp=struct('min','','max','','unit','','description','','startVal','');
            [var,~]=strtok(g_name,'(');
            blockPath=getSimulinkBlockHandle([this.ModelIdentifier,'/',g_name]);
            if blockPath<0

                blockPath=getSimulinkBlockHandle([this.ModelIdentifier,'/',var]);
                if blockPath<0

                    blockPath=getSimulinkBlockHandle([this.ModelIdentifier,'/',strtok(g_name,'.')]);
                end
            end
            if blockPath>0
                unitObject=Simulink.fmuexport.internal.CompileTimeInfoUtil.queryCompiledUnit(this.compileTimeUnitMap,['<Root>/',get_param(blockPath,'name')]);
                sglProp.description=get_param(blockPath,'Description');
                sglProp.min=this.getMinimumValue(blockPath);
                sglProp.max=this.getMaximumValue(blockPath);
                sglProp.unit=unitObject;
            end

            if isKey(this.DataTypeMap,var)
                mappedBusType=this.DataTypeMap(var);
                mappedProp=this.resolveSignalPropForParam(mappedBusType,flag);
                if isempty(sglProp.min)
                    sglProp.min=mappedProp.min;
                end
                if isempty(sglProp.max)
                    sglProp.max=mappedProp.max;
                end
                if isempty(sglProp.unit)
                    sglProp.unit=mappedProp.unit;
                end
                if isempty(sglProp.description)
                    sglProp.description=mappedProp.description;
                end
            end
        end

        function sglProp=resolveSignalPropForParam(this,g_name,flag)
            evalStr=strrep(strrep(g_name,'[','('),']',')');

            lastParens=find(evalStr=='(',1,'last');
            scalarValueMayContainUnit=false;
            if isempty(lastParens)||~endsWith(evalStr,')')

                var=evalStr;idx='';
            else
                var=evalStr(1:lastParens-1);idx=evalStr(lastParens:end);
                if endsWith(evalStr,['.Value',idx])



                    scalarValueMayContainUnit=true;

                end
            end
            evalKey=[var,'_',flag];
            if isKey(this.SimulinkObjectCache,evalKey)
                evalVal=this.SimulinkObjectCache(evalKey);
            else
                if isempty(flag)
                    evalVal=Simulink.data.evalinGlobal(this.ModelIdentifier,var);
                elseif length(flag)>=8&&strcmp(flag(1:8),'InstArg_')
                    blkPath=flag(9:end);
                    bps=strsplit(blkPath,':');
                    names=strsplit(evalStr,':');
                    evalStr=names{end};
                    [var,idx]=strtok(evalStr,'(');
                    evalVal=this.getInstArgValue(bps,var);
                else
                    evalWS=get_param(flag,'ModelWorkspace');
                    evalVal=evalWS.evalin(var);
                end
                this.SimulinkObjectCache(evalKey)=evalVal;
            end
            sglProp=struct('min','','max','','unit','','description','','startVal','');
            if isa(evalVal,'Simulink.LookupTable')
                sglProp.startVal=evalVal.Table.Value(str2num(idx));
                sglProp.min=evalVal.Table.Min;
                sglProp.max=evalVal.Table.Max;
                sglProp.unit=evalVal.Table.Unit;
                sglProp.description=evalVal.Table.Description;
            elseif isa(evalVal,'Simulink.lookuptable.Table')

                sglProp.min=evalVal.Min;
                sglProp.max=evalVal.Max;
                sglProp.unit=evalVal.Unit;
                sglProp.description=evalVal.Description;
            elseif isa(evalVal,'Simulink.Breakpoint')
                sglProp.startVal=evalVal.Breakpoints.Value(str2num(idx));
                sglProp.min=evalVal.Breakpoints.Min;
                sglProp.max=evalVal.Breakpoints.Max;
                sglProp.unit=evalVal.Breakpoints.Unit;
                sglProp.description=evalVal.Breakpoints.Description;
            elseif isa(evalVal,'Simulink.lookuptable.Breakpoint')
                sglProp.min=evalVal.Min;
                sglProp.max=evalVal.Max;
                sglProp.unit=evalVal.Unit;
                sglProp.description=evalVal.Description;
            elseif isa(evalVal,'Simulink.Parameter')
                if isa(evalVal.Value,'Simulink.data.Expression')

                    c_expr=char(evalVal.Value.ExpressionString);
                    evalVal.Value=slResolve(c_expr,this.ModelIdentifier,'expression');
                    evalVal.Dimensions=size(evalVal.Value);
                end
                v=reshape(evalVal.Value,evalVal.Dimensions);
                index=str2num(idx);
                if isempty(index)
                    sglProp.startVal=v;
                elseif length(index)==1
                    sglProp.startVal=v(index);
                else
                    sglProp.startVal=v(index(1),index(2));
                end
                sglProp.min=evalVal.Min;
                sglProp.max=evalVal.Max;
                sglProp.unit=evalVal.Unit;
                sglProp.description=evalVal.Description;
            elseif isa(evalVal,'Simulink.Signal')
                sglProp.startVal=evalVal.InitialValue;
                sglProp.min=evalVal.Min;
                sglProp.max=evalVal.Max;
                sglProp.unit=evalVal.Unit;
                sglProp.description=evalVal.Description;
            elseif isa(evalVal,'Simulink.Bus')
                sglProp.description=evalVal.Description;
            elseif isa(evalVal,'Simulink.BusElement')



                idx=strtok(idx,')');
                index=str2num([idx,')']);
                if length(index)==1
                    evalVal=evalVal(index);
                end
                sglProp.min=evalVal.Min;
                sglProp.max=evalVal.Max;
                sglProp.unit=evalVal.Unit;
                sglProp.description=evalVal.Description;
            else
                if isempty(idx)
                    sglProp.startVal=evalVal;
                else
                    sglProp.startVal=eval(['evalVal',idx]);
                end
                if isKey(this.DataTypeMap,evalStr)
                    mappedBusType=this.DataTypeMap(evalStr);
                    mappedProp=this.resolveSignalPropForParam(mappedBusType,'');
                    sglProp.min=mappedProp.min;
                    sglProp.max=mappedProp.max;
                    sglProp.unit=mappedProp.unit;
                    sglProp.description=mappedProp.description;
                end
                if scalarValueMayContainUnit
                    objProp=this.resolveSignalPropForParam(var(1:end-length('.Value')),flag);
                    sglProp.min=objProp.min;
                    sglProp.max=objProp.max;
                    sglProp.unit=objProp.unit;
                    sglProp.description=objProp.description;
                end
            end
        end

        function sglProp=resolveSignalPropForInternal(this,g_name)
            evalStr=strrep(strrep(g_name,'[','('),']',')');

            lastParens=find(g_name=='[',1,'last');
            if isempty(lastParens)

                var=evalStr;idx='';
            else

                var=evalStr(1:lastParens-1);idx=evalStr(lastParens:end);
            end
            evalVal=Simulink.data.evalinGlobal(this.ModelIdentifier,var);
            sglProp=struct('min','','max','','unit','','description','','startVal','');
            if isa(evalVal,'Simulink.Signal')
                sglProp.startVal=str2num(evalVal.InitialValue);
                sglProp.min=evalVal.Min;
                sglProp.max=evalVal.Max;
                sglProp.unit=evalVal.Unit;
                sglProp.description=evalVal.Description;
            else
                if isempty(idx)
                    sglProp.startVal=evalVal;
                else
                    sglProp.startVal=eval(['evalVal',idx]);
                end
                if isKey(this.DataTypeMap,g_name)
                    mappedBusType=this.DataTypeMap(g_name);
                    mappedProp=this.resolveSignalPropForParam(mappedBusType,'');
                    sglProp.min=mappedProp.min;
                    sglProp.max=mappedProp.max;
                    sglProp.unit=mappedProp.unit;
                    sglProp.description=mappedProp.description;
                end
            end
        end

        function reportCachedWarning(this)
            for i=1:length(this.WarningList)
                item=this.WarningList{i};
                DAStudio.warning(item{1},item{2});
            end
        end

        function evalVal=getInstArgValue(this,bps,var)
            instArgs=get_param(bps{1},'InstanceParameters');
            for j=1:length(instArgs)
                isSamePath=false;
                path=instArgs(j).Path.convertToCell;
                if(isempty(path)&&length(bps)==1)||(~isempty(path)&&isequal(intersect(bps,path),path))
                    isSamePath=true;
                end
                if strcmp(instArgs(j).Name,var)&&isSamePath

                    if isempty(instArgs(j).Value)


                        if length(bps)==1
                            submdl=get_param(bps{1},'ModelName');
                            evalWS=get_param(submdl,'ModelWorkspace');
                            evalVal=evalWS.evalin(var);
                        else
                            bps(1)=[];
                            evalVal=this.getInstArgValue(this,bps,var);
                        end
                    else

                        evalVal=slResolve(instArgs(j).Value,bps{1});
                    end
                end
            end
        end

        function minValue=getMinimumValue(this,blk)
            minValue=get_param(blk,'OutMin');

            if isnan(str2double(minValue))
                if isvarname(minValue)&&hasVariable(get_param(this.ModelIdentifier,'ModelWorkspace'),minValue)
                    minValue=getVariable(get_param(this.ModelIdentifier,'ModelWorkspace'),minValue);
                else
                    minValue=Simulink.data.evalinGlobal(this.ModelIdentifier,minValue);
                end
                if isa(minValue,'Simulink.Parameter')
                    minValue=minValue.Value;
                end
            else
                minValue=str2double(minValue);
            end
        end

        function maxValue=getMaximumValue(this,blk)
            maxValue=get_param(blk,'OutMax');

            if isnan(str2double(maxValue))
                if isvarname(maxValue)&&hasVariable(get_param(this.ModelIdentifier,'ModelWorkspace'),maxValue)
                    maxValue=getVariable(get_param(this.ModelIdentifier,'ModelWorkspace'),maxValue);
                else
                    maxValue=Simulink.data.evalinGlobal(this.ModelIdentifier,maxValue);
                end
                if isa(maxValue,'Simulink.Parameter')
                    maxValue=maxValue.Value;
                end
            else
                maxValue=str2double(maxValue);
            end
        end

        function exportedTypeName=convertToFMUSupportedType(this,varName,origTypeName)
            exportedTypeName=origTypeName;
            warnID='FMUExport:FMU:FMU2ExpCSIVAutoConverted';
            switch origTypeName
            case{'int8','uint8','int16','uint16','uint32','int64','uint64'}
                exportedTypeName='int32';
                DAStudio.warning(warnID,varName,origTypeName,exportedTypeName);
            case{'single','half'}
                exportedTypeName='double';
                DAStudio.warning(warnID,varName,origTypeName,exportedTypeName);
            end
        end

    end

    methods(Static)
        function guid=ModelChecksumToGUID(checksum)

            cs=sprintf('%x',checksum);

            cslong=repmat(cs,1,8);
            cs32=cslong(1:32);

            guid=[cs32(1:8),'-',cs32(9:12),'-',cs32(13:16),'-',cs32(17:20),'-',cs32(21:32)];
        end

        function fmitype=simulinkDataTypetoFMIType(type,xmlname)
            switch type
            case 'double'
                fmitype='Real';
            case 'int32'
                fmitype='Integer';
            case 'logical'
                fmitype='Boolean';
            case 'boolean'
                fmitype='Boolean';
            case 'string'
                fmitype='String';
            otherwise
                if startsWith(type,'enum:')
                    fmitype='Enumeration';
                else
                    error(DAStudio.message('FMUExport:FMU:UnknownDataType',xmlname,type));
                end
            end
        end

        function out=getRelease()
            r=ver('Simulink');
            out=strrep(strrep(r.Release,'(',''),')','');
        end

        function out=getPlatform()
            out=computer;
        end

        function out=UseRefactorCode()
            out=true;
        end
    end

end

