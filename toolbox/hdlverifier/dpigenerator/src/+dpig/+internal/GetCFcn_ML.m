classdef GetCFcn_ML<handle

    properties
        mCodeInfo;

        BitInterfaceMap;

    end


    properties(Access=private)
        StackData_DataType;
        StackData_Name;
        FreePersistentVars;
    end
    properties(Constant)
        ExistHandle='existhandle';
        ObjHandle='objhandle';
    end

    methods(Access=private)

        function str=getTerminateCall(obj,FirstArgVarName)
            str=sprintf('%s(%s)',obj.mCodeInfo.TerminateFcn.DPIName,FirstArgVarName);
        end

        function str=getInitializeCall(obj,FirstArgVarName)
            str=sprintf('%s(%s)',obj.mCodeInfo.InitializeFcn.DPIName,FirstArgVarName);
        end

        function str=getOutputCall(obj,FirstArgVarName)
            [argList,~]=l_getArgumentCallList(obj);
            str=sprintf('%s(%s)',obj.mCodeInfo.OutputFcn.DPIName,...
            char(join([FirstArgVarName,argList],',')));
        end


        function str=getOutput1Call(obj,FirstArgVarName)
            [argList,~]=l_getArgumentCallList(obj);
            str=sprintf('%s(%s)',obj.mCodeInfo.OutputFcn.DPIRealNames{1},...
            char(join([FirstArgVarName,argList],',')));
        end

        function str=getOutput2Call(obj)
            [~,argList]=l_getArgumentCallList(obj);
            str=sprintf('%s(%s)',obj.mCodeInfo.OutputFcn.DPIRealNames{2},...
            char(join(argList,',')));
        end
        function str=getTempSizeVarForResetFcn(obj)


            str='';
            for ii=1:(obj.mCodeInfo.OutStruct.NumPorts)
                curPortInfo=obj.mCodeInfo.PortMap(obj.mCodeInfo.OutStruct.Port{ii});
                if curPortInfo.IsVarSize
                    str=sprintf('%s%s;\n',str,['int ',curPortInfo.FlatName,'_size',obj.mCodeInfo.VarSizeInfo.staticVarSufix]);
                end
            end
        end

    end

    methods
        function obj=GetCFcn_ML(codeInfo)
            obj.mCodeInfo=codeInfo;
            obj.BitInterfaceMap=containers.Map;
        end

        function CFunctionDeclaration=getImportFcn(obj,fcnName)
            switch(fcnName)
            case 'Init'



                CFunctionDeclaration=['DPI_DLL_EXPORT void * ',obj.mCodeInfo.InitializeFcn.DPIName,'(void* ',obj.ExistHandle,');'];
            case 'Reset'
                ArgumentList=l_getArgumentList(obj,'Reset');
                CFunctionDeclaration=['DPI_DLL_EXPORT void * ',obj.mCodeInfo.ResetFcn.DPIName,'(void* objhandle',ArgumentList];
            case 'Output'
                [ArgumentList,~]=l_getArgumentList(obj,'Output');
                CFunctionDeclaration=['DPI_DLL_EXPORT void ',obj.mCodeInfo.OutputFcn.DPIName,'(void* objhandle',ArgumentList];
            case 'Output1'
                [ArgumentList,~]=l_getArgumentList(obj,'Output1');
                CFunctionDeclaration=['DPI_DLL_EXPORT void ',obj.mCodeInfo.OutputFcn.DPIRealNames{1},'(void* objhandle',ArgumentList];
            case 'Output2'
                [~,ArgumentList]=l_getArgumentList(obj,'Output2');
                CFunctionDeclaration=['DPI_DLL_EXPORT void ',obj.mCodeInfo.OutputFcn.DPIRealNames{2},'(',ArgumentList];
            case 'Terminate'
                CFunctionDeclaration=['DPI_DLL_EXPORT void ',obj.mCodeInfo.TerminateFcn.DPIName,'(void* ',obj.ExistHandle,');'];
            otherwise
                error(message('HDLLink:DPIG:InvalidFunctionName',fcnName));
            end
        end

        function str=getSVDPIHeader(obj)
            str='';
            if obj.mCodeInfo.VarSizeInfo.containUpperBoundArr||obj.mCodeInfo.VarSizeInfo.containEmxArr
                str='#include "svdpi.h"';
            end
        end

        function str=getEmxAPIHeader(obj)
            str='';
            if obj.mCodeInfo.VarSizeInfo.containEmxArr
                str=['#include "',obj.mCodeInfo.Name,'_emxAPI.h"'];
            end
        end

        function str=getStaticVarDelForVarSizeVar(obj)


            str='';
            declaredVar=containers.Map;
            if obj.mCodeInfo.VarSizeInfo.containVarSizeOutput
                for ii=1:(obj.mCodeInfo.OutStruct.NumPorts)
                    curPortInfo=obj.mCodeInfo.PortMap(obj.mCodeInfo.OutStruct.Port{ii});
                    if curPortInfo.IsVarSize
                        if strcmpi(curPortInfo.VarSizeType,'emxArray')
                            if curPortInfo.IsComplex
                                varName=[curPortInfo.StructInfo.TopStructName{1},obj.mCodeInfo.VarSizeInfo.staticVarSufix];
                            else
                                if strcmpi(curPortInfo.DPIPortsDataType,'LogicVector')||strcmpi(curPortInfo.DPIPortsDataType,'BitVector')




                                    varName=[curPortInfo.Name,obj.mCodeInfo.VarSizeInfo.staticVarSufix];
                                else
                                    varName=[curPortInfo.FlatName,obj.mCodeInfo.VarSizeInfo.staticVarSufix];
                                end
                            end
                            if~isKey(declaredVar,varName)
                                str=sprintf('%s%s;\n',str,['static ',curPortInfo.EmxDataType,' *',varName]);
                                declaredVar(varName)=true;
                            end
                        else
                            if curPortInfo.IsComplex
                                varType=curPortInfo.StructInfo.TopStructType{1};
                                varSize=num2str(curPortInfo.StructInfo.TopStructDim);
                            else
                                varType=curPortInfo.DataType;
                                varSize=num2str(curPortInfo.Dim);
                            end


                            varName=[curPortInfo.CPortNames{1},obj.mCodeInfo.VarSizeInfo.staticVarSufix];
                            if~isKey(declaredVar,varName)
                                str=sprintf('%s%s;\n',str,['static ',varType,' ',varName,'[',varSize,']']);
                                declaredVar(varName)=true;
                            end
                        end
                    end
                end
            end
        end

        function str=getCanonicalBitInterfaceRepresentation(obj)
            svCanonicalRepresentation='';
            for Direction={'InStruct','OutStruct'}
                DirectionKey=Direction{1};
                for ii=1:(obj.mCodeInfo.(DirectionKey).NumPorts)
                    portInfo=obj.mCodeInfo.PortMap(obj.mCodeInfo.(DirectionKey).Port{ii});

                    if strcmpi(portInfo.DPIPortsDataType,'BitVector')||strcmpi(portInfo.DPIPortsDataType,'LogicVector')

                        if strcmpi(portInfo.Direction,'input')
                            obj.BitInterfaceMap(portInfo.DPIFixedPointInterfaceMarshallingObj.getCDataFromBits_FcnCall('',''))=portInfo.DPIFixedPointInterfaceMarshallingObj.getCDataFromBits_FcnDef();
                        else
                            obj.BitInterfaceMap(portInfo.DPIFixedPointInterfaceMarshallingObj.getBitsFromCData_FcnCall('',''))=portInfo.DPIFixedPointInterfaceMarshallingObj.getBitsFromCData_FcnDef();
                        end

                        if isempty(svCanonicalRepresentation)
                            if obj.mCodeInfo.VarSizeInfo.containUpperBoundArr||obj.mCodeInfo.VarSizeInfo.containEmxArr



                                svCanonicalRepresentation=portInfo.DPIFixedPointInterfaceMarshallingObj.getDPICanonicalRepresentation(true);
                            else
                                svCanonicalRepresentation=portInfo.DPIFixedPointInterfaceMarshallingObj.getDPICanonicalRepresentation(false);
                            end
                        end
                    end
                end
            end
            str=svCanonicalRepresentation;
        end

        function str=getBitInterfaceFcnDef(obj)
            str='';
            for key_temp=keys(obj.BitInterfaceMap)
                key=key_temp{1};
                str=sprintf('%s\n%s',str,obj.BitInterfaceMap(key));
            end
        end

        function str=getFcnCall(obj,fcnName)
            varSizeInfo=obj.mCodeInfo.VarSizeInfo;
            switch(fcnName)
            case 'Init'

                str_InitStaticEmxArr=l_InitStaticEmxArr(obj.mCodeInfo);


                if obj.mCodeInfo.MultiInstance


                    obj.StackData_DataType=obj.mCodeInfo.StackData_EmbedStructType;
                    obj.StackData_Name=obj.mCodeInfo.StackData_EmbedStructName;
                    CastTo_StackData_pointer=['(',obj.StackData_DataType,'* )'];

                    AllocateStruct_StackData=[CastTo_StackData_pointer,'malloc(sizeof(',obj.StackData_DataType,'));'];


                    OpaquePointerAllocation='';
                    obj.FreePersistentVars='';
                    for idx=1:length(obj.mCodeInfo.OpaquePointerInfo)

                        if~isempty(obj.mCodeInfo.OpaquePointerInfo(idx).DataType)&&~isempty(obj.mCodeInfo.OpaquePointerInfo(idx).Expresion)

                            CastTo_Opaque_pointer=['(',obj.mCodeInfo.OpaquePointerInfo(idx).DataType,'* )'];
                            AllocateStruct_PersistentData=[CastTo_Opaque_pointer,'malloc(sizeof(',obj.mCodeInfo.OpaquePointerInfo(idx).DataType,'));'];
                            OpaquePointerAllocation=sprintf('%s%s\n',OpaquePointerAllocation,[obj.mCodeInfo.OpaquePointerInfo(idx).Expresion,'=',AllocateStruct_PersistentData]);

                            obj.FreePersistentVars=sprintf('%sfree(%s);\n',obj.FreePersistentVars,obj.mCodeInfo.OpaquePointerInfo(idx).Expresion);
                        end
                    end


                    Initialize_objhandle=sprintf('\t%s=%s\n\t%s\n',obj.StackData_Name,AllocateStruct_StackData,OpaquePointerAllocation);
                    Assign_objhandle=sprintf('\t%s=%s;\n',obj.StackData_Name,obj.ExistHandle);
                    Return_objhandle=sprintf('return (void*) %s;\n',obj.StackData_Name);

                    str_InitBody=sprintf(['%s * %s;\n',...
                    'if(%s==NULL){\n',...
                    '%s\n}',...
                    'else{\n',...
                    '%s\n}'],...
                    obj.StackData_DataType,obj.StackData_Name,...
                    obj.ExistHandle,...
                    Initialize_objhandle,...
                    Assign_objhandle);


                    obj.mCodeInfo.InitializeFcn.ArgsKeys=[{[CastTo_StackData_pointer,obj.StackData_Name]},obj.mCodeInfo.InitializeFcn.ArgsKeys];
                    obj.mCodeInfo.InitializeFcn.IsVarSize=[{false},obj.mCodeInfo.InitializeFcn.IsVarSize];
                    str_NativeSignature=l_getFcnCall(obj,obj.mCodeInfo.InitializeFcn);
                elseif obj.mCodeInfo.RequiresDynMemAlloc
                    obj.StackData_DataType=obj.mCodeInfo.StackData_EmbedStructType;
                    obj.StackData_Name=obj.mCodeInfo.StackData_EmbedStructName;
                    str_InitBody=sprintf(['%s * %s;\n',...
                    'if(%s==NULL){\n',...
                    '%s=malloc(sizeof(%s));\n}',...
                    'else{\n',...
                    '%s=%s;\n}'],...
                    obj.StackData_DataType,obj.StackData_Name,...
                    obj.ExistHandle,...
                    obj.StackData_Name,obj.StackData_DataType,...
                    obj.StackData_Name,obj.ExistHandle);


                    str_NativeSignature=l_getFcnCall(obj,obj.mCodeInfo.InitializeFcn);
                    Return_objhandle=sprintf('return (void*)%s;\n',obj.StackData_Name);
                else
                    str_InitBody='';
                    str_NativeSignature=l_getFcnCall(obj,obj.mCodeInfo.InitializeFcn);
                    Return_objhandle=sprintf('%s=NULL;\nreturn NULL;\n',obj.ExistHandle);
                end


                str=sprintf('%s%s\n%s\n%s',str_InitStaticEmxArr,str_InitBody,str_NativeSignature,Return_objhandle);

            case 'Reset'
                if varSizeInfo.containVarSizeOutput



                    str=sprintf(['%s;\n',...
                    '%s=NULL;\n',...
                    '%s=%s;\n',...
                    '%s',...
                    '%s;\n',...
                    '%s;\n',...
                    '%s;\n',...
                    '%s=NULL;\n',...
                    'return %s;\n'],...
                    obj.getTerminateCall(obj.ObjHandle),...
                    obj.ObjHandle,...
                    obj.ObjHandle,obj.getInitializeCall('NULL'),...
                    obj.getTempSizeVarForResetFcn,...
                    obj.getOutput1Call(obj.ObjHandle),...
                    obj.getOutput2Call,...
                    obj.getTerminateCall(obj.ObjHandle),...
                    obj.ObjHandle,...
                    obj.getInitializeCall('NULL'));
                else
                    str=sprintf(['%s;\n',...
                    '%s=NULL;\n',...
                    '%s=%s;\n',...
                    '%s;\n',...
                    '%s;\n',...
                    '%s=NULL;\n',...
                    'return %s;\n'],...
                    obj.getTerminateCall(obj.ObjHandle),...
                    obj.ObjHandle,...
                    obj.ObjHandle,obj.getInitializeCall('NULL'),...
                    obj.getOutputCall(obj.ObjHandle),...
                    obj.getTerminateCall(obj.ObjHandle),...
                    obj.ObjHandle,...
                    obj.getInitializeCall('NULL'));
                end
            case 'Output'




                if obj.mCodeInfo.MultiInstance||obj.mCodeInfo.RequiresDynMemAlloc

                    obj.mCodeInfo.OutputFcn.ArgsKeys={['(',obj.mCodeInfo.StackData_EmbedStructType,' *) objhandle'],obj.mCodeInfo.OutputFcn.ArgsKeys{:}};
                    obj.mCodeInfo.OutputFcn.IsVarSize=[{false},obj.mCodeInfo.OutputFcn.IsVarSize];
                end

                str_varSizeInputInit=l_varSizeInputInit(obj.mCodeInfo);


                str_NativeSignature=l_getFcnCall(obj,obj.mCodeInfo.OutputFcn);



                [TopStructsDecl,TopStructsInit,TopStructOutputInit]=l_flatten_And_unflatten_StructIO(obj.mCodeInfo);

                if~obj.mCodeInfo.MultiInstance&&~obj.mCodeInfo.RequiresDynMemAlloc
                    str_NativeSignature=sprintf('%s\n%s',str_NativeSignature,'objhandle=NULL;');
                end

                str_emxInputDestroy=l_emxDestroy(obj.mCodeInfo,'input');

                str=sprintf('%s%s\n%s\n%s\n%s%s\n',str_varSizeInputInit,TopStructsDecl,TopStructsInit,str_NativeSignature,str_emxInputDestroy,TopStructOutputInit);
            case 'Output1'
                if obj.mCodeInfo.MultiInstance||obj.mCodeInfo.RequiresDynMemAlloc

                    obj.mCodeInfo.OutputFcn.ArgsKeys={['(',obj.mCodeInfo.StackData_EmbedStructType,' *) objhandle'],obj.mCodeInfo.OutputFcn.ArgsKeys{:}};
                    obj.mCodeInfo.OutputFcn.IsVarSize=[{false},obj.mCodeInfo.OutputFcn.IsVarSize];
                end

                str_varSizeInputInit=l_varSizeInputInit(obj.mCodeInfo);

                str_sizeVectorForVarSizeOutput=l_createSizeVectorForVarSizeOutput(obj.mCodeInfo);

                str_NativeSignature=l_getFcnCall(obj,obj.mCodeInfo.OutputFcn);



                [TopStructsDecl,TopStructsInit,TopStructOutputInit]=l_flatten_And_unflatten_StructIO(obj.mCodeInfo);

                if~obj.mCodeInfo.MultiInstance&&~obj.mCodeInfo.RequiresDynMemAlloc
                    str_NativeSignature=sprintf('%s\n%s',str_NativeSignature,'objhandle=NULL;');
                end

                str_emxInputDestroy=l_emxDestroy(obj.mCodeInfo,'input');
                str_getVarSizeOutputSize=l_getVarSizeOutputSize(obj.mCodeInfo);
                str=sprintf('%s%s\n%s\n%s%s\n%s%s\n%s',str_varSizeInputInit,TopStructsDecl,TopStructsInit,str_sizeVectorForVarSizeOutput,str_NativeSignature,str_emxInputDestroy,TopStructOutputInit,str_getVarSizeOutputSize);
            case 'Output2'
                str=l_getVarSizeOutputData(obj.mCodeInfo);
            case 'Terminate'



                if obj.mCodeInfo.RequiresMLCoderCleanUp
                    obj.mCodeInfo.TerminateFcn.ArgsKeys=[{obj.StackData_Name},obj.mCodeInfo.TerminateFcn.ArgsKeys];
                    obj.mCodeInfo.TerminateFcn.IsVarSize=[{false},obj.mCodeInfo.TerminateFcn.IsVarSize];
                end

                str_NativeSignature=l_getFcnCall(obj,obj.mCodeInfo.TerminateFcn);
                str_emxOutputDestroy=l_emxDestroy(obj.mCodeInfo,'output');
                if obj.mCodeInfo.MultiInstance

                    str_InitBody=sprintf(['%s *%s=(%s*)%s;\n',...
                    '%s\n',...
                    '%s',...
                    'if(%s!=NULL){\n',...
'\t%s\n'...
                    ,'\tfree(%s);\n',...
                    '}\n'],...
                    obj.StackData_DataType,obj.StackData_Name,obj.StackData_DataType,obj.ExistHandle,...
                    str_NativeSignature,...
                    str_emxOutputDestroy,...
                    obj.ExistHandle,...
                    obj.FreePersistentVars,...
                    obj.StackData_Name);
                elseif obj.mCodeInfo.RequiresDynMemAlloc
                    str_InitBody=sprintf(['%s *%s=(%s*)%s;\n',...
                    '%s\n',...
                    '%s',...
                    'if(%s!=NULL){\n',...
                    '\tfree(%s);\n',...
                    '}\n'],...
                    obj.StackData_DataType,obj.StackData_Name,obj.StackData_DataType,obj.ExistHandle,...
                    str_NativeSignature,...
                    str_emxOutputDestroy,...
                    obj.ExistHandle,...
                    obj.StackData_Name);
                else
                    str_InitBody=sprintf(['%s=NULL;\n',...
                    '%s\n',...
                    '%s'],...
                    obj.ExistHandle,...
                    str_NativeSignature,...
                    str_emxOutputDestroy);
                end
                str=str_InitBody;
            otherwise
                error(message('HDLLink:DPIG:InvalidFunctionName',fcnName));
            end
        end

    end
end





function[ArgCallList1,ArgCallList2]=l_getArgumentCallList(obj)
    InputArgCallList_Temp={};
    OutputArgCallList_Temp={};
    portMap=obj.mCodeInfo.PortMap;
    if obj.mCodeInfo.InStruct.NumPorts>0
        ArgCallList1=cellfun(@(x)[InputArgCallList_Temp,portMap(x).FlatName],obj.mCodeInfo.InStruct.Port,'UniformOutput',true);
    else
        ArgCallList1=InputArgCallList_Temp;
    end

    ArgCallList2={};
    if obj.mCodeInfo.OutStruct.NumPorts>0
        if obj.mCodeInfo.VarSizeInfo.containVarSizeOutput
            for idx=1:(obj.mCodeInfo.OutStruct.NumPorts)
                curPortInfo=portMap(obj.mCodeInfo.OutStruct.Port{idx});
                if curPortInfo.IsVarSize
                    ArgCallList1=[ArgCallList1,['&',curPortInfo.FlatName,'_size',obj.mCodeInfo.VarSizeInfo.staticVarSufix]];%#ok<AGROW>
                    ArgCallList2=[ArgCallList2,curPortInfo.FlatName];%#ok<AGROW>
                else
                    ArgCallList1=[ArgCallList1,curPortInfo.FlatName];%#ok<AGROW>
                end
            end
        else
            ArgCallList1=[ArgCallList1,...
            cellfun(@(x)[OutputArgCallList_Temp,portMap(x).FlatName],obj.mCodeInfo.OutStruct.Port,'UniformOutput',true);];
        end
    else
        ArgCallList1=[ArgCallList1,OutputArgCallList_Temp];
    end
end

function[ArgList1,ArgList2]=l_getArgumentList(obj,fcnName)
    portMap=obj.mCodeInfo.PortMap;
    ArgList1=',';

    ArgList2='';


    for idx=1:obj.mCodeInfo.InStruct.NumPorts
        portInfo=portMap(obj.mCodeInfo.InStruct.Port{idx});
        ArgList1=[ArgList1,l_getFcnArgDecl(obj,portInfo),','];%#ok<AGROW>
    end

    for idx=1:obj.mCodeInfo.OutStruct.NumPorts
        portInfo=portMap(obj.mCodeInfo.OutStruct.Port{idx});
        if obj.mCodeInfo.VarSizeInfo.containVarSizeOutput&&startsWith(fcnName,'Output')
            curArg1=l_getFcnArgDecl(obj,portInfo,'Output1');
            curArg2=l_getFcnArgDecl(obj,portInfo,'Output2');
            ArgList1=[ArgList1,curArg1,','];%#ok<AGROW>
            if~isempty(curArg2)
                ArgList2=[ArgList2,curArg2,','];%#ok<AGROW>
            end
        else
            curArg1=l_getFcnArgDecl(obj,portInfo);
            ArgList1=[ArgList1,curArg1,','];%#ok<AGROW>
        end
    end


    if ArgList1(end)==','
        ArgList1(end)=[];
    end
    ArgList1=[ArgList1,');'];
    if~isempty(ArgList2)
        ArgList2(end)=[];
    end
    ArgList2=[ArgList2,');'];
end

function str=l_getFcnArgDecl(obj,portInfo,varargin)


    type=portInfo.DPI_C_InterfaceDataType;
    io=portInfo.Direction;
    dim=portInfo.Dim;
    BitInterface=portInfo.DPIPortsDataType;
    fcnName='';
    str='';
    if nargin>2
        fcnName=varargin{1};
    end
    if portInfo.IsVarSize
        if strcmpi(fcnName,'Output1')


            str=sprintf('%s %s','int*',[portInfo.FlatName,'_size_Handle']);
        else

            str=sprintf('%s %s','svOpenArrayHandle',portInfo.FlatName);
        end
    elseif~strcmpi(fcnName,'Output2')
        if strcmpi(BitInterface,'BitVector')||strcmpi(BitInterface,'LogicVector')

            str=sprintf('%s * %s',type,portInfo.FlatName);

        elseif dim>1

            str=sprintf('%s * %s',type,portInfo.FlatName);
        else





            if~isempty(portInfo.StructInfo)&&nnz(portInfo.StructInfo.TopStructDim>1)>0

                str=sprintf('%s * %s',type,portInfo.FlatName);
            else

                if strcmpi(io,'output')
                    str=sprintf('%s * %s',type,portInfo.FlatName);
                else
                    str=sprintf('%s %s',type,portInfo.FlatName);
                end
            end
        end
    end
end


function str=l_getFcnCall(obj,fcnInfo)
    if isempty(fcnInfo)
        str='';
    else
        if~strcmpi(fcnInfo.ReturnKey,'void')
            str=[fcnInfo.ReturnKey,'=',fcnInfo.Name,'('];
        else
            str=[fcnInfo.Name,'('];
        end

        for idx=1:numel(fcnInfo.ArgsKeys)
            myarg=fcnInfo.ArgsKeys{idx};
































            if fcnInfo.IsVarSize{idx}


                myarg=[myarg,obj.mCodeInfo.VarSizeInfo.staticVarSufix];%#ok<AGROW>
            end
            str=[str,myarg,','];%#ok<AGROW>
        end

        if str(end)==','
            str(end)=[];
        end
        str=[str,');'];
    end
end
function[str,ptrName]=l_getOpenArrPointer(identifier,dataType)
    ptrName=[identifier,'_Ptr'];
    str=sprintf('%s* %s=(%s* )svGetArrayPtr(%s);\n',dataType,ptrName,dataType,identifier);
end
function[str,varSizeCInputName]=l_createVarSizeInputStruct(portInfo,varSizeInfo,declaredVarMap)
    initSizeVector='';
    dimSize=portInfo.NumOfDim;
    if portInfo.IsComplex
        if strcmpi(portInfo.DPIPortsDataType,'LogicVector')||strcmpi(portInfo.DPIPortsDataType,'BitVector')
            [createSVOpenArrPointer,~]=l_getOpenArrPointer(portInfo.FlatName,portInfo.DPI_C_InterfaceDataType);
        else
            [createSVOpenArrPointer,~]=l_getOpenArrPointer(portInfo.FlatName,portInfo.DataType);
        end
        if strcmpi(portInfo.VarSizeType,'emxArray')
            sizeVectorName=[portInfo.StructInfo.TopStructName{1},'_size',varSizeInfo.staticVarSufix];
        else
            sizeVectorName=[portInfo.CPortNames{2},varSizeInfo.staticVarSufix];
        end
        createInputSizeVector=sprintf('int %s[%d];\n',sizeVectorName,dimSize);

    else
        if strcmpi(portInfo.DPIPortsDataType,'LogicVector')||strcmpi(portInfo.DPIPortsDataType,'BitVector')
            if strcmpi(portInfo.VarSizeType,'emxArray')



                sizeVectorName=[portInfo.Name,'_size',varSizeInfo.staticVarSufix];
            else
                sizeVectorName=[portInfo.CPortNames{2},varSizeInfo.staticVarSufix];
            end


            [createSVOpenArrPointer,OpenArrPointerName]=l_getOpenArrPointer(portInfo.FlatName,portInfo.DPI_C_InterfaceDataType);
        else
            if strcmpi(portInfo.VarSizeType,'emxArray')
                sizeVectorName=[portInfo.FlatName,'_size',varSizeInfo.staticVarSufix];
            else
                sizeVectorName=[portInfo.CPortNames{2},varSizeInfo.staticVarSufix];
            end
            [createSVOpenArrPointer,OpenArrPointerName]=l_getOpenArrPointer(portInfo.FlatName,portInfo.DataType);
        end
        createInputSizeVector=sprintf('int %s[%d];\n',sizeVectorName,dimSize);
    end

    for idx=1:dimSize
        if portInfo.MLMatrixSize(idx)==1
            initSizeVector=sprintf('%s%s\n',initSizeVector,[sizeVectorName,'[',num2str(idx-1),'] = 1;']);
        else
            initSizeVector=sprintf('%s%s\n',initSizeVector,[sizeVectorName,'[',num2str(idx-1),'] = svSize(',portInfo.FlatName,',1);']);
        end
    end


    if strcmpi(portInfo.VarSizeType,'emxArray')
        if portInfo.IsComplex
            varSizeCInputName=[portInfo.StructInfo.TopStructName{1},varSizeInfo.staticVarSufix];
            createFcnName=[varSizeInfo.emxAPIPrefix,varSizeInfo.emxCreateFcn,portInfo.StructInfo.TopStructType{1}];
            createVarSizeInput=sprintf('%s* %s=%s(%d,%s);\n',portInfo.EmxDataType,varSizeCInputName,createFcnName,...
            dimSize,sizeVectorName);

            copyDataFromOpenArrToVarSizeCInput='';
        else
            if strcmpi(portInfo.DPIPortsDataType,'LogicVector')||strcmpi(portInfo.DPIPortsDataType,'BitVector')
                varSizeCInputName=[portInfo.Name,varSizeInfo.staticVarSufix];

                copyDataFromOpenArrToVarSizeCInput='';
            else
                varSizeCInputName=[portInfo.FlatName,varSizeInfo.staticVarSufix];
                copyDataFromOpenArrToVarSizeCInput=sprintf('memcpy(%s->data,%s,%s);\n',varSizeCInputName,OpenArrPointerName,l_getOpenArrSizeInByte(portInfo.FlatName,portInfo.DataType));
            end
            if portInfo.IsEnum
                createFcnName=[varSizeInfo.emxAPIPrefix,varSizeInfo.emxCreateFcn,portInfo.EnumInfo.EnumType];
            else
                createFcnName=[varSizeInfo.emxAPIPrefix,varSizeInfo.emxCreateFcn,portInfo.DataType];
            end
            createVarSizeInput=sprintf('%s* %s=%s(%d,%s);\n',portInfo.EmxDataType,varSizeCInputName,createFcnName,...
            dimSize,sizeVectorName);
        end
    else
        varSizeCInputName=[portInfo.CPortNames{1},varSizeInfo.staticVarSufix];
        if portInfo.IsComplex
            createVarSizeInput=sprintf('%s %s[%d];\n',portInfo.StructInfo.TopStructType{1},varSizeCInputName,portInfo.StructInfo.TopStructDim);
            copyDataFromOpenArrToVarSizeCInput='';
        else
            if strcmpi(portInfo.DPIPortsDataType,'LogicVector')||strcmpi(portInfo.DPIPortsDataType,'BitVector')

                copyDataFromOpenArrToVarSizeCInput='';
            else
                copyDataFromOpenArrToVarSizeCInput=sprintf('memcpy(%s,%s,%s);\n',varSizeCInputName,OpenArrPointerName,l_getOpenArrSizeInByte(portInfo.FlatName,portInfo.DataType));
            end
            createVarSizeInput=sprintf('%s %s[%d];\n',portInfo.DataType,varSizeCInputName,portInfo.Dim);
        end
    end
    if isKey(declaredVarMap,varSizeCInputName)


        str=createSVOpenArrPointer;
    else
        str=[createSVOpenArrPointer,createInputSizeVector,initSizeVector,createVarSizeInput,copyDataFromOpenArrToVarSizeCInput];
    end
end

function str=l_InitStaticEmxArr(mCodeInfo)
    str='';
    varSizeInfo=mCodeInfo.VarSizeInfo;
    declaredVar=containers.Map;
    if varSizeInfo.containVarSizeOutput
        for ii=1:mCodeInfo.OutStruct.NumPorts
            curPortInfo=mCodeInfo.PortMap(mCodeInfo.OutStruct.Port{ii});
            if curPortInfo.IsVarSize
                if strcmpi(curPortInfo.VarSizeType,'emxArray')
                    if curPortInfo.IsComplex
                        varName=curPortInfo.StructInfo.TopStructName{1};
                        str_initCall=sprintf('%s%s%s(&%s%s,%d);\n',...
                        varSizeInfo.emxAPIPrefix,varSizeInfo.emxInitFcn,curPortInfo.StructInfo.TopStructType{1},...
                        varName,varSizeInfo.staticVarSufix,curPortInfo.NumOfDim);
                    elseif curPortInfo.IsEnum
                        varName=curPortInfo.FlatName;
                        str_initCall=sprintf('%s%s%s(&%s%s,%d);\n',...
                        varSizeInfo.emxAPIPrefix,varSizeInfo.emxInitFcn,curPortInfo.EnumInfo.EnumType,...
                        varName,varSizeInfo.staticVarSufix,curPortInfo.NumOfDim);
                    else
                        if strcmpi(curPortInfo.DPIPortsDataType,'LogicVector')||strcmpi(curPortInfo.DPIPortsDataType,'BitVector')
                            varName=curPortInfo.Name;
                        else
                            varName=curPortInfo.FlatName;
                        end
                        str_initCall=sprintf('%s%s%s(&%s%s,%d);\n',...
                        varSizeInfo.emxAPIPrefix,varSizeInfo.emxInitFcn,curPortInfo.DataType,...
                        varName,varSizeInfo.staticVarSufix,curPortInfo.NumOfDim);
                    end
                    if~isKey(declaredVar,varName)
                        str=sprintf('%s%s',str,str_initCall);
                        declaredVar(varName)=true;
                    end
                end
            end
        end
    end
end

function str=l_varSizeInputInit(mCodeInfo)
    str='';
    declaredVar=containers.Map;
    for idx=keys(mCodeInfo.PortMap)

        KeyVal=idx{1};
        curPortInfo=mCodeInfo.PortMap(KeyVal);
        if curPortInfo.IsVarSize&&strcmpi(curPortInfo.Direction,'input')
            [str_varSizeInput,varName]=l_createVarSizeInputStruct(curPortInfo,mCodeInfo.VarSizeInfo,declaredVar);
            str=sprintf('%s%s',str,str_varSizeInput);
            declaredVar(varName)=true;
        end
    end
end

function str=l_createSizeVectorForVarSizeOutput(mCodeInfo)
    str='';
    declaredVar=containers.Map;
    for idx=keys(mCodeInfo.PortMap)

        KeyVal=idx{1};
        curPortInfo=mCodeInfo.PortMap(KeyVal);
        if curPortInfo.IsVarSize&&strcmpi(curPortInfo.Direction,'output')...
            &&strcmpi(curPortInfo.VarSizeType,'upperBoundedArray')
            sizeVectorName=[curPortInfo.CPortNames{2},mCodeInfo.VarSizeInfo.staticVarSufix];
            if~isKey(declaredVar,sizeVectorName)
                str=sprintf('%sint %s[%d];\n',str,sizeVectorName,curPortInfo.NumOfDim);
                declaredVar(sizeVectorName)=true;
            end
        end
    end
end

function str=l_emxDestroy(mCodeInfo,direction)
    str='';
    declaredVar=containers.Map;
    for idx=keys(mCodeInfo.PortMap)

        KeyVal=idx{1};
        curPortInfo=mCodeInfo.PortMap(KeyVal);
        if curPortInfo.IsVarSize&&strcmpi(curPortInfo.Direction,direction)&&strcmpi(curPortInfo.VarSizeType,'emxArray')
            if curPortInfo.IsComplex
                emxVarName=[curPortInfo.StructInfo.TopStructName{1},mCodeInfo.VarSizeInfo.staticVarSufix];
                destroyFcnName=[mCodeInfo.VarSizeInfo.emxAPIPrefix,mCodeInfo.VarSizeInfo.emxDestroyFcn,curPortInfo.StructInfo.TopStructType{1}];
            elseif curPortInfo.IsEnum
                emxVarName=[curPortInfo.FlatName,mCodeInfo.VarSizeInfo.staticVarSufix];
                destroyFcnName=[mCodeInfo.VarSizeInfo.emxAPIPrefix,mCodeInfo.VarSizeInfo.emxDestroyFcn,curPortInfo.EnumInfo.EnumType];
            else
                if strcmpi(curPortInfo.DPIPortsDataType,'LogicVector')||strcmpi(curPortInfo.DPIPortsDataType,'BitVector')
                    emxVarName=[curPortInfo.Name,mCodeInfo.VarSizeInfo.staticVarSufix];
                else
                    emxVarName=[curPortInfo.FlatName,mCodeInfo.VarSizeInfo.staticVarSufix];
                end
                destroyFcnName=[mCodeInfo.VarSizeInfo.emxAPIPrefix,mCodeInfo.VarSizeInfo.emxDestroyFcn,curPortInfo.DataType];
            end
            if~isKey(declaredVar,emxVarName)
                str=sprintf('%s%s\n',str,[destroyFcnName,'(',emxVarName,');']);
                declaredVar(emxVarName)=true;
            end
        end
    end
end
function str=l_getVarSizeOutputData(mCodeInfo)
    createSVOpenArrPointer='';
    copyVarSizeOutputDataFromStaticVar='';
    for idx=keys(mCodeInfo.PortMap)

        KeyVal=idx{1};
        curPortInfo=mCodeInfo.PortMap(KeyVal);
        if curPortInfo.IsVarSize&&strcmpi(curPortInfo.Direction,'output')
            if strcmpi(curPortInfo.DPIPortsDataType,'LogicVector')||strcmpi(curPortInfo.DPIPortsDataType,'BitVector')

                [n_createSVOpenArrPointer,openArrPointerName]=l_getOpenArrPointer(curPortInfo.FlatName,curPortInfo.DPI_C_InterfaceDataType);
            else
                [n_createSVOpenArrPointer,openArrPointerName]=l_getOpenArrPointer(curPortInfo.FlatName,curPortInfo.DataType);
            end
            if~curPortInfo.IsComplex&&~(strcmpi(curPortInfo.DPIPortsDataType,'LogicVector')||strcmpi(curPortInfo.DPIPortsDataType,'BitVector'))






                if strcmpi(curPortInfo.VarSizeType,'emxArray')
                    varSizeOutputData=[curPortInfo.FlatName,mCodeInfo.VarSizeInfo.staticVarSufix,'->data'];
                else
                    varSizeOutputData=[curPortInfo.CPortNames{1},mCodeInfo.VarSizeInfo.staticVarSufix];
                end
                n_copyVarSizeOutputDataFromStaticVar=sprintf('memcpy(%s,%s,%s);\n',...
                openArrPointerName,...
                varSizeOutputData,...
                l_getOpenArrSizeInByte(curPortInfo.FlatName,curPortInfo.DataType));
                copyVarSizeOutputDataFromStaticVar=sprintf('%s%s',copyVarSizeOutputDataFromStaticVar,n_copyVarSizeOutputDataFromStaticVar);
            end
            createSVOpenArrPointer=sprintf('%s%s',createSVOpenArrPointer,n_createSVOpenArrPointer);
        end
    end
    [~,~,~,complexVarSizeOutputDataInit]=l_flatten_And_unflatten_StructIO(mCodeInfo);
    str=sprintf('%s%s%s',createSVOpenArrPointer,copyVarSizeOutputDataFromStaticVar,complexVarSizeOutputDataInit);
end
function str=l_getOpenArrSizeInByte(identifier,dataType)
    str=['svSize(',identifier,',1)*sizeof(',dataType,')'];
end
function str=l_getVarSizeOutputSize(mCodeInfo)
    str='';
    decalredVar=containers.Map;
    for idx=keys(mCodeInfo.PortMap)

        KeyVal=idx{1};
        curPortInfo=mCodeInfo.PortMap(KeyVal);
        if curPortInfo.IsVarSize&&strcmpi(curPortInfo.Direction,'output')
            if strcmpi(curPortInfo.VarSizeType,'emxArray')
                if curPortInfo.IsComplex
                    varSizeOutputSizeVector=[curPortInfo.StructInfo.TopStructName{1},mCodeInfo.VarSizeInfo.staticVarSufix,'->size'];
                else
                    if strcmpi(curPortInfo.DPIPortsDataType,'LogicVector')||strcmpi(curPortInfo.DPIPortsDataType,'BitVector')
                        varSizeOutputSizeVector=[curPortInfo.Name,mCodeInfo.VarSizeInfo.staticVarSufix,'->size'];
                    else
                        varSizeOutputSizeVector=[curPortInfo.FlatName,mCodeInfo.VarSizeInfo.staticVarSufix,'->size'];
                    end
                end
            else
                varSizeOutputSizeVector=[curPortInfo.CPortNames{2},mCodeInfo.VarSizeInfo.staticVarSufix];
            end
            sizeValue='';
            for idx_1=1:curPortInfo.NumOfDim
                sizeValue=sprintf('%s%s',sizeValue,[varSizeOutputSizeVector,'[',num2str(idx_1-1),']*']);
            end
            sizeValue(end)=[];
            if~isKey(decalredVar,curPortInfo.FlatName)
                str=sprintf('%s%s\n',str,['*',curPortInfo.FlatName,'_size_Handle=',sizeValue,';']);
                decalredVar(curPortInfo.FlatName)=true;
            end
        end
    end
end

function[TopStructsDecl,TopStructsInit,TopStructOutputInit,TopStructOutput2Init]=l_flatten_And_unflatten_StructIO(mCodeInfo)


    TopStructsDecl='';
    TopStructsInit='';
    TopStructOutputInit='';
    TopStructOutput2Init='';

    TopStructNames=cell(1,numel(keys(mCodeInfo.PortMap)));
    TempTopStructNames={''};



    StructArrayIndexNames=containers.Map;
    StructArrayIndexNames('')='';
    StructArrayIndexNamesForOutput2=containers.Map;
    StructArrayIndexNamesForOutput2('')='';
    count=1;
    for idx=keys(mCodeInfo.PortMap)

        KeyVal=idx{1};

        if isempty(mCodeInfo.PortMap(KeyVal).StructInfo)
            if strcmpi(mCodeInfo.PortMap(KeyVal).DPIPortsDataType,'CompatibleCType')

                continue;
            else


                if mCodeInfo.PortMap(KeyVal).Dim>1

                    if~mCodeInfo.PortMap(KeyVal).IsVarSize



                        TopStructsDecl=sprintf('%s%s %s[%s];\n',TopStructsDecl,mCodeInfo.PortMap(KeyVal).DataType,mCodeInfo.PortMap(KeyVal).Name,num2str(mCodeInfo.PortMap(KeyVal).Dim));
                    end
                    StructArrayIndexNames(mCodeInfo.PortMap(KeyVal).Name)='';

                    if strcmp(mCodeInfo.PortMap(KeyVal).Direction,'input')


                        if mCodeInfo.PortMap(KeyVal).IsVarSize
                            if strcmpi(mCodeInfo.PortMap(KeyVal).VarSizeType,'emxArray')



                                firstArg=[mCodeInfo.PortMap(KeyVal).Name,mCodeInfo.VarSizeInfo.staticVarSufix,'->data'];
                            else


                                firstArg=[mCodeInfo.PortMap(KeyVal).CPortNames{1},mCodeInfo.VarSizeInfo.staticVarSufix];
                            end

                            [~,secondArg]=l_getOpenArrPointer(mCodeInfo.PortMap(KeyVal).FlatName,mCodeInfo.PortMap(KeyVal).DataType);

                            thirdArg=['svSize(',mCodeInfo.PortMap(KeyVal).FlatName,',1)'];
                            TopStructsInit=sprintf('%s%s\n',...
                            TopStructsInit,...
                            mCodeInfo.PortMap(KeyVal).DPIFixedPointInterfaceMarshallingObj.getCDataFromBits_FcnCall(firstArg,secondArg,thirdArg));
                        else
                            TopStructsInit=sprintf('%s%s\n',...
                            TopStructsInit,...
                            mCodeInfo.PortMap(KeyVal).DPIFixedPointInterfaceMarshallingObj.getCDataFromBits_FcnCall(mCodeInfo.PortMap(KeyVal).Name,mCodeInfo.PortMap(KeyVal).FlatName));
                        end
                    else
                        if mCodeInfo.PortMap(KeyVal).IsVarSize


                            [~,firstArg]=l_getOpenArrPointer(mCodeInfo.PortMap(KeyVal).FlatName,mCodeInfo.PortMap(KeyVal).DataType);
                            if strcmpi(mCodeInfo.PortMap(KeyVal).VarSizeType,'emxArray')



                                secondArg=[mCodeInfo.PortMap(KeyVal).Name,mCodeInfo.VarSizeInfo.staticVarSufix,'->data'];
                            else


                                secondArg=[mCodeInfo.PortMap(KeyVal).CPortNames{1},mCodeInfo.VarSizeInfo.staticVarSufix];
                            end

                            thirdArg=['svSize(',mCodeInfo.PortMap(KeyVal).FlatName,',1)'];
                            TopStructOutput2Init=sprintf('%s%s\n',...
                            TopStructOutput2Init,...
                            mCodeInfo.PortMap(KeyVal).DPIFixedPointInterfaceMarshallingObj.getBitsFromCData_FcnCall(firstArg,secondArg,thirdArg));
                        else


                            TopStructOutputInit=sprintf('%s%s\n',...
                            TopStructOutputInit,...
                            mCodeInfo.PortMap(KeyVal).DPIFixedPointInterfaceMarshallingObj.getBitsFromCData_FcnCall(mCodeInfo.PortMap(KeyVal).FlatName,mCodeInfo.PortMap(KeyVal).Name));
                        end

                    end
                else

                    TopStructsDecl=sprintf('%s%s\n',TopStructsDecl,[mCodeInfo.PortMap(KeyVal).DataType,' ',mCodeInfo.PortMap(KeyVal).Name,';']);
                    StructArrayIndexNames(mCodeInfo.PortMap(KeyVal).Name)='';

                    if strcmp(mCodeInfo.PortMap(KeyVal).Direction,'input')


                        TopStructsInit=sprintf('%s%s\n',...
                        TopStructsInit,...
                        mCodeInfo.PortMap(KeyVal).DPIFixedPointInterfaceMarshallingObj.getCDataFromBits_FcnCall(['&',mCodeInfo.PortMap(KeyVal).Name],mCodeInfo.PortMap(KeyVal).FlatName));
                    else


                        TopStructOutputInit=sprintf('%s%s\n',...
                        TopStructOutputInit,...
                        mCodeInfo.PortMap(KeyVal).DPIFixedPointInterfaceMarshallingObj.getBitsFromCData_FcnCall(mCodeInfo.PortMap(KeyVal).FlatName,['&',mCodeInfo.PortMap(KeyVal).Name]));

                    end
                end
            end
        else
            LocalStructInfo=mCodeInfo.PortMap(KeyVal).StructInfo;







            if~ismember(LocalStructInfo.TopStructName{1},TempTopStructNames)




                if~(mCodeInfo.PortMap(KeyVal).IsVarSize&&mCodeInfo.PortMap(KeyVal).IsComplex)
                    TopStructsDecl=sprintf('%s%s\n',TopStructsDecl,[LocalStructInfo.TopStructType{1},' ',LocalStructInfo.TopStructName{1},LocalStructInfo.TopStructIndexing{1},';']);
                end


                TopStructNames{count}=LocalStructInfo.TopStructName{1};
                TempTopStructNames=TopStructNames(1:count);
                count=count+1;
            end





            if nnz(LocalStructInfo.TopStructDim>1)>0
                IndexNamesKeys=keys(StructArrayIndexNames);
                Lia=ismember(LocalStructInfo.ElementAccessIndexVariable,IndexNamesKeys);
                IndicesForNonDelcaredCIndex=find(~Lia);
                for Idx=IndicesForNonDelcaredCIndex

                    TopStructsDecl=sprintf('%s%s\n',TopStructsDecl,['uint32_T ',LocalStructInfo.ElementAccessIndexVariable{Idx},';']);
                    if mCodeInfo.PortMap(KeyVal).IsVarSize&&mCodeInfo.PortMap(KeyVal).IsComplex

                    end


                    StructArrayIndexNames(LocalStructInfo.ElementAccessIndexVariable{Idx})='';
                end
            end





            if nnz(LocalStructInfo.TopStructDim>1)>0&&mCodeInfo.PortMap(KeyVal).IsVarSize&&...
                mCodeInfo.PortMap(KeyVal).IsComplex&&strcmpi(mCodeInfo.PortMap(KeyVal).Direction,'output')
                IndexNamesKeys=keys(StructArrayIndexNamesForOutput2);
                Lia=ismember(LocalStructInfo.ElementAccessIndexVariable,IndexNamesKeys);
                IndicesForNonDelcaredCIndex=find(~Lia);
                for Idx=IndicesForNonDelcaredCIndex

                    TopStructOutput2Init=sprintf('%s%s\n',TopStructOutput2Init,['uint32_T ',LocalStructInfo.ElementAccessIndexVariable{Idx},';']);


                    StructArrayIndexNamesForOutput2(LocalStructInfo.ElementAccessIndexVariable{Idx})='';
                end
            end




            if strcmp(mCodeInfo.PortMap(KeyVal).Direction,'input')


                if nnz(LocalStructInfo.TopStructDim>1)>0

                    [ForLoopBegin,FlattenedIndexing,ForLoopEnd]=l_getFlattenedArrayOfStructsIndexing(LocalStructInfo.ElementAccessIndexVariable,LocalStructInfo.TopStructDim,mCodeInfo.PortMap(KeyVal));
                    LocalCast_str=['(',mCodeInfo.PortMap(KeyVal).DataType,'*)'];

                    if mCodeInfo.PortMap(KeyVal).Dim>1

                        if strcmpi(mCodeInfo.PortMap(KeyVal).DPIPortsDataType,'BitVector')||strcmpi(mCodeInfo.PortMap(KeyVal).DPIPortsDataType,'LogicVector')





                            TopStructsInit=sprintf('%s%s%s\n%s',TopStructsInit,...
                            ForLoopBegin,...
                            mCodeInfo.PortMap(KeyVal).DPIFixedPointInterfaceMarshallingObj.getCDataFromBits_FcnCall(LocalStructInfo.ElementAccess,...
                            ['&',mCodeInfo.PortMap(KeyVal).FlatName,'[',l_getUpdatedFlatteningIndex(FlattenedIndexing,mCodeInfo.PortMap(KeyVal).DataTypeSize),']']),...
                            ForLoopEnd);
                        else



                            TopStructsInit=sprintf('%s%s%s\n%s',TopStructsInit,...
                            ForLoopBegin,...
                            ['memcpy(',LocalStructInfo.ElementAccess,',',...
                            '&(',LocalCast_str,mCodeInfo.PortMap(KeyVal).FlatName,')','[',FlattenedIndexing,']',',',...
                            'sizeof(',...
                            mCodeInfo.PortMap(KeyVal).DataType,...
                            '[',num2str(mCodeInfo.PortMap(KeyVal).Dim),']));'],...
                            ForLoopEnd);
                        end
                    else
                        if strcmpi(mCodeInfo.PortMap(KeyVal).DPIPortsDataType,'BitVector')||strcmpi(mCodeInfo.PortMap(KeyVal).DPIPortsDataType,'LogicVector')





                            if mCodeInfo.PortMap(KeyVal).IsVarSize&&mCodeInfo.PortMap(KeyVal).IsComplex



                                [~,PtrName]=l_getOpenArrPointer(mCodeInfo.PortMap(KeyVal).FlatName,mCodeInfo.PortMap(KeyVal).DPI_C_InterfaceDataType);
                                TopStructsInit=sprintf('%s%s%s\n%s',TopStructsInit,...
                                ForLoopBegin,...
                                mCodeInfo.PortMap(KeyVal).DPIFixedPointInterfaceMarshallingObj.getCDataFromBits_FcnCall(['&',LocalStructInfo.ElementAccess],...
                                ['&',PtrName,'[',l_getUpdatedFlatteningIndex(FlattenedIndexing,mCodeInfo.PortMap(KeyVal).DataTypeSize),']']),...
                                ForLoopEnd);
                            else

                                TopStructsInit=sprintf('%s%s%s\n%s',TopStructsInit,...
                                ForLoopBegin,...
                                mCodeInfo.PortMap(KeyVal).DPIFixedPointInterfaceMarshallingObj.getCDataFromBits_FcnCall(['&',LocalStructInfo.ElementAccess],...
                                ['&',mCodeInfo.PortMap(KeyVal).FlatName,'[',l_getUpdatedFlatteningIndex(FlattenedIndexing,mCodeInfo.PortMap(KeyVal).DataTypeSize),']']),...
                                ForLoopEnd);
                            end
                        else



                            if mCodeInfo.PortMap(KeyVal).IsVarSize&&mCodeInfo.PortMap(KeyVal).IsComplex


                                [~,PtrName]=l_getOpenArrPointer(mCodeInfo.PortMap(KeyVal).FlatName,mCodeInfo.PortMap(KeyVal).DPI_C_InterfaceDataType);
                                TopStructsInit=sprintf('%s%s%s\n%s',TopStructsInit,...
                                ForLoopBegin,...
                                [LocalStructInfo.ElementAccess,'=','(',LocalCast_str,PtrName,')','[',FlattenedIndexing,'];'],...
                                ForLoopEnd);
                            else
                                TopStructsInit=sprintf('%s%s%s\n%s',TopStructsInit,...
                                ForLoopBegin,...
                                [LocalStructInfo.ElementAccess,'=','(',LocalCast_str,mCodeInfo.PortMap(KeyVal).FlatName,')','[',FlattenedIndexing,'];'],...
                                ForLoopEnd);
                            end
                        end
                    end
                else

                    if mCodeInfo.PortMap(KeyVal).Dim>1

                        if strcmpi(mCodeInfo.PortMap(KeyVal).DPIPortsDataType,'BitVector')||strcmpi(mCodeInfo.PortMap(KeyVal).DPIPortsDataType,'LogicVector')


                            TopStructsInit=sprintf('%s%s\n',TopStructsInit,...
                            mCodeInfo.PortMap(KeyVal).DPIFixedPointInterfaceMarshallingObj.getCDataFromBits_FcnCall(LocalStructInfo.ElementAccess,mCodeInfo.PortMap(KeyVal).FlatName));
                        else



                            TopStructsInit=sprintf('%s%s\n',TopStructsInit,...
                            ['memcpy(',LocalStructInfo.ElementAccess,',',...
                            mCodeInfo.PortMap(KeyVal).FlatName,',',...
                            'sizeof(',...
                            mCodeInfo.PortMap(KeyVal).DataType,...
                            '[',num2str(mCodeInfo.PortMap(KeyVal).Dim),']));']);
                        end
                    else
                        if strcmpi(mCodeInfo.PortMap(KeyVal).DPIPortsDataType,'BitVector')||strcmpi(mCodeInfo.PortMap(KeyVal).DPIPortsDataType,'LogicVector')


                            TopStructsInit=sprintf('%s%s\n',TopStructsInit,...
                            mCodeInfo.PortMap(KeyVal).DPIFixedPointInterfaceMarshallingObj.getCDataFromBits_FcnCall(['&',LocalStructInfo.ElementAccess],mCodeInfo.PortMap(KeyVal).FlatName));
                        else


                            TopStructsInit=sprintf('%s%s\n',TopStructsInit,...
                            [LocalStructInfo.ElementAccess,'=',mCodeInfo.PortMap(KeyVal).FlatName,';']);
                        end
                    end
                end
            else


                if nnz(LocalStructInfo.TopStructDim>1)>0

                    [ForLoopBegin,FlattenedIndexing,ForLoopEnd]=l_getFlattenedArrayOfStructsIndexing(LocalStructInfo.ElementAccessIndexVariable,LocalStructInfo.TopStructDim,mCodeInfo.PortMap(KeyVal));
                    LocalCast_str=['(',mCodeInfo.PortMap(KeyVal).DataType,'*)'];

                    if mCodeInfo.PortMap(KeyVal).Dim>1

                        if strcmpi(mCodeInfo.PortMap(KeyVal).DPIPortsDataType,'BitVector')||strcmpi(mCodeInfo.PortMap(KeyVal).DPIPortsDataType,'LogicVector')





                            TopStructOutputInit=sprintf('%s%s%s\n%s',TopStructOutputInit,...
                            ForLoopBegin,...
                            mCodeInfo.PortMap(KeyVal).DPIFixedPointInterfaceMarshallingObj.getBitsFromCData_FcnCall(['&',mCodeInfo.PortMap(KeyVal).FlatName,'[',l_getUpdatedFlatteningIndex(FlattenedIndexing,mCodeInfo.PortMap(KeyVal).DataTypeSize),']'],...
                            LocalStructInfo.ElementAccess),...
                            ForLoopEnd);
                        else



                            TopStructOutputInit=sprintf('%s%s%s\n%s',TopStructOutputInit,...
                            ForLoopBegin,...
                            ['memcpy(','&(',LocalCast_str,mCodeInfo.PortMap(KeyVal).FlatName,')','[',FlattenedIndexing,']',',',...
                            LocalStructInfo.ElementAccess,',',...
                            'sizeof(',...
                            mCodeInfo.PortMap(KeyVal).DataType,...
                            '[',num2str(mCodeInfo.PortMap(KeyVal).Dim),']));'],...
                            ForLoopEnd);
                        end
                    else
                        if strcmpi(mCodeInfo.PortMap(KeyVal).DPIPortsDataType,'BitVector')||strcmpi(mCodeInfo.PortMap(KeyVal).DPIPortsDataType,'LogicVector')





                            if mCodeInfo.PortMap(KeyVal).IsVarSize&&mCodeInfo.PortMap(KeyVal).IsComplex




                                [~,PtrName]=l_getOpenArrPointer(mCodeInfo.PortMap(KeyVal).FlatName,mCodeInfo.PortMap(KeyVal).DPI_C_InterfaceDataType);
                                TopStructOutput2Init=sprintf('%s%s%s\n%s',TopStructOutput2Init,...
                                ForLoopBegin,...
                                mCodeInfo.PortMap(KeyVal).DPIFixedPointInterfaceMarshallingObj.getBitsFromCData_FcnCall(['&',PtrName,'[',l_getUpdatedFlatteningIndex(FlattenedIndexing,mCodeInfo.PortMap(KeyVal).DataTypeSize),']'],...
                                ['&',LocalStructInfo.ElementAccess]),...
                                ForLoopEnd);
                            else
                                TopStructOutputInit=sprintf('%s%s%s\n%s',TopStructOutputInit,...
                                ForLoopBegin,...
                                mCodeInfo.PortMap(KeyVal).DPIFixedPointInterfaceMarshallingObj.getBitsFromCData_FcnCall(['&',mCodeInfo.PortMap(KeyVal).FlatName,'[',l_getUpdatedFlatteningIndex(FlattenedIndexing,mCodeInfo.PortMap(KeyVal).DataTypeSize),']'],...
                                ['&',LocalStructInfo.ElementAccess]),...
                                ForLoopEnd);
                            end
                        else


                            if mCodeInfo.PortMap(KeyVal).IsVarSize&&mCodeInfo.PortMap(KeyVal).IsComplex

                                [~,PtrName]=l_getOpenArrPointer(mCodeInfo.PortMap(KeyVal).FlatName,mCodeInfo.PortMap(KeyVal).DataType);
                                TopStructOutput2Init=sprintf('%s%s%s\n%s',TopStructOutput2Init,...
                                ForLoopBegin,...
                                ['(',LocalCast_str,PtrName,')','[',FlattenedIndexing,']=',LocalStructInfo.ElementAccess,';'],...
                                ForLoopEnd);
                            else
                                TopStructOutputInit=sprintf('%s%s%s\n%s',TopStructOutputInit,...
                                ForLoopBegin,...
                                ['(',LocalCast_str,mCodeInfo.PortMap(KeyVal).FlatName,')','[',FlattenedIndexing,']=',LocalStructInfo.ElementAccess,';'],...
                                ForLoopEnd);
                            end
                        end
                    end
                else

                    if mCodeInfo.PortMap(KeyVal).Dim>1

                        if strcmpi(mCodeInfo.PortMap(KeyVal).DPIPortsDataType,'BitVector')||strcmpi(mCodeInfo.PortMap(KeyVal).DPIPortsDataType,'LogicVector')


                            TopStructOutputInit=sprintf('%s%s\n',TopStructOutputInit,...
                            mCodeInfo.PortMap(KeyVal).DPIFixedPointInterfaceMarshallingObj.getBitsFromCData_FcnCall(mCodeInfo.PortMap(KeyVal).FlatName,LocalStructInfo.ElementAccess));
                        else



                            TopStructOutputInit=sprintf('%s%s\n',TopStructOutputInit,...
                            ['memcpy(',mCodeInfo.PortMap(KeyVal).FlatName,',',...
                            LocalStructInfo.ElementAccess,',',...
                            'sizeof(',...
                            mCodeInfo.PortMap(KeyVal).DataType,...
                            '[',num2str(mCodeInfo.PortMap(KeyVal).Dim),']));']);
                        end
                    else

                        if strcmpi(mCodeInfo.PortMap(KeyVal).DPIPortsDataType,'BitVector')||strcmpi(mCodeInfo.PortMap(KeyVal).DPIPortsDataType,'LogicVector')


                            TopStructOutputInit=sprintf('%s%s\n',TopStructOutputInit,...
                            mCodeInfo.PortMap(KeyVal).DPIFixedPointInterfaceMarshallingObj.getBitsFromCData_FcnCall(mCodeInfo.PortMap(KeyVal).FlatName,['&',LocalStructInfo.ElementAccess]));
                        else


                            TopStructOutputInit=sprintf('%s%s\n',TopStructOutputInit,...
                            ['*',mCodeInfo.PortMap(KeyVal).FlatName,'=',LocalStructInfo.ElementAccess,';']);
                        end
                    end
                end
            end

        end
    end
end

function[ForLoopBegin,FlattenedIndexing,ForLoopEnd]=l_getFlattenedArrayOfStructsIndexing(ElementAccessIndexVariable,TopStructDim,PortInfo)

    StructArrayIndices=find(TopStructDim>1);
    ForLoopBegin='';
    ForLoopEnd='';
    TabbingForEnd='';
    FlattenedIndexing='';
    for idx=StructArrayIndices

        if PortInfo.IsVarSize&&PortInfo.IsComplex
            loopHighValue=sprintf('svSize(%s,1)',PortInfo.FlatName);
        else
            loopHighValue=num2str(TopStructDim(idx));
        end


        ForLoopBegin=sprintf('%sfor(%s=0;%s<%s;%s++){\n\t',ForLoopBegin,...
        ElementAccessIndexVariable{idx},...
        ElementAccessIndexVariable{idx},...
        loopHighValue,...
        ElementAccessIndexVariable{idx});










        FlattenedIndexing=sprintf('%s%s*%s+',FlattenedIndexing,...
        ElementAccessIndexVariable{idx},...
        num2str(prod([TopStructDim(idx+1:end),PortInfo.Dim])));

        ForLoopEnd=sprintf('%s}\n%s',TabbingForEnd,ForLoopEnd);
        TabbingForEnd=sprintf('%s\t',TabbingForEnd);
    end

    FlattenedIndexing=FlattenedIndexing(1:end-1);
end

function str=l_getUpdatedFlatteningIndex(FlattenedIndexing,DataTypeSize)



    str=['(',FlattenedIndexing,')*',int2str(ceil(double(DataTypeSize)/32))];
end
