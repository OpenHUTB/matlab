function buildInfo=launchFILWithSLHDLC(codeGenInfo)
    validateDUT(codeGenInfo);
    buildInfo=eda.internal.workflow.FILBuildInfo;
    buildInfo.HDLSourceType='SLHDLCoder';


    buildInfo.DUTName=codeGenInfo.EntityTop;


    if strcmpi(codeGenInfo.target_language,'VHDL')
        lang='VHDL';
        ext=codeGenInfo.vhdl_file_ext;
    else
        lang='Verilog';
        ext=codeGenInfo.verilog_file_ext;
    end
    for n=1:numel(codeGenInfo.EntityFileNames)
        buildInfo.addSourceFile(fullfile(codeGenInfo.codegendir,...
        codeGenInfo.EntityFileNames{n}),lang);
    end


    idx=find(strcmp([codeGenInfo.EntityTop,ext],codeGenInfo.EntityFileNames),1);
    buildInfo.setTopLevelSourceFile(idx);



    if~isempty(codeGenInfo.ports.clk)
        buildInfo.addDUTPort(codeGenInfo.ports.clk.Name,'In',1,'Clock');
    end
    if~isempty(codeGenInfo.ports.enb)
        buildInfo.addDUTPort(codeGenInfo.ports.enb.Name,'In',1,'Clock enable');
    end
    if~isempty(codeGenInfo.ports.rst)
        buildInfo.addDUTPort(codeGenInfo.ports.rst.Name,'In',1,'Reset');
    end


    pT=eda.internal.filhost.ParamsT;

    for n=1:numel(codeGenInfo.ports.din)
        sigtype=codeGenInfo.ports.din(n).Signal.Type;


        if codeGenInfo.input_type_std_logic
            datatype='std';
        else
            if sigtype.Signed
                datatype='sfix';
            else
                datatype='ufix';
            end
        end

        buildInfo.addDUTPort(codeGenInfo.ports.din(n).Name,'In',...
        sigtype.WordLength,'Data',datatype);

        if sigtype.isBooleanType
            dtype='boolean';
        else
            dtype=fixdt(sigtype.Signed,sigtype.WordLength,-sigtype.FractionLength);
        end
        pT=pT.addPort(...
        'InputPort',...
        eda.internal.filhost.PortInfoT(...
        'name',codeGenInfo.ports.din(n).Name,...
        'elemBitwidth',sigtype.WordLength,...
        'dtypeSpec',dtype,...
        'sampleTime',codeGenInfo.ports.din(n).Signal.SimulinkRate));
    end

    for n=1:numel(codeGenInfo.ports.dout)
        sigtype=codeGenInfo.ports.dout(n).Signal.Type;


        if codeGenInfo.output_type_std_logic
            datatype='std';
        else
            if sigtype.Signed
                datatype='sfix';
            else
                datatype='ufix';
            end
        end

        buildInfo.addDUTPort(codeGenInfo.ports.dout(n).Name,'Out',...
        sigtype.WordLength,'Data',datatype);

        if sigtype.isBooleanType
            dtype='boolean';
        else
            dtype=fixdt(sigtype.Signed,sigtype.WordLength,-sigtype.FractionLength);
        end
        pT=pT.addPort(...
        'OutputPort',...
        eda.internal.filhost.PortInfoT(...
        'name',codeGenInfo.ports.dout(n).Name,...
        'elemBitwidth',sigtype.WordLength,...
        'dtypeSpec',dtype,...
        'sampleTime',codeGenInfo.ports.dout(n).Signal.SimulinkRate));
    end

    buildInfo.ParamsTObj=pT;


    buildInfo.AutoPortInfo=1;

    if~codeGenInfo.reset_asserted_level
        buildInfo.ResetAssertedLevel='Active-low';
    end


    buildInfo.OrigDutBaseRate=codeGenInfo.DutBaseRate;
    buildInfo.DutBaseRateScalingFactor=codeGenInfo.ScalingFactor;


    hWiz=eda.FilAssistantDlg(buildInfo);
    DAStudio.Dialog(hWiz);


    function validateDUT(codeGenInfo)













        if codeGenInfo.numClk>1
            error(message('EDALink:launchFILWithSLHDLC:MultiClock'));
        end




        if codeGenInfo.numClk==1&&codeGenInfo.numEnb==0
            error(message('EDALink:launchFILWithSLHDLC:MinClockEnable'));
        end


        if codeGenInfo.oversampling>1
            error(message('EDALink:launchFILWithSLHDLC:UserOversampling'));
        end


        isVHDL=strcmpi(codeGenInfo.target_language,'VHDL');

        msg='Make sure DUT has at least one input and one output, and then re-generate code.';
        if isempty(codeGenInfo.ports.din)
            error(message('EDALink:launchFILWithSLHDLC:NoInput',msg));
        end
        for n=1:numel(codeGenInfo.ports.din)
            validatePort(codeGenInfo.ports.din(n),isVHDL);
        end

        if isempty(codeGenInfo.ports.dout)
            error(message('EDALink:launchFILWithSLHDLC:NoOutput',msg));
        end
        for n=1:numel(codeGenInfo.ports.dout)
            validatePort(codeGenInfo.ports.dout(n),isVHDL);
        end


        function validatePort(port,isVHDL)

            if isempty(port.Signal)
                error(message('EDALink:launchFILWithSLHDLC:PortHasNoSignal'));
            end
            sigtype=port.Signal.Type;
            if sigtype.isDoubleType
                error(message('EDALink:launchFILWithSLHDLC:DoublePort'));
            elseif sigtype.isSingleType
                error(message('EDALink:launchFILWithSLHDLC:SinglePort'));
            elseif isVHDL&&sigtype.isArrayType
                error(message('EDALink:launchFILWithSLHDLC:VectorPort'));
            end

