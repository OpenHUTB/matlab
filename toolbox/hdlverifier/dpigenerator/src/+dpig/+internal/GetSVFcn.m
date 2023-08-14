

classdef GetSVFcn<handle


    properties
        mCodeInfo;
        mParamType;
        mParamId;
    end

    properties(Access=private)
        mSVDPISingleDataTypePorts;
        AssertionManager;
        PostFix='_temp';

        IsTSVerifyPresent;

        SVStructEnabled;

        SVScalarizePortsEnabled;


        SVNativeStructFcnImpl_TermCode;
    end

    properties(Access=protected)

        IdInterfacePrefix;


        NeedsTempPostFix;
    end

    properties(Constant)
        ObjHandle='objhandle';
    end


    properties(Access=private,Constant)
        NumOfVer='NumberOfVerifies';
        TSInfoVar='vcomp';
        TSVerifyResult='VerifyResult';
        TSVerifyStructInfo='VerifyInterfaceT';
        TSVerifyInfoFcn='DPI_getVerifyInfo';

        TSVerifyInfo_Fields=struct('NumberOfVerifies',containers.Map({'Type','IsPointer'},{'int',false}),...
        'VerifyResult',containers.Map({'Type','IsPointer'},{'int',false}),...
        'SSID',containers.Map({'Type','IsPointer'},{'int',false}),...
        'FullSSID',containers.Map({'Type','IsPointer'},{'string',false}),...
        'SFPath',containers.Map({'Type','IsPointer'},{'string',false}),...
        'MessageID',containers.Map({'Type','IsPointer'},{'string',false}),...
        'FmtMessage',containers.Map({'Type','IsPointer'},{'string',false}),...
        'TSBlkPath',containers.Map({'Type','IsPointer'},{'string',false}));


        TSVerifyInfoAPI_Fields=struct('VerifyResult',containers.Map({'Type','IsPointer'},{'slTestResult_T',false}),...
        'VerifyStepSID',containers.Map({'Type','IsPointer'},{'string',false}),...
        'StepID',containers.Map({'Type','IsPointer'},{'string',false}),...
        'VerifyID',containers.Map({'Type','IsPointer'},{'string',false}));

        FieldsMapping=containers.Map({'VerifyResult','FullSSID','SFPath','MessageID'},...
        {'VerifyResult','VerifyStepSID','StepID','VerifyID'});
    end

    properties(Access=private)
        Namespace;
    end

    methods
        function this=GetSVFcn(codeInfo,varargin)
            p=inputParser;
            addOptional(p,'Namespace','');
            addOptional(p,'AssertionInfo',[]);
            addOptional(p,'dpig_config',[]);
            parse(p,varargin{:});
            this.Namespace=p.Results.Namespace;
            this.mCodeInfo=codeInfo;
            this.mSVDPISingleDataTypePorts=containers.Map;
            if~isempty(p.Results.AssertionInfo)
                this.AssertionManager=p.Results.AssertionInfo;
            end
            this.IdInterfacePrefix='';
            this.NeedsTempPostFix=true;

            if~isempty(p.Results.dpig_config)
                this.IsTSVerifyPresent=p.Results.dpig_config.IsTSVerifyPresent;
                this.SVStructEnabled=p.Results.dpig_config.SVStructEnabled;
                this.SVScalarizePortsEnabled=p.Results.dpig_config.SVScalarizePortsEnabled;
                this.mCodeInfo.ComponentTemplateType=p.Results.dpig_config.DPIComponentTemplateType;
            else
                this.mCodeInfo.ComponentTemplateType='Sequential';
                this.SVStructEnabled=false;
                this.SVScalarizePortsEnabled=false;
            end

        end
    end
    methods
        function res=IsStructEnabled(obj)
            res=obj.SVStructEnabled;
        end
        function res=IsScalarizePortsEnabled(obj)
            res=obj.SVScalarizePortsEnabled;
        end

        function str=getIsLibContinuous(obj)
            str='0';
            if obj.mCodeInfo.IsContinuous
                str='1';
            end
        end
        function str=getAlwaysEventExpressionDecl(obj)
            str='';
            if strcmpi(obj.mCodeInfo.ComponentTemplateType,'sequential')

                str=sprintf('always @(posedge %s or posedge %s) begin',...
                obj.getClockId,obj.getResetId);
            else

                for idx=1:obj.mCodeInfo.InStruct.NumPorts
                    decl=l_getInputArgForEventExpression(obj.mCodeInfo.InStruct.Port(idx),obj.SVStructEnabled,obj.SVScalarizePortsEnabled,obj.IdInterfacePrefix);
                    str=[str,decl];%#ok<AGROW>
                end

                str=str(1:end-4);
                str=sprintf('always @(%s) begin',str);
            end
        end

        function str=getPortDeclList(obj,varargin)

            [IsSVDPITB,RemoverCtrlSigs]=l_processThreeOptionalArg(varargin);

            CtrlSig_decl='';
            Input_decl='';
            Output_decl='';
            if~RemoverCtrlSigs&&strcmpi(obj.mCodeInfo.ComponentTemplateType,'sequential')

                for idx=1:length(obj.mCodeInfo.CtrlSigStruct)
                    CtrlSig_decl_temp=sprintf('%s %s %s,\n','input','bit',obj.mCodeInfo.CtrlSigStruct(idx).Name);
                    CtrlSig_decl=[CtrlSig_decl,CtrlSig_decl_temp];%#ok<AGROW>
                end
            end

            for idx=1:obj.mCodeInfo.InStruct.NumPorts
                Input_decl_temp=l_getPortDecl(obj.mCodeInfo.InStruct.Port(idx),'input',0,IsSVDPITB,',',false,'',obj.SVStructEnabled,obj.SVScalarizePortsEnabled);
                Input_decl=[Input_decl,Input_decl_temp];%#ok<AGROW>
            end
            for idx=1:obj.mCodeInfo.OutStruct.NumPorts
                Output_decl_temp=l_getPortDecl(obj.mCodeInfo.OutStruct.Port(idx),'output',0,IsSVDPITB,',',false,'',obj.SVStructEnabled,obj.SVScalarizePortsEnabled);
                Output_decl=[Output_decl,Output_decl_temp];%#ok<AGROW>
            end
            str=sprintf('%s\n%s\n%s',CtrlSig_decl,Input_decl,Output_decl);



            last_comma=strfind(str,',');

            str=str(1:last_comma(end)-1);
        end

        function str=getSVDPITBObjHandleAndTempVars(obj)

            TempVarDecl='';

            for idx=1:obj.mCodeInfo.OutStruct.NumPorts

                n_getSingleDataTypePortsAndDeclareTempOutputs(obj.mCodeInfo.OutStruct.Port(idx));
            end
            str=sprintf('%s\n\n%s','chandle objhandle=null;',TempVarDecl);

            function n_getSingleDataTypePortsAndDeclareTempOutputs(portInfo)

                if~isempty(portInfo.StructInfo)

                    for idx_n=1:length(portInfo.StructInfo)
                        n_getSingleDataTypePortsAndDeclareTempOutputs(portInfo.StructInfo(num2str(idx_n)))
                    end
                else
                    FlattenedDims=l_GetFlattenedPortDimensions(portInfo.Dim,portInfo.StructFieldInfo);
                    if strcmpi(portInfo.SVDataType,'shortreal')
                        obj.mSVDPISingleDataTypePorts(portInfo.FlatName)=FlattenedDims;
                    end

                    IsVectorOfBuses=~isempty(portInfo.StructFieldInfo)&&nnz(portInfo.StructFieldInfo.TopStructDim>1)>0;
                    if portInfo.Dim>1||IsVectorOfBuses
                        Dim_Decl=[' [0:',num2str(FlattenedDims-1),']'];
                    else
                        Dim_Decl='';
                    end
                    TempVarDecl=sprintf('%s%s %s%s;\n',TempVarDecl,[portInfo.SVDataType,' '],[portInfo.FlatName,obj.PostFix],Dim_Decl);
                end
            end
        end

        function str=getSVDPITBTempVarsAssignment(obj)
            str='';

            for idx=keys(obj.mSVDPISingleDataTypePorts)
                idKey=idx{1};

                if obj.mSVDPISingleDataTypePorts(idKey)>1

                    for idx1=0:obj.mSVDPISingleDataTypePorts(idKey)-1
                        str=sprintf('%s%s<=$shortrealtobits(%s);\n',...
                        str,[idKey,'[',num2str(idx1),']'],[idKey,obj.PostFix,'[',num2str(idx1),']']);
                    end
                else

                    str=sprintf('%s%s<=$shortrealtobits(%s);\n',str,idKey,[idKey,obj.PostFix]);
                end

            end

            for idx=1:obj.mCodeInfo.OutStruct.NumPorts
                n_getTempVarAssignmentForRestOfPorts(obj.mCodeInfo.OutStruct.Port(idx));
            end

            function n_getTempVarAssignmentForRestOfPorts(portInfo)
                if obj.mSVDPISingleDataTypePorts.isKey(portInfo.FlatName)

                    return;
                end

                if~isempty(portInfo.StructInfo)

                    for idx_n=1:length(portInfo.StructInfo)
                        n_getTempVarAssignmentForRestOfPorts(portInfo.StructInfo(num2str(idx_n)))
                    end
                else
                    str=sprintf('%s%s <=%s;\n',str,portInfo.FlatName,[portInfo.FlatName,obj.PostFix]);
                end
            end
        end

        function str=getSVPortStructDef(obj)
            StructName2DefMap=containers.Map;
            StructName2StructDependencies=containers.Map;
            str='';
            if obj.SVStructEnabled

                for idx=1:obj.mCodeInfo.InStruct.NumPorts
                    if~isempty(obj.mCodeInfo.InStruct.Port(idx).StructInfo)
                        [StructName2DefMap,StructName2StructDependencies]=obj.getStructDef(obj.mCodeInfo.InStruct.Port(idx),'',StructName2DefMap,StructName2StructDependencies,obj.SVScalarizePortsEnabled);
                    end
                end

                for idx=1:obj.mCodeInfo.OutStruct.NumPorts
                    if~isempty(obj.mCodeInfo.OutStruct.Port(idx).StructInfo)
                        [StructName2DefMap,StructName2StructDependencies]=obj.getStructDef(obj.mCodeInfo.OutStruct.Port(idx),'',StructName2DefMap,StructName2StructDependencies,obj.SVScalarizePortsEnabled);
                    end
                end

                for idx=1:obj.mCodeInfo.ParamStruct.NumPorts
                    if~isempty(obj.mCodeInfo.ParamStruct.Port(idx).StructInfo)
                        [StructName2DefMap,StructName2StructDependencies]=obj.getStructDef(obj.mCodeInfo.ParamStruct.Port(idx),'',StructName2DefMap,StructName2StructDependencies,false);
                    end
                end


                for idx=keys(obj.mCodeInfo.TestPointStruct.TestPointContainer)
                    keyVal=idx{1};
                    curTestPointInfo=obj.mCodeInfo.TestPointStruct.TestPointContainer(keyVal);
                    if~isempty(curTestPointInfo.StructInfo)
                        [StructName2DefMap,StructName2StructDependencies]=obj.getStructDef(curTestPointInfo,'',StructName2DefMap,StructName2StructDependencies,false);
                    end
                end
                str=obj.printStructDef(StructName2DefMap,StructName2StructDependencies);
            end
        end

        function str=getImportTSVerifyFcn(obj)
            str='';
            if obj.IsTSVerifyPresent
                for Idx=fields(obj.TSVerifyInfo_Fields)'
                    Fld=Idx{1};
                    if~strcmp(Fld,'FullSSID')
                        if strcmp(Fld,obj.NumOfVer)
                            SecondArg='';
                        else
                            SecondArg=',input int idx';
                        end

                        RetType=obj.TSVerifyInfo_Fields.(Fld)('Type');

                        str=sprintf('%simport "DPI-C" function %s %s(input chandle %s%s);\n',...
                        str,RetType,['DPI_get',Fld],obj.ObjHandle,SecondArg);
                    end
                end
            else
                str='';
            end
        end

        function str=getImportInitializeFcn(obj)
            if isempty(obj.mCodeInfo.InitializeFcn)
                str='';
            else
                str=['import "DPI-C" function chandle ',obj.mCodeInfo.InitializeFcn.DPIName,'(chandle existhandle);'];
            end
        end

        function str=getImportResetFcn(obj)
            if isempty(obj.mCodeInfo.ResetFcn)||strcmpi(obj.mCodeInfo.ComponentTemplateType,'combinational')
                str='';
            else
                str=['import "DPI-C" function chandle ',obj.mCodeInfo.ResetFcn.DPIName,'('];
                arglist=[l_getFcnInputArgDeclList(obj),l_getFcnOutputArgDeclList(obj,false)];
                if(~isempty(arglist))


                    last_comma=strfind(arglist,',');

                    arglist=arglist(1:last_comma(end)-1);
                end
                str=[str,arglist,');'];
            end
        end

        function str=getImportOutputFcn(obj,varargin)

            [IsSVDPITB,~]=l_processThreeOptionalArg(varargin);

            if isempty(obj.mCodeInfo.OutputFcn)
                str='';
            else
                str=['import "DPI-C" function void ',obj.mCodeInfo.OutputFcn.DPIName,'('];
                arglist=[l_getFcnInputArgDeclList(obj),l_getFcnOutputArgDeclList(obj,IsSVDPITB)];
                if(~isempty(arglist))


                    last_comma=strfind(arglist,',');

                    arglist=arglist(1:last_comma(end)-1);
                end
                str=[str,arglist,');'];
            end
        end

        function str=getImportUpdateFcn(obj)
            if isempty(obj.mCodeInfo.UpdateFcn)||strcmpi(obj.mCodeInfo.ComponentTemplateType,'combinational')
                str='';
            else
                str=['import "DPI-C" function void ',obj.mCodeInfo.UpdateFcn.DPIName,'('];
                arglist=l_getFcnInputArgDeclList(obj);
                if(~isempty(arglist))


                    last_comma=strfind(arglist,',');

                    arglist=arglist(1:last_comma(end)-1);
                end
                str=[str,arglist,');'];
            end
        end



        function str=getDPIEntryPointWrapperFcn(obj,Part)
            str='';
            if obj.SVStructEnabled||obj.SVScalarizePortsEnabled
                switch Part
                case 'comment'
                    if obj.SVScalarizePortsEnabled&&obj.SVStructEnabled
                        str='Define SystemVerilog wrapper functions for native struct and scalarize ports support';
                    elseif obj.SVStructEnabled
                        str='Define SystemVerilog wrapper functions for native struct support';
                    else
                        str='Define SystemVerilog wrapper functions for scalarize ports support';
                    end
                case 'definition'
                    InputArgDeclList=l_getFcnInputArgDeclList_uf(obj);
                    OutputArgDeclList=l_getFcnOutputArgDeclList_uf(obj,false);
                    if strcmpi(obj.mCodeInfo.ComponentTemplateType,'sequential')
                        FcnTypes={'ResetFcn','OutputFcn','UpdateFcn'};
                    else
                        FcnTypes={'OutputFcn'};
                    end
                    for FcnType_k=FcnTypes
                        FcnType=FcnType_k{1};
                        if strcmp(FcnType,'ResetFcn')
                            ReturnType='chandle';
                        else
                            ReturnType='void';
                        end

                        if strcmp(FcnType,'UpdateFcn')
                            DeclList=InputArgDeclList;
                        else
                            DeclList=[InputArgDeclList,OutputArgDeclList];
                        end

                        if~isempty(obj.mCodeInfo.(FcnType))
                            str=sprintf(['%s\n\n',...
                            'function %s %s(%s);\n',...
                            '%s',...
                            'endfunction'],...
                            str,...
                            ReturnType,obj.mCodeInfo.(FcnType).DPIName(1:end-2),DeclList(1:end-2),...
                            obj.getDPIEntryPointWrapperFcnImpl(FcnType));
                        end
                    end
                end
            end

        end

        function str=getSVNativePrmStructFcn(obj,idx,Part)
            str='';
            ParamInfo=obj.mCodeInfo.ParamStruct.Port(idx);
            if obj.SVStructEnabled
                switch Part
                case 'comment'
                    str=['Define SystemVerilog wrapper functions for tunable parameter native struct support for parameter: ',ParamInfo.Name];
                case 'definition'







                    if isPrmStructTypeSameWithIOStructType(obj,ParamInfo)
                        IsScalarizePortsEnabled=obj.SVScalarizePortsEnabled;
                    else
                        IsScalarizePortsEnabled=false;
                    end
                    InputPrmArgDeclList=l_getFcnParamArgDeclList_uf(obj,ParamInfo,IsScalarizePortsEnabled);
                    ArgCall=l_getFcnPrmArgCallList(obj,ParamInfo,true,IsScalarizePortsEnabled);
                    str=sprintf(['function void %s(%s);\n',...
                    '\t%s(%s);\n',...
                    'endfunction'],...
                    obj.mCodeInfo.SetParamFcn(idx).DPIName(1:end-2),InputPrmArgDeclList(1:end-2),...
                    obj.mCodeInfo.SetParamFcn(idx).DPIName,ArgCall(1:end-2));
                end
            end
        end

        function res=isPrmStructTypeSameWithIOStructType(obj,ParamInfo)
            res=false;
            if~isempty(ParamInfo.StructInfo)
                IOPorts=[];
                if obj.mCodeInfo.InStruct.NumPorts~=0
                    IOPorts=[IOPorts,obj.mCodeInfo.InStruct.Port];
                end
                if obj.mCodeInfo.OutStruct.NumPorts~=0
                    IOPorts=[IOPorts,obj.mCodeInfo.OutStruct.Port];
                end
                for idx=1:numel(IOPorts)
                    if~isempty(IOPorts(idx).StructInfo)&&strcmp(IOPorts(idx).SVDataType,ParamInfo.SVDataType)
                        res=true;
                        return;
                    end
                end
            end
        end



        function str=getImportTerminateFcn(obj)
            if isempty(obj.mCodeInfo.TerminateFcn)
                str='';
            else
                str=['import "DPI-C" function void ',obj.mCodeInfo.TerminateFcn.DPIName,'(input chandle objhandle);'];
            end
        end
        function str=getImportRunTimeErrFcn(obj)
            if isempty(obj.mCodeInfo.RunTimeErrorFcn)
                str='';
            else
                str=['import "DPI-C" function string ',obj.mCodeInfo.RunTimeErrorFcn.DPIName,'(input chandle objhandle);'];
            end
        end

        function str=getImportStopSimFcn(obj)
            if isempty(obj.mCodeInfo.StopSimFcn)
                str='';
            else
                str=['import "DPI-C" function byte ',obj.mCodeInfo.StopSimFcn.DPIName,'(input chandle objhandle);'];
            end
        end

        function str=getImportAccessTestPointFcn(obj)
            str='';
            switch(obj.mCodeInfo.TestPointStruct.AccessFcnInterface)
            case 'None'
                return;
            case 'One function per Test Point'
                for idx=keys(obj.mCodeInfo.TestPointStruct.TestPointContainer)
                    keyval=idx{1};
                    curTestPointInfo=obj.mCodeInfo.TestPointStruct.TestPointContainer(keyval);
                    if obj.SVStructEnabled

                        CFcnName=['DPI_',curTestPointInfo.FlatName,'_f'];
                    else

                        CFcnName=['DPI_',curTestPointInfo.FlatName];
                    end

                    FcnName=['DPI_',curTestPointInfo.FlatName];

                    ArgsDecl=l_getFcnTestPointArgDeclList(obj,curTestPointInfo);

                    ArgsDecl(end-1:end)=[];
                    ImportedCFcn=sprintf('import "DPI-C" function void %s(input chandle %s, \n%s);\n',CFcnName,obj.ObjHandle,ArgsDecl);
                    NativeStructWrapperFcn='';
                    if obj.SVStructEnabled

                        ArgsDecl_uf=l_getFcnTestPointArgDeclList_uf(obj,curTestPointInfo,false);

                        ArgCall_uf=l_getFcnTestPointArgCallList(obj,curTestPointInfo,true,false);

                        ArgsDecl_uf(end-1:end)=[];
                        ArgCall_uf(end-1:end)=[];

                        [TempVarCreate,AssignFromTempVarToOutput]=obj.getTestPointSVFcnBody(curTestPointInfo,obj.SVStructEnabled,false);
                        NativeStructWrapperFcn=sprintf(['/*Define SystemVerilog wrapper function for test point native struct support*/\n',...
                        'function void %s(input chandle %s,\n%s);\n',...
                        '%s',...
                        '\t%s(%s,%s);\n',...
                        '%s',...
                        'endfunction\n'],...
                        FcnName,obj.ObjHandle,ArgsDecl_uf,...
                        TempVarCreate,...
                        CFcnName,obj.ObjHandle,ArgCall_uf,...
                        AssignFromTempVarToOutput);
                    end
                    str=sprintf('%s%s%s',str,ImportedCFcn,NativeStructWrapperFcn);
                end
            case 'One function for all Test Points'
                if obj.mCodeInfo.TestPointStruct.NumTestPoints~=0
                    TPKeys=keys(obj.mCodeInfo.TestPointStruct.TestPointContainer);
                    ArgsDecl='';
                    ArgsDecl_uf='';
                    ArgCall_uf='';
                    TempVarCreate='';
                    AssignFromTempVarToOutput='';
                    for idx=TPKeys
                        keyval=idx{1};
                        curTestPointInfo=obj.mCodeInfo.TestPointStruct.TestPointContainer(keyval);
                        ArgsDecl=[ArgsDecl,l_getFcnTestPointArgDeclList(obj,curTestPointInfo)];%#ok<AGROW>
                        ArgsDecl_uf=[ArgsDecl_uf,l_getFcnTestPointArgDeclList_uf(obj,curTestPointInfo,false)];%#ok<AGROW>
                        ArgCall_uf=[ArgCall_uf,l_getFcnTestPointArgCallList(obj,curTestPointInfo,true,false)];%#ok<AGROW>
                        if obj.SVStructEnabled
                            [sub_TempVarCreate,sub_AssignFromTempVarToOutput]=obj.getTestPointSVFcnBody(curTestPointInfo,obj.SVStructEnabled,false);
                            TempVarCreate=[TempVarCreate,sub_TempVarCreate];%#ok<AGROW>
                            AssignFromTempVarToOutput=[AssignFromTempVarToOutput,sub_AssignFromTempVarToOutput];%#ok<AGROW>
                        end
                    end

                    ArgsDecl(end-1:end)=[];
                    ArgsDecl_uf(end-1:end)=[];
                    ArgCall_uf(end-1:end)=[];

                    str=sprintf(['import "DPI-C" function void %s(input chandle %s,\n%s);\n',...
                    '/*Scoped SystemVerilog test point access function*/\n',...
                    'function void %s(input chandle %s,\n%s);\n',...
                    '%s',...
                    '\t%s(%s,%s);\n',...
                    '%s',...
                    'endfunction //%s\n'],...
                    obj.mCodeInfo.TestPointStruct.TestPointContainer(TPKeys{1}).C_UniqueAccessFcnId,obj.ObjHandle,ArgsDecl,...
                    obj.mCodeInfo.TestPointStruct.TestPointContainer(TPKeys{1}).SV_UniqueAccessFcnId,obj.ObjHandle,ArgsDecl_uf,...
                    TempVarCreate,...
                    obj.mCodeInfo.TestPointStruct.TestPointContainer(TPKeys{1}).C_UniqueAccessFcnId,obj.ObjHandle,ArgCall_uf,...
                    AssignFromTempVarToOutput,...
                    obj.mCodeInfo.TestPointStruct.TestPointContainer(TPKeys{1}).SV_UniqueAccessFcnId);
                end
            otherwise
                error(message('HDLLink:DPITargetCC:IncorrectAccessFcnInterface'));
            end
        end

        function[str_init,str_term]=getTestPointSVFcnBody(obj,portInfo,SVStructEnabled,SVScalarizePortsEnabled)


            str_init='';
            str_term='';
            if~isempty(portInfo.StructInfo)
                for idx_n=1:length(portInfo.StructInfo)
                    [str_init_n_temp,str_term_n_temp]=obj.getTestPointSVFcnBody(portInfo.StructInfo(num2str(idx_n)),SVStructEnabled,SVScalarizePortsEnabled);
                    if~isempty(str_init_n_temp)
                        str_init=sprintf('%s%s',str_init,str_init_n_temp);
                        str_term=sprintf('%s%s',str_term,str_term_n_temp);
                    end
                end
            else
                str_init=portInfo.getSVAutoVarDecl4SVWrapperFcn(SVScalarizePortsEnabled);
                str_term=portInfo.getSVAutoVars2SVWrapperFcnOutput(SVStructEnabled,SVScalarizePortsEnabled);
            end
        end


        function str=getImportSetParamFcn(obj,idx)
            portInfo=obj.mCodeInfo.ParamStruct.Port(idx);
            PortDecl=l_getFcnParamArgDeclList(obj,portInfo);
            str=['import "DPI-C" function void ',obj.mCodeInfo.SetParamFcn(idx).DPIName,'(',PortDecl(1:end-2),');'];
        end

        function str=getInitializeFcnCall(obj)
            if isempty(obj.mCodeInfo.InitializeFcn)
                str='';
            else
                str=['objhandle = ',obj.mCodeInfo.InitializeFcn.DPIName,'(objhandle);'];
            end
        end

        function str=getResetFcnCall(obj,varargin)
            [~,~,NeedsTempPostFix_t]=l_processThreeOptionalArg(varargin);
            obj.NeedsTempPostFix=NeedsTempPostFix_t;
            if isempty(obj.mCodeInfo.ResetFcn)
                str='';
            else
                if obj.SVStructEnabled||obj.SVScalarizePortsEnabled


                    str=[obj.ObjHandle,'=',obj.mCodeInfo.ResetFcn.DPIName(1:end-2),'('];
                else
                    str=[obj.ObjHandle,'=',obj.mCodeInfo.ResetFcn.DPIName,'('];
                end

                arglist=[l_getFcnInputArgCallList(obj,false),l_getFcnOutputArgCallList(obj,false,false)];
                if(~isempty(arglist))


                    last_comma=strfind(arglist,',');

                    arglist=arglist(1:last_comma(end)-1);
                end
                str=[str,arglist,');'];
            end
        end

        function str=getOutputFcnCall(obj,varargin)

            [IsSVDPITB,~,NeedsTempPostFix_t]=l_processThreeOptionalArg(varargin);
            obj.NeedsTempPostFix=NeedsTempPostFix_t;

            if isempty(obj.mCodeInfo.OutputFcn)
                str='';
            else
                if obj.SVStructEnabled||obj.SVScalarizePortsEnabled


                    str=[obj.mCodeInfo.OutputFcn.DPIName(1:end-2),'('];
                else
                    str=[obj.mCodeInfo.OutputFcn.DPIName,'('];
                end
                arglist=[l_getFcnInputArgCallList(obj,false),l_getFcnOutputArgCallList(obj,IsSVDPITB,false)];
                if(~isempty(arglist))


                    last_comma=strfind(arglist,',');

                    arglist=arglist(1:last_comma(end)-1);
                end
                str=[str,arglist,');'];
            end
        end


        function[portNameList,portDataTypeList]=getOutputFcnCallArgs(obj,structEnabled)
            portNameList={};
            portDataTypeList={};


            if nargin==2
                svEnabled=structEnabled;
            else
                svEnabled=obj.SVStructEnabled;
            end
            for idx=1:obj.mCodeInfo.OutStruct.NumPorts
                [portNameListTemp,portDataTypeListTemp]=l_getFcnPortArgs(obj.mCodeInfo.OutStruct.Port(idx),true,'',true,obj.IdInterfacePrefix,false,'',svEnabled,obj.SVScalarizePortsEnabled);
                portNameList=[portNameList,portNameListTemp];%#ok<AGROW>
                portDataTypeList=[portDataTypeList,portDataTypeListTemp];%#ok<AGROW>
            end
        end

        function[portNameList,portDataTypeList]=getInputFcnCallArgs(obj)
            portNameList={};
            portDataTypeList={};
            for idx=1:obj.mCodeInfo.InStruct.NumPorts
                [portNameListTemp,portDataTypeListTemp]=l_getFcnPortArgs(obj.mCodeInfo.InStruct.Port(idx),true,'',true,obj.IdInterfacePrefix,false,'',obj.SVStructEnabled,obj.SVScalarizePortsEnabled);
                portNameList=[portNameList,portNameListTemp];%#ok<AGROW>
                portDataTypeList=[portDataTypeList,portDataTypeListTemp];%#ok<AGROW>
            end
        end

        function str=getUpdateFcnCall(obj)
            if isempty(obj.mCodeInfo.UpdateFcn)||strcmpi(obj.mCodeInfo.ComponentTemplateType,'combinational')
                str='';
            else

                if obj.SVStructEnabled||obj.SVScalarizePortsEnabled


                    str=[obj.mCodeInfo.UpdateFcn.DPIName(1:end-2),'('];
                else
                    str=[obj.mCodeInfo.UpdateFcn.DPIName,'('];
                end
                arglist=l_getFcnInputArgCallList(obj,false);
                if(~isempty(arglist))


                    last_comma=strfind(arglist,',');

                    arglist=arglist(1:last_comma(end)-1);
                end
                str=[str,arglist,');'];
            end
        end

        function str=getTerminateFcnCall(obj)
            if isempty(obj.mCodeInfo.TerminateFcn)
                str='';
            else
                str=[obj.mCodeInfo.TerminateFcn.DPIName,'(objhandle);'];
            end
        end

        function str=getAccessTestPointFcnCall(obj)
            str='';
            switch(obj.mCodeInfo.TestPointStruct.AccessFcnInterface)
            case 'None'
                return;
            case 'One function per Test Point'
                for idx=keys(obj.mCodeInfo.TestPointStruct.TestPointContainer)
                    keyval=idx{1};
                    curTestPointInfo=obj.mCodeInfo.TestPointStruct.TestPointContainer(keyval);
                    ArgCall=l_getFcnTestPointArgCallList(obj,curTestPointInfo,false,false);

                    ArgCall(end-1:end)=[];
                    str=[str,'DPI_',curTestPointInfo.FlatName,'(objhandle,',ArgCall,');'];%#ok<AGROW>
                    str=sprintf('%s\n',str);
                end
            case 'One function for all Test Points'
                if obj.mCodeInfo.TestPointStruct.NumTestPoints~=0
                    str_FcnName='DPI_TestPointAccessFcn(objhandle,';
                    str_FcnArgs='';
                    for idx=keys(obj.mCodeInfo.TestPointStruct.TestPointContainer)
                        keyval=idx{1};
                        curTestPointInfo=obj.mCodeInfo.TestPointStruct.TestPointContainer(keyval);
                        str_FcnArgs=[str_FcnArgs,l_getFcnTestPointArgCallList(obj,curTestPointInfo,false,false)];%#ok<AGROW>
                    end

                    str_FcnArgs(end-1:end)=[];
                    str=[str_FcnName,str_FcnArgs,');'];
                end
            otherwise
                error(message('HDLLink:DPITargetCC:IncorrectAccessFcnInterface'));
            end
        end
        function str=getReportRunTimeErrPackageCode(obj)
            if isempty(obj.mCodeInfo.RunTimeErrorFcn)
                str='';
            else
                switch obj.mCodeInfo.RunTimeErrorFcn.Severity
                case 'Fatal'
                    svTaskStr=['$fatal(1, "Run-time error : %s ", ',obj.mCodeInfo.RunTimeErrorFcn.MsgName,');'];
                case 'Info'
                    svTaskStr=['$display("Run-time error : %s ", ',obj.mCodeInfo.RunTimeErrorFcn.MsgName,');'];
                case 'Warning'
                    svTaskStr=['$warning("Run-time error : %s ", ',obj.mCodeInfo.RunTimeErrorFcn.MsgName,');'];
                case 'Error'
                    svTaskStr=['$error("Run-time error : %s ", ',obj.mCodeInfo.RunTimeErrorFcn.MsgName,');'];
                otherwise
                    svTaskStr=['$fatal(1, "Run-time error : %s ", ',obj.mCodeInfo.RunTimeErrorFcn.MsgName,');'];
                end
                str=sprintf(['// Define SystemVerilog function for run-time error reporting\n'...
                ,'function automatic void %s(input chandle %s);\n'...
                ,'string %s = %s(%s);\n'...
                ,'if(%s.len() != 0) begin\n'...
                ,repmat('\t',1,1),'%s\n'...
                ,'end\nendfunction\n'],...
                obj.mCodeInfo.RunTimeErrorFcn.SVName,...
                obj.ObjHandle,...
                obj.mCodeInfo.RunTimeErrorFcn.MsgName,...
                obj.mCodeInfo.RunTimeErrorFcn.DPIName,...
                obj.ObjHandle,...
                obj.mCodeInfo.RunTimeErrorFcn.MsgName,...
                svTaskStr);
            end
        end

        function str=getAssertionSVPackageCode(obj)
            str='';

            str=sprintf('%s%s\n',str,obj.AssertionManager.getSVDefinition('DataType'));

            str=sprintf('%s%s\n',str,obj.AssertionManager.getSVDeclaration('Function'));

            str=sprintf('%s%s\n',str,obj.AssertionManager.getSVDefinition('Function'));
        end

        function str=getTSVerifyPackageCode(obj)
            str='';

            if obj.IsTSVerifyPresent



                pkginfo=what('+dpig/+internal');
                svt=fullfile(pkginfo.path,'private','TSVerifyPackageCode.svt');
                [fid,msg]=fopen(svt,'r');
                if fid==-1,error(['(internal) during fopen of TSVerifyPackageCode:',msg]);end
                context=fread(fid,inf,'uint8=>char')';
                fclose(fid);

                str=strrep(context,'%<FullSSIDCases>',n_getTSBlkSIDMap());

            end

            function str=n_getTSBlkSIDMap()
                str='';
                for idxk=keys(obj.mCodeInfo.TSBlkPath2SIDMap)
                    KeyVal=idxk{1};
                    str=sprintf(['%s',repmat('\t',1,2),'"%s":\n',...
                    repmat('\t',1,3),'%s={"%s",%s};\n'],...
                    str,coder.internal.getEscapedString(KeyVal),...
                    'FullSSID',obj.mCodeInfo.TSBlkPath2SIDMap(KeyVal),'SSID_str');
                end
                str=sprintf(['%s',repmat('\t',1,2),'%s:\n',...
                repmat('\t',1,3),'%s={%s,%s};\n'],...
                str,'default',...
                'FullSSID','TSBlkPath','SSID_str');
            end
        end

        function str=getAssertionInfoStructDeclaration(obj,varargin)
            p=inputParser;
            addOptional(p,'ExplicitNamespace',false);
            parse(p,varargin{:});
            ExplicitNamespace=p.Results.ExplicitNamespace;

            str=obj.AssertionManager.getSVDeclaration('DataType','ExplicitNamespace',ExplicitNamespace);
        end

        function str=getTSVerifyInfoStructDeclaration(obj,varargin)
            p=inputParser;
            addOptional(p,'ExplicitNamespace',false);
            parse(p,varargin{:});
            ExplicitNamespace=p.Results.ExplicitNamespace;

            str='';
            if obj.IsTSVerifyPresent
                if~ExplicitNamespace
                    str=sprintf('%s %s;',obj.TSVerifyStructInfo,obj.TSInfoVar);
                else
                    str=sprintf('%s::%s %s;',obj.Namespace,obj.TSVerifyStructInfo,obj.TSInfoVar);
                end
            end
        end

        function str=getTSVerifyInfoInstantiation(obj,varargin)
            p=inputParser;
            addOptional(p,'ModuleName','');
            parse(p,varargin{:});
            ModuleName=p.Results.ModuleName;

            str='';
            if obj.IsTSVerifyPresent
                str=sprintf('%s = new(objhandle, "%s");',obj.TSInfoVar,ModuleName);
            end
        end

        function str=getTSVerifyInfoSetNewDPIObjHandle(obj,varargin)
            p=inputParser;
            addOptional(p,'ModuleName','');
            parse(p,varargin{:});
            ModuleName=p.Results.ModuleName;

            str='';
            if obj.IsTSVerifyPresent
                str=sprintf('%s.setNewDPIObjHandle(objhandle, "%s");',obj.TSInfoVar,ModuleName);
            end
        end

        function str=getTSVerifyInfoReporting(obj)
            str='';
            if obj.IsTSVerifyPresent
                str=sprintf('%s.reportVerifyCoverage();',obj.TSInfoVar);
            end
        end

        function str=getEnumDeclarations(obj)
            str='';
            EnumTypeMap=containers.Map;

            for idx=1:obj.mCodeInfo.InStruct.NumPorts
                [str,EnumTypeMap]=obj.getEnumDef(str,obj.mCodeInfo.InStruct.Port(idx),EnumTypeMap);
            end

            for idx=1:obj.mCodeInfo.OutStruct.NumPorts
                [str,EnumTypeMap]=obj.getEnumDef(str,obj.mCodeInfo.OutStruct.Port(idx),EnumTypeMap);
            end
        end


        function str=getAssertionQueryingSVCode(obj,varargin)
            p=inputParser;
            addOptional(p,'ExplicitNamespace',false);
            parse(p,varargin{:});
            ExplicitNamespace=p.Results.ExplicitNamespace;
            str='';
            if~obj.AssertionManager.NoAssertions
                str=sprintf('%s%s\n',str,obj.AssertionManager.getSVFunctionCall('ExplicitNameSpace',ExplicitNamespace));
                str=sprintf('%s%s\n',str,obj.AssertionManager.getAssertionStatements('ExplicitNameSpace',ExplicitNamespace));
            end
        end

        function str=getTSVerifyQueryingSVCode(obj,varargin)
            str='';
            if obj.IsTSVerifyPresent
                str=sprintf('%s.checkVerifyStatus();',obj.TSInfoVar);
            end
        end

    end


    methods(Access=protected)
        function str=getInputSignalsList(obj)
            Input_decl='';
            for idx=1:obj.mCodeInfo.InStruct.NumPorts
                Input_decl_temp=l_getPortDecl(obj.mCodeInfo.InStruct.Port(idx),'',0,false,';',false,'',obj.SVStructEnabled,obj.SVScalarizePortsEnabled);
                Input_decl=[Input_decl,Input_decl_temp];%#ok<AGROW>
            end
            str=Input_decl;
        end

        function str=getOutputSignalsList(obj)
            Output_decl='';
            for idx=1:obj.mCodeInfo.OutStruct.NumPorts
                Output_decl_temp=l_getPortDecl(obj.mCodeInfo.OutStruct.Port(idx),'',0,false,';',obj.NeedsTempPostFix,obj.PostFix,obj.SVStructEnabled,obj.SVScalarizePortsEnabled);
                Output_decl=[Output_decl,Output_decl_temp];%#ok<AGROW>
            end
            str=Output_decl;
        end
        function str=getTestPointSignalsList(obj)

            TestPoint_decl='';
            for idx=keys(obj.mCodeInfo.TestPointStruct.TestPointContainer)
                keyval=idx{1};
                curTestPointInfo=obj.mCodeInfo.TestPointStruct.TestPointContainer(keyval);



                TestPoint_decl_temp=l_getPortDecl(curTestPointInfo,'',0,false,';',obj.NeedsTempPostFix,'',obj.SVStructEnabled,false);
                TestPoint_decl=[TestPoint_decl,TestPoint_decl_temp];%#ok<AGROW>
            end
            str=TestPoint_decl;
        end
    end


    methods
        function str=DeclarePortsInterface(obj)%#ok<MANU>
            str='';
        end
    end


    methods
        function str=getOutputTempVarDecl(obj)
            str=obj.getOutputSignalsList();
        end

        function str=getTestPointVarDecl(obj)
            str=obj.getTestPointSignalsList();
        end

        function str=getNBVarAssignmentFromTmpToActual(obj)

            str='';
            for idx=1:obj.mCodeInfo.OutStruct.NumPorts
                str_t=l_getNBVarAssignmentFromTmpToActual(obj.mCodeInfo.OutStruct.Port(idx),obj.PostFix,obj.SVStructEnabled,obj.SVScalarizePortsEnabled);
                str=sprintf('%s%s',str,str_t);
            end
        end

        function str=getReportRunTimeErrFcnCall(obj)
            str='';
            if~isempty(obj.mCodeInfo.RunTimeErrorFcn)
                str=sprintf('//Run-time error reporting\n%s(%s);',obj.mCodeInfo.RunTimeErrorFcn.SVName,obj.ObjHandle);
            end
        end

        function str=getClockId(obj)


            str=sprintf('%s',obj.mCodeInfo.CtrlSigStruct(1).Name);
        end

        function str=getClockEnId(obj)
            str=sprintf('%s',obj.mCodeInfo.CtrlSigStruct(2).Name);
        end

        function str=getResetId(obj)
            str=sprintf('%s',obj.mCodeInfo.CtrlSigStruct(3).Name);
        end
    end

    methods(Access=private)
        function str=getTSVerifyAction(obj,VerifyResult)
            switch VerifyResult
            case 'Untested'
                str=sprintf('\t$display("At step ''%s'' verify id ''%s'' is Untested",%s[TSVer_Idx].%s,%s[TSVer_Idx].%s);',...
                '%s','%s',obj.TSInfoVar,'SFPath',obj.TSInfoVar,'MessageID');
            case 'Pass'
                str=sprintf('\t$display("At step ''%s'' verify id ''%s'' Passed",%s[TSVer_Idx].%s,%s[TSVer_Idx].%s);',...
                '%s','%s',obj.TSInfoVar,'SFPath',obj.TSInfoVar,'MessageID');
            case 'Fail'
                str=sprintf('\t$warning("At step ''%s'' verify id ''%s'' Failed",%s[TSVer_Idx].%s,%s[TSVer_Idx].%s);',...
                '%s','%s',obj.TSInfoVar,'SFPath',obj.TSInfoVar,'MessageID');
            otherwise
                str='';
            end
        end

        function str=getDPIEntryPointWrapperFcnImpl(obj,FcnType)
            str='';
            if obj.SVStructEnabled||obj.SVScalarizePortsEnabled
                [InitCode,obj.SVNativeStructFcnImpl_TermCode]=obj.getDPIEntryPointWrapperFcnImpl_BodyCode();
                InputCallList=l_getFcnInputArgCallList(obj,true);


                obj.NeedsTempPostFix=false;
                OutputCallList=l_getFcnOutputArgCallList(obj,false,true);
                IOCallList=[InputCallList,OutputCallList];

                obj.NeedsTempPostFix=true;
                TermCode=obj.SVNativeStructFcnImpl_TermCode;
                switch FcnType
                case 'ResetFcn'
                    str=sprintf(['%s',...
                    '\t%s=%s(%s);\n',...
                    '%s',...
                    '\treturn %s;\n'],...
                    InitCode,...
                    obj.ObjHandle,obj.mCodeInfo.ResetFcn.DPIName,IOCallList(1:end-2),...
                    TermCode,...
                    obj.ObjHandle);
                case 'OutputFcn'
                    str=sprintf(['%s',...
                    '\t%s(%s);\n',...
                    '%s'],...
                    InitCode,...
                    obj.mCodeInfo.OutputFcn.DPIName,IOCallList(1:end-2),...
                    TermCode);
                case 'UpdateFcn'
                    str=sprintf('\t%s(%s);\n',...
                    obj.mCodeInfo.UpdateFcn.DPIName,InputCallList(1:end-2));
                end
            end
        end

        function[str_init,str_term]=getDPIEntryPointWrapperFcnImpl_BodyCode(obj)

            assert(obj.SVStructEnabled||obj.SVScalarizePortsEnabled);
            str_init='';
            str_term='';
            for idx=1:obj.mCodeInfo.OutStruct.NumPorts
                [str_init_temp,str_term_temp]=n_getSVFcnBody(obj.mCodeInfo.OutStruct.Port(idx),obj.SVStructEnabled,obj.SVScalarizePortsEnabled);
                if~isempty(str_init_temp)
                    str_init=sprintf('%s%s',str_init,str_init_temp);
                    str_term=sprintf('%s%s',str_term,str_term_temp);
                end
            end

            function[str_init_n,str_term_n]=n_getSVFcnBody(portInfo,SVStructEnabled,SVScalarizePortsEnabled)
                str_init_n='';
                str_term_n='';
                if~isempty(portInfo.StructInfo)
                    for idx_n=1:length(portInfo.StructInfo)
                        [str_init_n_temp,str_term_n_temp]=n_getSVFcnBody(portInfo.StructInfo(num2str(idx_n)),SVStructEnabled,SVScalarizePortsEnabled);
                        if~isempty(str_init_n_temp)
                            str_init_n=sprintf('%s%s',str_init_n,str_init_n_temp);
                            str_term_n=sprintf('%s%s',str_term_n,str_term_n_temp);
                        end
                    end
                else
                    str_init_n=portInfo.getSVAutoVarDecl4SVWrapperFcn(SVScalarizePortsEnabled);
                    str_term_n=portInfo.getSVAutoVars2SVWrapperFcnOutput(SVStructEnabled,SVScalarizePortsEnabled);
                end
            end
        end
    end

    methods(Static)
        function str=getPackageCode(PackageSection,dpiModuleName)
            switch PackageSection
            case 'DeclStart'
                str=sprintf('%s %s;','package',dpiModuleName);
            case 'DeclEnd'
                str=sprintf('%s : %s','endpackage',dpiModuleName);
            case 'Import'
                str=sprintf('%s %s::*;','import',dpiModuleName);
            otherwise
            end
        end

        function str=getPackageFileSuffix()
            str='_pkg';
        end



        function[str,EnumTypeMap]=getEnumDef(str,portInfo,EnumTypeMap)
            if portInfo.IsEnum

                if~isKey(EnumTypeMap,portInfo.getSVEnumType())
                    str=sprintf('%s%s\n',str,portInfo.getSVEnumDecl());
                    EnumTypeMap(portInfo.getSVEnumType())=[];
                end
            elseif~isempty(portInfo.StructInfo)


                for n_idx=1:length(portInfo.StructInfo)

                    [str,EnumTypeMap]=dpig.internal.GetSVFcn.getEnumDef(str,portInfo.StructInfo(num2str(n_idx)),EnumTypeMap);
                end
            end
        end


        function[StructName2DefMap,StructName2StructDependencies]=getStructDef(portInfo,CStructDataType,StructName2DefMap,StructName2StructDependencies,IsScalarizePortsEnabled)

            if~isempty(portInfo.StructInfo)
                if~isKey(StructName2DefMap,portInfo.SVDataType)
                    StructName2StructDependencies(portInfo.SVDataType)={};

                    if portInfo.IsComplex
                        StructName2DefMap(portInfo.SVDataType)=sprintf(['/*Simulink signal name: ''%s'' Complex Signal Name: ''%s''*/\n',...
                        'typedef struct{\n'],portInfo.Name,portInfo.SVDataType);
                    else
                        StructName2DefMap(portInfo.SVDataType)=sprintf(['/*Simulink signal name: ''%s'' Bus Object Name: ''%s''*/\n',...
                        'typedef struct{\n'],portInfo.Name,portInfo.SVDataType);
                    end

                    for n_idx=1:length(portInfo.StructInfo)


                        if~isempty(portInfo.StructInfo(num2str(n_idx)).StructInfo)
                            struct_type=portInfo.StructInfo(num2str(n_idx)).SVDataType;
                            struct_dim=portInfo.StructInfo(num2str(n_idx)).Dim;










                            if~any(strcmp(struct_type,StructName2StructDependencies(portInfo.SVDataType)))

                                StructName2StructDependencies(portInfo.SVDataType)=[StructName2StructDependencies(portInfo.SVDataType),{struct_type}];
                            end

                            if struct_dim>1
                                if IsScalarizePortsEnabled
                                    str=sprintf(['%s',...
                                    '\t/* Simulink signal name: ''%s'' */\n'],...
                                    StructName2DefMap(portInfo.SVDataType),...
                                    portInfo.StructInfo(num2str(n_idx)).Name);
                                    for idx=1:struct_dim
                                        str=[str,sprintf('\t%s %s_%s;\n',...
                                        struct_type,portInfo.StructInfo(num2str(n_idx)).Name,num2str(idx-1))];%#ok<AGROW>
                                    end
                                    StructName2DefMap(portInfo.SVDataType)=str;
                                else
                                    StructName2DefMap(portInfo.SVDataType)=sprintf(['%s',...
                                    '\t/* Simulink signal name: ''%s'' */\n',...
                                    '\t%s %s [%s];\n'],...
                                    StructName2DefMap(portInfo.SVDataType),...
                                    portInfo.StructInfo(num2str(n_idx)).Name,...
                                    struct_type,portInfo.StructInfo(num2str(n_idx)).Name,num2str(struct_dim));
                                end
                            else
                                StructName2DefMap(portInfo.SVDataType)=sprintf(['%s',...
                                '\t/* Simulink signal name: ''%s'' */\n',...
                                '\t%s %s;\n'],...
                                StructName2DefMap(portInfo.SVDataType),...
                                portInfo.StructInfo(num2str(n_idx)).Name,...
                                struct_type,portInfo.StructInfo(num2str(n_idx)).Name);
                            end
                        end
                        [StructName2DefMap,StructName2StructDependencies]=dpig.internal.GetSVFcn.getStructDef(portInfo.StructInfo(num2str(n_idx)),portInfo.SVDataType,StructName2DefMap,StructName2StructDependencies,IsScalarizePortsEnabled);
                    end

                    StructName2DefMap(portInfo.SVDataType)=sprintf(['%s',...
                    '}%s;\n'],StructName2DefMap(portInfo.SVDataType),portInfo.SVDataType);
                end

            else
                type=portInfo.SVDataType;
                dim=portInfo.Dim;
                if dim>1
                    if IsScalarizePortsEnabled
                        str=sprintf(['%s',...
                        '\t/* Simulink signal name: ''%s'' */\n'],...
                        StructName2DefMap(CStructDataType),...
                        portInfo.Name);
                        for idx=1:dim
                            str=[str,sprintf('\t%s %s_%s;\n',...
                            type,portInfo.Name,num2str(idx-1))];%#ok<AGROW>
                        end
                        StructName2DefMap(CStructDataType)=str;
                    else
                        StructName2DefMap(CStructDataType)=sprintf(['%s',...
                        '\t/* Simulink signal name: ''%s'' */\n',...
                        '\t%s %s [%s];\n'],...
                        StructName2DefMap(CStructDataType),...
                        portInfo.Name,...
                        type,portInfo.Name,num2str(dim));
                    end
                else
                    StructName2DefMap(CStructDataType)=sprintf(['%s',...
                    '\t/* Simulink signal name: ''%s'' */\n',...
                    '\t%s %s;\n'],...
                    StructName2DefMap(CStructDataType),...
                    portInfo.Name,...
                    type,portInfo.Name);
                end
            end
        end


        function str=printStructDef(StructName2DefMap,StructName2StructDependencies)
            str='';

            if isempty(StructName2DefMap)
                UndeclaredStruct=containers.Map;
            else
                UndeclaredStruct=containers.Map(keys(StructName2DefMap),cell(length(StructName2DefMap),1));
            end
            DeclaredStructs=containers.Map;
            Count=0;
            while~isempty(UndeclaredStruct)
                TempUndeclaredStruct=keys(UndeclaredStruct);
                CountLimit=length(UndeclaredStruct);



                if isempty(StructName2StructDependencies(TempUndeclaredStruct{end-Count}))||all(isKey(DeclaredStructs,StructName2StructDependencies(TempUndeclaredStruct{end-Count})))

                    str=sprintf('%s%s\n',str,StructName2DefMap(TempUndeclaredStruct{end-Count}));

                    DeclaredStructs(TempUndeclaredStruct{end-Count})=[];

                    remove(UndeclaredStruct,TempUndeclaredStruct{end-Count});

                    Count=0;
                else
                    Count=Count+1;
                    assert(Count<CountLimit,'Unable to determine non-virtual bus dependencies');
                end
            end
        end
    end
end

function str=l_getFcnInputArgDeclList(obj)
    str=sprintf('input chandle objhandle,\n');
    for idx=1:obj.mCodeInfo.InStruct.NumPorts
        [arg,~]=l_getFcnPortArgs(obj.mCodeInfo.InStruct.Port(idx),false,'input',false,obj.IdInterfacePrefix,false,'',false,false);
        str=[str,arg];%#ok<AGROW>
    end
end



function str=l_getFcnInputArgDeclList_uf(obj)
    str=sprintf('input chandle objhandle,\n');
    for idx=1:obj.mCodeInfo.InStruct.NumPorts
        [arg,~]=l_getFcnPortArgs(obj.mCodeInfo.InStruct.Port(idx),false,'input',false,obj.IdInterfacePrefix,false,'',obj.SVStructEnabled,obj.SVScalarizePortsEnabled);
        str=[str,arg];%#ok<AGROW>
    end
end

function str=l_getFcnParamArgDeclList(~,ParamInfo)
    str=sprintf('input chandle objhandle,\n');
    [arg,~]=l_getFcnPortArgs(ParamInfo,false,'input',false,'',false,'',false,false);
    str=[str,arg];
end

function str=l_getFcnParamArgDeclList_uf(obj,ParamInfo,IsSVScalarizePortsEnabled)
    str=sprintf('input chandle objhandle,\n');
    [arg,~]=l_getFcnPortArgs(ParamInfo,false,'input',false,'',false,'',obj.SVStructEnabled,IsSVScalarizePortsEnabled);
    str=[str,arg];
end



function str=l_getFcnTestPointArgDeclList(~,TestPointInfo)
    [str,~]=l_getFcnPortArgs(TestPointInfo,false,'output',false,'',false,'',false,false);
end

function str=l_getFcnTestPointArgDeclList_uf(obj,TestPointInfo,IsSVScalarizePortsEnabled)
    [str,~]=l_getFcnPortArgs(TestPointInfo,false,'output',false,'',false,'',obj.SVStructEnabled,IsSVScalarizePortsEnabled);
end


function str=l_getFcnOutputArgDeclList(obj,IsSVDPITB)
    str='';
    dir='output';
    for idx=1:obj.mCodeInfo.OutStruct.NumPorts
        [arg,~]=l_getFcnPortArgs(obj.mCodeInfo.OutStruct.Port(idx),false,dir,IsSVDPITB,obj.IdInterfacePrefix,false,'',false,false);
        str=[str,arg];%#ok<AGROW>
    end
end



function str=l_getFcnOutputArgDeclList_uf(obj,IsSVDPITB)
    str='';
    dir='output';
    for idx=1:obj.mCodeInfo.OutStruct.NumPorts
        [arg,~]=l_getFcnPortArgs(obj.mCodeInfo.OutStruct.Port(idx),false,dir,IsSVDPITB,obj.IdInterfacePrefix,false,'',obj.SVStructEnabled,obj.SVScalarizePortsEnabled);
        str=[str,arg];%#ok<AGROW>
    end
end


function str=l_getFcnInputArgCallList(obj,wrapper_uf2f)
    str=sprintf('objhandle,\n');
    for idx=1:obj.mCodeInfo.InStruct.NumPorts
        IsStructOrArrWithScalarEnabled=~isempty(obj.mCodeInfo.InStruct.Port(idx).StructInfo)...
        ||(obj.mCodeInfo.InStruct.Port(idx).Dim>1&&obj.SVScalarizePortsEnabled);
        if wrapper_uf2f&&IsStructOrArrWithScalarEnabled


            arg=l_getFcnPortArgs_uf2f(obj.mCodeInfo.InStruct.Port(idx),'uf2f_input_cl',obj.SVStructEnabled,obj.SVScalarizePortsEnabled);
        else
            if wrapper_uf2f


                IdInterfacePrefix='';
            else


                IdInterfacePrefix=obj.IdInterfacePrefix;
            end
            [arg,~]=l_getFcnPortArgs(obj.mCodeInfo.InStruct.Port(idx),false,'',false,IdInterfacePrefix,false,'',obj.SVStructEnabled,obj.SVScalarizePortsEnabled);
        end
        str=[str,arg];%#ok<AGROW>
    end
end

function str=l_getFcnPrmArgCallList(obj,ParamInfo,wrapper_uf2f,IsSVScalarizePortsEnabled)
    str='objhandle,';


    IsStruct=~isempty(ParamInfo.StructInfo);
    if wrapper_uf2f&&IsStruct


        arg=l_getFcnPortArgs_uf2f(ParamInfo,'uf2f_input_cl',obj.SVStructEnabled,IsSVScalarizePortsEnabled);
    else
        if wrapper_uf2f


            IdInterfacePrefix='';
        else


            IdInterfacePrefix=obj.IdInterfacePrefix;
        end
        [arg,~]=l_getFcnPortArgs(ParamInfo,false,'',false,IdInterfacePrefix,false,'',obj.SVStructEnabled,IsSVScalarizePortsEnabled);
    end
    str=[str,arg];
end


function str=l_getFcnTestPointArgCallList(obj,TestPointInfo,wrapper_uf2f,IsSVScalarizePortsEnabled)
    IsStruct=~isempty(TestPointInfo.StructInfo);
    if wrapper_uf2f&&IsStruct


        arg=l_getFcnPortArgs_uf2f(TestPointInfo,'uf2f_output_cl',obj.SVStructEnabled,IsSVScalarizePortsEnabled);
    else

        IdInterfacePrefix='';
        [arg,~]=l_getFcnPortArgs(TestPointInfo,false,'',false,IdInterfacePrefix,false,'',obj.SVStructEnabled,IsSVScalarizePortsEnabled);
    end
    str=arg;
end


function str=l_getFcnOutputArgCallList(obj,IsSVDPITB,wrapper_uf2f)
    str='';
    for idx=1:obj.mCodeInfo.OutStruct.NumPorts
        IsStructOrArrWithScalarEnabled=~isempty(obj.mCodeInfo.OutStruct.Port(idx).StructInfo)...
        ||(obj.mCodeInfo.OutStruct.Port(idx).Dim>1&&obj.SVScalarizePortsEnabled);
        if wrapper_uf2f&&IsStructOrArrWithScalarEnabled


            arg=l_getFcnPortArgs_uf2f(obj.mCodeInfo.OutStruct.Port(idx),'uf2f_output_cl',obj.SVStructEnabled,obj.SVScalarizePortsEnabled);
        else
            if wrapper_uf2f


                IdInterfacePrefix='';
            else


                IdInterfacePrefix=obj.IdInterfacePrefix;
            end
            [arg,~]=l_getFcnPortArgs(obj.mCodeInfo.OutStruct.Port(idx),false,'',IsSVDPITB,IdInterfacePrefix,obj.NeedsTempPostFix,obj.PostFix,obj.SVStructEnabled,obj.SVScalarizePortsEnabled);
        end
        str=[str,arg];%#ok<AGROW>
    end
end







function[arg_str,portDataTypeList]=l_getFcnPortArgs(portInfo,isList,Direction,IsSVDPITB,Prefix,NeedsTempPostFix,PostFix,SVStructEnabled,SVScalarizePortsEnabled)

    if isList
        arg_str={};
    else
        arg_str='';
    end
    portDataTypeList={};

    IsStruct=~isempty(portInfo.StructInfo);
    IsStructThatRequiresFlattening=IsStruct&&~SVStructEnabled;

    if IsStructThatRequiresFlattening
        for idx=1:length(portInfo.StructInfo)
            [arg_str_temp,portDataTypeList_temp]=l_getFcnPortArgs(portInfo.StructInfo(num2str(idx)),isList,Direction,IsSVDPITB,Prefix,NeedsTempPostFix,PostFix,SVStructEnabled,SVScalarizePortsEnabled);
            arg_str=[arg_str,arg_str_temp];%#ok<AGROW>
            portDataTypeList=[portDataTypeList,portDataTypeList_temp];%#ok<AGROW> 
        end
    else

        TempPostFix='';

        portDataTypeList=portInfo.SVDataType;
        IsArrayOfStructs=~isempty(portInfo.StructFieldInfo)&&nnz(portInfo.StructFieldInfo.TopStructDim>1)>0;
        IsPortAnArray=portInfo.Dim>1;

        if(IsSVDPITB||NeedsTempPostFix)
            TempPostFix=PostFix;
        end


        if IsStruct
            PortName=portInfo.Name;
        elseif SVScalarizePortsEnabled&&IsArrayOfStructs
            PortName=portInfo.FlatName_uf2f('uf2f_flat_scalar_cl',SVStructEnabled,SVScalarizePortsEnabled);
        else
            PortName=portInfo.FlatName;
        end

        if isList
            if SVScalarizePortsEnabled&&IsArrayOfStructs
                arg_str={PortName};
            else
                arg_str=PortName;
            end
        elseif isempty(Direction)
            if SVScalarizePortsEnabled&&(IsPortAnArray||IsArrayOfStructs)
                if IsArrayOfStructs
                    arg_str=sprintf(char(join(cellfun(@(name)sprintf('%s, ',[Prefix,name,TempPostFix]),PortName,'UniformOutput',false),'')));
                else
                    dim=portInfo.Dim;
                    for idx=1:dim
                        arg_str=[arg_str,sprintf('%s, ',[Prefix,PortName,'_',num2str(idx-1),TempPostFix])];%#ok<AGROW>
                    end
                end
            else
                arg_str=sprintf('%s, ',[Prefix,PortName,TempPostFix]);
            end
        else
            if contains(portInfo.FlatNamePrefix,'Param')
                sl_comp='parameter name';
            else
                sl_comp='signal name';
            end
            if SVScalarizePortsEnabled&&(IsPortAnArray||IsArrayOfStructs)
                arg_str=sprintf(['/*Simulink ',sl_comp,': ''%s''*/\n',],portInfo.Name);
                temp_SVPortDecl=l_getSVPortDecl(portInfo,'',TempPostFix,IsStruct,SVScalarizePortsEnabled);
                for idx=1:numel(temp_SVPortDecl)
                    arg_str=[arg_str,sprintf('%s %s %s,\n',Direction,portInfo.SVDataType,temp_SVPortDecl{idx})];%#ok<AGROW>
                end
            else
                arg_str=sprintf(['/*Simulink ',sl_comp,': ''%s''*/\n','%s %s %s,\n'],portInfo.Name,Direction,portInfo.SVDataType,l_getSVPortDecl(portInfo,'',TempPostFix,IsStruct,SVScalarizePortsEnabled));
            end
        end
    end
end


function arg_str=l_getFcnPortArgs_uf2f(portInfo,Ctx,SVStructEnabled,SVScalarizePortsEnabled)
    IsStruct=~isempty(portInfo.StructInfo);
    arg_str='';
    if IsStruct
        for idx=1:length(portInfo.StructInfo)
            arg_str_temp=l_getFcnPortArgs_uf2f(portInfo.StructInfo(num2str(idx)),Ctx,SVStructEnabled,SVScalarizePortsEnabled);
            arg_str=[arg_str,arg_str_temp];%#ok<AGROW>
        end
    else
        arg_str=sprintf(['%s,',char(32)],portInfo.FlatName_uf2f(Ctx,SVStructEnabled,SVScalarizePortsEnabled));
    end
end

function arg_str=l_getInputArgForEventExpression(portInfo,SVStructEnabled,SVScalarizePortsEnabled,IdInterfacePrefix)
    IsStructWithStructEnabled=~isempty(portInfo.StructInfo)&&SVStructEnabled;
    IsArrWithScalarEnabled=portInfo.Dim>1&&SVScalarizePortsEnabled;
    IsArrOfStructsWithScalarEnabled=~isempty(portInfo.StructFieldInfo)&&nnz(portInfo.StructFieldInfo.TopStructDim>1)>0&&SVScalarizePortsEnabled;
    if IsStructWithStructEnabled||IsArrWithScalarEnabled||IsArrOfStructsWithScalarEnabled

        arg_str=l_getInputArgForEventExpression_structOrScalarArr(portInfo,SVStructEnabled,SVScalarizePortsEnabled,IdInterfacePrefix);
    else
        arg_str=l_getInputArgForEventExpression_flat(portInfo,SVStructEnabled,SVScalarizePortsEnabled,IdInterfacePrefix);
    end
end




function arg_str=l_getInputArgForEventExpression_structOrScalarArr(portInfo,SVStructEnabled,SVScalarizePortsEnabled,IdInterfacePrefix)
    IsStruct=~isempty(portInfo.StructInfo);
    arg_str='';
    if IsStruct
        for idx=1:length(portInfo.StructInfo)
            arg_str_temp=l_getInputArgForEventExpression_structOrScalarArr(portInfo.StructInfo(num2str(idx)),SVStructEnabled,SVScalarizePortsEnabled,IdInterfacePrefix);
            arg_str=[arg_str,arg_str_temp];%#ok<AGROW>
        end
    else
        arg_str=sprintf('%s or ',portInfo.FlatName_uf2f('comb_event_express',SVStructEnabled,SVScalarizePortsEnabled,IdInterfacePrefix));
    end
end

function arg_str=l_getInputArgForEventExpression_flat(portInfo,SVStructEnabled,SVScalarizePortsEnabled,IdInterfacePrefix)
    arg_str='';
    IsStruct=~isempty(portInfo.StructInfo);
    IsStructThatRequiresFlattening=IsStruct&&~SVStructEnabled;

    if IsStructThatRequiresFlattening
        for idx=1:length(portInfo.StructInfo)
            arg_str_temp=l_getInputArgForEventExpression_flat(portInfo.StructInfo(num2str(idx)),SVStructEnabled,SVScalarizePortsEnabled,IdInterfacePrefix);
            arg_str=[arg_str,arg_str_temp];%#ok<AGROW>
        end
    else
        IsArrayOfStructs=~isempty(portInfo.StructFieldInfo)&&nnz(portInfo.StructFieldInfo.TopStructDim>1)>0;
        IsPortAnArray=portInfo.Dim>1;
        PortName=portInfo.FlatName;
        if IsArrayOfStructs
            Dim=prod([portInfo.StructFieldInfo.TopStructDim,portInfo.Dim]);
        elseif IsPortAnArray
            Dim=portInfo.Dim;
        end
        if IsArrayOfStructs||IsPortAnArray
            for idx=1:Dim
                if SVScalarizePortsEnabled
                    arg_str=sprintf('%s%s_%d or ',arg_str,[IdInterfacePrefix,PortName],idx-1);
                else
                    arg_str=sprintf('%s%s[%d] or ',arg_str,[IdInterfacePrefix,PortName],idx-1);
                end
            end
        else
            arg_str=sprintf('%s or ',[IdInterfacePrefix,PortName]);
        end
    end
end


function str=l_getPortDecl(portInfo,Direction,Indentation,IsSVDPITB,Separator,NeedTempPostFix,PostFix,SVStructEnabled,SVScalarizePortsEnabled)





    IsStruct=~isempty(portInfo.StructInfo);
    IsStructThatRequiresFlattening=IsStruct&&~SVStructEnabled;

    if IsStructThatRequiresFlattening

        if~isa(portInfo,'dpig.internal.TestPointPortInfo')
            if portInfo.IsComplex
                str=sprintf([repmat('\t',1,Indentation),'/* Simulink signal name: ''%s'' Complex Signal Name: ''%s'' */\n'],portInfo.Name,portInfo.DataType);
            else
                str=sprintf([repmat('\t',1,Indentation),'/* Simulink signal name: ''%s'' Bus Object Name: ''%s'' */\n'],portInfo.Name,portInfo.DataType);
            end
        else
            str='';
        end

        for idx=1:length(portInfo.StructInfo)
            str_temp=l_getPortDecl(portInfo.StructInfo(num2str(idx)),Direction,Indentation+1,IsSVDPITB,Separator,NeedTempPostFix,PostFix,SVStructEnabled,SVScalarizePortsEnabled);
            str=[str,str_temp];%#ok<AGROW>
        end
    else
        if IsSVDPITB&&strcmpi(portInfo.SVDataType,'shortreal')

            type='int unsigned';
        else
            type=portInfo.SVDataType;
        end

        if NeedTempPostFix&&~IsSVDPITB
            TempPostFix=PostFix;
            str='';
            tab='';
        else
            TempPostFix='';
            str=sprintf([repmat('\t',1,Indentation),'/* Simulink signal name: ''%s'' */\n'],portInfo.Name);
            tab='\t';
        end

        dim=portInfo.Dim;
        IsVectorOfBuses=~isempty(portInfo.StructFieldInfo)&&nnz(portInfo.StructFieldInfo.TopStructDim>1)>0;
        if IsStruct


            if dim>1
                if SVScalarizePortsEnabled
                    for idx=1:dim
                        str=sprintf(['%s',repmat(tab,1,Indentation),'%s %s %s%s\n'],...
                        str,Direction,type,[portInfo.Name,'_',num2str(idx-1),TempPostFix],Separator);
                    end
                else
                    str=sprintf(['%s',repmat(tab,1,Indentation),'%s %s %s [%d:%d]%s\n'],str,Direction,type,[portInfo.Name,TempPostFix],0,dim-1,Separator);
                end
            else
                str=sprintf(['%s',repmat(tab,1,Indentation),'%s %s %s %s\n'],str,Direction,type,[portInfo.Name,TempPostFix],Separator);
            end
        else
            if dim>1||IsVectorOfBuses
                if SVScalarizePortsEnabled
                    if IsVectorOfBuses
                        portNames=portInfo.FlatName_uf2f('uf2f_flat_scalar_cl',false,SVScalarizePortsEnabled);
                        for idx=1:l_GetFlattenedPortDimensions(dim,portInfo.StructFieldInfo)
                            str=sprintf(['%s',repmat(tab,1,Indentation),'%s %s %s%s\n'],...
                            str,Direction,type,[portNames{idx},TempPostFix],...
                            Separator);
                        end
                    else
                        for idx=1:dim
                            str=sprintf(['%s',repmat(tab,1,Indentation),'%s %s %s%s\n'],...
                            str,Direction,type,[portInfo.FlatName,'_',num2str(idx-1),TempPostFix],...
                            Separator);
                        end
                    end
                else
                    str=sprintf(['%s',repmat(tab,1,Indentation),'%s %s %s [%d:%d]%s\n'],str,Direction,type,[portInfo.FlatName,TempPostFix],0,l_GetFlattenedPortDimensions(dim,portInfo.StructFieldInfo)-1,Separator);
                end
            else
                str=sprintf(['%s',repmat(tab,1,Indentation),'%s %s %s %s\n'],str,Direction,type,[portInfo.FlatName,TempPostFix],Separator);
            end
        end
    end
end

function FlattenDims=l_GetFlattenedPortDimensions(LeafDims,StructFieldInfo)
    if isempty(StructFieldInfo)

        FlattenDims=LeafDims;
    else



        FlattenDims=prod([LeafDims,StructFieldInfo.TopStructDim]);
    end
end

function SVPortDecl=l_getSVPortDecl(portInfo,Prefix,SVDPIPostfix,IsStruct,IsScalarizePortsEnabled)


    if IsStruct


        if portInfo.Dim>1
            if IsScalarizePortsEnabled
                for idx=1:portInfo.Dim
                    SVPortDecl{idx}=sprintf('%s_%s',portInfo.Name,num2str(idx-1));%#ok<AGROW>
                end
            else
                SVPortDecl=sprintf('%s [%s]',portInfo.Name,num2str(portInfo.Dim));
            end
        else
            SVPortDecl=portInfo.Name;
        end
    else
        IsVectorOfBuses=~isempty(portInfo.StructFieldInfo)&&nnz(portInfo.StructFieldInfo.TopStructDim>1)>0;

        if portInfo.Dim>1||IsVectorOfBuses

            if IsScalarizePortsEnabled
                if IsVectorOfBuses
                    PortNames=portInfo.FlatName_uf2f('uf2f_flat_scalar_cl',false,IsScalarizePortsEnabled);
                    SVPortDecl=cellfun(@(name)[Prefix,name,SVDPIPostfix],PortNames,'UniformOutput',false);
                else
                    for idx=1:portInfo.Dim
                        SVPortDecl{idx}=[Prefix,portInfo.FlatName,'_',num2str(idx-1),SVDPIPostfix];%#ok<AGROW>
                    end
                end
            else
                SVPortDecl=[[Prefix,portInfo.FlatName,SVDPIPostfix],' [',num2str(l_GetFlattenedPortDimensions(portInfo.Dim,portInfo.StructFieldInfo)),']'];
            end
        else

            SVPortDecl=[Prefix,portInfo.FlatName,SVDPIPostfix];
        end
    end
end

function[IsSVDPITB,RemoveCtrlSigs,NeedsTempPostFix]=l_processThreeOptionalArg(optionalArgs)












    numvarargs=length(optionalArgs);
    if numvarargs>3
        error('Too many optional arguments');
    end

    optarg={false,false,true};

    optarg(1:numvarargs)=optionalArgs;

    IsSVDPITB=optarg{1};
    RemoveCtrlSigs=optarg{2};
    NeedsTempPostFix=optarg{3};
end

function str=l_getNBVarAssignmentFromTmpToActual(portInfo,PostFixOfTempVars,SVStructEnabled,SVScalarizePortsEnabled)

    IsStruct=~isempty(portInfo.StructInfo);
    IsStructThatRequiresFlattening=IsStruct&&~SVStructEnabled;

    IsArrayOfStructs=~isempty(portInfo.StructFieldInfo)&&nnz(portInfo.StructFieldInfo.TopStructDim>1)>0;
    IsPortAnArray=portInfo.Dim>1;


    str='';
    if IsStructThatRequiresFlattening
        for idx=1:length(portInfo.StructInfo)
            str_t=l_getNBVarAssignmentFromTmpToActual(portInfo.StructInfo(num2str(idx)),PostFixOfTempVars,SVStructEnabled,SVScalarizePortsEnabled);
            str=sprintf('%s%s',str,str_t);
        end
    else
        if IsStruct

            if SVScalarizePortsEnabled&&(IsPortAnArray||IsArrayOfStructs)
                for idx=1:portInfo.Dim
                    str=[str,sprintf('%s_%d<=%s;\n',...
                    portInfo.Name,idx-1,[portInfo.Name,'_',num2str(idx-1),PostFixOfTempVars])];%#ok<AGROW>
                end
            else
                str=sprintf('%s<=%s;\n',portInfo.Name,[portInfo.Name,PostFixOfTempVars]);
            end
        else
            if SVScalarizePortsEnabled&&(IsPortAnArray||IsArrayOfStructs)
                if IsArrayOfStructs
                    portNames=portInfo.FlatName_uf2f('uf2f_flat_scalar_cl',false,SVScalarizePortsEnabled);
                    for idx=1:l_GetFlattenedPortDimensions(portInfo.Dim,portInfo.StructFieldInfo)
                        str=[str,sprintf('%s<=%s;\n',...
                        portNames{idx},[portNames{idx},PostFixOfTempVars])];%#ok<AGROW>
                    end
                else
                    for idx=1:portInfo.Dim
                        str=[str,sprintf('%s_%d<=%s;\n',...
                        portInfo.FlatName,idx-1,[portInfo.FlatName,'_',num2str(idx-1),PostFixOfTempVars])];%#ok<AGROW>
                    end
                end
            else
                str=sprintf('%s<=%s;\n',portInfo.FlatName,[portInfo.FlatName,PostFixOfTempVars]);
            end
        end
    end
end




