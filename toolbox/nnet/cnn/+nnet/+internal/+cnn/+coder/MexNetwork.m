classdef MexNetwork














    properties(SetAccess=private)

        MexFunctionName char
    end

    properties(SetAccess=private)

Config
    end

    properties(Access=private)

        RootGenerationDirectory char


        MexGenerationDirectory char


        DesignFunction char



        NetworkFilename char


        Checksum=[]



CustomLayerFiles
    end

    properties(Constant,Access=private)


        NetworkMatFileName='dl_net.mat';
    end

    properties(Constant)


        DebugGPUCoderOutput(1,1)logical=false
    end

    methods
        function this=MexNetwork(network,rootGenerationDirectory,mexNetworkConfig)




            this.RootGenerationDirectory=rootGenerationDirectory;
            this.Config=mexNetworkConfig;





            this.CustomLayerFiles=nnet.internal.cnn.coder.validateCustomLayersAndFindDependencies(network);


            mexNetworkConfig.mustBeSupportedNetwork(network);


            this=generateMexNames(this);


            this=this.generateMEX(network);
        end

        function out=predict(this,data)




            inputArgs=[{this.NetworkFilename},this.Config.ConstantInputs,data];


            out=cell(1,this.Config.NumOutputs);


            try
                [out{:}]=feval(this.MexFunctionName,inputArgs{:});
            catch me



                clear(this.MexFunctionName);


                e=MException(message('nnet_cnn:dlAccel:MEXCallFailed'));
                e=addCause(e,me);
                throw(e)
            end
        end

        function tf=isValid(this)


            [chksum,mexExist]=this.computeChecksum();
            tf=mexExist&&isequal(this.Checksum,chksum);
        end

        function removeGeneratedFiles(this)




            clear(this.MexFunctionName)


            mexFile=fullfile(this.RootGenerationDirectory,[this.MexFunctionName,'.',mexext]);
            if exist(mexFile,'file')
                delete(mexFile);
            end
            [~]=rmdir(this.MexGenerationDirectory,'s');
        end
    end


    methods(Access=private)
        function this=generateMexNames(this)




            uniqueStr=strrep(tempname,tempdir,'');



            [designFileName,designFilePath]=this.Config.getDesignFileInfo();

            this.MexFunctionName=[uniqueStr,'_',designFileName,'_mex'];
            this.DesignFunction=fullfile(designFilePath,designFileName);

            this.MexGenerationDirectory=fullfile(this.RootGenerationDirectory,this.MexFunctionName);
            this.NetworkFilename=fullfile(this.RootGenerationDirectory,this.NetworkMatFileName);
        end

        function this=generateMEX(this,network)




            fprintf('%s \n',string(message('nnet_cnn:dlAccel:GeneratingMEX',lower(this.Config.TargetLib))));


            iValidateMexSetup(false);


            save(this.NetworkFilename,'network');


            this.callCodegen();


            this.Checksum=this.computeChecksum();
        end

        function callCodegen(this)




            codegenArgs=this.Config.getCodegenArguments(this.NetworkFilename,this.MexGenerationDirectory);%#ok<NASGU>


            [~,coderReport]=evalc('dlcoder_base.internal.generateDlAccelPlugin(this.DesignFunction, codegenArgs{:});');

            if this.DebugGPUCoderOutput
                iDisplayGpuCoderOutput(coderReport)
            end


            iDiagnosticError(coderReport);


            cleanGenerationDirectoryAfterCodegen(this);
        end

        function[chksum,mexExist]=computeChecksum(this)





            mexFile=fullfile(this.RootGenerationDirectory,[this.MexFunctionName,'.',mexext]);
            if exist(mexFile,'file')
                mexInfo=dir(mexFile);
                mexStamp=mexInfo.datenum;
                mexExist=true;
            else
                mexStamp=[];
                mexExist=false;
            end


            dataFiles=dir(fullfile(this.MexGenerationDirectory,'cnn*'));
            dataStamps=ones(numel(dataFiles),1);
            for k=1:length(dataStamps)
                dataStamps(k)=dataFiles(k).datenum;
            end


            numCustomLayerFiles=numel(this.CustomLayerFiles);
            customLayerStamps=ones(numCustomLayerFiles,1);
            for k=1:customLayerStamps
                fileInfo=dir(this.CustomLayerFiles{k});
                customLayerStamps(k)=fileInfo.datenum;
            end


            chksum=[mexStamp;dataStamps;customLayerStamps];
        end

        function cleanGenerationDirectoryAfterCodegen(this)





            if exist(this.NetworkFilename,'file')
                delete(this.NetworkFilename);
            end



            [~]=rmdir(fullfile(this.MexGenerationDirectory,'build'),'s');
            [~]=rmdir(fullfile(this.MexGenerationDirectory,'interface'),'s');
            [~]=rmdir(fullfile(this.MexGenerationDirectory,'html'),'s');
            iDeleteIgnoringError(fullfile(this.MexGenerationDirectory,'*.cu'));
            iDeleteIgnoringError(fullfile(this.MexGenerationDirectory,'*.cpp'));
            iDeleteIgnoringError(fullfile(this.MexGenerationDirectory,'*.h'));
            iDeleteIgnoringError(fullfile(this.MexGenerationDirectory,'*.hpp'));
            iDeleteIgnoringError(fullfile(this.MexGenerationDirectory,[this.MexFunctionName,'_mex.*']));
        end
    end
end

function iValidateMexSetup(resetCheck)






    persistent checkStatus;

    if isempty(checkStatus)||~(checkStatus.gpu&&checkStatus.deepcodegen&&checkStatus.deepcodeexec)||resetCheck

        [checkStatus,errorList]=coder.checkDlAccel;
    end


    if~(checkStatus.gpu&&checkStatus.deepcodegen&&checkStatus.deepcodeexec)
        if~isempty(errorList)
            error(message('nnet_cnn:dlAccel:InvalidMEXSetup',char(join(string(errorList),newline))));
        else
            error(message('nnet_cnn:dlAccel:InvalidMEXSetupUnknownError'));
        end
    end
end

function iDiagnosticError(errorStruct)


    if isfield(errorStruct,'summary')
        if~errorStruct.summary.passed




            error(message('nnet_cnn:dlAccel:MEXCompilationFailed'));
        end
    else


        iValidateMexSetup(true);


        error(message('nnet_cnn:dlAccel:MEXCompilationFailed'));
    end
end

function iDisplayGpuCoderOutput(coderReport)



    e=MException(message('nnet_cnn:dlAccel:MEXCompilationFailed'));
    if isfield(coderReport,'summary')&&~coderReport.summary.passed
        numMsg=numel(coderReport.summary.messageList);
        codeGenMsg=cell(numMsg+1,1);
        for i=1:numMsg
            codeGenMsg{i}=coderReport.summary.messageList{i}.MsgText;
        end
        codeGenMsg{end}=['<a href="matlab:open(''',coderReport.summary.mainhtml,''')">View report</a>'];
        msg=join(["Coder reported the following issues: ";string(codeGenMsg)],newline);
        e=e.addCause(MException('nnet_cnn:dlAccel:CompilationError',msg));
        throw(e)
    elseif isfield(coderReport,'internal')

        e=e.addCause(coderReport.internal);
        throw(e)
    end
end

function iDeleteIgnoringError(filePath)

    try
        delete(filePath);
    catch
    end
end
