




classdef(Hidden=true)ModelCompileInfoUtils<Simulink.fmuexport.internal.ModelInfoUtilsBase
    properties(SetAccess=private,GetAccess=public)


ModelFileName
ProjectFileName


ModelArgumentList
        busObjSizeMap;
        busEleInfoTypeMap;


resolvedValue
scope
toolCouplingFMUTarget

bdCompObj
bdLoadObj
bdWarnObj
bdWarnState

ModelWS

SourceFileList
    end

    methods(Access=private)
        function constructModelDataBeforeCompile(this,model,modeldat)

            this.ProjectFileName=modeldat.ProjectName;
            this.ModelFileName=modeldat.ModelName;
            this.Description=modeldat.Description;
            this.Author=modeldat.Author;
            this.Version=get_param(model,'ModelVersion');
            this.Copyright=modeldat.Copyright;
            this.License=modeldat.License;
            sl_ver=ver('Simulink');
            this.CompatibleRelease=sl_ver.Release(2:end-1);
            this.requireMATLAB='yes';
            this.FixedStepSize=[];
            this.FMUType='CS';
            this.canBeInstantiatedOnlyOncePerProcessOverride=true;
            this.initialUnknownDependenciesOverride=false;
            this.toolCouplingFMUTarget=~strcmp(modeldat.target,'raccel');
            this.scope=this.ModelIdentifier;
        end

        function addScalarVariableToList(this,varName,varAccess,type,dt,name,ts,unit,gname)
            gname=[gname,strrep(strrep(varAccess,'[','('),']',')')];
            xmlname=[name,strrep(strrep(varAccess,'(','['),')',']')];

            this.addToModelVariableList(gname,xmlname,'',this.scope,type,dt,0,0,0);
            this.ModelVariableList(length(this.ModelVariableList)).tag=varName;
            this.ModelVariableList(length(this.ModelVariableList)).elementAccess=varAccess;
        end

        function ret=isStringDataType(this,dtStr)
            try
                if Simulink.data.evalinGlobal(this.ModelIdentifier,['exist(''',dtStr,''', ''var'')'])


                    [~]=Simulink.data.evalinGlobal(this.ModelIdentifier,dtStr);
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

                if Simulink.data.evalinGlobal(this.ModelIdentifier,['exist(''',dtStr,''', ''var'')'])
                    dtObj=Simulink.data.evalinGlobal(this.ModelIdentifier,dtStr);
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
                if Simulink.data.evalinGlobal(this.ModelIdentifier,['exist(''',dtStr,''', ''var'')'])
                    dtObj=Simulink.data.evalinGlobal(this.ModelIdentifier,dtStr);
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

        function addStructVariableToList(this,varPrefix,varPostfix,type,datatype,name,ts,unit,gname)


            if strcmp(datatype,'double')||strcmp(datatype,'int32')||strcmp(datatype,'boolean')||strcmp(datatype,'logical')

                addScalarVariableToList(this,varPrefix,varPostfix,type,datatype,name,ts,unit,gname);
            elseif regexp(datatype,'^(single|u?int8|u?int16|uint32)$')

                throwAsCaller(MSLException([],message('FMUShare:FMU:InvalidBuiltInDataType',datatype)));
            elseif this.isBusDataType(datatype)
                if startsWith(datatype,'Bus:')
                    datatype=strtrim(datatype(5:end));
                end
                dtObj=Simulink.data.evalinGlobal(this.ModelIdentifier,datatype);
                if isempty(find(ismember(this.BusNameList,datatype),1))
                    this.BusObjectList{end+1}=dtObj;
                    this.BusNameList{end+1}=datatype;
                    [busDtSize,eleDtInfo]=Simulink.internal.fmushare.datatypeInfo(this.ModelIdentifier,datatype);
                    this.busObjSizeMap(datatype)=busDtSize;
                    this.busEleInfoTypeMap(datatype)=eleDtInfo;
                end


                for iter=1:length(dtObj.Elements)
                    assert(isa(dtObj.Elements(iter),'Simulink.BusElement'));
                    this.addArrayVariableToList(varPrefix,[varPostfix,'.',dtObj.Elements(iter).Name],type,dtObj.Elements(iter).Dimensions,dtObj.Elements(iter).DataType,name,ts,dtObj.Elements(iter).Unit,[datatype,'.Elements(',num2str(iter),')']);
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


                baseType=Simulink.data.evalinGlobal(this.ModelIdentifier,[datatype,'.BaseType']);
                addStructVariableToList(this,varPrefix,varPostfix,type,baseType,name,ts,unit,gname);
            else

                throwAsCaller(MSLException([],message('FMUShare:FMU:InvalidDataType',datatype)));
            end
        end

        function addStructVariableToListForModelArg(this,varPrefix,varPostfix,type,class,name)


            if strcmp(class,'double')||strcmp(class,'int32')||strcmp(class,'logical')||strcmp(class,'boolean')

                addScalarVariableToList(this,varPrefix,varPostfix,type,class,name,'','',varPrefix);
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

        function addArrayVariableToList(this,varPrefix,varPostfix,type,dimension,datatype,name,ts,unit,gname)
            if prod(dimension)==1

                this.addStructVariableToList(varPrefix,varPostfix,type,datatype,name,ts,unit,gname);
            else

                dims=ones(1,length(dimension));
                for iter=1:prod(dimension)
                    dimsStr=['(',strjoin(arrayfun(@(x)num2str(x),dims,'UniformOutput',false),','),')'];
                    this.addStructVariableToList(varPrefix,[varPostfix,dimsStr],type,datatype,name,ts,unit,gname);


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
            this.compileTimeUnitMap=Simulink.fmuexport.internal.CompileTimeInfoUtil.queryCompileTimeUnitMap(this.ModelIdentifier);



            this.GUID=this.ModelChecksumToGUID(this.bdCompObj.UID);
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





            this.InportList=Simulink.fmuexport.internal.CompileTimeInfoUtil.queryCompileTimeInportList(model);
            for i=1:length(this.InportList)
                p=this.InportList(i);
                p.name=this.graphicalNameMap([strtrim(p.graphicalName),', input']);
                varRoot=['cosimTransformedInput_',num2str(p.portNumber)];
                this.InportList(i).tag=varRoot;

                val=p.sampleTimeRaw;


                if val(1)<0||val(2)<0
                    throw(MSLException([],message('FMUShare:FMU:InvalidInputSampleTime',p.blockPath,p.sampleTime)));
                end


                if p.complex==1
                    throwAsCaller(MSLException([],message('FMUShare:FMU:InvalidComplexInputValue',p.blockPath)));
                end
                if p.frameData==1
                    throwAsCaller(MSLException([],message('FMUShare:FMU:InvalidFrameInputValue',p.blockPath)));
                end

                if p.dimMode==1
                    throwAsCaller(MSLException([],message('FMUShare:FMU:InvalidInputDimensionsMode',b)));
                end

                if strcmp(p.busType,'VIRTUAL_BUS')==1
                    throwAsCaller(MSLException([],message('FMUShare:FMU:InvalidInputBusMode',b)));
                end


                this.addArrayVariableToList(varRoot,'','input',p.dimRaw,p.dataType,p.name,p.sampleTimeRaw,p.unit,p.name);
            end


            this.OutportList=Simulink.fmuexport.internal.CompileTimeInfoUtil.queryCompileTimeOutportList(model);
            for i=1:length(this.OutportList)
                p=this.OutportList(i);
                p.name=this.graphicalNameMap([strtrim(p.graphicalName),', output']);
                varRoot=['cosimTransformedOutput_',num2str(p.portNumber)];
                this.OutportList(i).tag=varRoot;

                val=p.sampleTimeRaw;


                if val(1)<0||val(2)<0
                    throw(MSLException([],message('FMUShare:FMU:InvalidOutputSampleTime',p.blockPath,p.sampleTime)));
                end


                if p.complex==1
                    throwAsCaller(MSLException([],message('FMUShare:FMU:InvalidComplexOutputValue',b)));
                end
                if p.frameData==1
                    throwAsCaller(MSLException([],message('FMUShare:FMU:InvalidFrameOutputValue',b)));
                end

                if p.dimMode==1
                    throw(MSLException([],message('FMUShare:FMU:InvalidOutputDimensionsMode',b)));
                end

                if strcmp(p.busType,'VIRTUAL_BUS')==1
                    throw(MSLException([],message('FMUShare:FMU:InvalidOutputBusMode',b)));
                end


                this.addArrayVariableToList(varRoot,'','output',p.dimRaw,p.dataType,p.name,p.sampleTimeRaw,p.unit,p.name);
            end


            if this.toolCouplingFMUTarget
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
            end




            if(strcmpi(get_param(model,'SolverType'),'Fixed-step'))
                this.FixedStepSize=get_param(model,'CompiledStepSize');
            end

        end

    end

    methods(Access=public)
        function this=ModelCompileInfoUtils(model,modeldat)
            assert(ischar(model),'Input parameter must be a model name.');
            this=this@Simulink.fmuexport.internal.ModelInfoUtilsBase(model);

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
            this.logCategory('logAll')='All messages from FMU, MATLAB exceptions, and MATLAB command window.';
            this.logCategory('logStatusError')='Error message from FMU or MATLAB exceptions.';


            this.constructModelDataBeforeCompile(model,modeldat);


            this.bdCompObj=Simulink.fmuexport.internal.CompileTimeInfoUtil(model);

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

        function addRuntTimeParameterFromRapid(this,parameters)
            for i=1:length(parameters)
                class=parameters(i).dataTypeName;
                for j=1:length(parameters(i).map)
                    pname=parameters(i).map(j).Identifier;
                    postfix='';
                    if Simulink.data.existsInGlobal(this.ModelIdentifier,pname)
                        this.scope='';
                        objectType=Simulink.data.evalinGlobal(this.ModelIdentifier,['class(',pname,')']);

                    else
                        this.scope=this.ModelIdentifier;
                        objectType=this.ModelWS.evalin(['class(',pname,')']);
                    end
                    if(strcmp(objectType,'Simulink.Parameter'))
                        postfix='.Value';
                    end
                    dim=parameters(i).map(j).Dimensions;
                    serilizedValues=parameters(i).values(parameters(i).map(j).ValueIndices(1):parameters(i).map(j).ValueIndices(2));
                    this.resolvedValue=reshape(serilizedValues,dim);

                    this.addArrayVariableToListForModelArg(pname,postfix,'parameter',dim,class,pname);
                    this.resolvedValue=[];
                end
            end
        end
    end

end
