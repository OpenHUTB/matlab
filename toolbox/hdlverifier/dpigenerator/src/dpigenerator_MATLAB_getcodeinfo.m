function SystemInfo=dpigenerator_MATLAB_getcodeinfo(projectName)




    load codeInfo;


    SystemInfo.Name=codeInfo.Name;%#ok<NODEF>

    SystemInfo.TestPointStruct.NumTestPoints=0;
    SystemInfo.TestPointStruct.TestPointContainer=containers.Map;

    SystemInfo.ComponentTemplateType=MATLAB_DPICGen.DPICGenInst.ComponentTemplateType;

    if isa(MATLAB_DPICGen.DPICGenInst.configObj,'coder.EmbeddedCodeConfig')

        emxArrPrefix=erase(MATLAB_DPICGen.DPICGenInst.configObj.CustomSymbolStrEMXArray,'$M$N');
        emxAPIPrefix=erase(MATLAB_DPICGen.DPICGenInst.configObj.CustomSymbolStrEMXArrayFcn,'$M$N');
    else
        emxArrPrefix='emxArray_';
        emxAPIPrefix='emx';
    end
    SystemInfo.VarSizeInfo=struct('containVarSizeOutput',false,...
    'containUpperBoundArr',false,...
    'containEmxArr',false,...
    'emxArrPrefix',emxArrPrefix,...
    'emxAPIPrefix',emxAPIPrefix,...
    'staticVarSufix','_hdlv_dpi_temp',...
    'emxCreateFcn','CreateND_',...
    'emxDestroyFcn','DestroyArray_',...
    'emxInitFcn','InitArray_');
    SystemInfo.CtrlSigStruct=struct('CtrlType',{'Clock','Clock_Enable','Reset'},...
    'Name',{'clk','clk_enable','reset'},...
    'SVDataType',{'bit','bit','bit'});
    try




        structInfoInports=containers.Map({'TopStructName','TopStructDim','TopRowMajor','ElementAccessIndexNumber','ElementAccessIndexVariable','TopStructIndexing','ElementAccess','TopStructType','VariableNameDataSet'},...
        {{},[],[],[],{},{},{},{},{}});
        portInfoInports=containers.Map;


        munlock('dpigenerator_MATLAB_getFlattenedPortInfo')
        clear dpigenerator_MATLAB_getFlattenedPortInfo;
        SystemInfo=dpigenerator_MATLAB_getFlattenedPortInfo(codeInfo.Inports,'',structInfoInports,portInfoInports,true,'input',SystemInfo);
        clear dpigenerator_MATLAB_getFlattenedPortInfo;

        SystemInfo.InStruct.Port=l_getPortPositionToFlatNameMapping(portInfoInports);
        SystemInfo.InStruct.NumPorts=numel(SystemInfo.InStruct.Port);



        structInfoOutports=containers.Map({'TopStructName','TopStructDim','TopRowMajor','ElementAccessIndexNumber','ElementAccessIndexVariable','TopStructIndexing','ElementAccess','TopStructType','VariableNameDataSet'},...
        {{},[],[],[],{},{},{},{},{}});
        portInfoOutports=containers.Map;
        munlock('dpigenerator_MATLAB_getFlattenedPortInfo')
        clear dpigenerator_MATLAB_getFlattenedPortInfo;
        SystemInfo=dpigenerator_MATLAB_getFlattenedPortInfo(codeInfo.Outports,'',structInfoOutports,portInfoOutports,true,'output',SystemInfo);
        clear dpigenerator_MATLAB_getFlattenedPortInfo;
        SystemInfo.OutStruct.Port=l_getPortPositionToFlatNameMapping(portInfoOutports);

        SystemInfo.OutStruct.NumPorts=numel(SystemInfo.OutStruct.Port);


        if(SystemInfo.InStruct.NumPorts==0)&&(SystemInfo.OutStruct.NumPorts==0)
            error(message('HDLLink:DPIG:FcnNoPort',projectName));
        end


        if(SystemInfo.InStruct.NumPorts==0)&&strcmpi(SystemInfo.ComponentTemplateType,'combinational')
            error(message('HDLLink:DPIG:CombTemplateFcnNoInput',projectName));
        end


        InputKeys=keys(portInfoInports);
        InputValues=values(portInfoInports,InputKeys);
        OutputKeys=keys(portInfoOutports);
        OutputValues=values(portInfoOutports,OutputKeys);
        SystemInfo.PortMap=containers.Map([InputKeys,OutputKeys],[InputValues,OutputValues]);






        validPortNames=containers.Map;

        varSizeCPortMap=containers.Map;
        l_getNativeCPortNames(SystemInfo.PortMap,validPortNames,varSizeCPortMap);

        SystemInfo.InitializeFcn=l_getFuncArgs(codeInfo.InitializeFunctions,validPortNames,varSizeCPortMap);
        SystemInfo.ResetFcn=l_getResetFuncArgs(codeInfo.OutputFunctions,validPortNames,varSizeCPortMap);
        SystemInfo.OutputFcn=l_getFuncArgs(codeInfo.OutputFunctions,validPortNames,varSizeCPortMap);
        SystemInfo.TerminateFcn=l_getFuncArgs(codeInfo.TerminateFunctions,validPortNames,varSizeCPortMap);
        SystemInfo.MLCoderCodeGen=true;
        if SystemInfo.VarSizeInfo.containVarSizeOutput



            SystemInfo.OutputFcn.DPIRealNames={[SystemInfo.OutputFcn.DPIName,'_output1'],...
            [SystemInfo.OutputFcn.DPIName,'_output2']};
        end

        if SystemInfo.VarSizeInfo.containEmxArr||SystemInfo.VarSizeInfo.containUpperBoundArr



            if strcmpi(SystemInfo.ComponentTemplateType,'combinational')
                throw(MException(message('HDLLink:DPIG:VariableSizedNotSupportCombinationalTemplate')));
            end
        end

















        if~isempty(codeInfo.InitializeFunctions.ActualArgs)&&(strcmp(class(codeInfo.InitializeFunctions.ActualArgs.Implementation.Type.BaseType.Elements),'coder.types.AggregateElement'))%#ok<STISA> 'isa' does not seem to work
            SystemInfo.RequiresDynMemAlloc=false;
            SystemInfo.MultiInstance=true;

            OneStackDataCount=1;
            InternalDataLength=length(codeInfo.InternalData);
            for idx=1:InternalDataLength
                if isa(codeInfo.InternalData(idx).Implementation,'RTW.PointerVariable')


                    assert(OneStackDataCount==1,message('HDLLink:DPIG:MoreThanOneStackData'))
                    OneStackDataCount=OneStackDataCount+1;

                    codeInfo.InternalData(idx).Implementation.Owner='dpigen';
                    codeInfo.InternalData(idx).Implementation.TargetVariable.Owner='dpigen';
                    SystemInfo.StackData_EmbedStructType=codeInfo.InternalData(idx).Implementation.Type.BaseType.Identifier;
                    SystemInfo.StackData_EmbedStructName=codeInfo.InternalData(idx).Implementation.getExpression;
                end
            end


            SystemInfo.OpaquePointerInfo=struct('Expresion',cell(1,InternalDataLength-1),'DataType',cell(1,InternalDataLength-1));
            for idx=1:InternalDataLength
                if isa(codeInfo.InternalData(idx).Implementation,'RTW.PointerExpression')&&codeInfo.InternalData(idx).Implementation.isDefined

                    SystemInfo.OpaquePointerInfo(idx).Expresion=codeInfo.InternalData(idx).Implementation.getExpression;

                    SystemInfo.OpaquePointerInfo(idx).DataType=codeInfo.InternalData(idx).Implementation.Type.Identifier;
                end
            end



        elseif isempty(codeInfo.InitializeFunctions.ActualArgs)&&...
            ~isempty(codeInfo.OutputFunctions.ActualArgs)&&...
            isa(codeInfo.OutputFunctions.ActualArgs(1).Implementation.Type,'coder.types.Pointer')&&...
            isa(codeInfo.OutputFunctions.ActualArgs(1).Implementation.Type.BaseType.Elements,'coder.types.AggregateElement')

            SystemInfo.RequiresDynMemAlloc=true;
            SystemInfo.MultiInstance=false;

            OneStackDataCount=1;
            InternalDataLength=length(codeInfo.InternalData);
            for idx=1:InternalDataLength
                if isa(codeInfo.InternalData(idx).Implementation,'RTW.PointerVariable')


                    assert(OneStackDataCount==1,message('HDLLink:DPIG:MoreThanOneStackData'))
                    OneStackDataCount=OneStackDataCount+1;

                    codeInfo.InternalData(idx).Implementation.Owner='dpigen';
                    codeInfo.InternalData(idx).Implementation.TargetVariable.Owner='dpigen';
                    SystemInfo.StackData_EmbedStructType=codeInfo.InternalData(idx).Implementation.Type.BaseType.Identifier;
                    SystemInfo.StackData_EmbedStructName=codeInfo.InternalData(idx).Implementation.getExpression;
                end
            end
        else
            SystemInfo.RequiresDynMemAlloc=false;
            SystemInfo.MultiInstance=false;
        end


        if~isempty(codeInfo.TerminateFunctions.ActualArgs)
            SystemInfo.RequiresMLCoderCleanUp=true;
        else
            SystemInfo.RequiresMLCoderCleanUp=false;
        end
    catch ME
        baseME=MException(message('HDLLink:DPIG:CodeInfoError'));
        newME=addCause(ME,baseME);
        throw(newME);
    end
end

function fcn=l_getResetFuncArgs(codeInfoFcn,validPortNames,varSizePortMap)
    fcn=l_getFuncArgs(codeInfoFcn,validPortNames,varSizePortMap);
    fcn.Name='reset';
    fcn.DPIName=[fcn.DPIName,'_reset'];
end

function fcn=l_getFuncArgs(codeInfoFcn,validPortNames,varSizePortMap)
    if isempty(codeInfoFcn)
        fcn={};
        return;
    else
        fcn.Name=codeInfoFcn.Prototype.Name;
        fcn.DPIName=['DPI_',fcn.Name];

        p=MATLAB_DPICGen.DPICGenInst;
        IsBitVector=strcmpi(p.PortsDataType,'BitVector')||strcmpi(p.PortsDataType,'LogicVector');
        IsNonFloating=false;
        if~(isempty(codeInfoFcn.Prototype.Return)||codeInfoFcn.ActualReturn.Type.isEnum)
            IsNonFloating=~(codeInfoFcn.ActualReturn.Type.isDouble||codeInfoFcn.ActualReturn.Type.isSingle||codeInfoFcn.ActualReturn.Type.isHalf);
        end
        if isempty(codeInfoFcn.Prototype.Return)
            fcn.ReturnKey='void';
        elseif codeInfoFcn.Prototype.Return.Type.isComplex||(~codeInfoFcn.ActualReturn.Type.isEnum&&IsNonFloating&&IsBitVector)





            fcn.ReturnKey=codeInfoFcn.ActualReturn.GraphicalName;
        else
            fcn.ReturnKey=['*',codeInfoFcn.ActualReturn.GraphicalName];
        end

        tmp=codeInfoFcn.Prototype.Arguments;
        argsInfo=arrayfun(@(x)struct('args',x.Name,'Type',x.Type),tmp,'UniformOutput',false);


        fcn.ArgsKeys={};
        fcn.IsVarSize={};
        count=1;
        for idx=1:numel(argsInfo)

            if isKey(validPortNames,argsInfo{idx}.args)

                if validPortNames(argsInfo{idx}.args)



                    if argsInfo{idx}.Type.isComplex||(argsInfo{idx}.Type.isMatrix&&IsBitVector)
                        fcn.ArgsKeys{count}=argsInfo{idx}.args;
                    else




                        fcn.ArgsKeys{count}=['&',argsInfo{idx}.args];
                    end
                else


                    fcn.ArgsKeys{count}=argsInfo{idx}.args;
                end
                fcn.IsVarSize{count}=varSizePortMap(argsInfo{idx}.args);
                count=count+1;
            end
        end
    end
end

function PortCell=l_getPortPositionToFlatNameMapping(PortsMap)

    Portkeys=keys(PortsMap);
    PortCell=cell(1,numel(Portkeys));
    for idx=Portkeys
        keyVal=idx{1};
        PortCell{PortsMap(keyVal).PortPosition}=PortsMap(keyVal).FlatName;
    end
end

function l_getNativeCPortNames(PortMap,validCNativePortNames,varSizeCPortMap)
    PortNameKeys=keys(PortMap);
    for idx=PortNameKeys
        keyvals=idx{1};

        if PortMap(keyvals).IsVarSize&&strcmpi(PortMap(keyvals).VarSizeType,'upperBoundedArray')

            validCNativePortNames(PortMap(keyvals).CPortNames{1})=false;
            validCNativePortNames(PortMap(keyvals).CPortNames{2})=false;
            varSizeCPortMap(PortMap(keyvals).CPortNames{1})=true;
            varSizeCPortMap(PortMap(keyvals).CPortNames{2})=true;

        elseif isempty(PortMap(keyvals).StructInfo)
            if strcmpi(PortMap(keyvals).DPIPortsDataType,'BitVector')||strcmpi(PortMap(keyvals).DPIPortsDataType,'LogicVector')
                if strcmpi(PortMap(keyvals).Direction,'Input')
                    validCNativePortNames(PortMap(keyvals).Name)=false;
                elseif PortMap(keyvals).Dim>1&&PortMap(keyvals).DataTypeSize>64...
                    ||PortMap(keyvals).Dim==inf


                    validCNativePortNames(PortMap(keyvals).Name)=false;
                else
                    validCNativePortNames(PortMap(keyvals).Name)=true;
                end
                if PortMap(keyvals).IsVarSize
                    varSizeCPortMap(PortMap(keyvals).Name)=true;
                else
                    varSizeCPortMap(PortMap(keyvals).Name)=false;
                end
            else


                validCNativePortNames(PortMap(keyvals).FlatName)=false;
                if PortMap(keyvals).IsVarSize
                    varSizeCPortMap(PortMap(keyvals).FlatName)=true;
                else
                    varSizeCPortMap(PortMap(keyvals).FlatName)=false;
                end
            end





        else





            if PortMap(keyvals).StructInfo.TopStructDim(1)==1




                validCNativePortNames(PortMap(keyvals).StructInfo.TopStructName{1})=true;
            else



                validCNativePortNames(PortMap(keyvals).StructInfo.TopStructName{1})=false;
            end

            if PortMap(keyvals).IsVarSize
                varSizeCPortMap(PortMap(keyvals).StructInfo.TopStructName{1})=true;
            else
                varSizeCPortMap(PortMap(keyvals).StructInfo.TopStructName{1})=false;
            end

        end

    end
end




