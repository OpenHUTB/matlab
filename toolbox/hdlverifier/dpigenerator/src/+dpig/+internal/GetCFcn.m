




classdef GetCFcn<handle


    properties
        mCodeInfo;
        hasParameter;
        mParamType;
        mParamId;

        TestPointFcnSignatureMap;




SVStructEnabled
    end

    properties(Access=private,Constant)
        ExistHandle='existhandle';
        ObjHandle='objhandle';
        E_ObjHandle='e_objhandle';

        NumOfVer='NumberOfVerifies';
        TSVerifyInfo_G='DPI_TSVerifyInfo';
        TSVerifyInfo_G_T='DPI_TSVerifyInfo_T';
        TSVerifyInfo_Fields=struct('NumberOfVerifies',containers.Map({'Type','IsPointer'},{'int',false}),...
        'TSBlkPath',containers.Map({'Type','IsPointer'},{'const char',true}),...
        'VerifyResult',containers.Map({'Type','IsPointer'},{'int',false}),...
        'SFPath',containers.Map({'Type','IsPointer'},{'const char',true}),...
        'MessageID',containers.Map({'Type','IsPointer'},{'const char',true}),...
        'FmtMessage',containers.Map({'Type','IsPointer'},{'const char',true}),...
        'SSID',containers.Map({'Type','IsPointer'},{'int',false}));
        TSVerifyHeader='svdpi_verify.h'
    end



    properties(Access=private)

        TopStructDeclaration='';
        ComplexDeclaration='';
        TopParamStructDeclaration={};

        ParamPtrFromInterfaceOrLocals={};
        ParamPtrFromRTW={};

        InputPtrFromInterfaceOrLocals='';
        InputPtrFromRTW='';

        OutputPtrFromInterfaceOrLocals='';
        OutputPtrFromRTW='';

        ErrStatusPrtFromRTW='';

        TopParamStructInit={};

        TopStructInit='';
        ComplexInit='';

        CopyParamToRTW={};



        CopyInputsToRTW='';

        NativeOutputCFcnCall='';
        NativeUpdateCFcnCall='';

        TopStructOutputInit='';
        ComplexOutputInit='';
        RegulatPortOutputInit='';



        TopTestPointStructInit='';



        TopTestPointPtrFromRTW='';



        TopTestPointIdxMap='';


        mVarsDeclared;


        rtmVarName;
        objhandlecast;


        BitInterfaceMap;


        AssertionManager;


        IsExtendedObjhandleEnabled;
        E_ObjHandleInfo;


        IsTSVerifyPresent;

        ComponentTemplateType;
    end

    methods(Access=private)
        function str=getActiveObjHandleDeclaration(obj)
            if obj.IsExtendedObjhandleEnabled
                str=sprintf('%s* %s',obj.E_ObjHandleInfo.(obj.E_ObjHandle)('Type'),obj.E_ObjHandle);
            else
                str=sprintf('%s* %s',obj.mCodeInfo.AllocateFcn.ReturnType,obj.ObjHandle);
            end
        end

        function str=InitializeObjHandle(obj)
            if obj.IsExtendedObjhandleEnabled
                str=sprintf(['%s=(%s*)malloc(sizeof(%s));\n',...
                'if(%s==NULL){\n',...
                '\treturn NULL;\n',...
                '}\n',...
                '%s->%s=%s();'],...
                obj.E_ObjHandle,obj.E_ObjHandleInfo.(obj.E_ObjHandle)('Type'),obj.E_ObjHandleInfo.(obj.E_ObjHandle)('Type'),...
                obj.E_ObjHandle,...
                obj.E_ObjHandle,obj.ObjHandle,obj.mCodeInfo.AllocateFcn.Name);
            else
                str=sprintf('%s=%s();',obj.ObjHandle,obj.mCodeInfo.AllocateFcn.Name);
            end
        end

        function str=CastExistingHandle(obj)
            if obj.IsExtendedObjhandleEnabled
                ObjHandleType=obj.E_ObjHandleInfo.(obj.E_ObjHandle)('Type');
            else
                ObjHandleType=obj.mCodeInfo.AllocateFcn.ReturnType;
            end
            str=sprintf('%s=(%s*)%s',obj.getActiveObjHandle(),ObjHandleType,obj.ExistHandle);
        end

        function str=getActiveObjHandle(obj)
            if obj.IsExtendedObjhandleEnabled
                str=obj.E_ObjHandle;
            else
                str=obj.ObjHandle;
            end
        end

        function str=getNativeInitializeCFcnCall(obj)
            if obj.IsExtendedObjhandleEnabled
                objhandle=sprintf('%s->%s',obj.E_ObjHandle,obj.ObjHandle);
            else
                objhandle=obj.ObjHandle;
            end
            str=sprintf('%s(%s)',obj.mCodeInfo.InitializeFcn.Name,objhandle);
        end

        function str=getTSVerifyGlobalVariableInit(obj)
            if obj.IsTSVerifyPresent
                str=sprintf('%s=0;\n%s=NULL;\n',obj.NumOfVer,obj.TSVerifyInfo_G);
            else
                str='';
            end
        end

        function str=getTSVerifyEObjHandleVariableInit(obj,Action)
            if obj.IsTSVerifyPresent
                if strcmp('Initialize',Action)
                    str=sprintf('%s->%s=0;\n%s->%s=NULL;\n',obj.E_ObjHandle,obj.NumOfVer,...
                    obj.E_ObjHandle,obj.TSVerifyInfo_G);
                elseif strcmp('Allocate',Action)
                    str=sprintf(['%s->%s=%s;\n',...
                    '%s->%s=(%s*)malloc(sizeof(%s)*%s);\n'],...
                    obj.E_ObjHandle,obj.NumOfVer,obj.NumOfVer,...
                    obj.E_ObjHandle,obj.TSVerifyInfo_G,obj.TSVerifyInfo_G_T,obj.TSVerifyInfo_G_T,obj.NumOfVer);
                else
                end
            else
                str='';
            end
        end

        function str=getTSVerifyInitialization(obj)
            if obj.IsTSVerifyPresent
                str=sprintf(['if(%s==NULL){\n',...
                '\t%s\n',...
                '}else{\n',...
                '\t%s\n',...
                '\tmemcpy(%s->%s,%s,sizeof(%s)*%s);\n',...
                '}\n',...
                'free(%s);\n',...
                '%s\n'],...
                obj.TSVerifyInfo_G,...
                obj.getTSVerifyEObjHandleVariableInit('Initialize'),...
                obj.getTSVerifyEObjHandleVariableInit('Allocate'),...
                obj.E_ObjHandle,obj.TSVerifyInfo_G,obj.TSVerifyInfo_G,obj.TSVerifyInfo_G_T,obj.NumOfVer,...
                obj.TSVerifyInfo_G,...
                obj.getTSVerifyGlobalVariableInit());
            else
                str='';
            end
        end

        function str=getTunableParamsInitialization(obj)
            str='';
            for idx=1:obj.mCodeInfo.ParamStruct.NumPorts
                ParamPortInfo=obj.mCodeInfo.ParamStruct.Port(idx);
                if ParamPortInfo.IsInstanceSpecific()

                    str=sprintf('%s%s(%s,%s);\n',str,obj.mCodeInfo.SetParamFcn(idx).DPIName,...
                    obj.getActiveObjHandle(),ParamPortInfo.getParamInitializationConst());
                end
            end
        end
    end

    methods
        function this=GetCFcn(codeInfo,AssertionInfo,dpig_config)
            this.mCodeInfo=codeInfo;


            this.mVarsDeclared=containers.Map;
            this.mVarsDeclared('')='';

            this.TestPointFcnSignatureMap=containers.Map;

            this.rtmVarName=this.mCodeInfo.AllocateFcn.ReturnType(1:end-2);
            this.objhandlecast=['((',this.mCodeInfo.AllocateFcn.ReturnType,'*) objhandle )'];

            this.GenCodeFromCodeInfo();

            this.BitInterfaceMap=containers.Map;

            this.AssertionManager=AssertionInfo;

            this.IsExtendedObjhandleEnabled=dpig_config.IsExtendedObjhandleEnabled;
            this.SVStructEnabled=dpig_config.SVStructEnabled;

            this.IsTSVerifyPresent=dpig_config.IsTSVerifyPresent;
            if this.IsTSVerifyPresent
                this.E_ObjHandleInfo=struct(this.E_ObjHandle,containers.Map({'Type','IsPointer'},{['extended_',this.mCodeInfo.AllocateFcn.ReturnType],false}),...
                'Fields',struct(this.ObjHandle,containers.Map({'Type','IsPointer'},{this.mCodeInfo.AllocateFcn.ReturnType,true}),...
                this.TSVerifyInfo_G,containers.Map({'Type','IsPointer'},{this.TSVerifyInfo_G_T,true}),...
                this.NumOfVer,containers.Map({'Type','IsPointer'},{'int',false})));
            else
                this.E_ObjHandleInfo=struct(this.E_ObjHandle,containers.Map({'Type','IsPointer'},{['extended_',this.mCodeInfo.AllocateFcn.ReturnType],false}),...
                'Fields',struct(this.ObjHandle,containers.Map({'Type','IsPointer'},{this.mCodeInfo.AllocateFcn.ReturnType,true})));
            end

            this.ComponentTemplateType=dpig_config.DPIComponentTemplateType;
        end

        function GenCodeFromCodeInfo(obj)

            if isempty(obj.mCodeInfo.OutputFcn)
                error(message('HDLLink:DPITargetCC:NoOutputOrStepFunction'));
            else
                obj.NativeOutputCFcnCall=[obj.mCodeInfo.OutputFcn.Name,'(',obj.objhandlecast,');'];
            end

            if isempty(obj.mCodeInfo.UpdateFcn)
                obj.NativeUpdateCFcnCall='';
            else
                obj.NativeUpdateCFcnCall=[obj.mCodeInfo.UpdateFcn.Name,'(',obj.objhandlecast,');'];
            end
            if~isempty(obj.mCodeInfo.RunTimeErrorFcn)
                obj.ErrStatusPrtFromRTW=['(',obj.mCodeInfo.RunTimeErrorFcn.ReturnType,')',obj.objhandlecast,'->errorStatus;'];
            end
            for idx=1:(obj.mCodeInfo.InStruct.NumPorts+obj.mCodeInfo.OutStruct.NumPorts)

                if idx<=obj.mCodeInfo.InStruct.NumPorts

                    portInfo=obj.mCodeInfo.InStruct.Port(idx);
                    direction='input';
                else

                    portInfo=obj.mCodeInfo.OutStruct.Port(idx-obj.mCodeInfo.InStruct.NumPorts);
                    direction='output';
                end

                if~isempty(portInfo.StructInfo)
                    for idx1=1:length(portInfo.StructInfo)
                        GenCodeForStruct(obj,portInfo.StructInfo(num2str(idx1)),direction);
                    end
                elseif portInfo.IsComplex

                else
                    GenCodeForRegularPort(obj,portInfo,direction);
                end
            end

            obj.TopTestPointStructInit=containers.Map;
            obj.TopTestPointPtrFromRTW=containers.Map;
            obj.TopTestPointIdxMap=containers.Map;
            for idx=keys(obj.mCodeInfo.TestPointStruct.TestPointContainer)
                keyVal=idx{1};
                TestPointPortInfo=obj.mCodeInfo.TestPointStruct.TestPointContainer(keyVal);

                TestPointPortInfo.objhandlecast=obj.objhandlecast;
                if~isempty(TestPointPortInfo.StructInfo)

                    obj.TopTestPointStructInit(TestPointPortInfo.FlatName)='';

                    obj.TopTestPointPtrFromRTW(TestPointPortInfo.FlatName)=TestPointPortInfo.getTestPointPortPtrFromRTW;
                    for idx1=1:length(TestPointPortInfo.StructInfo)
                        GenCodeForStruct(obj,TestPointPortInfo.StructInfo(num2str(idx1)),'testpoint');
                    end
                end
            end

            obj.ParamPtrFromInterfaceOrLocals=cell(1,obj.mCodeInfo.ParamStruct.NumPorts);
            obj.ParamPtrFromRTW=cell(1,obj.mCodeInfo.ParamStruct.NumPorts);
            obj.CopyParamToRTW=cell(1,obj.mCodeInfo.ParamStruct.NumPorts);
            obj.TopParamStructDeclaration=cell(1,obj.mCodeInfo.ParamStruct.NumPorts);
            obj.TopParamStructInit=cell(1,obj.mCodeInfo.ParamStruct.NumPorts);
            for idx=1:obj.mCodeInfo.ParamStruct.NumPorts
                PrmPortInfo=obj.mCodeInfo.ParamStruct.Port(idx);
                if~isempty(PrmPortInfo.StructInfo)
                    for idx1=1:length(PrmPortInfo.StructInfo)
                        GenCodeForStruct(obj,PrmPortInfo.StructInfo(num2str(idx1)),[PrmPortInfo.getParamStType(),':',num2str(idx)]);
                    end
                else
                    GenCodeForRegularPort(obj,PrmPortInfo,[PrmPortInfo.getParamStType(),':',num2str(idx)]);
                end
            end
        end

        function str=getCanonicalBitInterfaceRepresentation(obj)
            svCanonicalRepresentation='';

            for ii=1:(obj.mCodeInfo.InStruct.NumPorts+obj.mCodeInfo.OutStruct.NumPorts)

                if ii<=obj.mCodeInfo.InStruct.NumPorts

                    portInfo=obj.mCodeInfo.InStruct.Port(ii);
                    direction='input';
                else

                    portInfo=obj.mCodeInfo.OutStruct.Port(ii-obj.mCodeInfo.InStruct.NumPorts);
                    direction='output';
                end

                if~isempty(portInfo.StructInfo)
                    for iii=1:length(portInfo.StructInfo)
                        n_getDeepestField(portInfo.StructInfo(num2str(iii)),direction);
                    end
                else
                    n_getBitInterfaceInfo(portInfo,direction);
                end
            end

            for idxParam=1:obj.mCodeInfo.ParamStruct.NumPorts
                portInfo=obj.mCodeInfo.ParamStruct.Port(idxParam);
                if~isempty(portInfo.StructInfo)
                    for iii=1:length(portInfo.StructInfo)
                        n_getDeepestField(portInfo.StructInfo(num2str(iii)),'input');
                    end
                else
                    n_getBitInterfaceInfo(portInfo,'input');
                end
            end

            for TPKey=keys(obj.mCodeInfo.TestPointStruct.TestPointContainer)
                TPKeyV=TPKey{1};
                curTestPointInfo=obj.mCodeInfo.TestPointStruct.TestPointContainer(TPKeyV);

                if~isempty(curTestPointInfo.StructInfo)
                    for iii=1:length(curTestPointInfo.StructInfo)
                        n_getDeepestField(curTestPointInfo.StructInfo(num2str(iii)),'output');
                    end
                else

                    n_getBitInterfaceInfo(obj.mCodeInfo.TestPointStruct.TestPointContainer(TPKeyV),'output');
                end
            end
            str=sprintf('%s\n',svCanonicalRepresentation);
            function n_getBitInterfaceInfo(n_portInfo,n_direction)
                if isempty(svCanonicalRepresentation)
                    svCanonicalRepresentation=n_portInfo.DPIFixedPointInterfaceMarshallingObj.getDPICanonicalRepresentation();
                end
                if strcmpi(n_direction,'input')


                    obj.BitInterfaceMap(n_portInfo.DPIFixedPointInterfaceMarshallingObj.getCDataFromBits_FcnCall('',''))=n_portInfo.DPIFixedPointInterfaceMarshallingObj.getCDataFromBits_FcnDef();
                else


                    obj.BitInterfaceMap(n_portInfo.DPIFixedPointInterfaceMarshallingObj.getBitsFromCData_FcnCall('',''))=n_portInfo.DPIFixedPointInterfaceMarshallingObj.getBitsFromCData_FcnDef();
                end

            end
            function n_getDeepestField(n_portInfo,n_direction)

                if~isempty(n_portInfo.StructInfo)


                    for idx=1:length(n_portInfo.StructInfo)
                        n_getDeepestField(n_portInfo.StructInfo(num2str(idx)),n_direction);
                    end
                else
                    n_getBitInterfaceInfo(n_portInfo,n_direction);
                end
            end
        end

        function str=getBitInterfaceFcnDef(obj)
            str='';
            for key_temp=keys(obj.BitInterfaceMap)
                key=key_temp{1};
                str=sprintf('%s\n%s',str,obj.BitInterfaceMap(key));
            end
        end

        function GenCodeForStruct(obj,portInfo,direction)

            if~isempty(portInfo.StructInfo)


                for idx=1:length(portInfo.StructInfo)
                    GenCodeForStruct(obj,portInfo.StructInfo(num2str(idx)),direction);
                end
            else

                LocalStructInfo=portInfo.StructFieldInfo;

                n_GetDeclarations(direction);


                n_UnflattenInputAndFlattenOutput(direction);
            end

            function n_GetDeclarations(direction)


                if~isKey(obj.mVarsDeclared,LocalStructInfo.TopStructFlatName{1})
                    if strcmp(direction,'input')









                        if LocalStructInfo.TopStructDim(1)~=1




                            obj.InputPtrFromRTW=sprintf('%s%s\n',...
                            obj.InputPtrFromRTW,...
                            [LocalStructInfo.TopStructType{1},'* ',LocalStructInfo.TopStructFlatName{1},' = ',obj.objhandlecast,'->inputs->',LocalStructInfo.TopStructName{1},';']);
                        else




                            obj.InputPtrFromRTW=sprintf('%s%s\n',...
                            obj.InputPtrFromRTW,...
                            [LocalStructInfo.TopStructType{1},'* ',LocalStructInfo.TopStructFlatName{1},' = &',obj.objhandlecast,'->inputs->',LocalStructInfo.TopStructName{1},';']);
                        end
                    elseif strcmp(direction,'output')



                        if LocalStructInfo.TopStructDim(1)~=1




                            obj.OutputPtrFromRTW=sprintf('%s%s\n',...
                            obj.OutputPtrFromRTW,...
                            [LocalStructInfo.TopStructType{1},'* ',LocalStructInfo.TopStructFlatName{1},' = ',obj.objhandlecast,'->outputs->',LocalStructInfo.TopStructName{1},';']);
                        else




                            obj.OutputPtrFromRTW=sprintf('%s%s\n',...
                            obj.OutputPtrFromRTW,...
                            [LocalStructInfo.TopStructType{1},'* ',LocalStructInfo.TopStructFlatName{1},' = &',obj.objhandlecast,'->outputs->',LocalStructInfo.TopStructName{1},';']);
                        end
                    elseif strcmpi(direction,'testpoint')



                    else

                        PrmSt=extractBefore(direction,':');

                        PrmType=extractBefore(LocalStructInfo.TopStructFlatName,'_');
                        if~isempty(PrmType)&&strcmp(PrmType{1},'ExternParam')
                            rv=PrmSt;
                        else
                            rv=[obj.objhandlecast,'->',PrmSt,'->',LocalStructInfo.TopStructName{1}];
                        end
                        if LocalStructInfo.TopStructDim(1)~=1

                            obj.ParamPtrFromRTW{str2double(extractAfter(direction,':'))}=[obj.ParamPtrFromRTW{str2double(extractAfter(direction,':'))},...
                            [LocalStructInfo.TopStructType{1},'* ',LocalStructInfo.TopStructFlatName{1},' = ',rv,';']];
                        else

                            obj.ParamPtrFromRTW{str2double(extractAfter(direction,':'))}=[obj.ParamPtrFromRTW{str2double(extractAfter(direction,':'))},...
                            [LocalStructInfo.TopStructType{1},'* ',LocalStructInfo.TopStructFlatName{1},' = &',rv,';']];
                        end
                    end

                    obj.mVarsDeclared(LocalStructInfo.TopStructFlatName{1})='';
                end


                if nnz(LocalStructInfo.TopStructDim>1)>0
                    for idx1=1:numel(LocalStructInfo.ElementAccessIndexVariable)


                        if(strcmp(direction,'output')||strcmp(direction,'input'))&&...
                            ~isKey(obj.mVarsDeclared,LocalStructInfo.ElementAccessIndexVariable{idx1})

                            obj.TopStructDeclaration=sprintf('%s%s\n',obj.TopStructDeclaration,['uint32_T ',LocalStructInfo.ElementAccessIndexVariable{idx1},';']);


                            obj.mVarsDeclared(LocalStructInfo.ElementAccessIndexVariable{idx1})='';
                        end
                        if strcmp(direction,'testpoint')&&...
                            ~isKey(obj.TopTestPointIdxMap,LocalStructInfo.TopStructName{1})

                            obj.TopTestPointIdxMap(LocalStructInfo.TopStructName{1})=LocalStructInfo.ElementAccessIndexVariable{idx1};
                        end




                        if~(strcmp(direction,'output')||strcmp(direction,'input')||strcmp(direction,'testpoint'))&&...
                            ~isempty(LocalStructInfo.ElementAccessIndexVariable{idx1})&&...
                            ~isKey(obj.mVarsDeclared,[direction,LocalStructInfo.ElementAccessIndexVariable{idx1}])

                            obj.TopParamStructDeclaration{str2double(extractAfter(direction,':'))}=[obj.TopParamStructDeclaration{str2double(extractAfter(direction,':'))},...
                            ['uint32_T ',LocalStructInfo.ElementAccessIndexVariable{idx1},';']];

                            obj.mVarsDeclared([direction,LocalStructInfo.ElementAccessIndexVariable{idx1}])='';
                        end
                    end
                end
            end

            function n_UnflattenInputAndFlattenOutput(direction)
                if strcmp(direction,'input')

                    obj.TopStructInit=sprintf('%s%s\n',...
                    obj.TopStructInit,...
                    portInfo.getInputTopStructInitialization());
                elseif strcmp(direction,'output')

                    obj.TopStructOutputInit=sprintf('%s%s\n',...
                    obj.TopStructOutputInit,...
                    portInfo.getOutputTopStructInitialization());
                elseif strcmp(direction,'testpoint')

                    obj.TopTestPointStructInit(LocalStructInfo.TopStructName{1})=sprintf('%s%s',...
                    obj.TopTestPointStructInit(LocalStructInfo.TopStructName{1}),...
                    portInfo.getOutputTopStructInitialization());
                else

                    obj.TopParamStructInit{str2double(extractAfter(direction,':'))}=[obj.TopParamStructInit{str2double(extractAfter(direction,':'))},...
                    portInfo.getInputTopStructInitialization()];
                end
            end
        end

        function GenCodeForRegularPort(obj,portInfo,direction)

            if strcmp(direction,'input')

                obj.InputPtrFromInterfaceOrLocals=sprintf('%s%s\n',...
                obj.InputPtrFromInterfaceOrLocals,...
                portInfo.getInputPtrFromInterfaceOrLocals());
                obj.InputPtrFromRTW=sprintf('%s%s\n',...
                obj.InputPtrFromRTW,...
                portInfo.getInputPtrFromRTW(obj.rtmVarName,obj.objhandlecast));



                obj.CopyInputsToRTW=sprintf('%s%s\n',...
                obj.CopyInputsToRTW,...
                portInfo.getCopyInputsToRTW(obj.rtmVarName));
            elseif strcmp(direction,'output')

                obj.OutputPtrFromInterfaceOrLocals=sprintf('%s%s\n',...
                obj.OutputPtrFromInterfaceOrLocals,...
                portInfo.getOutputPtrFromInterfaceOrLocals());
                obj.OutputPtrFromRTW=sprintf('%s%s\n',...
                obj.OutputPtrFromRTW,...
                portInfo.getOutputPtrFromRTW(obj.rtmVarName,obj.objhandlecast));
                obj.RegulatPortOutputInit=sprintf('%s%s\n',...
                obj.RegulatPortOutputInit,...
                portInfo.getCopyRTWToOutput(obj.rtmVarName));

            else

                obj.ParamPtrFromInterfaceOrLocals{str2double(extractAfter(direction,':'))}=[obj.ParamPtrFromInterfaceOrLocals{str2double(extractAfter(direction,':'))},...
                sprintf([portInfo.getInputPtrFromInterfaceOrLocals(),'\n'])];
                obj.ParamPtrFromRTW{str2double(extractAfter(direction,':'))}=[obj.ParamPtrFromRTW{str2double(extractAfter(direction,':'))},...
                sprintf([portInfo.getParamPtrFromRTW(obj.rtmVarName,obj.objhandlecast),'\n'])];



                obj.CopyParamToRTW{str2double(extractAfter(direction,':'))}=[obj.CopyParamToRTW{str2double(extractAfter(direction,':'))},...
                portInfo.getCopyInputsToRTW(obj.rtmVarName)];
            end
        end


        function str=getActiveRTWObjHandle(obj)
            if obj.IsExtendedObjhandleEnabled
                str=sprintf('void* %s=(void*)((%s*)%s)->%s;',...
                obj.ObjHandle,...
                obj.E_ObjHandleInfo.(obj.E_ObjHandle)('Type'),...
                obj.E_ObjHandle,...
                obj.ObjHandle);
            else
                str='';
            end
        end


        function str=FreeActiveObjHandle(obj)
            if obj.IsExtendedObjhandleEnabled
                str=sprintf('free(%s);\n%s=NULL;\n',obj.E_ObjHandle,obj.E_ObjHandle);
            else
                str='';
            end
        end


        function str=getDeclarations(obj)
            str=sprintf('%s\n%s',obj.TopStructDeclaration,obj.ComplexDeclaration);
        end

        function str=getParamDeclarations(obj,idx)
            if isempty(obj.TopParamStructDeclaration{idx})
                str='';
            else
                str=obj.TopParamStructDeclaration{idx};
            end
        end


        function str=getInputPtr(obj)
            str=sprintf('%s\n%s',obj.InputPtrFromInterfaceOrLocals,obj.InputPtrFromRTW);
        end

        function str=getParamPtr(obj,idx)
            str=[obj.ParamPtrFromInterfaceOrLocals{idx},obj.ParamPtrFromRTW{idx}];
        end

        function str=getTestPointFcnDef(obj,varargin)
            if nargin>1

                singlekeyval=varargin{1};
            else
                singlekeyval='';
            end
            str='';
            if strcmp(obj.mCodeInfo.TestPointStruct.AccessFcnInterface,'One function per Test Point')

                str=obj.getActiveRTWObjHandle();
                curTestPointInfo=obj.mCodeInfo.TestPointStruct.TestPointContainer(singlekeyval);
                if isKey(obj.TopTestPointIdxMap,curTestPointInfo.FlatName)

                    str_IndexForTP=sprintf('uint32_T %s;',obj.TopTestPointIdxMap(curTestPointInfo.FlatName));
                else
                    str_IndexForTP='';
                end
                str_CopyRTWToTestPoint=obj.getCopyRTWToTestPoint(singlekeyval);
                str=sprintf('%s\n%s\n%s',str,str_IndexForTP,str_CopyRTWToTestPoint);
            else
                if obj.mCodeInfo.TestPointStruct.NumTestPoints==0
                    return;
                end
                declaredIdx=containers.Map;


                str=obj.getActiveRTWObjHandle();
                for idx=keys(obj.mCodeInfo.TestPointStruct.TestPointContainer)
                    keyval=idx{1};
                    curTestPointInfo=obj.mCodeInfo.TestPointStruct.TestPointContainer(keyval);


                    if isKey(obj.TopTestPointIdxMap,curTestPointInfo.FlatName)&&~isKey(declaredIdx,obj.TopTestPointIdxMap(curTestPointInfo.FlatName))
                        str_IndexForTP=sprintf('uint32_T %s;',obj.TopTestPointIdxMap(curTestPointInfo.FlatName));
                        declaredIdx(obj.TopTestPointIdxMap(curTestPointInfo.FlatName))=true;
                    else
                        str_IndexForTP='';
                    end
                    str_CopyRTWToTestPoint=obj.getCopyRTWToTestPoint(keyval);
                    str=sprintf('%s\n%s\n%s',str,str_IndexForTP,str_CopyRTWToTestPoint);
                end
            end
        end

        function str=getCopyRTWToTestPoint(obj,keyVal)
            TPPortInfo=obj.mCodeInfo.TestPointStruct.TestPointContainer(keyVal);
            TPPortInfo.objhandlecast=obj.objhandlecast;
            if isKey(obj.TopTestPointPtrFromRTW,TPPortInfo.FlatName)

                str=sprintf('%s\n%s',obj.TopTestPointPtrFromRTW(TPPortInfo.FlatName),obj.TopTestPointStructInit(TPPortInfo.FlatName));
            else
                str=TPPortInfo.getCopyRTWToOutput();
            end
        end


        function str=getOutputPtr(obj)
            str=sprintf('%s\n%s',obj.OutputPtrFromInterfaceOrLocals,obj.OutputPtrFromRTW);
        end

        function str=getInputToRTW(obj)
            str=sprintf('%s\n%s\n%s',obj.TopStructInit,obj.ComplexInit,obj.CopyInputsToRTW);
        end

        function str=getParamToRTW(obj,idx)
            str=[obj.TopParamStructInit{idx},obj.CopyParamToRTW{idx}];
        end


        function str=getNativeOutputCFcnCall(obj)
            str=obj.NativeOutputCFcnCall;
        end

        function str=getNativeUpdateCFcnCall(obj)
            str=obj.NativeUpdateCFcnCall;
        end

        function str=getOutputFromRTW(obj)
            str=sprintf('%s\n%s\n%s',obj.TopStructOutputInit,obj.ComplexOutputInit,obj.RegulatPortOutputInit);
        end


        function str=getInitializeFcnDefinition(obj)
            str=sprintf(['%s;\n',...
            '%s\n',...
            'if(%s==NULL)\n{\n',...
            '\t%s\n',...
            '}else{\n',...
            '\t%s;\n',...
            '}\n',...
            '%s;\n',...
            '%s\n',...
            '%s\n',...
            'return (void*)%s;'],...
            obj.getActiveObjHandleDeclaration(),...
            obj.getTSVerifyGlobalVariableInit(),...
            obj.ExistHandle,...
            obj.InitializeObjHandle(),...
            obj.CastExistingHandle(),...
            obj.getNativeInitializeCFcnCall(),...
            obj.getTSVerifyInitialization(),...
            obj.getTunableParamsInitialization(),...
            obj.getActiveObjHandle());
        end

        function str=getRunTimeErrorFcnDefinition(obj)
            str=sprintf('return %s',...
            obj.ErrStatusPrtFromRTW);
        end


        function str=getStopSimFcnDefinition(obj)
            str=sprintf('return rtmGetStopRequested(%s);',obj.objhandlecast);
        end


        function str=getResetFcnDefinition(obj)
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

        function str=getTerminateCall(obj,FirstArgVarName)
            str=sprintf('%s(%s)',obj.mCodeInfo.TerminateFcn.DPIName,FirstArgVarName);
        end
        function str=getInitializeCall(obj,FirstArgVarName)
            str=sprintf('%s(%s)',obj.mCodeInfo.InitializeFcn.DPIName,FirstArgVarName);
        end
        function str=getOutputCall(obj,FirstArgVarName)
            str=sprintf('%s(%s)',obj.mCodeInfo.OutputFcn.DPIName,char(join([FirstArgVarName,l_getFcnInputArgCallList(obj),l_getFcnOutputArgCallList(obj)],',')));
        end

        function str=getAssertionCDeclarations(obj)
            str='';
            for CodeConstructIter={'DataType','Function'}
                CodeConstructVal=CodeConstructIter{1};
                str=sprintf('%s%s\n',str,obj.AssertionManager.getCDeclaration(CodeConstructVal));
            end
        end

        function str=getAssertionCDefinitions(obj)
            if obj.IsExtendedObjhandleEnabled
                str=sprintf('%s',obj.AssertionManager.getCDefinition('Function',obj.E_ObjHandleInfo.(obj.E_ObjHandle)('Type')));
            else
                str=sprintf('%s',obj.AssertionManager.getCDefinition('Function',obj.mCodeInfo.AllocateFcn.ReturnType));
            end
        end

        function str=getExtendedObjectHandleTypeDef(obj)
            if obj.IsExtendedObjhandleEnabled
                str=sprintf('typedef struct{\n%s\n}%s;\n',...
                n_getExtendedObjDef,...
                obj.E_ObjHandleInfo.(obj.E_ObjHandle)('Type'));
            else
                str='';
            end

            function E_ObjContent=n_getExtendedObjDef()


                E_ObjContent='';
                for idx=fieldnames(obj.E_ObjHandleInfo.Fields)'
                    fname=idx{1};
                    if obj.E_ObjHandleInfo.Fields.(fname)('IsPointer')
                        E_ObjContent=sprintf('%s\t%s* %s;\n',E_ObjContent,obj.E_ObjHandleInfo.Fields.(fname)('Type'),fname);
                    else
                        E_ObjContent=sprintf('%s\t%s %s;\n',E_ObjContent,obj.E_ObjHandleInfo.Fields.(fname)('Type'),fname);
                    end
                end
            end
        end
    end
    methods

        function str=getInitializeFcnDecl(obj)
            str=l_getFuncDecl(getInitializeFcnImpl(obj));
        end
        function str=getInitializeFcnImpl(obj)
            if isempty(obj.mCodeInfo.InitializeFcn)
                str='';
            else
                str=['DPI_DLL_EXPORT void* ',obj.mCodeInfo.InitializeFcn.DPIName,'(void* existhandle)'];
            end
        end

        function str=getResetFcnDecl(obj)
            str='';
            if strcmpi(obj.ComponentTemplateType,'sequential')

                str=l_getFuncDecl(getOutputFcnImpl(obj,'ResetFcn'));
            end
        end


        function str=getOutputFcnDecl(obj)
            str=l_getFuncDecl(getOutputFcnImpl(obj,'OutputFcn'));
        end
        function str=getOutputFcnImpl(obj,FcnType)
            if strcmpi(FcnType,'ResetFcn')
                returnType='void*';
            else
                returnType='void';
            end
            if isempty(obj.mCodeInfo.(FcnType))
                str='';
            else
                str=['DPI_DLL_EXPORT ',returnType,' ',obj.mCodeInfo.(FcnType).DPIName,'('];
                arglist=[l_getFcnInputArgDeclList(obj,strcmpi(FcnType,'ResetFcn')),l_getFcnOutputArgDeclList(obj)];
                if(isempty(arglist))
                    arglist='void';
                else

                    if strcmpi(arglist(end),char(32))
                        arglist(end)=[];
                    end

                    if strcmpi(arglist(end),',')
                        arglist(end)=[];
                    end
                end
                str=[str,arglist,')'];
            end
        end

        function str=getUpdateFcnDecl(obj)
            str='';
            if strcmpi(obj.ComponentTemplateType,'sequential')

                str=l_getFuncDecl(getUpdateFcnImpl(obj));
            end
        end

        function str=getUpdateFcnImpl(obj)
            if isempty(obj.mCodeInfo.UpdateFcn)
                str='';
            else
                str=['DPI_DLL_EXPORT void ',obj.mCodeInfo.UpdateFcn.DPIName,'('];
                arglist=l_getFcnInputArgDeclList(obj,false);
                if(isempty(arglist))
                    arglist='void';
                else

                    if strcmpi(arglist(end),char(32))
                        arglist(end)=[];
                    end

                    if strcmpi(arglist(end),',')
                        arglist(end)=[];
                    end
                end
                str=[str,arglist,')'];
            end
        end

        function str=getTerminateFcnDecl(obj)
            str=l_getFuncDecl(getTerminateFcnImpl(obj));
        end


        function str=getTerminateFcnImpl(obj)
            if isempty(obj.mCodeInfo.TerminateFcn)
                str='';
            else
                str=sprintf('DPI_DLL_EXPORT void %s(void* %s)',obj.mCodeInfo.TerminateFcn.DPIName,obj.getActiveObjHandle());
            end
        end


        function str=getRunTimeErrorFcnDecl(obj)
            str=l_getFuncDecl(getRunTimeErrorFcnImpl(obj));
        end

        function str=getRunTimeErrorFcnImpl(obj)
            if isempty(obj.mCodeInfo.RunTimeErrorFcn)
                str='';
            else
                str=sprintf('DPI_DLL_EXPORT %s %s(void* %s)',obj.mCodeInfo.RunTimeErrorFcn.ReturnType,obj.mCodeInfo.RunTimeErrorFcn.DPIName,obj.getActiveObjHandle());
            end
        end
        function str=getStopSimFcnDecl(obj)
            str=l_getFuncDecl(getStopSimFcnImpl(obj));
        end
        function str=getStopSimFcnImpl(obj)
            if isempty(obj.mCodeInfo.StopSimFcn)
                str='';
            else
                str=sprintf('DPI_DLL_EXPORT %s %s(void* %s)',obj.mCodeInfo.StopSimFcn.ReturnType,obj.mCodeInfo.StopSimFcn.DPIName,obj.getActiveObjHandle());
            end
        end

        function str=TSGlobalVarDecl(obj)
            str='';
            if obj.IsTSVerifyPresent
                str=sprintf(['extern %s* %s;\n',...
                'extern int %s;'],...
                obj.TSVerifyInfo_G_T,obj.TSVerifyInfo_G,...
                obj.NumOfVer);
            end
        end


        function str=getSVDPI_VerifyHeader(obj)
            str='';
            if obj.IsTSVerifyPresent
                str=sprintf('#include "%s"',obj.TSVerifyHeader);
            end
        end

        function str=getTSVerifyFcnDecl(obj)
            str='';
            if obj.IsTSVerifyPresent
                for Idx=fields(obj.TSVerifyInfo_Fields)'
                    Fld=Idx{1};
                    if strcmp(Fld,obj.NumOfVer)
                        SecondArg='';
                    else
                        SecondArg=',int idx';
                    end

                    if obj.TSVerifyInfo_Fields.(Fld)('IsPointer')
                        RetType=[obj.TSVerifyInfo_Fields.(Fld)('Type'),'*'];
                    else
                        RetType=obj.TSVerifyInfo_Fields.(Fld)('Type');
                    end

                    str=sprintf('%s%s\n',str,l_getFuncDecl(sprintf('DPI_DLL_EXPORT %s %s(void* %s%s)',...
                    RetType,['DPI_get',Fld],obj.E_ObjHandle,SecondArg)));
                end
            else
                str='';
            end
        end

        function str=getTSVerifyFcnDef(obj)
            str='';
            if obj.IsTSVerifyPresent
                for Idx=fields(obj.TSVerifyInfo_Fields)'
                    Fld=Idx{1};
                    if obj.TSVerifyInfo_Fields.(Fld)('IsPointer')
                        RetType=[obj.TSVerifyInfo_Fields.(Fld)('Type'),'*'];
                    else
                        RetType=obj.TSVerifyInfo_Fields.(Fld)('Type');
                    end

                    if strcmp(Fld,obj.NumOfVer)
                        str=sprintf(['%sDPI_DLL_EXPORT %s %s(void* %s)\n{\n',...
                        '\treturn ((%s*)%s)->%s;\n',...
                        '}\n'],...
                        str,...
                        RetType,['DPI_get',Fld],obj.E_ObjHandle,...
                        obj.E_ObjHandleInfo.(obj.E_ObjHandle)('Type'),obj.E_ObjHandle,Fld);
                    elseif strcmp(Fld,'VerifyResult')
                        str=sprintf(['%sDPI_DLL_EXPORT %s %s(void* %s,int idx)\n{\n',...
                        '\treturn (%s)(*((%s*)%s)->%s[idx].%s);\n',...
                        '}\n'],...
                        str,...
                        RetType,['DPI_get',Fld],obj.E_ObjHandle,...
                        RetType,obj.E_ObjHandleInfo.(obj.E_ObjHandle)('Type'),obj.E_ObjHandle,obj.TSVerifyInfo_G,Fld);
                    else
                        str=sprintf(['%sDPI_DLL_EXPORT %s %s(void* %s,int idx)\n{\n',...
                        '\treturn ((%s*)%s)->%s[idx].%s;\n',...
                        '}\n'],...
                        str,...
                        RetType,['DPI_get',Fld],obj.E_ObjHandle,...
                        obj.E_ObjHandleInfo.(obj.E_ObjHandle)('Type'),obj.E_ObjHandle,obj.TSVerifyInfo_G,Fld);
                    end

                end
            else
                str='';
            end
        end


        function str=getTestPointAccessFcnDecl(obj)
            str='';
            switch(obj.mCodeInfo.TestPointStruct.AccessFcnInterface)
            case 'None'
                return;
            case 'One function per Test Point'
                for idx=keys(obj.mCodeInfo.TestPointStruct.TestPointContainer)
                    kval=idx{1};
                    curTestPointInfo=obj.mCodeInfo.TestPointStruct.TestPointContainer(kval);
                    if obj.SVStructEnabled

                        fcnName=['DPI_',curTestPointInfo.FlatName,'_f'];
                    else
                        fcnName=['DPI_',curTestPointInfo.FlatName];
                    end
                    str_temp=['void ',fcnName,...
                    '(void * ',obj.getActiveObjHandle(),',',...
                    l_getArgDeclList(curTestPointInfo,'Output'),')'];
                    obj.TestPointFcnSignatureMap(kval)=str_temp;
                    str_temp=l_getFuncDecl(['DPI_DLL_EXPORT ',str_temp]);
                    str=sprintf('%s\n',[str,str_temp]);
                end
            case 'One function for all Test Points'
                idx_num=1;
                for idx=keys(obj.mCodeInfo.TestPointStruct.TestPointContainer)
                    kval=idx{1};
                    if idx_num==1
                        str_temp=['void ',obj.mCodeInfo.TestPointStruct.TestPointContainer(kval).C_UniqueAccessFcnId,'(void * ',obj.getActiveObjHandle(),','];
                    end
                    str_temp=[str_temp,l_getArgDeclList(obj.mCodeInfo.TestPointStruct.TestPointContainer(kval),'Output'),','];%#ok<AGROW>
                    if idx_num==obj.mCodeInfo.TestPointStruct.NumTestPoints
                        str_temp=[str_temp(1:end-1),')'];
                        for idx1=keys(obj.mCodeInfo.TestPointStruct.TestPointContainer)
                            obj.TestPointFcnSignatureMap(idx1{1})=str_temp;
                        end
                        str_temp=l_getFuncDecl(['DPI_DLL_EXPORT ',str_temp]);
                        str=sprintf('%s\n',str_temp);
                    end
                    idx_num=idx_num+1;
                end

            otherwise
                error(message('HDLLink:DPITargetCC:IncorrectAccessFcnInterface'));
            end
        end

        function str=getSetParamFcnDecl(obj,idx)
            str=l_getFuncDecl(getSetParamFcnImpl(obj,idx));
        end


        function str=getSetParamFcnImpl(obj,idx)
            portInfo=obj.mCodeInfo.ParamStruct.Port(idx);
            str=sprintf('DPI_DLL_EXPORT void %s(void* %s,%s)',obj.mCodeInfo.SetParamFcn(idx).DPIName,obj.getActiveObjHandle(),l_getArgDeclList(portInfo,'Input'));
        end

    end
end

function str=l_getFcnInputArgDeclList(obj,IsReset)
    if obj.IsExtendedObjhandleEnabled&&~IsReset
        str=sprintf('void* %s, ',obj.E_ObjHandle);
    else
        str=sprintf('void* %s, ',obj.ObjHandle);
    end
    for idx=1:obj.mCodeInfo.InStruct.NumPorts
        portInfo=obj.mCodeInfo.InStruct.Port(idx);
        arg=l_getArgDeclList(portInfo,'Input');
        str=[str,arg,',',char(32)];%#ok<AGROW>
    end
end

function ArgCellList=l_getFcnInputArgCallList(obj)
    tmp={};
    if obj.mCodeInfo.InStruct.NumPorts>0
        ArgCellList_Temp=arrayfun(@(x)l_getTrueFlatName(x),obj.mCodeInfo.InStruct.Port,'UniformOutput',false);
        for idx=1:numel(ArgCellList_Temp)
            tmp=[tmp,ArgCellList_Temp{idx}];%#ok<AGROW>
        end
        ArgCellList=tmp;
    else
        ArgCellList=tmp;
    end
end


function str=l_getFcnOutputArgDeclList(obj)
    str='';
    for idx=1:obj.mCodeInfo.OutStruct.NumPorts
        portInfo=obj.mCodeInfo.OutStruct.Port(idx);







        arg=l_getArgDeclList(portInfo,'Output');
        str=[str,arg,',',char(32)];%#ok<AGROW>
    end
end

function ArgCellList=l_getFcnOutputArgCallList(obj)
    tmp={};
    if obj.mCodeInfo.OutStruct.NumPorts>0
        ArgCellList_Temp=arrayfun(@(x)l_getTrueFlatName(x),obj.mCodeInfo.OutStruct.Port,'UniformOutput',false);
        for idx=1:numel(ArgCellList_Temp)
            tmp=[tmp,ArgCellList_Temp{idx}];%#ok<AGROW>
        end
        ArgCellList=tmp;
    else
        ArgCellList=tmp;
    end
end

function CellofStrWithFlatNames=l_getTrueFlatName(portInfo)
    if isempty(portInfo.StructInfo)
        CellofStrWithFlatNames=portInfo.FlatName;
    else
        CellofStrWithFlatNames_Temp={};
        for idx=1:length(portInfo.StructInfo)
            Temp=l_getTrueFlatName(portInfo.StructInfo(num2str(idx)));
            CellofStrWithFlatNames_Temp=[CellofStrWithFlatNames_Temp,Temp];%#ok<AGROW>
        end
        CellofStrWithFlatNames=CellofStrWithFlatNames_Temp;
    end
end

function arguments=l_getArgDeclList(portInfo,Direction)
    if isempty(portInfo.StructInfo)
        TempDataType=portInfo.DPI_C_InterfaceDataType;
        if(strcmpi('Output',Direction))&&strcmpi(portInfo.DPIPortsDataType,'CompatibleCType')
            TempDataType=[portInfo.DPI_C_InterfaceDataType,'*'];
        end
        arguments=sprintf('%s %s',TempDataType,portInfo.FlatName);
    else
        arguments_temp='';
        for idx=1:length(portInfo.StructInfo)
            args=l_getArgDeclList(portInfo.StructInfo(num2str(idx)),Direction);
            arguments_temp=[arguments_temp,args,',',char(32)];%#ok<AGROW>
        end
        arguments=arguments_temp(1:end-2);
    end
end

function r=l_getFuncDecl(str)
    if isempty(str)
        r='';
    else
        r=['DPI_LINK_DECL ',str,';'];
    end
end





