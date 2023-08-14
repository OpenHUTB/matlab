




classdef(Hidden=true)ModelCGInfoUtils<Simulink.fmuexport.internal.ModelInfoUtilsBase
    properties(SetAccess=private,GetAccess=public)
CodeInfo
CompInterface
BuildOpts
RTWInfo
CGModel


hasNestedFMUs



        SaveSourceCode(1,1)logical=false;
        SourceFileList cell


        AddProtectedModel(1,1)logical=false;
    end

    methods(Access=private)
        function addVariable(this,cname,gname,xmlname,dtname,causality,flag,is_cont_state,is_derivative,dimensions)
            this.addToModelVariableList(gname,xmlname,cname,flag,causality,dtname,dimensions,is_cont_state,is_derivative);
        end

        function expandVariables(this,cname,gname,xmlname,dt,causality,flag)
            if isa(dt,'coder.types.Numeric')||isa(dt,'coder.descriptor.types.Numeric')
                this.addVariable(cname,gname,xmlname,dt.Name,causality,flag,0,0,0);
            elseif isa(dt,'coder.types.Matrix')||isa(dt,'coder.descriptor.types.Matrix')
                assert(~isempty(dt.Dimensions));

                if((isa(dt.BaseType,'coder.types.Char')||isa(dt.BaseType,'coder.descriptor.types.Char'))&&contains(dt.Name,['matrix',num2str(dt.Dimensions),'xchar']))
                    this.addVariable(cname,gname,xmlname,'string',causality,flag,0,0,dt.Dimensions);
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

                        this.expandVariables(cname,gname,xmlname,dt.BaseType,causality,flag);
                    else
                        isSimulinkParameterObject=0;
                        isSimulinkSignalObject=0;
                        if strcmp(causality,'parameter')
                            evalStr=strrep(strrep(gname,'[','('),']',')');
                            if isempty(flag)
                                isSimulinkParameterObject=Simulink.data.evalinGlobal(...
                                this.ModelIdentifier,['isa(',evalStr,', ''Simulink.Parameter'')']);
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
                                [gname,'.Value(',strjoin(arrayfun(@num2str,dims,'UniformOutput',false),','),')'],...
                                [xmlname,'[',strjoin(arrayfun(@num2str,dims,'UniformOutput',false),','),']'],...
                                dt.BaseType,causality,flag);
                            elseif isSimulinkSignalObject
                                this.expandVariables([cname,'[',num2str(colMajorIdx),']'],...
                                ['str2num(',gname,'.InitialValue)[',strjoin(arrayfun(@num2str,dims,'UniformOutput',false),','),']'],...
                                [xmlname,'[',strjoin(arrayfun(@num2str,dims,'UniformOutput',false),','),']'],...
                                dt.BaseType,causality,flag);
                            else
                                this.expandVariables([cname,'[',num2str(colMajorIdx),']'],...
                                [gname,'(',strjoin(arrayfun(@num2str,dims,'UniformOutput',false),','),')'],...
                                [xmlname,'[',strjoin(arrayfun(@num2str,dims,'UniformOutput',false),','),']'],...
                                dt.BaseType,causality,flag);
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
                        this.ModelIdentifier,['isa(',evalStr,', ''Simulink.LookupTable'')']);
                        isSimulinkParameterObject=Simulink.data.evalinGlobal(...
                        this.ModelIdentifier,['isa(',evalStr,', ''Simulink.Parameter'')']);
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
                        lut=Simulink.data.evalinGlobal(this.ModelIdentifier,evalStr);
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
                        {['Breakpoints[',num2str(iter),'].Value']};
                    end
                    for iter=1:length(dt.Elements)
                        breakPointField=lutDictionary(dt.Elements(iter).Identifier);
                        this.expandVariables([cname,'.',dt.Elements(iter).Identifier],...
                        [gname,'.',breakPointField{1}],...
                        [xmlname,'.',breakPointField{1}],...
                        dt.Elements(iter).Type,causality,flag);
                    end
                else
                    for iter=1:length(dt.Elements)
                        if isSimulinkParameterObject
                            this.DataTypeMap([gname,'.Value.',dt.Elements(iter).Identifier])=[dt.Identifier,'.Elements(',num2str(iter),')'];
                            this.expandVariables([cname,'.',dt.Elements(iter).Identifier],...
                            [gname,'.Value.',dt.Elements(iter).Identifier],...
                            [xmlname,'.',dt.Elements(iter).Identifier],...
                            dt.Elements(iter).Type,causality,flag);
                        elseif isSimulinkSignalObject
                            this.DataTypeMap(['str2num(',gname,'.InitialValue).',dt.Elements(iter).Identifier])=[dt.Identifier,'.Elements(',num2str(iter),')'];
                            this.expandVariables([cname,'.',dt.Elements(iter).Identifier],...
                            ['str2num(',gname,'.InitialValue).',dt.Elements(iter).Identifier],...
                            [xmlname,'.',dt.Elements(iter).Identifier],...
                            dt.Elements(iter).Type,causality,flag);
                        else
                            if~startsWith(dt.Identifier,'struct_')

                                this.DataTypeMap([gname,'.',dt.Elements(iter).Identifier])=[dt.Identifier,'.Elements(',num2str(iter),')'];
                            end
                            this.expandVariables([cname,'.',dt.Elements(iter).Identifier],...
                            [gname,'.',dt.Elements(iter).Identifier],...
                            [xmlname,'.',dt.Elements(iter).Identifier],...
                            dt.Elements(iter).Type,causality,flag);
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

                this.addVariable(cname,gname,xmlname,['enum:',dt.Name],causality,flag,0,0,0);
            elseif isa(dt,'coder.types.Complex')
                error(DAStudio.message('FMUExport:FMU:UnknownComplexity',gname));
            else


                error(DAStudio.message('FMUExport:FMU:UnknownDataType',gname,dt.Name));
            end

        end

        function buildVariableList(this)






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
                for i=1:numel(this.CodeInfo.Inports)
                    origNameCausalitySet=[origNameCausalitySet,[this.CodeInfo.Inports(i).GraphicalName,', input']];
                end
            end
            if~isempty(this.CodeInfo.Outports)
                origNameSet=[origNameSet,{this.CodeInfo.Outports.GraphicalName}];
                for i=1:numel(this.CodeInfo.Outports)
                    origNameCausalitySet=[origNameCausalitySet,[this.CodeInfo.Outports(i).GraphicalName,', output']];
                end
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


            this.compileTimeUnitMap=Simulink.fmuexport.internal.CompileTimeInfoUtil.queryCompileTimeUnitMap(this.ModelIdentifier);
            this.InportList=Simulink.fmuexport.internal.CompileTimeInfoUtil.queryCompileTimeInportList(this.ModelIdentifier);

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





                if isprop(impl,'ElementIdentifier')&&~isempty(impl.ElementIdentifier)


                    signalName=impl.ElementIdentifier;
                    signalObject=coder.internal.fmuexport.searchObjectsInWorkspace(this.CodeInfo.Name,signalName,'Simulink.Signal');
                    if~isempty(signalObject)
                        this.DataTypeMap(gName)=impl.ElementIdentifier;
                    end
                end

                varName=this.resolveCGName('input',gName,impl);
                this.expandVariables(varName,gName,xmlName,varType,'input','');
            end

            this.OutportList=Simulink.fmuexport.internal.CompileTimeInfoUtil.queryCompileTimeOutportList(this.ModelIdentifier);
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

                if isprop(impl,'ElementIdentifier')&&~isempty(impl.ElementIdentifier)


                    signalName=impl.ElementIdentifier;
                    signalObject=coder.internal.fmuexport.searchObjectsInWorkspace(this.CodeInfo.Name,signalName,'Simulink.Signal');
                    if~isempty(signalObject)
                        this.DataTypeMap(gName)=impl.ElementIdentifier;
                    end
                end

                varName=this.resolveCGName('output',gName,impl);
                this.expandVariables(varName,gName,xmlName,varType,'output','');
            end
























            this.addVariable('modelData->time','time','time','double','independent','',0,0,0);



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
                    varName=this.resolveCGName('local',gName,impl);
                    this.expandVariables(varName,gName,xmlName,varType,'local','');
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
                    errorID='FMUExport:FMU:UnknowSignalStorageClass';
                    varName=this.resolveCodeDescriptorGName(gName,impl,errorID);
                    this.expandVariables(varName,gName,xmlName,varType,'local','');
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
                    errorID='FMUExport:FMU:UnknownTestPointStorageClass';
                    varName=this.resolveCodeDescriptorGName(gName,impl,errorID);
                    this.expandVariables(varName,gName,xmlName,varType,'local','');
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
                        this.addVariable(varName,xmlName,xmlName,varType,causality,flag,is_cont_state,is_derivative,0);
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
                        this.addVariable(varName,xmlName,xmlName,varType,causality,flag,is_cont_state,is_derivative,0);
                    end
                end
            end









            dataTypeFields=fieldnames(this.TypeTable);
            for f=1:length(dataTypeFields)
                this.TypeParamStartTableVr.(dataTypeFields{f})=length(this.TypeTable.(dataTypeFields{f}));
            end



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
                        flag=this.ModelIdentifier;
                    end
                    xmlName=this.graphicalNameMap([tmp{2},', parameter']);
                    varType=this.CodeInfo.Parameters(i).Type;
                    impl=this.CodeInfo.Parameters(i).Implementation;
                    varName=this.resolveCGName('parameter',gName,impl);
                    this.expandVariables(varName,gName,xmlName,varType,'parameter',flag);
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
        function this=ModelCGInfoUtils(codeInfo,compInt,buildOpts,rtwInfo,cgModel,buildInfo)
            assert(isa(codeInfo,'RTW.ComponentInterface'));
            this=this@Simulink.fmuexport.internal.ModelInfoUtilsBase(codeInfo.Name);
            this.CodeInfo=codeInfo;
            this.CompInterface=compInt;
            this.BuildOpts=buildOpts;
            this.RTWInfo=rtwInfo;
            this.CGModel=cgModel;
            this.Description=get_param(this.ModelIdentifier,'Description');
            this.Author='';
            this.Copyright='';
            this.License='';
            this.StartTime=rtwInfo.StartTime;
            this.StopTime=rtwInfo.StopTime;
            this.FixedStepSize=rtwInfo.FundamentalStepSize;
            this.CompatibleRelease='all';
            this.requireMATLAB='no';
            this.GUID=Simulink.fmuexport.internal.ModelInfoUtilsBase.ModelChecksumToGUID(this.CodeInfo.Checksum);
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

            this.Version=get_param(this.ModelIdentifier,'ModelVersion');
            this.updateBuildInfoSourceCode(buildInfo);
            this.constructBusObjectInformation();

            modelSettingBackup=coder.internal.fmuexport.getSetFMUSetting;


            this.canBeInstantiatedOnlyOncePerProcessOverride=false;
            this.initialUnknownDependenciesOverride=false;

            if modelSettingBackup.isKey([this.ModelIdentifier,'.canBeInstantiatedOnlyOncePerProcessOverride'])
                this.canBeInstantiatedOnlyOncePerProcessOverride=strcmpi(modelSettingBackup([this.ModelIdentifier,'.canBeInstantiatedOnlyOncePerProcessOverride']),'on');
            end
            if modelSettingBackup.isKey([this.ModelIdentifier,'.initialUnknownDependenciesOverride'])
                this.initialUnknownDependenciesOverride=strcmpi(modelSettingBackup([this.ModelIdentifier,'.initialUnknownDependenciesOverride']),'on');
            end

            this.AddProtectedModel=strcmpi(get_param(this.ModelIdentifier,'AddNativeSimulinkBehavior'),'on');
        end

        function updateBuildInfoSourceCode(this,updatedBuildInfo)
            this.SaveSourceCode=strcmpi(get_param(this.ModelIdentifier,'SaveSourceCodeToFMU'),'on');
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
                busObject=coder.internal.fmuexport.searchObjectsInWorkspace(this.ModelIdentifier,type.Name,'Simulink.Bus');
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

        function varName=resolveCGName(this,type,gName,impl)
            varName={};
            while isa(impl,'RTW.StructExpression')
                varName=[impl.ElementIdentifier,varName];%#ok
                impl=impl.BaseRegion;
            end

            assert(isa(impl,'RTW.Variable'));
            [StructType,fieldName,errorId]=this.getStructName(type);
            if isa(impl,'RTW.PointerVariable')

                varName=[impl.Identifier,varName];%#ok
                varName=strjoin(varName,'.');
                varName=['*',varName];
            elseif strcmp(impl.Identifier,StructType)


                varName=strjoin(varName,'.');
                if this.IsReusable
                    varName=['modelData->S->',fieldName,'->',varName];
                else
                    varName=[impl.Identifier,'.',varName];
                end
            elseif isempty(impl.Owner)

                varName=[impl.Identifier,varName];%#ok
                varName=strjoin(varName,'.');
            elseif strcmp(this.ModelIdentifier,impl.Owner)

                varName=[impl.Identifier,varName];%#ok
                varName=strjoin(varName,'.');
            else
                error(DAStudio.message(errorId,gName));
            end
        end

        function varName=resolveCodeDescriptorGName(this,gName,impl,errorID)
            varName={};
            while isa(impl,'coder.descriptor.StructExpression')
                varName=[impl.ElementIdentifier,varName];%#ok
                impl=impl.BaseRegion;
            end

            assert(isa(impl,'coder.descriptor.Variable'));
            if isa(impl,'coder.descriptor.PointerVariable')

                varName=[impl.Identifier,varName];%#ok
                varName=strjoin(varName,'.');
                varName=['*',varName];
            elseif isempty(impl.VarOwner)

                varName=[impl.Identifier,varName];%#ok
                varName=strjoin(varName,'.');
            elseif strcmp(this.CodeInfo.Name,impl.VarOwner)

                varName=[impl.Identifier,varName];%#ok
                varName=strjoin(varName,'.');
            else
                error(DAStudio.message(errorID,gName));
            end
        end

        function[structName,fieldName,errorId]=getStructName(this,type)
            switch type
            case 'input'
                structName=this.getInputStructName();
                fieldName='inputs';
                errorId='FMUExport:FMU:UnknownInputStorageClass';
            case 'output'
                structName=this.getOutputStructName();
                fieldName='outputs';
                errorId='FMUExport:FMU:UnknownOutputStorageClass';
            case 'parameter'
                structName=this.getParameterStructName();
                fieldName='defaultParam';
                errorId='FMUExport:FMU:UnknownParameterStorageClass';
            case 'local'
                structName='local';
                fieldName='locals';
                errorId='FMUExport:FMU:UnknownDSMStorageClass';
            otherwise
                assert(false,['invalid type: ',type]);
            end
        end

        function delete(this)
        end

        function isReusable=IsReusable(this)
            isReusable=strcmp(get_param(this.ModelIdentifier,'CodeInterfacePackaging'),'Reusable function');
        end

        function isCombineOutputUpdate=IsCombineOutputUpdate(this)
            isCombineOutputUpdate=strcmp(get_param(this.ModelIdentifier,'CombineOutputUpdateFcns'),'on');
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



