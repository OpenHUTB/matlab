classdef SynthesisDriver<handle




    properties
        m_toolInfo=struct();
        m_folders=struct();
        m_timingGenerators;
    end

    methods

        function self=SynthesisDriver(inputArgs,targetFolders)
            self.addSynthesisTarget(inputArgs);
            self.populateTimingGenerators(inputArgs);
            self.m_folders=targetFolders;
        end

        function self=addSynthesisTarget(self,inputArgs)

            self.m_toolInfo.toolName=inputArgs.SynthesisToolName;
            self.m_toolInfo.toolPath=inputArgs.SynthesisToolPath;
            self.m_toolInfo.deviceFullName=inputArgs.SynthesisDevicePart;
            self.m_toolInfo.deviceFamily=inputArgs.SynthesisDeviceFamily;
            self.m_toolInfo.deviceName=inputArgs.SynthesisDeviceName;
            self.m_toolInfo.devicePackage=inputArgs.SynthesisDevicePackage;
            self.m_toolInfo.deviceSpeedGrade=inputArgs.SynthesisDeviceSpeedGrade;
            if~isempty(inputArgs.SynthesisDevicePart)
                self.m_toolInfo.deviceFullName=inputArgs.SynthesisDevicePart;
            else
                self.m_toolInfo.deviceFullName=[inputArgs.SynthesisDeviceName...
                ,inputArgs.SynthesisDevicePackage,inputArgs.SynthesisDeviceSpeedGrade];
            end
        end

        function populateTimingGenerators(self,inputArgs)
            self.m_timingGenerators=containers.Map('KeyType','char','ValueType','any');


            switch inputArgs.SynthesisToolName
            case 'Xilinx Vivado'
                self.m_timingGenerators(lower(inputArgs.SynthesisToolName))=characterization.STA.XilinxVivado.TimingGenerator();
            case 'Altera Quartus'
                self.m_timingGenerators(inputArgs.SynthesisToolName)=characterization.STA.AlteraQuartus.TimingGenerator();
            case 'Microchip LiberoSoC'
                self.m_timingGenerators(inputArgs.SynthesisToolName)=characterization.STA.MicrosemiLibero.TimingGenerator();
            end
        end

        function[status,logTxt,timingInfo]=runSynthesisTool(self,modelInfo)


            runToolFolder=fullfile(self.m_folders.workingDir,self.getFolderNameToRunTool(modelInfo));


            self.loadRTL(runToolFolder);


            timingGenerator=self.m_timingGenerators(lower(self.m_toolInfo.toolName));


            timingGenerator.init(self.m_toolInfo,runToolFolder,modelInfo);


            [status,logTxt,timingInfo]=timingGenerator.runToolAndGetDelay();
            cd(self.m_folders.workingDir);

        end

        function folderName=getFolderNameToRunTool(self,modelInfo)

            legalName=regexprep(self.m_toolInfo.toolName,' ','_');
            folderName=fullfile(legalName,self.m_toolInfo.deviceFullName,modelInfo.compName,modelInfo.compName);
            idx=2;
            widthIdx=numel(modelInfo.currentWidthSettings);
            while idx<=widthIdx


                folderName=[folderName,'_',int2str(modelInfo.currentWidthSettings{idx})];
                idx=idx+2;
            end
        end

        function self=loadRTL(self,runToolFolder)

            if~exist(runToolFolder,'dir')
                mkdir(runToolFolder);
            end


            try
                copyfile(fullfile(self.m_folders.rtlGoldDir,'*.vhd'),runToolFolder);
            catch
            end
        end
    end
end

