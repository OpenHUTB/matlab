



classdef(Hidden=true)ModelInfoUtils<handle
    properties(SetAccess=private,GetAccess=public)
CodeInfo
CompInterface
BuildOpts
RTWInfo
FMUType
CGModel
ModelIdentifier
GUID
Author
Copyright
License
Description
StartTime
StopTime
FixedStepSize
getCompatibleRelease
requireMATLAB
logCategory
InportList
OutportList
BusNameList
BusObjectList



ModelVariableList


RealTable
IntTable
BoolTable
StrTable


RealOutputTableIdx
IntOutputTableIdx
BoolOutputTableIdx
StrOutputTableIdx


GenerationTool
Version
GenerationDateAndTime
graphicalNameMap

hasNestedFMUs
RealParamStartVr
IntParamStartVr
BoolParamStartVr
StrParamStartVr


EnumTypeMap



        SaveSourceCode(1,1)logical=false;
        SourceFileList cell


        canBeInstantiatedOnlyOncePerProcessOverride(1,1)logical=false;
        initialUnknownDependenciesOverride(1,1)logical=false;





UnitDefinitions


        AddProtectedModel(1,1)logical=false;
    end

    methods(Access=private)
        function addVariable(this,cname,gname,xmlname,dtname,causality,flag,is_cont_state,is_derivative,dimensions,unit,description,minValue,maxValue)

            if isa(unit,'Simulink.BusElement')


                unit=unit.Unit;
                minValue=num2str(minValue.Min);
                maxValue=num2str(maxValue.Max);
            end
            if isa(description,'Simulink.BusElement')


                description=description.Description;
            end

            var.c_name=cname;
            var.g_name=gname;
            var.xml_name=xmlname;
            var.causality=causality;
            var.flag=flag;
            var.is_cont_state=is_cont_state;
            var.is_derivative=is_derivative;
            var.dimensions=dimensions;
            var.unit=unit;
            if~isempty(description)
                var.description=description;
            else
                var.description=var.g_name;
            end
            var.enumName='';
            var.min=minValue;
            var.max=maxValue;


            if strcmp(var.causality,'local')
                dtname=this.convertToFMUSupportedType(xmlname,dtname);
            end


            if strcmp(dtname,'double')
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
                var.start=this.getStartValueFromParameter(gname,flag);
            elseif strcmp(var.causality,'local')
                var.initial='calculated';
                var.start=this.getStartValueFromInternalVar(gname);
            else
            end


            if~isempty(unit)&&~this.UnitDefinitions.isKey(unit)&&strcmp(dtname,'double')
                this.UnitDefinitions(unit)=struct('name',unit);
            end

            if strcmp(dtname,'double')
                var.dt='Real';
                var.vr=length(this.RealTable);
                var.start=num2str(var.start,'%.16g');
                this.ModelVariableList=[this.ModelVariableList;var];
                this.RealTable=[this.RealTable;length(this.ModelVariableList)];
                if strcmp(var.causality,'output');this.RealOutputTableIdx=[this.RealOutputTableIdx;length(this.RealTable)];end
            elseif strcmp(dtname,'int32')||startsWith(dtname,'enum:')
                if strcmp(dtname,'int32')
                    var.dt='Integer';
                    if~isempty(var.min)
                        var.min=int2str(int32(str2double(var.min)));
                    end
                    if~isempty(var.max)
                        var.max=num2str(floor(str2double(var.max)));
                    end
                else
                    var.dt='Enumeration';
                    enumName=dtname(6:end);
                    assert(~isempty(enumName));
                    var.enumName=enumName;
                    if strcmp(var.dt,'Enumeration')&&strcmp(var.causality,'input')
                        enumObj=this.EnumTypeMap(enumName);
                        var.start=enumObj.Values(enumObj.DefaultMember);
                    end
                end
                var.start=num2str(int32(var.start));
                var.vr=length(this.IntTable);
                this.ModelVariableList=[this.ModelVariableList;var];
                this.IntTable=[this.IntTable;length(this.ModelVariableList)];
                if strcmp(var.causality,'output');this.IntOutputTableIdx=[this.IntOutputTableIdx;length(this.IntTable)];end
            elseif strcmp(dtname,'logical')||strcmp(dtname,'boolean')
                var.dt='Boolean';
                var.vr=length(this.BoolTable);
                var.start=num2str(boolean(var.start));
                this.ModelVariableList=[this.ModelVariableList;var];
                this.BoolTable=[this.BoolTable;length(this.ModelVariableList)];
                if strcmp(var.causality,'output');this.BoolOutputTableIdx=[this.BoolOutputTableIdx;length(this.BoolTable)];end
            elseif strcmp(dtname,'string')
                var.dt='String';
                var.start=num2str(var.start);
                var.vr=length(this.StrTable);
                this.ModelVariableList=[this.ModelVariableList;var];
                this.StrTable=[this.StrTable;length(this.ModelVariableList)];
                if strcmp(var.causality,'output');this.StrOutputTableIdx=[this.StrOutputTableIdx;length(this.StrTable)];end
            else
                error(DAStudio.message('FMUExport:FMU:UnknownDataType',xmlname,dtname));
            end
        end

        function expandVariables(this,cname,gname,xmlname,dt,causality,flag,isTopLevel,unitObject,descriptionObject,minValue,maxValue)
            if strcmp(causality,'parameter')&&isTopLevel
                isSimulinkParameterObject=0;%#ok<NASGU>
                evalStr=strrep(strrep(gname,'[','('),']',')');
                if isempty(flag)
                    isSimulinkParameterObject=Simulink.data.evalinGlobal(...
                    this.CodeInfo.Name,['isa(',evalStr,', ''Simulink.Parameter'')']);
                elseif length(flag)>=8&&strcmp(flag(1:8),'InstArg_')
                    blkPath=flag(9:end);
                    bps=strsplit(blkPath,':');
                    submdl=get_param(bps{end},'ModelName');
                    names=strsplit(evalStr,':');
                    evalStr=names{end};
                    evalWS=get_param(submdl,'ModelWorkspace');
                    isSimulinkParameterObject=evalWS.evalin(['isa(',evalStr,', ''Simulink.Parameter'')']);
                else
                    evalWS=get_param(flag,'ModelWorkspace');
                    isSimulinkParameterObject=evalWS.evalin(['isa(',evalStr,', ''Simulink.Parameter'')']);
                end

                if isSimulinkParameterObject





                    if isempty(flag)
                        spo=Simulink.data.evalinGlobal(this.CodeInfo.Name,evalStr);
                    elseif length(flag)>=8&&strcmp(flag(1:8),'InstArg_')
                        blkPath=flag(9:end);
                        bps=strsplit(blkPath,':');
                        submdl=get_param(bps{end},'ModelName');
                        evalWS=get_param(submdl,'ModelWorkspace');
                        spo=evalWS.evalin(evalStr);
                    else
                        evalWS=get_param(flag,'ModelWorkspace');
                        spo=evalWS.evalin(evalStr);
                    end
                    assert(isa(spo,'Simulink.Parameter'));
                    assert(isempty(unitObject));
                    assert(isempty(descriptionObject));
                    assert(isempty(minValue));
                    assert(isempty(maxValue));
                    minValue=num2str(spo.Min);
                    maxValue=num2str(spo.Max);
                    if strcmp(spo.DataType,'int32')
                        minValue=num2str(int32(spo.Min));
                        maxValue=num2str(floor(spo.Max));
                    end


                    if startsWith(spo.DataType,'Bus:')
                        busName=strrep(spo.DataType,'Bus:','');
                        busName=strtrim(busName);
                        busObj=coder.internal.fmuexport.searchObjectsInWorkspace(this.CodeInfo.Name,busName,'Simulink.Bus');
                        if~isempty(busObj)
                            unitObject=busObj;
                            descriptionObject=busObj;
                        end
                    else
                        unitObject=spo.Unit;
                        descriptionObject=spo.Description;
                    end

                end
            end

            if strcmp(causality,'local')&&isTopLevel
                evalStr=strrep(strrep(gname,'[','('),']',')');
                isSimulinkSignalObject=Simulink.data.evalinGlobal(...
                this.CodeInfo.Name,['isa(',evalStr,', ''Simulink.Signal'')']);
                if isSimulinkSignalObject
                    sso=Simulink.data.evalinGlobal(this.CodeInfo.Name,evalStr);
                    assert(isa(sso,'Simulink.Signal'));
                    assert(isempty(unitObject));
                    assert(isempty(descriptionObject));
                    assert(isempty(minValue));
                    assert(isempty(maxValue));
                    minValue=num2str(sso.Min);
                    maxValue=num2str(sso.Max);
                    if strcmp(sso.DataType,'int32')
                        minValue=num2str(int32(sso.Min));
                        maxValue=num2str(int32(sso.Max));
                    end


                    if startsWith(sso.DataType,'Bus:')
                        busName=strrep(sso.DataType,'Bus:','');
                        busName=strtrim(busName);
                        busObj=coder.internal.fmuexport.searchObjectsInWorkspace(this.CodeInfo.Name,busName,'Simulink.Bus');
                        if~isempty(busObj)
                            unitObject=busObj;
                            descriptionObject=busObj;
                        end
                    else
                        unitObject=sso.Unit;
                        descriptionObject=sso.Description;
                    end

                end
            end

            if isa(dt,'coder.types.Numeric')||isa(dt,'coder.descriptor.types.Numeric')
                this.addVariable(cname,gname,xmlname,dt.Name,causality,flag,0,0,0,unitObject,descriptionObject,minValue,maxValue);
            elseif isa(dt,'coder.types.Matrix')||isa(dt,'coder.descriptor.types.Matrix')
                assert(~isempty(dt.Dimensions));

                if((isa(dt.BaseType,'coder.types.Char')||isa(dt.BaseType,'coder.descriptor.types.Char'))&&contains(dt.Name,['matrix',num2str(dt.Dimensions),'xchar']))
                    this.addVariable(cname,gname,xmlname,'string',causality,flag,0,0,dt.Dimensions,unitObject,descriptionObject,minValue,maxValue);
                else
                    if isa(dt,'coder.types.Matrix')
                        dimsUpperBound=dt.Dimensions;
                    else
                        dimsUpperBound=[];
                        for i=1:dt.Dimensions.Size
                            dimsUpperBound=[dimsUpperBound,dt.Dimensions(i)];
                        end
                    end
                    if prod(dimsUpperBound)==1

                        this.expandVariables(cname,gname,xmlname,dt.BaseType,causality,flag,0,unitObject,descriptionObject,minValue,maxValue);
                    else
                        isSimulinkParameterObject=0;
                        isSimulinkSignalObject=0;
                        if strcmp(causality,'parameter')
                            evalStr=strrep(strrep(gname,'[','('),']',')');
                            if isempty(flag)
                                isSimulinkParameterObject=Simulink.data.evalinGlobal(...
                                this.CodeInfo.Name,['isa(',evalStr,', ''Simulink.Parameter'')']);
                            else
                                evalWS=get_param(flag,'ModelWorkspace');
                                isSimulinkParameterObject=evalWS.evalin(['isa(',evalStr,', ''Simulink.Parameter'')']);
                            end


                            if length(dt.Dimensions)==2&&dt.Dimensions(2)==1
                                dimsUpperBound=dt.Dimensions(1);
                            end
                        end

                        if strcmp(causality,'local')
                            evalStr=strrep(strrep(gname,'[','('),']',')');
                            isSimulinkSignalObject=Simulink.data.evalinGlobal(...
                            this.CodeInfo.Name,['isa(',evalStr,', ''Simulink.Signal'')']);


                            if length(dimsUpperBound)==2&&dimsUpperBound(2)==1
                                dimsUpperBound=dimsUpperBound(1);
                            end
                        end


                        dims=ones(1,length(dimsUpperBound));
                        for iter=1:prod(dimsUpperBound)

                            colMajorIdx=0;
                            for j=length(dims):-1:1
                                if j>1
                                    d=dimsUpperBound(j-1);
                                else
                                    d=1;
                                end
                                colMajorIdx=(colMajorIdx+dims(j)-1)*d;
                            end

                            if isSimulinkParameterObject
                                this.expandVariables([cname,'[',num2str(colMajorIdx),']'],...
                                [gname,'.Value[',strjoin(arrayfun(@num2str,dims,'UniformOutput',false),','),']'],...
                                [xmlname,'[',strjoin(arrayfun(@num2str,dims,'UniformOutput',false),','),']'],...
                                dt.BaseType,causality,flag,0,unitObject,descriptionObject,minValue,maxValue);
                            elseif isSimulinkSignalObject
                                this.expandVariables([cname,'[',num2str(colMajorIdx),']'],...
                                ['str2num(',gname,'.InitialValue)[',strjoin(arrayfun(@num2str,dims,'UniformOutput',false),','),']'],...
                                [xmlname,'[',strjoin(arrayfun(@num2str,dims,'UniformOutput',false),','),']'],...
                                dt.BaseType,causality,flag,0,unitObject,descriptionObject,minValue,maxValue);
                            else
                                this.expandVariables([cname,'[',num2str(colMajorIdx),']'],...
                                [gname,'[',strjoin(arrayfun(@num2str,dims,'UniformOutput',false),','),']'],...
                                [xmlname,'[',strjoin(arrayfun(@num2str,dims,'UniformOutput',false),','),']'],...
                                dt.BaseType,causality,flag,0,unitObject,descriptionObject,minValue,maxValue);
                            end

                            j=length(dims);
                            while 1
                                dims(j)=dims(j)+1;
                                if(j==1||dims(j)<=dimsUpperBound(j))
                                    break;
                                end
                                dims(j)=1;j=j-1;
                            end
                        end
                    end
                end
            elseif isa(dt,'coder.types.Struct')||isa(dt,'coder.descriptor.types.Struct')
                isLookUpTableObject=0;
                isSimulinkParameterObject=0;
                isSimulinkSignalObject=0;
                if strcmp(causality,'parameter')
                    evalStr=strrep(strrep(gname,'[','('),']',')');
                    if isempty(flag)
                        isLookUpTableObject=Simulink.data.evalinGlobal(...
                        this.CodeInfo.Name,['isa(',evalStr,', ''Simulink.LookupTable'')']);
                        isSimulinkParameterObject=Simulink.data.evalinGlobal(...
                        this.CodeInfo.Name,['isa(',evalStr,', ''Simulink.Parameter'')']);
                    else
                        evalWS=get_param(flag,'ModelWorkspace');
                        isLookUpTableObject=evalWS.evalin(['isa(',evalStr,', ''Simulink.LookupTable'')']);
                        isSimulinkParameterObject=evalWS.evalin(['isa(',evalStr,', ''Simulink.Parameter'')']);
                    end
                end
                if strcmp(causality,'local')
                    evalStr=strrep(strrep(gname,'[','('),']',')');
                    [var,idx]=strtok(gname,'[');
                    isSimulinkSignalObject=Simulink.data.evalinGlobal(...
                    this.CodeInfo.Name,['isa(',var,', ''Simulink.Signal'')']);
                end
                if isLookUpTableObject






                    if isempty(flag)
                        lut=Simulink.data.evalinGlobal(this.CodeInfo.Name,evalStr);
                    else
                        evalWS=get_param(flag,'ModelWorkspace');
                        lut=evalWS.evalin(evalStr);
                    end
                    assert(isa(lut,'Simulink.LookupTable'));
                    if strcmp(lut.BreakpointsSpecification,'Even spacing')
                        error(DAStudio.message('FMUExport:FMU:FMU2ExpCSParameterLUTEvenSpacingNotSupported'));
                    end
                    lutDictionary=containers.Map;
                    lutDictionary(lut.Table.FieldName)={'Table.Value',lut.Table.Unit,lut.Table.Description,...
                    num2str(lut.Table.Min),num2str(lut.Table.Max)};
                    for iter=1:length(lut.Breakpoints)









                        lutDictionary(lut.Breakpoints(iter).FieldName)=...
                        {['Breakpoints[',num2str(iter),'].Value'],lut.Breakpoints(iter).Unit,lut.Breakpoints(iter).Description,...
                        num2str(lut.Breakpoints(iter).Min),num2str(lut.Breakpoints(iter).Max)};
                    end
                    for iter=1:length(dt.Elements)
                        breakPointField=lutDictionary(dt.Elements(iter).Identifier);
                        this.expandVariables([cname,'.',dt.Elements(iter).Identifier],...
                        [gname,'.',breakPointField{1}],...
                        [xmlname,'.',breakPointField{1}],...
                        dt.Elements(iter).Type,causality,flag,0,breakPointField{2},breakPointField{3},...
                        breakPointField{4},breakPointField{5});
                    end
                else
                    if isa(unitObject,'Simulink.Bus')
                        assert(length(dt.Elements)==length(unitObject.Elements));
                    end
                    for iter=1:length(dt.Elements)






                        if isa(unitObject,'Simulink.Bus')
                            unitVal=unitObject.Elements(iter);
                            minValue=unitObject.Elements(iter);
                            maxValue=unitObject.Elements(iter);
                            if startsWith(unitVal.DataType,'Bus:')
                                nestedBusName=strrep(unitVal.DataType,'Bus:','');
                                nestedBusName=strtrim(nestedBusName);
                                nestedBus=coder.internal.fmuexport.searchObjectsInWorkspace(this.CodeInfo.Name,nestedBusName,'Simulink.Bus');
                                if~isempty(nestedBus)
                                    unitVal=nestedBus;
                                    minValue=nestedBus;
                                    maxValue=nestedBus;
                                end
                            end
                        else
                            unitVal=unitObject;
                            minValue=unitObject;
                            maxValue=unitObject;
                        end
                        if isa(descriptionObject,'Simulink.Bus')




                            descriptionVal=unitVal;
                        else
                            descriptionVal=descriptionObject;
                        end
                        if isSimulinkParameterObject
                            this.expandVariables([cname,'.',dt.Elements(iter).Identifier],...
                            [gname,'.Value.',dt.Elements(iter).Identifier],...
                            [xmlname,'.',dt.Elements(iter).Identifier],...
                            dt.Elements(iter).Type,causality,flag,0,unitVal,descriptionVal,minValue,maxValue);
                        elseif isSimulinkSignalObject
                            this.expandVariables([cname,'.',dt.Elements(iter).Identifier],...
                            ['str2num(',gname,'.InitialValue).',dt.Elements(iter).Identifier],...
                            [xmlname,'.',dt.Elements(iter).Identifier],...
                            dt.Elements(iter).Type,causality,flag,0,unitVal,descriptionVal,minValue,maxValue);
                        else
                            this.expandVariables([cname,'.',dt.Elements(iter).Identifier],...
                            [gname,'.',dt.Elements(iter).Identifier],...
                            [xmlname,'.',dt.Elements(iter).Identifier],...
                            dt.Elements(iter).Type,causality,flag,0,unitVal,descriptionVal,minValue,maxValue);
                        end
                    end
                end
            elseif isa(dt,'coder.types.Enum')||isa(dt,'coder.descriptor.types.Enum')



                if~isempty(dt.StorageType)&&...
                    ~strcmp(dt.StorageType.Name,'int32')
                    error(DAStudio.message('FMUExport:FMU:InvalidEnumBaseType',gname,dt.Name));
                end

                if length(unique(dt.Values))~=length(dt.Values)||...
                    length(unique(dt.Strings))~=length(dt.Strings)
                    error(DAStudio.message('FMUExport:FMU:InvalidEnumDuplicateValue',gname,dt.Name));
                end







                if~this.EnumTypeMap.isKey(dt.Name)
                    this.EnumTypeMap(dt.Name)=dt;
                end

                this.addVariable(cname,gname,xmlname,['enum:',dt.Name],causality,flag,0,0,0,unitObject,descriptionObject,minValue,maxValue);
            elseif isa(dt,'coder.types.Complex')||isa(dt,'coder.descriptor.types.Complex')
                error(DAStudio.message('FMUExport:FMU:UnknownComplexity',gname));
            else


                error(DAStudio.message('FMUExport:FMU:UnknownDataType',gname,dt.Name));
            end

        end

        function buildVariableList(this)
            this.RealTable=[];
            this.IntTable=[];
            this.BoolTable=[];
            this.StrTable=[];
            this.RealOutputTableIdx=[];
            this.IntOutputTableIdx=[];
            this.BoolOutputTableIdx=[];
            this.StrOutputTableIdx=[];
            this.ModelVariableList=[];
            this.UnitDefinitions=containers.Map;
            this.EnumTypeMap=containers.Map;






            vars=containers.Map;
            res=evalin('base','exist(''paramListSource'')');
            if slfeature('FMUExportParameterConfiguration')>0&&res==1
                paramListSource=evalin('base','paramListSource');
                valueStructure=paramListSource.valueStructure;
                for i=1:length(valueStructure)
                    if valueStructure(i).IsRoot&&strcmp(valueStructure(i).exported,'on')
                        if contains(valueStructure(i).SourceType,'InstArg_')
                            blkPath=valueStructure(i).SourceType(9:end);
                            if contains(blkPath,':')
                                bps=strsplit(blkPath,':');
                                sid=Simulink.ID.getSID(bps{1});
                                for k=2:length(bps)
                                    sid=[sid,':',extractAfter(Simulink.ID.getSID(bps{k}),':')];
                                end
                                vars(['InstParameterArgument:',sid,'.',valueStructure(i).Name])={valueStructure(i).SourceType,valueStructure(i).exportedName};
                            else
                                sid=Simulink.ID.getSID(blkPath);
                                vars(['InstParameterArgument:',sid,':',valueStructure(i).Name])={valueStructure(i).SourceType,valueStructure(i).exportedName};
                            end
                        else
                            vars(valueStructure(i).Name)={valueStructure(i).SourceType,valueStructure(i).exportedName};
                        end
                    end
                end
            else
                for i=1:length(this.CodeInfo.Parameters)
                    if isempty(this.CodeInfo.Parameters(i).SID)||contains(this.CodeInfo.Parameters(i).SID,'#var')
                        vars(this.CodeInfo.Parameters(i).GraphicalName)={'',this.CodeInfo.Parameters(i).GraphicalName};
                    end
                end
            end

            i_vars=containers.Map;
            i_res=evalin('base','exist(''ivListSource'')');
            if slfeature('FMUExportInternalVarConfiguration')>0&&i_res==1
                ivListSource=evalin('base','ivListSource');
                valueStructure=ivListSource.valueStructure;
                for i=1:length(valueStructure)
                    if valueStructure(i).IsRoot&&strcmp(valueStructure(i).exported,'on')
                        i_vars(valueStructure(i).Name)=valueStructure(i).exportedName;
                    end
                end
            end
            origNameSet={};
            origNameCausalitySet={};
            if~isempty(this.CodeInfo.Inports)
                origNameSet=[origNameSet,{this.CodeInfo.Inports.GraphicalName}];
                origNameCausalitySet=[origNameCausalitySet,[this.CodeInfo.Inports(i).GraphicalName,', input']];
            end
            if~isempty(this.CodeInfo.Outports)
                origNameSet=[origNameSet,{this.CodeInfo.Outports.GraphicalName}];
                origNameCausalitySet=[origNameCausalitySet,[this.CodeInfo.Outports(i).GraphicalName,', output']];
            end
            if~isempty(this.CodeInfo.Parameters)




                for i=1:length(this.CodeInfo.Parameters)
                    if vars.isKey(this.CodeInfo.Parameters(i).GraphicalName)
                        tmp=vars(this.CodeInfo.Parameters(i).GraphicalName);
                        origNameSet=[origNameSet,tmp{2}];
                        origNameCausalitySet=[origNameCausalitySet,[tmp{2},', parameter']];
                    end
                end
            end
            if~isempty(this.CodeInfo.DataStores)
                if strcmp(this.FMUType,'ME')
                    origNameSet=[origNameSet,{this.CodeInfo.DataStores.GraphicalName}];
                else


                    for i=1:length(this.CodeInfo.DataStores)
                        if i_vars.isKey(this.CodeInfo.DataStores(i).GraphicalName)
                            tmp=i_vars(this.CodeInfo.DataStores(i).GraphicalName);
                            origNameSet=[origNameSet,tmp];
                            origNameCausalitySet=[origNameCausalitySet,[tmp,', internal']];
                        end
                    end
                end
            end
            if~isempty(this.CompInterface.ExternalBlockOutputs)


                for i=1:this.CompInterface.ExternalBlockOutputs.Size
                    if i_vars.isKey(this.CompInterface.ExternalBlockOutputs(i).GraphicalName)
                        tmp=i_vars(this.CompInterface.ExternalBlockOutputs(i).GraphicalName);
                        origNameSet=[origNameSet,tmp];
                        origNameCausalitySet=[origNameCausalitySet,[tmp,', internal']];
                    end
                end
            end
            if~isempty(this.CompInterface.GlobalBlockOutputs)


                for i=1:this.CompInterface.GlobalBlockOutputs.Size
                    if i_vars.isKey(this.CompInterface.GlobalBlockOutputs(i).GraphicalName)
                        tmp=i_vars(this.CompInterface.GlobalBlockOutputs(i).GraphicalName);
                        origNameSet=[origNameSet,tmp];
                        origNameCausalitySet=[origNameCausalitySet,[tmp,', internal']];
                    end
                end
            end
            [validNameSet,modified_invalid]=matlab.lang.makeValidName(origNameSet);
            [uniqueNameSet,modified_dup]=matlab.lang.makeUniqueStrings(validNameSet,'time');
            modified=modified_invalid|modified_dup;
            if nnz(modified)

                warnID='FMUExport:FMU:FMU2ExpCSInvalidOrDuplicatesRenamed';
                modifiedSet=origNameSet(modified);
                newSet=uniqueNameSet(modified);
                if numel(modifiedSet)>10
                    modifiedSet_str=[strjoin(modifiedSet(1:10),','),',...'];
                    newSet_str=[strjoin(newSet(1:10),','),',...'];
                else
                    modifiedSet_str=strjoin(modifiedSet,',');
                    newSet_str=strjoin(newSet,',');
                end
                DAStudio.warning(warnID,modifiedSet_str,newSet_str);
            end

            if~isempty(origNameSet)
                this.graphicalNameMap=containers.Map(origNameCausalitySet,uniqueNameSet);
            else
                this.graphicalNameMap=containers.Map;
            end



            assert(length(this.CodeInfo.Inports)==this.RTWInfo.ExternalInputs.NumExternalInputs);
            assert(length(this.CodeInfo.Outports)==this.RTWInfo.ExternalOutputs.NumExternalOutputs);


            compileTimeUnitMap=coder.internal.fmuexport.CompileTimeInfoUtil.queryCompileTimeUnitMap(this.CodeInfo.Name);
            this.InportList=coder.internal.fmuexport.CompileTimeInfoUtil.queryCompileTimeInportList(this.CodeInfo.Name);

            for i=1:length(this.CodeInfo.Inports)
                assert(isa(this.CodeInfo.Inports(i),'RTW.DataInterface'));


                rtwInput=this.RTWInfo.ExternalInputs.ExternalInput(i);
                if iscell(rtwInput);rtwInput=rtwInput{1};end
                if isfield(rtwInput,'HasVarDims')&&rtwInput.HasVarDims~=0
                    error(DAStudio.message('FMUExport:FMU:InvalidInputDimensionMode',Simulink.ID.getFullName(this.CodeInfo.Inports(i).SID)));
                end

                if~isempty(this.CodeInfo.Inports(i).VariantInfo)&&...
                    ~isempty(this.CodeInfo.Inports(i).VariantInfo.NetSTVCECExpr)
                    error(DAStudio.message('FMUExport:FMU:VariantInterfaceErrorForInports',Simulink.ID.getFullName(this.CodeInfo.Inports(i).SID)));
                end
                varType=this.CodeInfo.Inports(i).Type;
                impl=this.CodeInfo.Inports(i).Implementation;
                gName=this.CodeInfo.Inports(i).GraphicalName;
                xmlName=this.graphicalNameMap([gName,', input']);





                unitObject=coder.internal.fmuexport.CompileTimeInfoUtil.queryCompiledUnit(compileTimeUnitMap,['<Root>/',this.CodeInfo.Inports(i).GraphicalName]);
                if isempty(unitObject)&&~isempty(compileTimeUnitMap)


                    unitObject=coder.internal.fmuexport.searchObjectsInWorkspace(this.CodeInfo.Name,varType.Name,'Simulink.Bus');
                end

                try
                    description=get_param(rtwInput.BlockName,'Description');
                catch ME



                    if strcmp(ME.identifier,'Simulink:Engine:RTWNameUnableToLocateRootBlock')
                        description='';
                    end
                end

                try
                    minValue=getMinimumValue(this,this.CodeInfo.Inports(i).SID,varType);
                    maxValue=getMaximumValue(this,this.CodeInfo.Inports(i).SID,varType);
                catch ME
                    minValue='';
                    maxValue='';
                end

                if isprop(impl,'ElementIdentifier')&&~isempty(impl.ElementIdentifier)


                    signalName=impl.ElementIdentifier;
                    signalObject=coder.internal.fmuexport.searchObjectsInWorkspace(this.CodeInfo.Name,signalName,'Simulink.Signal');
                    if isempty(description)&&~isempty(signalObject)
                        description=signalObject.Description;
                    end
                    if isempty(minValue)&&~isempty(signalObject)
                        minValue=num2str(signalObject.Min);
                    end
                    if isempty(maxValue)&&~isempty(signalObject)
                        maxValue=num2str(signalObject.Max);
                    end
                end

                varName={};
                while isa(impl,'RTW.StructExpression')
                    varName=[impl.ElementIdentifier,varName];%#ok
                    impl=impl.BaseRegion;
                end

                assert(isa(impl,'RTW.Variable'));
                if isa(impl,'RTW.PointerVariable')

                    varName=[impl.Identifier,varName];%#ok
                    varName=strjoin(varName,'.');
                    this.expandVariables(['*',varName],gName,xmlName,varType,'input','',1,unitObject,description,minValue,maxValue);
                elseif strcmp(impl.Identifier,this.getInputStructName())


                    varName=strjoin(varName,'.');
                    if this.IsReusable
                        this.expandVariables(['modelData->S->inputs->',varName],gName,xmlName,varType,'input','',1,unitObject,description,minValue,maxValue);
                    else
                        this.expandVariables([impl.Identifier,'.',varName],gName,xmlName,varType,'input','',1,unitObject,description,minValue,maxValue);
                    end
                elseif isempty(impl.Owner)

                    varName=[impl.Identifier,varName];%#ok
                    varName=strjoin(varName,'.');
                    this.expandVariables(varName,gName,xmlName,varType,'input','',1,unitObject,description,minValue,maxValue);
                elseif strcmp(this.CodeInfo.Name,impl.Owner)

                    varName=[impl.Identifier,varName];%#ok
                    varName=strjoin(varName,'.');
                    this.expandVariables(varName,gName,xmlName,varType,'input','',1,unitObject,description,minValue,maxValue);
                else
                    error(DAStudio.message('FMUExport:FMU:UnknownInputStorageClass',gName));
                end
            end

            this.OutportList=coder.internal.fmuexport.CompileTimeInfoUtil.queryCompileTimeOutportList(this.CodeInfo.Name);
            for i=1:length(this.CodeInfo.Outports)
                assert(isa(this.CodeInfo.Outports(i),'RTW.DataInterface'));


                rtwOutput=this.RTWInfo.ExternalOutputs.ExternalOutput(i);
                if iscell(rtwOutput);rtwOutput=rtwOutput{1};end
                if isfield(rtwOutput,'HasVarDims')&&rtwOutput.HasVarDims~=0
                    error(DAStudio.message('FMUExport:FMU:InvalidOutputDimensionMode',Simulink.ID.getFullName(this.CodeInfo.Outports(i).SID)));
                end

                if~isempty(this.CodeInfo.Outports(i).VariantInfo)&&...
                    ~isempty(this.CodeInfo.Outports(i).VariantInfo.NetSTVCECExpr)
                    error(DAStudio.message('FMUExport:FMU:VariantInterfaceErrorForOutports',Simulink.ID.getFullName(this.CodeInfo.Outports(i).SID)));
                end
                varType=this.CodeInfo.Outports(i).Type;
                impl=this.CodeInfo.Outports(i).Implementation;
                gName=this.CodeInfo.Outports(i).GraphicalName;
                xmlName=this.graphicalNameMap([gName,', output']);





                unitObject=coder.internal.fmuexport.CompileTimeInfoUtil.queryCompiledUnit(compileTimeUnitMap,['<Root>/',this.CodeInfo.Outports(i).GraphicalName]);
                if isempty(unitObject)&&~isempty(compileTimeUnitMap)


                    unitObject=coder.internal.fmuexport.searchObjectsInWorkspace(this.CodeInfo.Name,varType.Name,'Simulink.Bus');
                end

                try
                    description=get_param(rtwOutput.BlockName,'Description');
                catch ME



                    if strcmp(ME.identifier,'Simulink:Engine:RTWNameUnableToLocateRootBlock')
                        description='';
                    end
                end

                try
                    minValue=getMinimumValue(this,this.CodeInfo.Outports(i).SID,varType);
                    maxValue=getMaximumValue(this,this.CodeInfo.Outports(i).SID,varType);
                catch ME
                    minValue='';
                    maxValue='';
                end

                if isprop(impl,'ElementIdentifier')&&~isempty(impl.ElementIdentifier)


                    signalName=impl.ElementIdentifier;
                    signalObject=coder.internal.fmuexport.searchObjectsInWorkspace(this.CodeInfo.Name,signalName,'Simulink.Signal');
                    if isempty(description)&&~isempty(signalObject)
                        description=signalObject.Description;
                    end
                    if isempty(minValue)&&~isempty(signalObject)
                        minValue=num2str(signalObject.Min);
                    end
                    if isempty(maxValue)&&~isempty(signalObject)
                        maxValue=num2str(signalObject.Max);
                    end
                end

                varName={};
                while isa(impl,'RTW.StructExpression')
                    varName=[impl.ElementIdentifier,varName];%#ok
                    impl=impl.BaseRegion;
                end

                assert(isa(impl,'RTW.Variable'));
                if isa(impl,'RTW.PointerVariable')

                    varName=[impl.Identifier,varName];%#ok
                    varName=strjoin(varName,'.');
                    this.expandVariables(['*',varName],gName,xmlName,varType,'output','',1,unitObject,description,minValue,maxValue);
                elseif strcmp(impl.Identifier,this.getOutputStructName())


                    varName=strjoin(varName,'.');
                    if this.IsReusable
                        this.expandVariables(['modelData->S->outputs->',varName],gName,xmlName,varType,'output','',1,unitObject,description,minValue,maxValue);
                    else
                        this.expandVariables([impl.Identifier,'.',varName],gName,xmlName,varType,'output','',1,unitObject,description,minValue,maxValue);
                    end
                elseif isempty(impl.Owner)

                    varName=[impl.Identifier,varName];%#ok
                    varName=strjoin(varName,'.');
                    this.expandVariables(varName,gName,xmlName,varType,'output','',1,unitObject,description,minValue,maxValue);
                elseif strcmp(this.CodeInfo.Name,impl.Owner)

                    varName=[impl.Identifier,varName];%#ok
                    varName=strjoin(varName,'.');
                    this.expandVariables(varName,gName,xmlName,varType,'output','',1,unitObject,description,minValue,maxValue);
                else
                    error(DAStudio.message('FMUExport:FMU:UnknownOutputStorageClass',gName));
                end
            end
























            this.addVariable('modelData->time','time','time','double','independent','',0,0,0,'','','','');



            exportedInternals={};
            for i=1:length(this.CodeInfo.DataStores)
                assert(isa(this.CodeInfo.DataStores(i),'RTW.DataInterface'));
                gName=this.CodeInfo.DataStores(i).GraphicalName;
                if strcmp(this.FMUType,'ME')||i_vars.isKey(gName)
                    exportedInternals=[exportedInternals,gName];
                    if strcmp(this.FMUType,'ME')

                        xmlName=this.graphicalNameMap([gName,', internal']);
                    else
                        xmlName=this.graphicalNameMap([i_vars(gName),', internal']);
                    end
                    varType=this.CodeInfo.DataStores(i).Type;
                    impl=this.CodeInfo.DataStores(i).Implementation;
                    varName={};
                    while isa(impl,'RTW.StructExpression')
                        varName=[impl.ElementIdentifier,varName];%#ok
                        impl=impl.BaseRegion;
                    end

                    assert(isa(impl,'RTW.Variable'));
                    if isa(impl,'RTW.PointerVariable')

                        varName=[impl.Identifier,varName];%#ok
                        varName=strjoin(varName,'.');
                        this.expandVariables(['*',varName],gName,xmlName,varType,'local','',1,'','','','');
                    elseif isempty(impl.Owner)

                        varName=[impl.Identifier,varName];%#ok
                        varName=strjoin(varName,'.');
                        this.expandVariables(varName,gName,xmlName,varType,'local','',1,'','','','');
                    elseif strcmp(this.CodeInfo.Name,impl.Owner)

                        varName=[impl.Identifier,varName];%#ok
                        varName=strjoin(varName,'.');
                        this.expandVariables(varName,gName,xmlName,varType,'local','',1,'','','','');
                    else
                        error(DAStudio.message('FMUExport:FMU:UnknownDSMStorageClass',gName));
                    end
                end
            end


            for i=1:this.CompInterface.ExternalBlockOutputs.Size
                assert(isa(this.CompInterface.ExternalBlockOutputs(i),'coder.descriptor.DataInterface'));
                gName=this.CompInterface.ExternalBlockOutputs(i).GraphicalName;
                if i_vars.isKey(gName)
                    exportedInternals=[exportedInternals,gName];
                    xmlName=this.graphicalNameMap([i_vars(gName),', internal']);
                    varType=this.CompInterface.ExternalBlockOutputs(i).Type;
                    impl=this.CompInterface.ExternalBlockOutputs(i).Implementation;
                    varName={};
                    while isa(impl,'coder.descriptor.StructExpression')
                        varName=[impl.ElementIdentifier,varName];%#ok
                        impl=impl.BaseRegion;
                    end

                    assert(isa(impl,'coder.descriptor.Variable'));
                    if isa(impl,'coder.descriptor.PointerVariable')

                        varName=[impl.Identifier,varName];%#ok
                        varName=strjoin(varName,'.');
                        this.expandVariables(['*',varName],gName,xmlName,varType,'local','',1,'','','','');
                    elseif isempty(impl.VarOwner)

                        varName=[impl.Identifier,varName];%#ok
                        varName=strjoin(varName,'.');
                        this.expandVariables(varName,gName,xmlName,varType,'local','',1,'','','','');
                    elseif strcmp(this.CodeInfo.Name,impl.VarOwner)

                        varName=[impl.Identifier,varName];%#ok
                        varName=strjoin(varName,'.');
                        this.expandVariables(varName,gName,xmlName,varType,'local','',1,'','','','');
                    else
                        error(DAStudio.message('FMUExport:FMU:UnknownSignalStorageClass',gName));
                    end
                end
            end


            for i=1:this.CompInterface.GlobalBlockOutputs.Size
                assert(isa(this.CompInterface.GlobalBlockOutputs(i),'coder.descriptor.DataInterface'));
                gName=this.CompInterface.GlobalBlockOutputs(i).GraphicalName;
                if i_vars.isKey(gName)
                    exportedInternals=[exportedInternals,gName];
                    xmlName=this.graphicalNameMap([i_vars(gName),', internal']);
                    varType=this.CompInterface.GlobalBlockOutputs(i).Type;
                    impl=this.CompInterface.GlobalBlockOutputs(i).Implementation;
                    varName={};
                    while isa(impl,'coder.descriptor.StructExpression')
                        varName=[impl.ElementIdentifier,varName];%#ok
                        impl=impl.BaseRegion;
                    end

                    assert(isa(impl,'coder.descriptor.Variable'));
                    if isa(impl,'coder.descriptor.PointerVariable')

                        varName=[impl.Identifier,varName];%#ok
                        varName=strjoin(varName,'.');
                        this.expandVariables(['*',varName],gName,xmlName,varType,'local','',1,'','','','');
                    elseif isempty(impl.VarOwner)

                        varName=[impl.Identifier,varName];%#ok
                        varName=strjoin(varName,'.');
                        this.expandVariables(varName,gName,xmlName,varType,'local','',1,'','','','');
                    elseif strcmp(this.CodeInfo.Name,impl.VarOwner)

                        varName=[impl.Identifier,varName];%#ok
                        varName=strjoin(varName,'.');
                        this.expandVariables(varName,gName,xmlName,varType,'local','',1,'','','','');
                    else
                        error(DAStudio.message('FMUExport:FMU:UnknownTestPointStorageClass',gName));
                    end
                end
            end



            if length(exportedInternals)<i_vars.length
                args=i_vars.keys;
                [~,~,ib]=intersect(exportedInternals,args);
                args(ib)=[];
                warnID='FMUExport:FMU:FMU2ExpCSIVNotExported';
                DAStudio.warning(warnID,strjoin(args,','));
            end


            if strcmp(this.FMUType,'ME')
                cs_count=0;
                for i=1:this.RTWInfo.VarGroups.NumVarGroups
                    if(~strcmp(this.RTWInfo.VarGroups.VarGroup{1,i}.Category,'ContStates'))
                        continue;
                    end
                    CGTypeIdx=this.RTWInfo.VarGroups.VarGroup{1,i}.CGTypeIdx+1;
                    Members=this.CGModel.CGTypes(CGTypeIdx).Members;
                    for j=1:length(Members)
                        cs_count=cs_count+1;
                        varName=['((',this.getContinuousStatesStructName,' *)(',this.getModelVariableName,'->contStates))->',Members(j).Name];
                        xmlName=['ContState',num2str(cs_count)];
                        varType='double';
                        causality='local';
                        flag=0;
                        is_derivative=0;
                        is_cont_state=1;
                        this.addVariable(varName,xmlName,xmlName,varType,causality,flag,is_cont_state,is_derivative,0,'','','','');
                    end
                end
            end

            if strcmp(this.FMUType,'ME')
                der_count=0;
                for i=1:this.RTWInfo.VarGroups.NumVarGroups
                    if(~strcmp(this.RTWInfo.VarGroups.VarGroup{1,i}.Category,'ContStatesDerivative'))
                        continue;
                    end
                    CGTypeIdx=this.RTWInfo.VarGroups.VarGroup{1,i}.CGTypeIdx+1;
                    Members=this.CGModel.CGTypes(CGTypeIdx).Members;
                    for j=1:length(Members)
                        der_count=der_count+1;
                        varName=['((',this.getStateDerivativesStructName,' *)(',this.getModelVariableName,'->derivs))->',Members(j).Name];
                        xmlName=['Deriv',num2str(der_count)];
                        varType='double';
                        causality='local';
                        flag=0;
                        is_derivative=1;
                        is_cont_state=0;
                        this.addVariable(varName,xmlName,xmlName,varType,causality,flag,is_cont_state,is_derivative,0,'','','','');
                    end
                end
            end









            this.RealParamStartVr=length(this.RealTable);
            this.IntParamStartVr=length(this.IntTable);
            this.BoolParamStartVr=length(this.BoolTable);
            this.StrParamStartVr=length(this.StrTable);



            exportedParameters={};
            for i=1:length(this.CodeInfo.Parameters)
                assert(isa(this.CodeInfo.Parameters(i),'RTW.DataInterface'));


                gName=this.CodeInfo.Parameters(i).GraphicalName;
                if vars.isKey(gName)
                    tmp=vars(gName);
                    exportedParameters=[exportedParameters,gName];
                    if isempty(this.CodeInfo.Parameters(i).SID)
                        flag='';
                    elseif contains(tmp{1},'InstArg_')
                        flag=tmp{1};
                    else
                        flag=this.CodeInfo.Name;
                    end
                    xmlName=this.graphicalNameMap([tmp{2},', parameter']);
                    varType=this.CodeInfo.Parameters(i).Type;
                    impl=this.CodeInfo.Parameters(i).Implementation;
                    varName={};
                    while isa(impl,'RTW.StructExpression')
                        varName=[impl.ElementIdentifier,varName];%#ok
                        impl=impl.BaseRegion;
                    end

                    assert(isa(impl,'RTW.Variable'));
                    if isa(impl,'RTW.PointerVariable')

                        varName=[impl.Identifier,varName];%#ok
                        varName=strjoin(varName,'.');
                        this.expandVariables(['*',varName],gName,xmlName,varType,'parameter',flag,1,'','','','');
                    elseif strcmp(impl.Identifier,this.getParameterStructName())


                        varName=strjoin(varName,'.');
                        if this.IsReusable
                            this.expandVariables(['modelData->S->defaultParam->',varName],gName,xmlName,varType,'parameter',flag,1,'','','','');
                        else
                            this.expandVariables([impl.Identifier,'.',varName],gName,xmlName,varType,'parameter',flag,1,'','','','');
                        end
                    elseif isempty(impl.Owner)

                        varName=[impl.Identifier,varName];%#ok                        
                        varName=strjoin(varName,'.');
                        this.expandVariables(varName,gName,xmlName,varType,'parameter',flag,1,'','','','');
                    elseif strcmp(this.CodeInfo.Name,impl.Owner)

                        varName=[impl.Identifier,varName];%#ok
                        varName=strjoin(varName,'.');
                        this.expandVariables(varName,gName,xmlName,varType,'parameter',flag,1,'','','','');
                    else
                        error(DAStudio.message('FMUExport:FMU:UnknownParameterStorageClass',gName));
                    end
                end
            end

            if length(exportedParameters)<vars.length
                args=vars.keys;
                [~,~,ib]=intersect(exportedParameters,args);
                args(ib)=[];
                warnID='FMUExport:FMU:FMU2ExpCSParameterNotExported';
                DAStudio.warning(warnID,strjoin(args,','));
            end
        end
    end


    methods(Access=public)
        function this=ModelInfoUtils(codeInfo,compInt,buildOpts,rtwInfo,cgModel,buildInfo)
            assert(isa(codeInfo,'RTW.ComponentInterface'));
            this.CodeInfo=codeInfo;
            this.CompInterface=compInt;
            this.BuildOpts=buildOpts;
            this.RTWInfo=rtwInfo;
            this.CGModel=cgModel;
            this.ModelIdentifier=this.CodeInfo.Name;
            this.Description=get_param(this.CodeInfo.Name,'Description');
            this.Author='';
            this.Copyright='';
            this.License='';
            this.logCategory=containers.Map;
            this.StartTime=rtwInfo.StartTime;
            this.StopTime=rtwInfo.StopTime;
            this.FixedStepSize=rtwInfo.FundamentalStepSize;
            this.getCompatibleRelease='all';
            this.requireMATLAB='no';
            this.GUID=Simulink.fmuexport.internal.ModelInfoUtils.ModelChecksumToGUID(this.CodeInfo.Checksum);
            this.hasNestedFMUs=this.hasFMUImportCGDefinition(buildInfo);


            for imdlRef=1:length(buildInfo.ModelRefs)
                if this.hasNestedFMUs
                    break;
                else
                    mdlRefBuildPath=buildInfo.ModelRefs(imdlRef).formatPaths(buildInfo.ModelRefs(imdlRef).Path);
                    mdlRefBuildInfo=load(fullfile(mdlRefBuildPath,'buildInfo.mat'));
                    this.hasNestedFMUs=this.hasFMUImportCGDefinition(mdlRefBuildInfo.buildInfo)|this.hasNestedFMUs;
                end
            end

            this.FMUType='CS';
            if(strcmp(this.BuildOpts.sysTargetFile,'fmu2me.tlc'))
                this.FMUType='ME';
            end

            this.buildVariableList;

            sl_ver=ver('Simulink');
            this.GenerationTool=[sl_ver.Name,' ',sl_ver.Release];
            this.Version=get_param(this.CodeInfo.Name,'ModelVersion');
            this.GenerationDateAndTime=datestr(datetime('now','TimeZone','UTC'),'yyyy-mm-ddTHH:MM:SSZ');

            this.updateBuildInfoSourceCode(buildInfo);
            this.constructBusObjectInformation();

            modelSettingBackup=coder.internal.fmuexport.getSetFMUSetting;

            if modelSettingBackup.isKey([this.CodeInfo.Name,'.canBeInstantiatedOnlyOncePerProcessOverride'])
                this.canBeInstantiatedOnlyOncePerProcessOverride=strcmpi(modelSettingBackup([this.CodeInfo.Name,'.canBeInstantiatedOnlyOncePerProcessOverride']),'on');
            end
            if modelSettingBackup.isKey([this.CodeInfo.Name,'.initialUnknownDependenciesOverride'])
                this.initialUnknownDependenciesOverride=strcmpi(modelSettingBackup([this.CodeInfo.Name,'.initialUnknownDependenciesOverride']),'on');
            end

            this.AddProtectedModel=strcmpi(get_param(this.CodeInfo.Name,'AddNativeSimulinkBehavior'),'on');
        end

        function updateBuildInfoSourceCode(this,updatedBuildInfo)
            this.SaveSourceCode=strcmpi(get_param(this.CodeInfo.Name,'SaveSourceCodeToFMU'),'on');
            if this.SaveSourceCode
                this.SourceFileList=arrayfun(@(x)x.FileName,updatedBuildInfo.Src.Files,'un',0);
            end
        end

        function constructBusObjectInformation(this)
            Inports=this.CodeInfo.Inports;
            Outports=this.CodeInfo.Outports;
            elementQueue={};
            for i=1:length(Inports)
                portElement=Inports(i);
                portType=portElement.Type;
                if isprop(portType,'Elements')&&length(portType.Elements)>=1
                    elementQueue{end+1}=portElement;
                end
            end
            for i=1:length(Outports)
                portElement=Outports(i);
                portType=portElement.Type;
                if isprop(portType,'Elements')&&length(portType.Elements)>=1
                    elementQueue{end+1}=portElement;
                end
            end
            this.BusNameList={};
            while(~isempty(elementQueue))
                element=elementQueue{end};
                type=element.Type;
                elementQueue(end)=[];
                busObject=coder.internal.fmuexport.searchObjectsInWorkspace(this.CodeInfo.Name,type.Name,'Simulink.Bus');
                if~isempty(busObject)
                    if(find(strcmp(this.BusNameList,type.Name),1))
                        continue;
                    end
                    this.BusNameList{end+1}=type.Name;
                    this.BusObjectList{end+1}=busObject;

                    assert(length(type.Elements)==length(busObject.Elements));

                    for i=1:length(type.Elements)
                        subElement=type.Elements(i);
                        subType=subElement.Type;

                        if isprop(subType,'Elements')&&length(subType.Elements)>=1
                            elementQueue{end+1}=subElement;
                        end
                    end
                end
            end
        end

        function startVal=getStartValueFromParameter(this,g_name,flag)
            evalStr=strrep(strrep(g_name,'[','('),']',')');
            [var,idx]=strtok(g_name,'[');
            if isempty(flag)
                evalVal=Simulink.data.evalinGlobal(this.CodeInfo.Name,var);
            elseif length(flag)>=8&&strcmp(flag(1:8),'InstArg_')
                blkPath=flag(9:end);
                bps=strsplit(blkPath,':');
                names=strsplit(evalStr,':');
                evalStr=names{end};
                [var,idx]=strtok(evalStr,'[');
                evalVal=this.getInstArgValue(bps,var);
            else
                evalWS=get_param(flag,'ModelWorkspace');
                evalVal=evalWS.evalin(var);
            end
            startVal='';
            if isa(evalVal,'Simulink.LookupTable')
                startVal=evalVal.Table.Value(str2num(idx));
            elseif isa(evalVal,'Simulink.Breakpoint')
                startVal=evalVal.Breakpoints.Value(str2num(idx));
            elseif isa(evalVal,'Simulink.Parameter')
                v=reshape(evalVal.Value,evalVal.Dimensions);
                index=str2num(idx);
                if isempty(index)
                    startVal=v;
                elseif length(index)==1
                    startVal=v(index);
                else
                    startVal=v(index(1),index(2));
                end
            else
                if isempty(flag)
                    startVal=Simulink.data.evalinGlobal(this.CodeInfo.Name,evalStr);
                elseif contains(flag,'InstArg_')

                else
                    evalWS=get_param(flag,'ModelWorkspace');
                    startVal=evalWS.evalin(evalStr);
                end
            end
        end

        function startVal=getStartValueFromInternalVar(this,g_name)
            evalStr=strrep(strrep(g_name,'[','('),']',')');
            [var,idx]=strtok(g_name,'[');
            [idx,elem]=strtok(idx,'.');
            index=str2num(idx);
            evalVal=Simulink.data.evalinGlobal(this.CodeInfo.Name,var);

            startVal='';
            if isa(evalVal,'Simulink.Signal')
                v=str2num(evalVal.InitialValue);
                if isempty(index)
                    startVal=v;
                elseif length(index)==1
                    startVal=v(index);
                else
                    startVal=v(index(1),index(2));
                end
            else
                if isempty(index)
                    startVal=evalVal;
                elseif length(index)==1
                    startVal=evalVal(index);
                else
                    startVal=evalVal(index(1),index(2));
                end
                if~isempty(elem)
                    startVal=getfield(startVal,elem(2:end));
                end
            end
        end

        function minValue=getMinimumValue(this,blk,varType)
            minValue=get_param(blk,'OutMin');

            if isnan(str2double(minValue))
                if isvarname(minValue)&&hasVariable(get_param(this.CodeInfo.Name,'ModelWorkspace'),minValue)
                    minValue=getVariable(get_param(this.CodeInfo.Name,'ModelWorkspace'),minValue);
                else
                    minValue=Simulink.data.evalinGlobal(this.CodeInfo.Name,minValue);
                end
                if isa(minValue,'Simulink.Parameter')
                    minValue=minValue.Value;
                end
                minValue=num2str(minValue);
            end
        end
        function maxValue=getMaximumValue(this,blk,varType)
            maxValue=get_param(blk,'OutMax');

            if isnan(str2double(maxValue))
                if isvarname(maxValue)&&hasVariable(get_param(this.CodeInfo.Name,'ModelWorkspace'),maxValue)
                    maxValue=getVariable(get_param(this.CodeInfo.Name,'ModelWorkspace'),maxValue);
                else
                    maxValue=Simulink.data.evalinGlobal(this.CodeInfo.Name,maxValue);
                end
                if isa(maxValue,'Simulink.Parameter')
                    maxValue=maxValue.Value;
                end
                maxValue=num2str(maxValue);
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

        function delete(this)
        end

        function isReusable=IsReusable(this)
            isReusable=strcmp(get_param(this.CodeInfo.Name,'CodeInterfacePackaging'),'Reusable function');
        end

        function isCombineOutputUpdate=IsCombineOutputUpdate(this)
            isCombineOutputUpdate=strcmp(get_param(this.CodeInfo.Name,'CombineOutputUpdateFcns'),'on');
        end

        function name=getParameterStructTypeName(this)
            name=this.RTWInfo.GlobalScope.tParametersType;
        end

        function name=getParameterStructName(this)
            name=this.RTWInfo.GlobalScope.tParameters;
        end

        function name=getInputStructName(this)
            name=this.RTWInfo.GlobalScope.tInput;
        end

        function name=getOutputStructName(this)
            name=this.RTWInfo.GlobalScope.tOutput;
        end

        function name=getModelTypeName(this)
            name=this.RTWInfo.GlobalScope.tSimStructType;
        end

        function name=getModelVariableName(this)
            name=this.RTWInfo.GlobalScope.tSimStruct;
        end

        function name=getContinuousStatesStructName(this)
            name=this.RTWInfo.GlobalScope.tContStateType;
        end

        function name=getStateDerivativesStructName(this)
            name=this.RTWInfo.GlobalScope.tXdotType;
        end

        function out=getGenerationTool(this)
            out=this.GenerationTool;
        end

        function out=getVersion(this)
            out=this.Version;
        end

        function out=getGenerationDateAndTime(this)
            out=this.GenerationDateAndTime;
        end

        function out=isFixedStepSolver(this)
            out=true;
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
        function hasNestedFMUs=hasFMUImportCGDefinition(buildInfo)
            fmu_cg_target=find(ismember({buildInfo.Options.Defines.Key},{'FMU_CG_TARGET'}),1);
            if~isempty(fmu_cg_target)


                hasNestedFMUs=strcmp(buildInfo.Options.Defines(fmu_cg_target).Value,'20');
            else
                hasNestedFMUs=false;
            end
        end
    end
end



