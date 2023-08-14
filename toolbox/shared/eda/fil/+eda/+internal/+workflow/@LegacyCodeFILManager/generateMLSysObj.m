function generateMLSysObj(h)




    h.displayStatus('Generating FIL System object ...');

    switch(h.mBuildInfo.HDLSourceType)
    case 'LegacyCode'

    case 'SLHDLCoder'
        return;

    otherwise
        error(message('EDALink:FILWorkflow:UnknownHDLSourceType'));
    end

    InputPorts=struct('Name',{{}},'BitWidth',{{}});
    jj=1;
    for m=1:numel(h.mBuildInfo.DUTPorts.PortName)
        if strcmp(h.mBuildInfo.DUTPorts.PortDirection{m},'In')
            if strcmp(h.mBuildInfo.DUTPorts.PortType{m},'Data')
                InputPorts.Name{jj}=h.mBuildInfo.DUTPorts.PortName{m};
                InputPorts.BitWidth{jj}=h.mBuildInfo.DUTPorts.PortWidth{m};
                jj=jj+1;
            end
        end
    end

    NumInPort=numel(InputPorts.Name);
    NumOutPort=numel(h.mBuildInfo.OutputDataTypes.Name);

    DUTNameStr=['''',h.mBuildInfo.DUTName,''''];

    InputSignalsStr='''';
    InputBitWidthsStr='0';

    if(NumInPort)
        InputSignalsStr='char(';
        InputBitWidthsStr='[';

        for ii=1:NumInPort
            SignalStr=['''',InputPorts.Name{ii},''''];
            BitStr=num2str(InputPorts.BitWidth{ii});

            InputSignalsStr=[InputSignalsStr,SignalStr];
            InputBitWidthsStr=[InputBitWidthsStr,BitStr];
            if(ii~=NumInPort)
                InputSignalsStr=[InputSignalsStr,','];
                InputBitWidthsStr=[InputBitWidthsStr,','];
            end
        end
        InputSignalsStr=[InputSignalsStr,')'];
        InputBitWidthsStr=[InputBitWidthsStr,']'];
    end

    OutputSignalsStr='''';
    OutputBitWidthsStr='0';
    OutputDataTypesStr='''fixedpoint''';
    OutputSignedStr='false';
    OutputFractionLengthsStr='0';

    if(NumOutPort)
        OutputSignalsStr='char(';
        OutputBitWidthsStr='[';
        OutputDataTypesStr='char(';
        OutputSignedStr='[';
        OutputFractionLengthsStr='[';

        for ii=1:NumOutPort
            SignalStr=['''',h.mBuildInfo.OutputDataTypes.Name{ii},''''];
            BitStr=num2str(h.mBuildInfo.OutputDataTypes.BitWidth{ii});
            switch h.mBuildInfo.OutputDataTypes.DataType{ii}
            case{'Logical','Boolean'}
                TypeStr='''logical''';
            case 'Integer'
                TypeStr='''integer''';
            otherwise
                TypeStr='''fixedpoint''';
            end

            if h.mBuildInfo.OutputDataTypes.Sign{ii}
                SignedStr='true';
            else
                SignedStr='false';
            end
            FracStr=num2str(h.mBuildInfo.OutputDataTypes.FracLen{ii});

            OutputSignalsStr=[OutputSignalsStr,SignalStr];
            OutputBitWidthsStr=[OutputBitWidthsStr,BitStr];
            OutputDataTypesStr=[OutputDataTypesStr,TypeStr];
            OutputSignedStr=[OutputSignedStr,SignedStr];
            OutputFractionLengthsStr=[OutputFractionLengthsStr,FracStr];
            if(ii~=NumOutPort)
                OutputSignalsStr=[OutputSignalsStr,','];
                OutputBitWidthsStr=[OutputBitWidthsStr,','];
                OutputDataTypesStr=[OutputDataTypesStr,','];
                OutputSignedStr=[OutputSignedStr,','];
                OutputFractionLengthsStr=[OutputFractionLengthsStr,','];
            end
        end
        OutputSignalsStr=[OutputSignalsStr,')'];
        OutputBitWidthsStr=[OutputBitWidthsStr,']'];
        OutputDataTypesStr=[OutputDataTypesStr,')'];
        OutputSignedStr=[OutputSignedStr,']'];
        OutputFractionLengthsStr=[OutputFractionLengthsStr,']'];
    end

    ConnectionStr=eda.internal.workflow.getMLSysobjConnection(h.mBuildInfo);

    FPGABoardStr=['''',h.mBuildInfo.Board,''''];






    if strcmp(h.mBuildInfo.BoardObj.Component.PartInfo.FPGAVendor,'Microsemi')
        FPGAVendorStr=['''','Microchip',''''];
    else
        FPGAVendorStr=['''',h.mBuildInfo.BoardObj.Component.PartInfo.FPGAVendor,''''];
    end
    FPGAToolStr=['''',h.mBuildInfo.FPGATool,''''];
    FPGAProgrammingFileStr=['''',h.BitFile.FullPath,''''];
    FPGAProgrammingFileStr=regexprep(FPGAProgrammingFileStr,'\\','\\\');
    ScanChainPositionStr=num2str(h.mBuildInfo.BoardObj.Component.ScanChain);



    if~isempty(h.mBuildInfo.DutBaseRateScalingFactor)&&isnumeric(h.mBuildInfo.DutBaseRateScalingFactor)
        OverclockingFactorStr=sprintf('%d',h.mBuildInfo.DutBaseRateScalingFactor);
        OutputDownsamplingStr=['[',OverclockingFactorStr,',0]'];
    else
        OverclockingFactorStr='1';
        OutputDownsamplingStr='[1,0]';
    end

    SourceFrameSizeStr='1';

    ClassName=getMLSysObjClassName(h);

    FileName=[ClassName,'.m'];
    FilePath=fullfile(pwd,FileName);



    if isPSEthernet(h)
        boardID=eda.internal.getBoardID(h.mBuildInfo.Board);
        deviceTree=h.mBuildInfo.BoardObj.ConnectionOptions.DeviceTree;
        deviceTreeStr=['obj.DeviceTree = ''',deviceTree,''';'];
        IPInfoStr=['obj.IPAddress = ''192.168.0.2''; % modify to match the board IP address\n'...
        ,'            obj.Username = ''root'';\n'...
        ,'            obj.Password = ''root'';\n'];
    else
        boardID='';
        deviceTree='';
        deviceTreeStr='';
        IPInfoStr='';
    end


    if(NumInPort)
        templateFile=fullfile(matlabroot,'toolbox','shared','eda',...
        'fil','template_fil.m');
    else
        templateFile=fullfile(matlabroot,'toolbox','shared','eda',...
        'fil','template_src_fil.m');
    end

    TemplateContent=fileread(templateFile);

    TemplateContent=regexprep(TemplateContent,'template_fil',ClassName);
    TemplateContent=regexprep(TemplateContent,'template_src_fil',ClassName);
    TemplateContent=regexprep(TemplateContent,'REPLACE_WITH_FILENAME',FileName,'once');
    TemplateContent=regexprep(TemplateContent,'REPLACE_WITH_DATESTR',datestr(now),'once');
    TemplateContent=regexprep(TemplateContent,'REPLACE_WITH_DUTNAME',DUTNameStr);
    TemplateContent=regexprep(TemplateContent,'REPLACE_WITH_INPUTSIGNALS',InputSignalsStr,'once');
    TemplateContent=regexprep(TemplateContent,'REPLACE_WITH_INPUTBITWIDTHS',InputBitWidthsStr,'once');
    TemplateContent=regexprep(TemplateContent,'REPLACE_WITH_OUTPUTSIGNALS',OutputSignalsStr,'once');
    TemplateContent=regexprep(TemplateContent,'REPLACE_WITH_OUTPUTBITWIDTHS',OutputBitWidthsStr,'once');
    TemplateContent=regexprep(TemplateContent,'REPLACE_WITH_CONNECTION',ConnectionStr,'once');
    TemplateContent=regexprep(TemplateContent,'REPLACE_WITH_FPGAVENDOR',FPGAVendorStr,'once');
    TemplateContent=regexprep(TemplateContent,'REPLACE_WITH_FPGATOOL',FPGAToolStr,'once');
    TemplateContent=regexprep(TemplateContent,'REPLACE_WITH_FPGABOARD',FPGABoardStr,'once');
    TemplateContent=regexprep(TemplateContent,'REPLACE_WITH_SCANCHAINPOSITION',ScanChainPositionStr,'once');
    TemplateContent=regexprep(TemplateContent,'REPLACE_WITH_OUTPUTSIGNED',OutputSignedStr,'once');
    TemplateContent=regexprep(TemplateContent,'REPLACE_WITH_OUTPUTDATATYPES',OutputDataTypesStr,'once');
    TemplateContent=regexprep(TemplateContent,'REPLACE_WITH_OUTPUTFRACTIONLENGTHS',OutputFractionLengthsStr,'once');
    TemplateContent=regexprep(TemplateContent,'REPLACE_WITH_OUTPUTDOWNSAMPLING',OutputDownsamplingStr,'once');
    TemplateContent=regexprep(TemplateContent,'REPLACE_WITH_OVERCLOCKINGFACTOR',OverclockingFactorStr,'once');
    TemplateContent=regexprep(TemplateContent,'REPLACE_WITH_SOURCEFRAMESIZE',SourceFrameSizeStr,'once');
    TemplateContent=regexprep(TemplateContent,'REPLACE_WITH_FPGAPROGRAMMINGFILE',FPGAProgrammingFileStr,'once');
    TemplateContent=regexprep(TemplateContent,'REPLACE_WITH_DEVICETREE',deviceTreeStr,'once');
    TemplateContent=regexprep(TemplateContent,'REPLACE_WITH_IPINFO',IPInfoStr,'once');

    l_writefile(FilePath,TemplateContent,false)
    fprintf('%s',dispFpgaMsg(sprintf('<a href="matlab:open(''%s'')">%s</a>\t\t- Open %s System object for FIL simulation with %s HDL',FilePath,FileName,ClassName,DUTNameStr),2));
    fprintf('%s',dispFpgaMsg(sprintf('<a href="matlab:help(''%s'')">help %s</a>\t- Type ''help %s'' to open the help for %s System object',ClassName,ClassName,ClassName,ClassName),2));

    FuncName=[h.mBuildInfo.DUTName,'_programFPGA'];
    FileName=[FuncName,'.m'];
    FilePath=fullfile(h.mBuildInfo.OutputFolder,FileName);
    if isfield(h.mBuildInfo.BoardObj.ProgramFPGAOptions,'Command')
        TemplateContent=sprintf('function %s\n',FuncName);
        TemplateContent=[TemplateContent,'programfile = ',FPGAProgrammingFileStr,';',char(10)];
        TemplateContent=[TemplateContent,h.mBuildInfo.BoardObj.ProgramFPGAOptions.Command,char(10)];
    else
        if isPSEthernet(h)
            templateFileName='template_programZynq';
        else
            templateFileName='template_programFPGA';
        end
        templateFile=fullfile(matlabroot,'toolbox','shared','eda',...
        'fil',[templateFileName,'.m']);

        TemplateContent=fileread(templateFile);

        TemplateContent=regexprep(TemplateContent,templateFileName,FuncName);
        TemplateContent=regexprep(TemplateContent,'REPLACE_WITH_FILENAME',FileName,'once');
        TemplateContent=regexprep(TemplateContent,'REPLACE_WITH_DATESTR',datestr(now),'once');
        TemplateContent=regexprep(TemplateContent,'REPLACE_WITH_DUTNAME',DUTNameStr);
        TemplateContent=regexprep(TemplateContent,'REPLACE_WITH_FPGATOOL',FPGAToolStr,'once');
        TemplateContent=regexprep(TemplateContent,'REPLACE_WITH_FPGABOARD',FPGABoardStr,'once');
        TemplateContent=regexprep(TemplateContent,'REPLACE_WITH_FPGAPROGRAMMINGFILE',FPGAProgrammingFileStr,'once');
        TemplateContent=regexprep(TemplateContent,'REPLACE_WITH_SCANCHAINPOSITION',ScanChainPositionStr,'once');
        TemplateContent=regexprep(TemplateContent,'REPLACE_WITH_BOARDID',['''',boardID,''''],'once');
        TemplateContent=regexprep(TemplateContent,'REPLACE_WITH_DEVICETREE',['''',deviceTree,''''],'once');


        if~exist(h.mBuildInfo.OutputFolder,'dir')
            mkdir(h.mBuildInfo.OutputFolder);
        end
    end
    l_writefile(FilePath,TemplateContent,false)
    fprintf('%s',dispFpgaMsg(sprintf('<a href="matlab:run(''%s'')">Program FPGA</a>\t\t- To configure the FPGA with with %s HW binary file',FilePath,DUTNameStr),2));

end

function l_writefile(FileName,TemplateContent,OverwriteCheck)



    Overwrite=true;
    if OverwriteCheck
        if(exist(fullfile(FileName),'file')==2)
            Title=getString(message('EDALink:LegacyCodeFILManager:generateMLSysObj:OverwriteFileTitle'));
            Question=getString(message('EDALink:LegacyCodeFILManager:generateMLSysObj:OverwriteFileQuestion',FileName));
            Answer=questdlg(Question,Title,'Overwrite','Cancel','Overwrite');
            if(strcmp(Answer,'Cancel'))
                Overwrite=false;
            end
        end
    end
    if(Overwrite)
        [fid,msg]=fopen(FileName,'w');
        assert(fid~=-1,...
        message('EDALink:LegacyCodeFILManager:generateMLSysObj:OpenFileFailure',msg));
        fprintf(fid,'%s',TemplateContent);
        fclose(fid);

        if(exist(FileName,'file')~=2)
            pause(1);
        end
    end

end

function result=isPSEthernet(h)
    result=strcmpi(h.mBuildInfo.BoardObj.ConnectionOptions.Communication_Channel,'PSEthernet');
end
