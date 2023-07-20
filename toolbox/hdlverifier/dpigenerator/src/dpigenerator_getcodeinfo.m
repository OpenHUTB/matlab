function SystemInfo=dpigenerator_getcodeinfo(cmd)


    mlock;
    persistent DPIInfo;

    if nargin==1&&strcmpi(cmd,'get')
        SystemInfo=DPIInfo;
        return;
    end

    load codeInfo;


    cs=getActiveConfigSet(bdroot);
    pp=cs.getPropOwner('DPIGenerateTestBench');

    if~strcmp(pp.getProp('DPITestPointAccessFcnInterface'),'None')


        assert(strcmp(get_param(bdroot,'RTWCAPISignals'),'on'),message('HDLLink:DPIG:NeedToEnableCAPIForLogging'));
        BuildDir=RTW.getBuildDir(codeInfo.Name);
        load(fullfile(BuildDir.CodeGenFolder,BuildDir.ModelRefRelativeBuildDir,'tmwinternal','capi.mat'));
    else

        CAPIData=0;
    end
    SystemInfo.Name=codeInfo.Name;


    SystemInfo.CombineOutputUpdateFcns=strcmp(cs.getProp('CombineOutputUpdateFcns'),'on');


    SystemInfo.InterfaceInfo=struct('IsInterfaceEnabled',false,...
    'InterfaceId','',...
    'InterfaceType','');

    SystemInfo.CtrlSigStruct=struct('CtrlType',{'Clock','Clock_Enable','Reset'},...
    'Name',{'clk','clk_enable','reset'},...
    'SVDataType',{'bit','bit','bit'});

    SystemInfo.InStruct.Name='';
    SystemInfo.InStruct.DataType='';
    SystemInfo.InStruct.NumPorts=0;

    SystemInfo.OutStruct.Name='';
    SystemInfo.OutStruct.DataType='';
    SystemInfo.OutStruct.NumPorts=0;

    SystemInfo.ParamStruct.Name='';
    SystemInfo.ParamStruct.DataType='';
    SystemInfo.ParamStruct.NumPorts=0;

    SystemInfo.TestPointStruct.NumTestPoints=0;

    SystemInfo.IsContinuous=0;


    TempBaseRateArray=[];
    for idx=1:numel(codeInfo.TimingProperties)
        if strcmpi(codeInfo.TimingProperties(idx).TimingMode,'CONTINUOUS')
            SystemInfo.IsContinuous=1;
            break;
        end
        if strcmpi(codeInfo.TimingProperties(idx).TimingMode,'PERIODIC')
            Tm=TempBaseRateArray;
            TempBaseRateArray=[Tm,codeInfo.TimingProperties(idx).SamplePeriod];
        end

        assert(~strcmp(codeInfo.TimingProperties(idx).TimingMode,'ASYNCHRONOUS'),message('HDLLink:DPIG:AsyncTMNotSupported'));
    end
    SystemInfo.BaseRate=min(TempBaseRateArray);

    for idx=0:numel(codeInfo.InternalData)
        try



            if idx==0
                SystemInfo.TestPointStruct=l_getTestPointInfo(CAPIData,pp);
                SystemInfo.ParamStruct=l_ParamStructInfo(codeInfo);
                continue;
            end

            if(isa(codeInfo.InternalData(idx).Implementation,'RTW.PointerExpression'))
                iH=codeInfo.InternalData(idx).Implementation.TargetRegion;
            elseif(isa(codeInfo.InternalData(idx).Implementation,'RTW.PointerVariable'))
                iH=codeInfo.InternalData(idx).Implementation.TargetVariable;
            else
                iH=codeInfo.InternalData(idx).Implementation;
            end
            gName=codeInfo.InternalData(idx).GraphicalName;
            switch gName
            case 'ExternalInput'
                SystemInfo.InStruct=l_getStructInfo(iH,codeInfo.Inports,SystemInfo.BaseRate);
            case 'ExternalOutput'
                SystemInfo.OutStruct=l_getStructInfo(iH,codeInfo.Outports,SystemInfo.BaseRate);
            otherwise




            end
        catch ME
            throw(ME);
        end
    end


    allPortNames={};
    if SystemInfo.InStruct.NumPorts>0
        allPortNames=[allPortNames,{SystemInfo.InStruct.Port.Name}];
    end
    if SystemInfo.OutStruct.NumPorts>0
        allPortNames=[allPortNames,{SystemInfo.OutStruct.Port.Name}];
    end
    if length(unique(allPortNames))~=length(allPortNames)
        error(message('HDLLink:DPIG:DuplicatePortNames',SystemInfo.Name,sprintf('\t%s\n',allPortNames{:})));
    end

    SystemInfo.PortRate=min(dpigenerator_getvariable('InputAndOutputSamplePeriods'));


    if(SystemInfo.InStruct.NumPorts==0)&&(SystemInfo.OutStruct.NumPorts==0)
        error(message('HDLLink:DPIG:NoPort',SystemInfo.Name));
    end

    if(SystemInfo.InStruct.NumPorts==0)&&strcmpi(pp.getProp('DPIComponentTemplateType'),'combinational')
        error(message('HDLLink:DPIG:CombTemplateNoInput',SystemInfo.Name));
    end

    if any(arrayfun(@(x)strcmp(x.Timing.TimingMode,'RESET'),codeInfo.OutputFunctions))




        warning(message('HDLLink:DPIG:ResetFunctionBlock'));
    end


    OutFcnObj=codeInfo.OutputFunctions(arrayfun(@(x)~strcmp(x.Timing.TimingMode,'RESET'),codeInfo.OutputFunctions));

    SystemInfo.AllocateFcn=l_getFuncInfo(codeInfo.AllocationFunction);
    SystemInfo.InitializeFcn=l_getFuncInfo(codeInfo.InitializeFunctions);
    SystemInfo.ResetFcn=l_getResetFuncInfo(OutFcnObj);
    SystemInfo.OutputFcn=l_getFuncInfo(OutFcnObj);
    SystemInfo.UpdateFcn=l_getFuncInfo(codeInfo.UpdateFunctions);
    SystemInfo.TerminateFcn=l_getFuncInfo(codeInfo.TerminateFunctions);
    SystemInfo.RunTimeErrorFcn=l_getRunTimeErrorFuncInfo(codeInfo.AllocationFunction,pp);
    SystemInfo.StopSimFcn=l_getStopSimFuncInfo(codeInfo.Name,codeInfo.AllocationFunction);

    if strcmpi(pp.getProp('DPICompositeDataType'),'structure')||strcmpi(pp.getProp('DPIScalarizePorts'),'on')

        uf_suffix='_f';
        SystemInfo.ResetFcn.DPIName=[SystemInfo.ResetFcn.DPIName,uf_suffix];
        SystemInfo.OutputFcn.DPIName=[SystemInfo.OutputFcn.DPIName,uf_suffix];
        if~isempty(SystemInfo.UpdateFcn)
            SystemInfo.UpdateFcn.DPIName=[SystemInfo.UpdateFcn.DPIName,uf_suffix];
        end
    end


    for Paramidx=1:SystemInfo.ParamStruct.NumPorts
        SystemInfo.SetParamFcn(Paramidx).Name=[codeInfo.Name,'_setparam_',SystemInfo.ParamStruct.Port(Paramidx).Name];
        if strcmpi(pp.getProp('DPICompositeDataType'),'structure')
            SystemInfo.SetParamFcn(Paramidx).DPIName=['DPI_',codeInfo.Name,'_setparam_',SystemInfo.ParamStruct.Port(Paramidx).Name,'_f'];
        else
            SystemInfo.SetParamFcn(Paramidx).DPIName=['DPI_',codeInfo.Name,'_setparam_',SystemInfo.ParamStruct.Port(Paramidx).Name];
        end
        SystemInfo.SetParamFcn(Paramidx).ReturnType='void';
        SystemInfo.SetParamFcn(Paramidx).ArgsType=SystemInfo.ParamStruct.Port(Paramidx).DataType;
    end



    DPIInfo=SystemInfo;
end





function structInfo=l_getStructInfo(rtwVarInfo,portInfo,SystemBaseRate)


    structInfo.Name=rtwVarInfo.Identifier;
    structInfo.DataType=rtwVarInfo.Type.Identifier;
    structInfo.NumPorts=int32(numel(rtwVarInfo.Type.Elements));


    structInfo.FlattenedDimensions=[];
    TempMapFlattenedDim=containers.Map;
    TempMapFlattenedDim('FlattenedDimensions')=[];

    StructFieldInfo=struct('TopStructFlatName',{},...
    'TopStructName',{},...
    'TopStructDim',[],...
    'ElementAccessIndexNumber',[],...
    'ElementAccessIndexVariable',{},...
    'TopStructIndexing',{},...
    'ElementAccess',{},...
    'TopStructType',{});

    StructFieldInfo(1).TopStructFlatName={};
    StructFieldInfo(1).TopStructName={};
    StructFieldInfo(1).TopStructDim=[];
    StructFieldInfo(1).ElementAccessIndexNumber=[];
    StructFieldInfo(1).ElementAccessIndexVariable={};
    StructFieldInfo(1).TopStructIndexing={};
    StructFieldInfo(1).ElementAccess={};
    StructFieldInfo(1).TopStructType={};

    SamplePeriodArray=[];
    PrevL=0;
    for ii=1:structInfo.NumPorts
        try

            TimingInfoStruct=l_getTimingInfoForPort(SystemBaseRate,portInfo(ii));

            structInfo.Name=l_getVariablePrefix(rtwVarInfo.Type.Elements(ii).Identifier,rtwVarInfo.Identifier);
            structInfo.Port(ii)=dpig.internal.PortInfo(rtwVarInfo.Type.Elements(ii).Type,...
            structInfo.Name,...
            rtwVarInfo.Type.Elements(ii).Identifier,...
            StructFieldInfo,...
            1,...
            TempMapFlattenedDim,...
            TimingInfoStruct.MultiRateCounter,...
            false);

            Tmp=SamplePeriodArray;
            SamplePeriodArray=[Tmp,TimingInfoStruct.SamplePeriod];
            structInfo.Port(ii).SamplePeriod=TimingInfoStruct.SamplePeriod;
            structInfo.Port(ii).SampleOffset=TimingInfoStruct.SampleOffset;
            structInfo.Port(ii).MultiRateCounter=TimingInfoStruct.MultiRateCounter;
            structInfo.Port(ii).NormalizedSamplePeriod=TimingInfoStruct.NormalizedSamplePeriod;
            structInfo.Port(ii).IsMultirate=TimingInfoStruct.IsMultirate;
            structInfo.Port(ii).FlatNumPorts=length(TempMapFlattenedDim('FlattenedDimensions'))-PrevL;
            PrevL=length(TempMapFlattenedDim('FlattenedDimensions'));
        catch ME
            l_me=MException('','port %s: %s',rtwVarInfo.Type.Elements(ii).Identifier,ME.message);
            l_me.addCause(ME);
            throw(l_me);
        end
    end
    structInfo.FlattenedDimensions=TempMapFlattenedDim('FlattenedDimensions');


    dpigenerator_setvariable('InputAndOutputSamplePeriods',[dpigenerator_getvariable('InputAndOutputSamplePeriods'),SamplePeriodArray]);
end

function fcn=l_getResetFuncInfo(codeInfoFcn)
    fcn=l_getFuncInfo(codeInfoFcn);

    fcn.Name='reset';
    [~,TempNameFlipped]=strtok(flip(fcn.DPIName),'_');
    fcn.DPIName=[flip(TempNameFlipped),'reset'];
end

function fcn=l_getFuncInfo(codeInfoFcn)
    if isempty(codeInfoFcn)
        fcn={};
        return;
    else
        fcn.Name=codeInfoFcn.Prototype.Name;
        fcn.DPIName=['DPI_',codeInfoFcn.Prototype.Name];

        if isempty(codeInfoFcn.ActualReturn)
            fcn.ReturnType='void';
        else
            fcn.ReturnType=codeInfoFcn.ActualReturn.Implementation.Type.BaseType.Identifier;
        end

        if isempty(codeInfoFcn.ActualArgs)
            fcn.ArgsType='void';
        else
            fcn.ArgsType=codeInfoFcn.ActualArgs.Implementation.Type.BaseType.Identifier;
        end


    end
end

function fcn=l_getRunTimeErrorFuncInfo(codeInfoFcn,pp)
    if strcmpi(pp.getProp('DPIReportRunTimeError'),'off')||isempty(codeInfoFcn)
        fcn={};
        return;
    else
        fcn.DPIName=['DPI_',codeInfoFcn.Prototype.Name,'_getErrMsg'];
        fcn.SVName=['SV_',codeInfoFcn.Prototype.Name,'_reportErrMsg'];
        if~isempty(codeInfoFcn.ActualArgs)
            fcn.ArgsType=codeInfoFcn.ActualArgs.Implementation.Type.BaseType.Identifier;
        end
        fcn.MsgName='errMsg';
        fcn.ReturnType='char_T*';
        fcn.Severity=pp.getProp('DPIRunTimeErrorSeverity');
    end

end

function fcn=l_getStopSimFuncInfo(Name,codeInfoFcn)
    fcn={};
    if hdlverifierfeature('IS_CODEGEN_FOR_UVMSEQ')
        fid=fopen([Name,'.h'],'rt');
        content=fscanf(fid,'%c');
        fclose(fid);
        if any(strfind(content,'rtmGetStopRequested'))
            fcn.DPIName=['DPI_',codeInfoFcn.Prototype.Name,'_getStopRequested'];
            fcn.SVName=['SV_',codeInfoFcn.Prototype.Name,'_getStopRequested'];
            fcn.ReturnType='boolean_T';
        end
    end
end

function structInfo=l_getTestPointInfo(CAPIData,pp)

    SubSysPath=dpigenerator_getvariable('dpigSubsystemPath');

    structInfo.AccessFcnInterface=pp.getProp('DPITestPointAccessFcnInterface');
    l_TestPointContainer=containers.Map;
    if~strcmp(structInfo.AccessFcnInterface,'None')

        structInfo.NumTestPoints=length(CAPIData.DataInterfaces);
    else
        structInfo.NumTestPoints=0;
        structInfo.TestPointContainer=l_TestPointContainer;
        return;
    end



    TestPointSID=cell(1,structInfo.NumTestPoints);
    TestPointRawSignalName=cell(1,structInfo.NumTestPoints);

    try
        for idx=1:structInfo.NumTestPoints
            TestPointInfo=dpig.internal.TestPointPortInfo(CAPIData.DataInterfaces(idx),SubSysPath);

            l_TestPointContainer(TestPointInfo.getCAPI_TestPointSID())=TestPointInfo;
            TestPointRawSignalName{idx}=TestPointInfo.RawSignalName;
            TestPointSID{idx}=TestPointInfo.getCAPI_TestPointSID();
        end


        l_MarkDuplicateTestPoints();

        structInfo.TestPointContainer=l_TestPointContainer;


        if~isempty(TestPointSID)
            dpigenerator_setvariable('TestPointContainer',l_TestPointContainer);
        else
            dpigenerator_setvariable('TestPointContainer',containers.Map);
        end
    catch ME
        l_me=MException('','Getting Test Point Info: %s',ME.message);
        throw(l_me);
    end
    function l_MarkDuplicateTestPoints()
        [~,uIdx]=unique(TestPointRawSignalName);
        DuplicateRawTestPoints=TestPointRawSignalName;
        DuplicateRawTestPoints(uIdx)=[];
        DuplicateRawTestPoints=unique(DuplicateRawTestPoints);

        for kcell=keys(l_TestPointContainer)

            keyval=kcell{1};
            if any(strcmp(l_TestPointContainer(keyval).RawSignalName,DuplicateRawTestPoints))
                TempCont=l_TestPointContainer(keyval);
                TempCont.Duplicate=true;
                l_TestPointContainer(keyval)=TempCont;
            end
        end

    end


end

function ParamStruct=l_ParamStructInfo(CodeInfo)

    ParamInfo=CodeInfo.Parameters(arrayfun(@(x)n_IsPrmOk(x),CodeInfo.Parameters));

    ParamStruct.NumPorts=numel(ParamInfo);


    for idx=1:numel(ParamInfo)
        ParamStruct.Port(idx)=dpig.internal.ParamPortInfo(CodeInfo,ParamInfo(idx));
    end

    function IsOk=n_IsPrmOk(prm)


























        NotSupportedPrm=['(',char(join({'Dialog:',...
        'SFunction:',...
        'ParameterArgument:',...
        'InstParameterArgument:',...
        'NonDialog:'},'(.*)|')),')'];

        if isempty(regexp(prm.GraphicalName,NotSupportedPrm,'ONCE'))
            IsOk=true;
        else
            IsOk=false;
            [PrmType,PrmName]=strtok(prm.GraphicalName,':');
            warning(message('HDLLink:DPIG:PrmTypeIsNotTunableInDPI',...
            PrmType,...
            flip(strtok(flip(PrmName),':'))));
        end
    end
end

function TimingInfoStruct=l_getTimingInfoForPort(SystemBaseRate,portInfo)

    TimingInfoStruct=struct('SamplePeriod',[],...
    'SampleOffset',[],...
    'MultiRateCounter',[],...
    'NormalizedSamplePeriod',[],...
    'IsMultirate',false);


    if~isempty(SystemBaseRate)



        TimingInfoStruct.SamplePeriod=portInfo.Timing.SamplePeriod;
        TimingInfoStruct.SampleOffset=portInfo.Timing.SampleOffset;
        if SystemBaseRate~=TimingInfoStruct.SamplePeriod



            TimingInfoStruct.MultiRateCounter=matlab.lang.makeValidName([strtok(portInfo.SID,':'),'_',portInfo.GraphicalName,'_Counter']);

            if portInfo.Timing.SamplePeriod==0


                TimingInfoStruct.NormalizedSamplePeriod=1;
            else
                TimingInfoStruct.NormalizedSamplePeriod=round(TimingInfoStruct.SamplePeriod/SystemBaseRate);
            end

            TimingInfoStruct.IsMultirate=true;
        else


            TimingInfoStruct.MultiRateCounter='';

            TimingInfoStruct.NormalizedSamplePeriod=[];

            TimingInfoStruct.IsMultirate=false;
        end
    end
end

function str=l_getVariablePrefix(PortName,RTWPrefix)

    SystemVerilogKeyWords={'always','ifnone','rpmos','and','initial','rtran','assign','inout','rtranif0','begin',...
    'input','rtranif1','buf','integer','scalared','bufif0','join','small','bufif1',...
    'large','specify','case','macromodule','specparam','casex','medium','strong0',...
    'casez','module','strong1','cmos','nand','supply0','deassign','negedge','supply1',...
    'default','nmos','table','defparam','nor','task','disable','not','time','edge','notif0',...
    'tran','else','notif1','tranif0','end','or','tranif1','endcase','output','tri','endmodule',...
    'parameter','tri0','endfunction','pmos','tri1','endprimitive','posedge','triand','endspecify',...
    'primitive','trior','endtable','pull0','trireg','endtask','pull1','vectored','event','pullup',...
    'wait','for','pulldown','wand','force','rcmos','weak0','forever','real','weak1','fork','realtime',...
    'while','function','reg','wire','highz0','release','wor','highz1','repeat','xnor','if','rnmos',...
    'xor'};
    C_Sufixes={'_initialize','_output','_reset','_update','_step','_Message','_Severity'};
    OtherTokensWithPotentialConflict={'A','DPI_getAssertionInfo'};


    if any(strcmp(PortName,SystemVerilogKeyWords))||(startsWith(PortName,'DPI_')&&endsWith(PortName,C_Sufixes))||...
        any(strcmp(PortName,OtherTokensWithPotentialConflict))



        str=RTWPrefix;
    else


        str='';
    end


end




