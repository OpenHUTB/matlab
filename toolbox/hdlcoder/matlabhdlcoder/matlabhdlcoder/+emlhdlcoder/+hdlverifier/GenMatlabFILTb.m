


classdef GenMatlabFILTb<emlhdlcoder.hdlverifier.GenMatlabTb

    properties(Constant)
        FeatureName=message('hdlcoder:hdlverifier:FIL').getString;
        FeatureAbbrev='fil';
        FeatureFullName=message('hdlcoder:hdlverifier:FILFull').getString;
    end

    properties
        hFilMgr;
        filSysObjClass;
        BuildInfo;
        fpgaPrjDir;
        isBlockingMode=true;
    end

    methods
        function this=GenMatlabFILTb(codeInfo,boardName,boardConnection,boardIPAddress,boardMACAddress,additionalFiles)
            if strcmp(boardName,'Choose a board')
                error(message('hdlcoder:hdlverifier:NoSelectedBoard'));
            end
            this=this@emlhdlcoder.hdlverifier.GenMatlabTb(codeInfo);
            this.BuildInfo=eda.internal.workflow.FILBuildInfo;
            this.BuildInfo.Board=boardName;
            if ismethod(this.BuildInfo,'setConnection')
                this.BuildInfo.setConnection(boardConnection);
            end
            this.BuildInfo.IPAddress=boardIPAddress;
            this.BuildInfo.MACAddress=boardMACAddress;


            if isa(additionalFiles,'java.util.ArrayList')

                fileList=additionalFiles.toArray;
                if~isempty(fileList)
                    for m=1:numel(fileList)
                        fullFileName=fileList(m);
                        filetypestr=this.BuildInfo.getDefaultFileType(fullFileName);
                        this.BuildInfo.addSourceFile(fullFileName,filetypestr);
                    end
                end
            else

                if~isempty(additionalFiles)
                    tmp=textscan(additionalFiles,'%s','delimiter',';');
                    fileList=tmp{1};
                    for m=1:numel(fileList)
                        fullFileName=fileList{m};
                        filetypestr=this.BuildInfo.getDefaultFileType(fullFileName);
                        this.BuildInfo.addSourceFile(fullFileName,filetypestr);
                    end
                end
            end

            this.filSysObjClass=['class_',this.codeInfo.topName,'_sysobj'];
            this.fpgaPrjDir=fullfile(this.projDir,[this.codeInfo.topName,'_fil']);
        end

        function compErr=getCompatibilityCheckErrMsg(this)
            compErr=getCompatibilityCheckErrMsg@emlhdlcoder.hdlverifier.GenMatlabTb(this);
            if isClkEnableAtInputDataRate(this)
                compErr=[compErr,char(10),'Parameter "Drive clock enable at:" must be "DUT base rate" when overclocking rate is greater than 1.'];
            end
        end


        function generateRunScript(this)

            fileName=fullfile(this.projDir,[this.cosimRunScriptName,'.m']);
            hdldisp(message('hdlcoder:hdlverifier:DispFILExecFcn',hdlgetfilelink(fileName)));

            generator=emlhdlcoder.hdlverifier.GenMCode(fileName);

            generator.addFuncDecl(this.cosimRunScriptName);


            FPGATool=this.BuildInfo.FPGATool;
            Position=this.BuildInfo.BoardObj.Component.ScanChain;
            BitFile=this.BuildInfo.FPGAProgrammingFile;


            if~isInDebugMode(this)
                generator.addComment('Program FPGA');
                generator.addExecFunction('disp','''### Programming FPGA ''');


                if isfield(this.BuildInfo.BoardObj.ProgramFPGAOptions,'Command')
                    generator.appendCode(['programfile = ''',BitFile,''';']);
                    generator.appendCode(this.BuildInfo.BoardObj.ProgramFPGAOptions.Command);
                else
                    argIn={['''',FPGATool,''''],['''',BitFile,''''],Position};
                    generator.addExecFunction('filProgramFPGA',argIn);
                end
                generator.addNewLine;
                generator.addExecFunction('disp','''### Waiting for FPGA initialization ''');
                generator.addExecFunction('pause',3);



                genPingCmd=true;
                if isfield(this.BuildInfo.BoardObj.ConnectionOptions,'Name')
                    if~strcmpi(this.BuildInfo.BoardObj.ConnectionOptions.Name,'UDP')
                        genPingCmd=false;
                    end
                end

                if genPingCmd
                    generator.addExecFunction('disp','''### Ping the FPGA board ''');
                    generator.addIfStatement('ispc');
                    cmd=['ping ',this.BuildInfo.IPAddress];
                    systemCmd=['s = system(''',cmd,''',''-echo'');'];
                    generator.appendCode(systemCmd);
                    generator.addElseStatement;
                    cmd=[cmd,' -c 4'];
                    systemCmd=['s = system(''',cmd,''',''-echo'');'];
                    generator.appendCode(systemCmd);
                    generator.addEndStatement;

                    generator.addIfStatement(' s~=0 ');
                    generator.appendCode('warning(''Failed to ping FPGA board.'');');
                    generator.addEndStatement;
                end
            end

            this.getCommonRunScriptText(generator);
        end

        function generateFeatureSpecificFiles(this)
            generateFPGAProgramFile(this);
        end

        function generateFPGAProgramFile(this)
            this.BuildInfo.Tool='MATLAB System Object';



            this.BuildInfo.DUTName=this.codeInfo.topName;
            this.BuildInfo.setOutputFolder(this.fpgaPrjDir);


            if strcmpi(this.codeInfo.codegenSettings.TargetLanguage,'VHDL')
                lang='VHDL';
            else
                lang='Verilog';
            end

            for m=1:numel(this.codeInfo.listOfGeneratedFiles)
                filepath=fullfile(this.codeInfo.targetDir,this.codeInfo.listOfGeneratedFiles{m});
                this.BuildInfo.addSourceFile(filepath,lang);
            end


            indx=numel(this.BuildInfo.SourceFiles.FilePath);
            this.BuildInfo.setTopLevelSourceFile(indx);


            for m=1:length(this.codeInfo.hdlDutPortInfo)
                port=this.codeInfo.hdlDutPortInfo(m);
                switch port.Direction

                case 'Input'
                    switch port.Kind
                    case 'reset'
                        this.BuildInfo.addDUTPort(port.Name,'In',1,'Reset');
                    case 'clock'
                        this.BuildInfo.addDUTPort(port.Name,'In',1,'Clock');
                    case 'clock_enable'
                        this.BuildInfo.addDUTPort(port.Name,'In',1,'Clock enable');
                    otherwise
                        datatype=l_getInputPortDataType(port,this.codeInfo.codegenSettings);
                        this.BuildInfo.addDUTPort(port.Name,'In',port.TypeInfo.wordsize,'Data',datatype);
                    end

                otherwise
                    if strcmpi(port.Kind,'data')
                        datatype=l_getOutputPortDataType(port,this.codeInfo.codegenSettings);
                        this.BuildInfo.addDUTPort(port.Name,'Out',port.TypeInfo.wordsize,'Data',datatype);
                        switch port.TypeInfo.sltype
                        case 'boolean'
                            datatype='Logical';
                        case{'int8','int16','int32','uint8','uint16','uint32'}
                            datatype='Integer';
                        otherwise
                            datatype='Fixedpoint';
                        end

                        this.BuildInfo.addOutputDataType(...
                        port.Name,...
                        port.TypeInfo.wordsize,...
                        datatype,...
                        port.TypeInfo.issigned==1,...
                        -1*port.TypeInfo.binarypoint);
                    end
                end
            end


            if strcmpi(this.codeInfo.codegenSettings.ResetAssertedLevel,'ActiveHigh')
                this.BuildInfo.ResetAssertedLevel='Active-high';
            else
                this.BuildInfo.ResetAssertedLevel='Active-low';
            end


            this.BuildInfo.DutBaseRateScalingFactor=this.codeInfo.baseRateScaling;


            this.hFilMgr=eda.internal.workflow.LegacyCodeFILManager(this.BuildInfo);

            oldMode=hdlcodegenmode;
            hdlcodegenmode('filtercoder');
            try


                wd=cd(this.projDir);
                onCleanupObj=onCleanup(@()cd(wd));
                if isInDebugMode(this)
                    arglist={'QuestionDialog','off',...
                    'BuildOutput','AllML',...
                    'FirstFPGAProcess','ProjectGeneration',...
                    'FinalFPGAProcess','None',...
                    'HDLCoderMode','on',...
                    'MLSysObjClassName',this.filSysObjClass};
                else
                    arglist={'QuestionDialog','on',...
                    'BuildOutput','AllML',...
                    'HDLCoderMode','on',...
                    'MLSysObjClassName',this.filSysObjClass};



                    if this.isBlockingMode
                        arglist=[arglist,{'FirstFPGAProcess','BitGeneration'}];
                    end
                end

                success=this.hFilMgr.build(arglist{:});

                if~success
                    error(message('hdlcoder:fil:FILBuildNotComplete'));
                end
                hdlcodegenmode(oldMode);
            catch ME
                hdlcodegenmode(oldMode);
                rethrow(ME);
            end

        end

        function generateSysObjInst(this,generator,sysobjVar)
            generator.appendCode([sysobjVar,' = ',this.filSysObjClass,';']);
            if isInDebugMode(this)
                sendport=getenv('HDL_VERIFIER_FIL_TB_SOCKET_SEND');
                generator.appendCode([sysobjVar,'.localhost = true;']);
                generator.appendCode([sysobjVar,'.testMode = true;']);
                generator.appendCode([sysobjVar,'.sendPort = ''',sendport,''';']);
                generator.appendCode([sysobjVar,'.recvPort = -1;']);
            end
        end

        function r=isInDebugMode(this)
            dbgLevel=this.codeInfo.codegenSettings.DebugLevel;
            r=(dbgLevel~=0);
        end
    end
end

function datatype=l_getInputPortDataType(port,codegenSetting)
    switch codegenSetting.InputType
    case 'SignedUnsigned'
        if port.TypeInfo.issigned
            datatype='sfix';
        else
            datatype='ufix';
        end
    otherwise
        datatype='std';
    end
end

function datatype=l_getOutputPortDataType(port,codegenSetting)
    switch codegenSetting.OutputType
    case 'SameAsInputType'
        datatype=l_getInputPortDataType(port,codegenSetting);
    case 'SignedUnsigned'
        if port.TypeInfo.issigned
            datatype='sfix';
        else
            datatype='ufix';
        end
    otherwise
        datatype='std';
    end
end


