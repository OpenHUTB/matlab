

classdef(Hidden=true)ModelInfoUtils<handle
    properties(SetAccess=private,GetAccess=public)

SystemName
ModelIdentifier
GUID
FMUType
Description
Author
Version
Copyright
License
GenerationTool
GenerationDateAndTime
CompatibleRelease
requireMATLAB


ModelFileName
ProjectFileName


InportList
OutportList
ModelArgumentList
UnitDefinitions
        BusNameList;
        BusObjectList;
        busObjSizeMap;
        busEleInfoTypeMap;
EnumTypeMap


graphicalNameMap
resolvedValue


ModelVariableList
VRCounter

StartTime
StopTime

bdCompObj
bdLoadObj
bdWarnObj
bdWarnState

ModelWS

FixedStepSize
        canBeInstantiatedOnlyOncePerProcessOverride(1,1)logical=true;
        initialUnknownDependenciesOverride(1,1)logical=false;
SourceFileList
logCategory
    end

    methods(Static)
        function guid=ModelChecksumToGUID(checksum)

            cs=sprintf('%x',checksum);

            cslong=repmat(cs,1,8);
            cs32=cslong(1:32);

            guid=[cs32(1:8),'-',cs32(9:12),'-',cs32(13:16),'-',cs32(17:20),'-',cs32(21:32)];
        end

    end

    methods(Access=private)

        function constructModelDataBeforeCompile(this,model,modeldat)


            this.SystemName=model;
            this.ProjectFileName=modeldat.ProjectName;
            this.ModelFileName=modeldat.ModelName;
            this.ModelIdentifier=model;
            this.Description=modeldat.Description;
            this.Author=modeldat.Author;
            this.Version=get_param(model,'ModelVersion');
            this.Copyright=modeldat.Copyright;
            this.License=modeldat.License;
            sl_ver=ver('Simulink');
            this.GenerationTool=[sl_ver.Name,' ',sl_ver.Release];
            this.CompatibleRelease=sl_ver.Release(2:end-1);
            this.requireMATLAB='yes';
            this.GenerationDateAndTime=datestr(datetime('now','TimeZone','UTC'),'yyyy-mm-ddTHH:MM:SSZ');
            this.FixedStepSize=[];
            this.FMUType='CS';
        end

        function addScalarVariableToList(this,varName,varAccess,type,dt,name,ts,unit)

            scalarVar.dt=dt;
            scalarVar.causality=type;
            scalarVar.xml_name=[name,strrep(strrep(varAccess,'(','['),')',']')];
            scalarVar.tag=varName;
            scalarVar.elementAccess=varAccess;
            scalarVar.vr=this.VRCounter.(dt);
            scalarVar.is_derivative=0;


            if strcmp(type,'parameter')

                scalarVar.variability='tunable';
                scalarVar.description=['Model Argument: ',varName];
                scalarVar.initial='exact';
                if isempty(this.resolvedValue)
                    value=this.ModelWS.evalin([varName,varAccess]);
                else
                    value=evalin('caller',['this.resolvedValue',varAccess]);
                end
                scalarVar.start=num2str(value,'%.18g ');
                scalarVar.unit='(null)';

                if~isreal(value)

                    throwAsCaller(MSLException([],message('FMUShare:FMU:InvalidComplexParameterValue',[varName,varAccess])));
                end
            elseif strcmp(type,'input')
                scalarVar.description=['Input Port: ',name];

                if ts(1)==0
                    scalarVar.variability='continuous';
                else
                    scalarVar.variability='discrete';
                end
                scalarVar.initial='(null)';


                if strcmp(dt,'Boolean')
                    scalarVar.start='false';
                elseif strcmp(dt,'String')
                    scalarVar.start='';
                else
                    scalarVar.start='0';
                end

                if~isempty(unit)&&strcmp(dt,'Real')
                    scalarVar.unit=unit;
                    if~this.UnitDefinitions.isKey(unit)
                        this.UnitDefinitions(unit)=struct('name',unit);
                    end
                else
                    scalarVar.unit='(null)';
                end



            elseif strcmp(type,'output')
                scalarVar.description=['Output Port: ',name];

                if ts(1)==0
                    scalarVar.variability='continuous';
                else
                    scalarVar.variability='discrete';
                end
                scalarVar.initial='calculated';






                scalarVar.start='(null)';

                if~isempty(unit)&&strcmp(dt,'Real')
                    scalarVar.unit=unit;
                    if~this.UnitDefinitions.isKey(unit)
                        this.UnitDefinitions(unit)=struct('name',unit);
                    end
                else
                    scalarVar.unit='(null)';
                end
            else
                assert(false,'Invalid variable type.');
            end


            this.ModelVariableList=[this.ModelVariableList,scalarVar];
            this.VRCounter.(dt)=this.VRCounter.(dt)+1;
        end

        function ret=isStringDataType(this,dtStr)
            try
                if Simulink.data.evalinGlobal(this.SystemName,['exist(''',dtStr,''', ''var'')'])


                    [~]=Simulink.data.evalinGlobal(this.SystemName,dtStr);
                    ret=false;
                    return;
                end
            catch
            end

            if isempty(Simulink.internal.getStringDTExprFromDTName(dtStr))
                ret=false;
            else
                ret=true;
            end
        end

        function ret=isBusDataType(this,dtStr)
            try

                if startsWith(dtStr,'Bus:')
                    dtStr=strtrim(dtStr(5:end));
                end

                if Simulink.data.evalinGlobal(this.SystemName,['exist(''',dtStr,''', ''var'')'])
                    dtObj=Simulink.data.evalinGlobal(this.SystemName,dtStr);
                    if isa(dtObj,'Simulink.Bus')
                        ret=true;
                        return;
                    end
                end
            catch
            end

            ret=false;
        end

        function ret=isAliasDataType(this,dtStr)
            try
                if Simulink.data.evalinGlobal(this.SystemName,['exist(''',dtStr,''', ''var'')'])
                    dtObj=Simulink.data.evalinGlobal(this.SystemName,dtStr);
                    if isa(dtObj,'Simulink.AliasType')
                        ret=true;
                        return;
                    end
                end
            catch
            end

            ret=false;
        end

        function ret=isEnumDataType(this,dtStr)
            try
                if startsWith(dtStr,'Enum:')
                    dtStr=strtrim(dtStr(6:end));
                end

                if~isempty(enumeration(strtrim(dtStr)))

                    ret=true;
                    return;
                end
            catch
            end
            ret=false;
        end

        function ret=isFixptDataType(this,dtStr)

            ret=false;
        end

        function addStructVariableToList(this,varPrefix,varPostfix,type,datatype,name,ts,unit)


            if strcmp(datatype,'double')

                addScalarVariableToList(this,varPrefix,varPostfix,type,'Real',name,ts,unit);
            elseif strcmp(datatype,'int32')

                addScalarVariableToList(this,varPrefix,varPostfix,type,'Integer',name,ts,unit);
            elseif strcmp(datatype,'boolean')

                addScalarVariableToList(this,varPrefix,varPostfix,type,'Boolean',name,ts,unit);
            elseif regexp(datatype,'^(single|u?int8|u?int16|uint32)$')

                throwAsCaller(MSLException([],message('FMUShare:FMU:InvalidBuiltInDataType',datatype)));
            elseif this.isBusDataType(datatype)
                if startsWith(datatype,'Bus:')
                    datatype=strtrim(datatype(5:end));
                end
                dtObj=Simulink.data.evalinGlobal(this.SystemName,datatype);
                if isempty(find(ismember(this.BusNameList,datatype),1))
                    this.BusObjectList{end+1}=dtObj;
                    this.BusNameList{end+1}=datatype;
                    [busDtSize,eleDtInfo]=Simulink.internal.fmushare.datatypeInfo(this.SystemName,datatype);
                    this.busObjSizeMap(datatype)=busDtSize;
                    this.busEleInfoTypeMap(datatype)=eleDtInfo;
                end


                for iter=1:length(dtObj.Elements)
                    assert(isa(dtObj.Elements(iter),'Simulink.BusElement'));
                    this.addArrayVariableToList(varPrefix,[varPostfix,'.',dtObj.Elements(iter).Name],type,dtObj.Elements(iter).Dimensions,dtObj.Elements(iter).DataType,name,ts,dtObj.Elements(iter).Unit);
                end
            elseif this.isStringDataType(datatype)


                throwAsCaller(MSLException([],message('FMUShare:FMU:InvalidStringDataType',datatype)));


            elseif this.isEnumDataType(datatype)
                if startsWith(datatype,'Enum:')
                    datatype=strtrim(datatype(6:end));
                end
                throwAsCaller(MSLException([],message('FMUShare:FMU:InvalidEnumDataType',datatype)));


            elseif this.isFixptDataType(datatype)
                throwAsCaller(MSLException([],message('FMUShare:FMU:InvalidFixptDataType',datatype)));


            elseif this.isAliasDataType(datatype)


                baseType=Simulink.data.evalinGlobal(this.SystemName,[datatype,'.BaseType']);
                addStructVariableToList(this,varPrefix,varPostfix,type,baseType,name,ts,unit);
            else

                throwAsCaller(MSLException([],message('FMUShare:FMU:InvalidDataType',datatype)));
            end
        end

        function addStructVariableToListForModelArg(this,varPrefix,varPostfix,type,class,name)


            if strcmp(class,'double')

                addScalarVariableToList(this,varPrefix,varPostfix,type,'Real',name);
            elseif strcmp(class,'int32')

                addScalarVariableToList(this,varPrefix,varPostfix,type,'Integer',name);
            elseif strcmp(class,'logical')||strcmp(class,'boolean')

                addScalarVariableToList(this,varPrefix,varPostfix,type,'Boolean',name);
            elseif strcmp(class,'struct')

                fields=this.ModelWS.evalin(['fieldnames(',varPrefix,varPostfix,')']);
                for i=1:length(fields)
                    v=[varPrefix,varPostfix,'.',fields{i}];
                    dim=this.ModelWS.evalin(['size(',v,')']);
                    class=this.ModelWS.evalin(['class(',v,')']);
                    this.addArrayVariableToListForModelArg(varPrefix,[varPostfix,'.',fields{i}],type,dim,class,name);
                end
            else

                throwAsCaller(MSLException([],message('FMUShare:FMU:InvalidParameterType',class)));
            end
        end

        function addArrayVariableToList(this,varPrefix,varPostfix,type,dimension,datatype,name,ts,unit)
            if prod(dimension)==1

                this.addStructVariableToList(varPrefix,varPostfix,type,datatype,name,ts,unit);
            else

                dims=ones(1,length(dimension));
                for iter=1:prod(dimension)
                    dimsStr=['(',strjoin(arrayfun(@(x)num2str(x),dims,'UniformOutput',false),','),')'];
                    this.addStructVariableToList(varPrefix,[varPostfix,dimsStr],type,datatype,name,ts,unit);


                    j=length(dims);
                    while 1
                        dims(j)=dims(j)+1;
                        if(j==1||dims(j)<=dimension(j))
                            break;
                        end
                        dims(j)=1;j=j-1;
                    end
                end
            end
        end

        function addArrayVariableToListForModelArg(this,varPrefix,varPostfix,type,dimension,class,name)
            if prod(dimension)==1

                this.addStructVariableToListForModelArg(varPrefix,varPostfix,type,class,name);
            else

                dims=ones(1,length(dimension));
                for iter=1:prod(dimension)
                    dimsStr=['(',strjoin(arrayfun(@(x)num2str(x),dims,'UniformOutput',false),','),')'];
                    this.addStructVariableToListForModelArg(varPrefix,[varPostfix,dimsStr],type,class,name);


                    j=length(dims);
                    while 1
                        dims(j)=dims(j)+1;
                        if(j==1||dims(j)<=dimension(j))
                            break;
                        end
                        dims(j)=1;j=j-1;
                    end
                end
            end
        end

        function creategraphicalNameMap(this,origNames,origNameCausalityPair)

            [validNames,modified_invalid]=matlab.lang.makeValidName(origNames,'Prefix','m_');
            [validNames,modified_dup]=matlab.lang.makeUniqueStrings(validNames);
            modified=modified_invalid|modified_dup;
            if nnz(modified)

                warnID='FMUShare:FMU:FMUShareInvalidOrDuplicatesRenamed';
                modifiedSet=origNames(modified);
                newSet=validNames(modified);
                if numel(modifiedSet)>10
                    modifiedSet_str=[strjoin(modifiedSet(1:10),','),',...'];
                    newSet_str=[strjoin(newSet(1:10),','),',...'];
                else
                    modifiedSet_str=strjoin(modifiedSet,',');
                    newSet_str=strjoin(newSet,',');
                end
                DAStudio.warning(warnID,modifiedSet_str,newSet_str);
            end

            if~isempty(origNames)
                this.graphicalNameMap=containers.Map(origNameCausalityPair,validNames);
            end
        end

        function constructModelDataDuringCompile(this,model)
            this.BusNameList={};
            this.BusObjectList={};
            this.busObjSizeMap=containers.Map('KeyType','char','ValueType','any');
            this.busEleInfoTypeMap=containers.Map('KeyType','char','ValueType','any');
            this.ModelVariableList=[];
            this.VRCounter=struct('Real',0,'Integer',0,'Boolean',0,'String',0);



            this.GUID=this.ModelChecksumToGUID(Simulink.BlockDiagram.getChecksum(model));
            this.StartTime=num2str(evalin('base',get_param(model,'StartTime')),'%.18g ');
            this.StopTime=num2str(evalin('base',get_param(model,'StopTime')),'%.18g ');

            rootInputPorts=find_system(model,'SearchDepth',1,'BlockType','Inport');
            rootOutputPorts=find_system(model,'SearchDepth',1,'BlockType','Outport');
            modelArgsStr=strtrim(get_param(model,'ParameterArgumentNames'));
            if isempty(modelArgsStr)
                rootModelArguments={};
            else
                rootModelArguments=textscan(modelArgsStr,'%s','delimiter',',');
                rootModelArguments=rootModelArguments{1};
            end


            origNames=cell(length(rootInputPorts)+length(rootOutputPorts)+length(rootModelArguments),1);
            origNameCausalityPair=cell(length(rootInputPorts)+length(rootOutputPorts)+length(rootModelArguments),1);
            for i=1:length(rootInputPorts)
                b=rootInputPorts{i};origNames{i}=strtrim(get_param(b,'Name'));
                origNameCausalityPair{i}=[strtrim(get_param(b,'Name')),', input'];
            end
            for i=1:length(rootOutputPorts)
                b=rootOutputPorts{i};origNames{i+length(rootInputPorts)}=strtrim(get_param(b,'Name'));
                origNameCausalityPair{i+length(rootInputPorts)}=[strtrim(get_param(b,'Name')),', output'];
            end
            for i=1:length(rootModelArguments)
                origNames{i+length(rootInputPorts)+length(rootOutputPorts)}=rootModelArguments{i};
                origNameCausalityPair{i+length(rootInputPorts)+length(rootOutputPorts)}=[rootModelArguments{i},', parameter'];
            end
            this.creategraphicalNameMap(origNames,origNameCausalityPair);


            this.UnitDefinitions=containers.Map('KeyType','char','ValueType','any');


            this.InportList=[];
            for i=1:length(rootInputPorts)
                b=rootInputPorts{i};
                p.blockPath=b;
                p.portNumber=get_param(b,'Port');
                p.graphicalName=get_param(b,'Name');
                p.name=this.graphicalNameMap([strtrim(p.graphicalName),', input']);
                varRoot=['cosimTransformedInput_',num2str(p.portNumber)];
                p.tag=varRoot;

                val=get_param(b,'CompiledSampleTime');p.sampleTime=['[',num2str(val,'%.18g '),']'];ts=val;


                if val(1)<0||val(2)<0
                    throw(MSLException([],message('FMUShare:FMU:InvalidInputSampleTime',b,p.sampleTime)));
                end
                val=get_param(b,'CompiledPortDimensions');p.dimension=['[',num2str(val.Outport(2:end)),']'];dim=val.Outport(2:end);
                val=get_param(b,'CompiledPortDataTypes');p.dataType=val.Outport{1};
                val=get_param(b,'CompiledPortUnits');p.unit=val.Outport{1};


                val=get_param(b,'CompiledPortComplexSignals');
                if val.Outport(1)==1
                    throwAsCaller(MSLException([],message('FMUShare:FMU:InvalidComplexInputValue',b)));
                end
                val=get_param(b,'CompiledPortFrameData');
                if val.Outport(1)==1
                    throwAsCaller(MSLException([],message('FMUShare:FMU:InvalidFrameInputValue',b)));
                end

                ph=get_param(b,'PortHandles');
                ph=ph.Outport(1);
                val=get_param(ph,'CompiledPortDimensionsMode');
                if val==1
                    throwAsCaller(MSLException([],message('FMUShare:FMU:InvalidInputDimensionsMode',b)));
                end

                val=get_param(ph,'CompiledBusType');
                if strcmp(val,'VIRTUAL_BUS')==1
                    throwAsCaller(MSLException([],message('FMUShare:FMU:InvalidInputBusMode',b)));
                end

                this.InportList=[this.InportList,p];


                this.addArrayVariableToList(varRoot,'','input',dim,p.dataType,p.name,ts,p.unit);
            end


            this.OutportList=[];
            for i=1:length(rootOutputPorts)
                b=rootOutputPorts{i};
                p.blockPath=b;
                p.graphicalName=get_param(b,'Name');
                p.portNumber=get_param(b,'Port');
                p.name=this.graphicalNameMap([strtrim(p.graphicalName),', output']);
                varRoot=['cosimTransformedOutput_',num2str(p.portNumber)];
                p.tag=varRoot;

                val=get_param(b,'CompiledSampleTime');p.sampleTime=['[',num2str(val,'%.18g '),']'];ts=val;


                if val(1)<0||val(2)<0
                    throw(MSLException([],message('FMUShare:FMU:InvalidOutputSampleTime',b,p.sampleTime)));
                end

                val=get_param(b,'CompiledPortDimensions');p.dimension=['[',num2str(val.Inport(2:end)),']'];dim=val.Inport(2:end);
                val=get_param(b,'CompiledPortDataTypes');p.dataType=val.Inport{1};
                val=get_param(b,'CompiledPortUnits');p.unit=val.Inport{1};


                val=get_param(b,'CompiledPortComplexSignals');
                if val.Inport(1)==1
                    throwAsCaller(MSLException([],message('FMUShare:FMU:InvalidComplexOutputValue',b)));
                end
                val=get_param(b,'CompiledPortFrameData');
                if val.Inport(1)==1
                    throwAsCaller(MSLException([],message('FMUShare:FMU:InvalidFrameOutputValue',b)));
                end

                ph=get_param(b,'PortHandles');
                ph=ph.Inport(1);
                val=get_param(ph,'CompiledPortDimensionsMode');
                if val==1
                    throw(MSLException([],message('FMUShare:FMU:InvalidOutputDimensionsMode',b)));
                end

                val=get_param(ph,'CompiledBusType');
                if strcmp(val,'VIRTUAL_BUS')==1
                    throw(MSLException([],message('FMUShare:FMU:InvalidOutputBusMode',b)));
                end

                this.OutportList=[this.OutportList,p];


                this.addArrayVariableToList(varRoot,'','output',dim,p.dataType,p.name,ts,p.unit);
            end


            this.ModelArgumentList=[];
            for i=1:length(rootModelArguments)
                v=rootModelArguments{i};
                p.tag=v;
                p.name=this.graphicalNameMap([v,', parameter']);




                dim=this.ModelWS.evalin(['size(',v,')']);
                p.dimension=['[',num2str(dim),']'];
                class=this.ModelWS.evalin(['class(',v,')']);
                postfix='';
                if(strcmp(class,'Simulink.Parameter'))
                    postfix='.Value';
                    class=this.ModelWS.evalin(['class(',v,postfix,')']);
                end

                this.ModelArgumentList=[this.ModelArgumentList,p];


                this.addArrayVariableToListForModelArg(v,postfix,'parameter',dim,class,p.name);
            end




            if(strcmpi(get_param(model,'SolverType'),'Fixed-step'))
                this.FixedStepSize=get_param(model,'CompiledStepSize');
            end

        end

    end

    methods(Access=public)
        function this=ModelInfoUtils(model,modeldat)
            assert(ischar(model),'Input parameter must be a model name.');

            this.bdWarnState=warning('backtrace','off');
            this.bdWarnObj=onCleanup(@()warning(this.bdWarnState));

            if~bdIsLoaded(model)
                load_system(model);
                this.bdLoadObj=onCleanup(@()close_system(model,0));
            else
                this.bdLoadObj=[];
            end
            if bdIsDirty(model)


                throwAsCaller(MSLException([],message('FMUShare:FMU:CannotExportUnsavedModel',model)));
            end
            if~strcmpi(get_param(model,'LibraryType'),'None')

                throwAsCaller(MSLException([],message('FMUShare:FMU:CannotExportLibrary',model)));
            end
            if strcmpi(get_param(model,'ModelingArchitecture'),'Deployment')


                throw(MSLException([],message('FMUShare:FMU:CannotExportDeploymentDiagram',model)));
            end
            if~strcmpi(get_param(model,'SimulationMode'),'normal')&&...
                ~strcmpi(get_param(model,'SimulationMode'),'accelerator')


                throwAsCaller(MSLException([],message('FMUShare:FMU:CannotExportRaccelOrCodeGenBasedTarget',model)));
            end

            this.graphicalNameMap=containers.Map;
            this.ModelWS=get_param(model,'ModelWorkspace');
            this.logCategory=containers.Map;
            this.logCategory('logAll')='All messages from FMU, MATLAB exceptions, and MATLAB command window.';
            this.logCategory('logStatusError')='Error message from FMU or MATLAB exceptions.';
            this.EnumTypeMap=containers.Map;


            this.constructModelDataBeforeCompile(model,modeldat);


            try
                bd=fmudialog.createCompiledBlockDiagram(model);
                bd.init;
                this.bdCompObj=onCleanup(@()bd.term);
            catch ex

                throwAsCaller(MSLException([],message('FMUShare:FMU:CannotCompileModel',model,ex.message)));
            end

            this.constructModelDataDuringCompile(model);


            this.bdCompObj.delete;
            if~isempty(this.bdLoadObj)
                this.bdLoadObj.delete;
            end
            this.bdWarnObj.delete;
        end

        function delete(this)
            if~isempty(this.bdCompObj)&&this.bdCompObj.isvalid
                this.bdCompObj.delete;
            end
            if~isempty(this.bdLoadObj)&&this.bdLoadObj.isvalid
                this.bdLoadObj.delete;
            end
            if~isempty(this.bdWarnObj)&&this.bdWarnObj.isvalid
                this.bdWarnObj.delete;
            end
        end

        function out=getName(this)
            out=this.SystemName;
        end

        function out=getGUID(this)
            out=this.GUID;
        end

        function out=getModelIdentifier(this)
            out=this.ModelIdentifier;
        end

        function out=getDescription(this)
            out=this.Description;
        end

        function out=getAuthor(this)
            out=this.Author;
        end

        function out=getVersion(this)
            out=this.Version;
        end

        function out=getLicense(this)
            out=this.License;
        end

        function out=getCopyright(this)
            out=this.Copyright;
        end

        function out=getGenerationTool(this)
            out=this.GenerationTool;
        end

        function out=getGenerationDateAndTime(this)
            out=this.GenerationDateAndTime;
        end

        function out=getPlatform(this)
            out=computer;
        end

        function out=getRelease(this)
            r=ver('Simulink');
            out=strrep(strrep(r.Release,'(',''),')','');
        end

        function out=getProjectFileName(this)
            out=this.ProjectFileName;
        end

        function out=getModelFileName(this)
            out=this.ModelFileName;
        end

        function out=getStartTime(this)
            out=this.StartTime;
        end

        function out=hasStopTime(this)
            out=~strcmp('Inf',this.StopTime);
        end

        function out=getStopTime(this)
            out=this.StopTime;
        end

        function out=isFixedStepSolver(this)
            out=~isempty(this.FixedStepSize);
        end

        function out=getCompiledFixedStepSize(this)
            assert(this.isFixedStepSolver);
            out=this.FixedStepSize;
        end

        function out=getCompatibleRelease(this)
            out=this.CompatibleRelease;
        end
        function addRuntTimeParameterFromRapid(this,parameters)
            for i=1:length(parameters)
                class=parameters(i).dataTypeName;
                for j=1:length(parameters(i).map)
                    pname=parameters(i).map(j).Identifier;
                    dim=parameters(i).map(j).Dimensions;
                    serilizedValues=parameters(i).values(parameters(i).map(j).ValueIndices(1):parameters(i).map(j).ValueIndices(2));
                    this.resolvedValue=reshape(serilizedValues,dim);

                    this.addArrayVariableToListForModelArg(pname,'','parameter',dim,class,pname);
                    this.resolvedValue=[];
                end
            end
        end
    end

end
