function buildInfo=getFILBuildInfoFromSHDLC(codeGenInfo,varargin)







    validateDUT(codeGenInfo);



    if nargin>1
        buildInfo=varargin{1};
    else
        buildInfo=eda.internal.workflow.FILBuildInfo;
    end
    buildInfo.HDLSourceType='SLHDLCoder';


    buildInfo.DUTName=codeGenInfo.EntityTop;


    if strcmpi(codeGenInfo.target_language,'VHDL')
        lang='VHDL';
        ext=codeGenInfo.vhdl_file_ext;
    else
        lang='Verilog';
        ext=codeGenInfo.verilog_file_ext;
    end

    numExistFile=numel(buildInfo.SourceFiles.FilePath);

    subModelData=codeGenInfo.SubModelData;
    numSubModels=numel(subModelData);
    allSrcFileList=fullfile(codeGenInfo.codegendir,codeGenInfo.EntityFileNames);
    topLevelLibName=codeGenInfo.top_level_library_name;
    startIdx=1;
    for ii=1:numSubModels
        stopIdx=startIdx+numel(subModelData(ii).FileNames)-1;

        for jj=startIdx:stopIdx
            buildInfo.addSourceFile(allSrcFileList{jj},lang,subModelData(ii).LibName);
        end
        startIdx=stopIdx+1;
    end
    for jj=startIdx:numel(allSrcFileList)
        buildInfo.addSourceFile(allSrcFileList{jj},lang,topLevelLibName);
    end


    idx=find(strcmp([codeGenInfo.EntityTop,ext],codeGenInfo.EntityFileNames),1)+numExistFile;
    if isempty(idx)
        idx=numExistFile+1;
    end
    buildInfo.setTopLevelSourceFile(idx);



    if strcmpi(buildInfo.BoardFPGAVendor,'Altera')
        if targetcodegen.alteradspbadriver.getDSPBALibSynthesisScriptsNeededPostMakehdl(codeGenInfo.codegendir)
            dspbaFiles=targetcodegen.alteradspbadriver.getDSPBALibFiles();
            hexFiles=targetcodegen.alteradspbadriver.getDSPBAAdditionalFilesPostMakehdl(codeGenInfo.codegendir);

            quartusRoot=hdlgetpathtoquartus;
            for i=1:numel(dspbaFiles)
                dspbaLibraryFile=fullfile(quartusRoot,dspbaFiles{i});
                buildInfo.addSourceFile(dspbaLibraryFile,'VHDL');
            end
            for i=1:numel(hexFiles)
                hexfilepath=fullfile(codeGenInfo.codegendir,hexFiles{i});
                buildInfo.addSourceFile(hexfilepath,'HEX file');
            end
        end











    end



    if strcmpi(buildInfo.BoardFPGAVendor,'Xilinx')
        org_dir=pwd;
        cd(codeGenInfo.codegendir);
        codeGenDir=pwd;
        cd(org_dir);

        codeGenDir=[codeGenDir,filesep];
        codeGenDir=strrep(codeGenDir,'\','/');
        addFileCmd=['xfile add "',codeGenDir,'%s"\n'];
        cmd1=targetcodegen.xilinxutildriver.getTclScriptsToAddAllTargetFiles(addFileCmd);

        cmd2=...
        targetcodegen.xilinxisesysgendriver.getXSGSynthesisScripts(...
        addFileCmd,...
        codeGenDir,...
        strcmpi(codeGenInfo.target_language,'VHDL'));

        sysgenCmd=[cmd1,cmd2];
        if~isempty(sysgenCmd)
            sysgenTclFile=fullfile(codeGenInfo.codegendir,'add_sysgen_file_fil.tcl');
            fid=fopen(sysgenTclFile,'w');
            fprintf(fid,sysgenCmd);
            fclose(fid);
            buildInfo.addSourceFile(sysgenTclFile,'Tcl script');
        end
    end


    pT=eda.internal.filhost.ParamsT;
    pT.connectionOptions=buildInfo.BoardObj.ConnectionOptions;
    pT.programFPGAOptions=buildInfo.BoardObj.ProgramFPGAOptions;



    if numel(codeGenInfo.ports.din)==0
        pT.outputFrameSize='1';
    else
        pT.outputFrameSize='Inherit: auto';
    end


    codeDescriptor=coder.internal.getCodeDescriptorInternal(codeGenInfo.codegendir,codeGenInfo.EntityTop,247362);
    codeInfo=codeDescriptor.getComponentInterface();
    if~isempty(codeInfo)


        if(~isempty(codeInfo.ClockProperties))
            ClockProp=codeInfo.ClockProperties(1);
            if(~isempty(ClockProp.Clock))
                buildInfo.addDUTPort(ClockProp.Clock.Identifier,'In',1,'Clock');
            end
            if(~isempty(ClockProp.ClockEnable))
                buildInfo.addDUTPort(ClockProp.ClockEnable.Identifier,'In',1,'Clock enable');
            end
            if(~isempty(ClockProp.Reset))
                buildInfo.addDUTPort(ClockProp.Reset.Identifier,'In',1,'Reset');
            end
        end


        for ii=1:numel(codeInfo.Inports)
            Impl=codeInfo.Inports(ii).Implementation;
            if(isa(Impl,'RTW.Variable'))
                if Impl.Type.isNumeric
                    portWordLength=double(Impl.Type.WordLength);
                end

                if codeGenInfo.input_type_std_logic
                    datatype='std';
                else
                    if Impl.Type.Signedness
                        datatype='sfix';
                    else
                        datatype='ufix';
                    end
                end

                buildInfo.addDUTPort(Impl.Identifier,'In',...
                portWordLength,'Data',datatype);


                pT=pT.addPort(...
                'InputPort',...
                eda.internal.filhost.PortInfoT(...
                'name',Impl.Identifier,...
                'elemBitwidth',portWordLength,...
                'dtypeSpec','Inherit: auto',...
                'sampleTime','Inherit: Inherit via propagation'));
            elseif(isa(Impl,'RTW.TypedCollection'))
                for jj=1:numel(Impl.Elements)
                    Elem=Impl.Elements(jj);
                    if Elem.Type.isNumeric
                        portWordLength=double(Elem.Type.WordLength);
                    end

                    if codeGenInfo.input_type_std_logic
                        datatype='std';
                    else
                        if Elem.Type.Signedness
                            datatype='sfix';
                        else
                            datatype='ufix';
                        end
                    end

                    buildInfo.addDUTPort(Elem.Identifier,'In',...
                    portWordLength,'Data',datatype);


                    pT=pT.addPort(...
                    'InputPort',...
                    eda.internal.filhost.PortInfoT(...
                    'name',Elem.Identifier,...
                    'elemBitwidth',portWordLength,...
                    'dtypeSpec','Inherit: auto',...
                    'sampleTime','Inherit: Inherit via propagation'));
                end
            end
        end








        idx_elem=1;
        for idx_outport=1:numel(codeInfo.Outports)
            Impl=codeInfo.Outports(idx_outport).Implementation;
            if(isa(Impl,'RTW.Variable'))
                pT=l_addOutputPort(pT,Impl,codeGenInfo,buildInfo,codeInfo,idx_outport,idx_elem);
                idx_elem=idx_elem+1;
            elseif(isa(Impl,'RTW.TypedCollection'))
                for jj=1:numel(Impl.Elements)
                    Elem=Impl.Elements(jj);
                    pT=l_addOutputPort(pT,Elem,codeGenInfo,buildInfo,codeInfo,idx_outport,idx_elem);
                    idx_elem=idx_elem+1;
                end
            end
        end

    else


        if~isempty(codeGenInfo.ports.clk)
            buildInfo.addDUTPort(codeGenInfo.ports.clk.Name,'In',1,'Clock');
        end
        if~isempty(codeGenInfo.ports.enb)
            buildInfo.addDUTPort(codeGenInfo.ports.enb.Name,'In',1,'Clock enable');
        end
        if~isempty(codeGenInfo.ports.rst)
            buildInfo.addDUTPort(codeGenInfo.ports.rst.Name,'In',1,'Reset');
        end


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


            pT=pT.addPort(...
            'InputPort',...
            eda.internal.filhost.PortInfoT(...
            'name',codeGenInfo.ports.din(n).Name,...
            'elemBitwidth',sigtype.WordLength,...
            'dtypeSpec','Inherit: auto',...
            'sampleTime','Inherit: Inherit via propagation'));
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
            elseif sigtype.isDoubleType
                dtype='double';
            elseif sigtype.isSingleType
                dtype='single';
            elseif sigtype.isHalfType
                dtype='half';
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


    end


    if~codeGenInfo.reset_asserted_level
        buildInfo.ResetAssertedLevel='Active-low';
    end


    buildInfo.OrigDutBaseRate=codeGenInfo.DutBaseRate;
    buildInfo.DutBaseRateScalingFactor=codeGenInfo.ScalingFactor;


    switch(pT.getNumInputPorts)
    case 0

        doutRates=arrayfun(@(x)x.Signal.SimulinkRate,codeGenInfo.ports.dout);
        if length(doutRates)>1
            if~isrow(doutRates)
                doutRates=doutRates';
            end
            inBaseSampleTime=computeBaseRate(doutRates);
        else
            inBaseSampleTime=doutRates;
        end
    case 1
        inBaseSampleTime=codeGenInfo.ports.din(1).Signal.SimulinkRate;
    otherwise
        stimes=arrayfun(@(x)(x.Signal.SimulinkRate),codeGenInfo.ports.din);

        stimes=reshape(stimes,1,numel(stimes));
        inBaseSampleTime=computeBaseRate(stimes);
    end

    if isinf(inBaseSampleTime)
        pT.overclocking=1;
    else


        overclocking=...
        round(inBaseSampleTime*(buildInfo.DutBaseRateScalingFactor/buildInfo.OrigDutBaseRate));



        if overclocking<1
            pT.overclocking=1;
        else
            pT.overclocking=overclocking;
        end
    end
    buildInfo.ParamsTObj=pT;



    function validateDUT(codeGenInfo)



        if codeGenInfo.numClk>1
            error(message('EDALink:getFILBuildInfoFromSHDLC:MultiClock'));
        end


        isVHDL=strcmpi(codeGenInfo.target_language,'VHDL');

        msg='Make sure DUT has at least one output, and then re-generate code.';

        for n=1:numel(codeGenInfo.ports.din)
            validatePort(codeGenInfo.ports.din(n),isVHDL,codeGenInfo.isTargetLibraryUsed);
        end

        if isempty(codeGenInfo.ports.dout)
            error(message('EDALink:getFILBuildInfoFromSHDLC:NoOutput',msg));
        end
        for n=1:numel(codeGenInfo.ports.dout)
            validatePort(codeGenInfo.ports.dout(n),isVHDL,codeGenInfo.isTargetLibraryUsed);
        end


        function validatePort(port,isVHDL,isTargetLibraryUsed)

            if isempty(port.Signal)
                error(message('EDALink:getFILBuildInfoFromSHDLC:PortHasNoSignal'));
            end
            sigtype=port.Signal.Type;

            if~isTargetLibraryUsed
                if sigtype.isDoubleType
                    error(message('EDALink:getFILBuildInfoFromSHDLC:DoublePort'));
                elseif sigtype.isSingleType
                    error(message('EDALink:getFILBuildInfoFromSHDLC:SinglePort'));
                end
            end

            if isVHDL&&sigtype.isArrayType
                error(message('EDALink:getFILBuildInfoFromSHDLC:VectorPort'));
            end


            function pT=l_addOutputPort(pT,Impl,codeGenInfo,buildInfo,codeInfo,idx_outport,idx_elem)
                if Impl.Type.isNumeric
                    portWordLength=double(Impl.Type.WordLength);
                end

                if codeGenInfo.output_type_std_logic
                    datatype='std';
                else
                    if Impl.Type.Signedness
                        datatype='sfix';
                    else
                        datatype='ufix';
                    end
                end

                buildInfo.addDUTPort(Impl.Identifier,'Out',...
                portWordLength,'Data',datatype);

                if portWordLength==1
                    dtype='boolean';
                elseif codeGenInfo.isTargetLibraryUsed
                    sigtype=codeGenInfo.ports.dout(idx_elem).Signal.Type;
                    if sigtype.isDoubleType
                        dtype='double';
                    elseif sigtype.isSingleType
                        dtype='single';
                    else
                        embedType=Impl.Type.getEmbeddedType;
                        dtype=fixdt(embedType.SignednessBool,portWordLength,-embedType.FractionLength);
                    end
                else
                    embedType=Impl.Type.getEmbeddedType;
                    dtype=fixdt(embedType.SignednessBool,portWordLength,-embedType.FractionLength);
                end

                pT=pT.addPort(...
                'OutputPort',...
                eda.internal.filhost.PortInfoT(...
                'name',Impl.Identifier,...
                'elemBitwidth',portWordLength,...
                'dtypeSpec',dtype,...
                'sampleTime',codeInfo.Outports(idx_outport).Timing.SamplePeriod));


