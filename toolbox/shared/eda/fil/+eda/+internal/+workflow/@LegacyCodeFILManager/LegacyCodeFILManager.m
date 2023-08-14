classdef LegacyCodeFILManager<handle















































    properties
mBuildInfo
mProjMgr
FilHdlDir
FilGenFiles
BitFile
LogFilePath
    end

    properties(Transient,Hidden)
BuildOpt
        LogMsg='';
        DialogMode=false;
DialogHandle
BuildStatus
    end

    methods


        function h=LegacyCodeFILManager(BuildInfoObj,varargin)

            if(~isa(BuildInfoObj,'eda.internal.workflow.FPGABuildInfo')&&...
                ~isa(BuildInfoObj,'sdr.internal.workflow.SDRBuildInfo2'))
                error(message('EDALink:LegacyCodeFILManager:LegacyCodeFILManager:InvalidBuildInfo'));
            end
            h.mBuildInfo=BuildInfoObj;


            if nargin>1
                h.DialogMode=true;
                h.DialogHandle=varargin{1};
            end

            h.setupProjManager;
            h.setupWorkflowInfo;
        end


        function success=validate(h)

            if~h.mBuildInfo.isValidHDLName(h.mBuildInfo.DUTName)
                error(message('EDALink:LegacyCodeFILManager:LegacyCodeFILManager:InvalidDUTName'));
            end
            h.mBuildInfo.validateSourceFiles;
            h.mBuildInfo.validateDUTPorts;

            success=true;
            if h.BuildOpt.GenFPGA



                h.mProjMgr.validateFPGATool;














                if~isa(h.mBuildInfo,'eda.internal.workflow.FILBuildInfo')
                    if h.isExistingFolder

                        success=h.warnFolderOverwrite;
                    end
                else
                    if strcmp(h.mBuildInfo.Tool,'MATLAB System Object')
                        if h.isExistingFolder||h.isExistingSysObj

                            success=h.warnFolderOverwrite;
                        end
                    else
                        if h.isExistingFolder

                            success=h.warnFolderOverwrite;
                        end
                    end
                end
            end
        end

        function success=build(h,varargin)
            h.checkoutLicense;
            h.parseBuildParam(varargin{:});

            success=h.validate;
            if~success
                h.displayStatus('FPGA-in-the-Loop build is incomplete.');
                return;
            end

            if h.BuildOpt.GenHDL||h.BuildOpt.GenFPGA||h.BuildOpt.GenMATFile

                eda.internal.workflow.makeDir(h.mBuildInfo.OutputFolder);

                bitDir=fileparts(h.mBuildInfo.FPGAProgrammingFile);
                bitFullDir=h.getFullDir(bitDir);
                h.BitFile.FullPath=fullfile(bitFullDir,h.BitFile.FileName);
            end

            if h.BuildOpt.GenMATFile
                h.generateMATFile;
            end

            if h.BuildOpt.GenHDL
                h.generateFILHDL;
            end
            if h.BuildOpt.GenFPGA
                h.generateFPGAProject;
            end
            if h.BuildOpt.GenSLBlock
                h.generateSLBlock;
            end

            if h.BuildOpt.GenMLSysObj
                h.generateMLSysObj;
            end







            if~isa(h.mBuildInfo,'eda.internal.workflow.FILBuildInfo')
                if h.BuildOpt.GenFPGA
                    h.compileFPGAProject;
                end
            else

                if~h.mBuildInfo.SkipFPGAProgFile
                    if h.BuildOpt.GenFPGA
                        h.compileFPGAProject;
                    end
                else
                    h.displayStatus('Skipping FPGA programming file generation...');
                end
            end

            if~isempty(h.LogMsg)
                h.writeLogFile;
            end
        end
    end

    methods(Static)
        function checkoutLicense
            if~(builtin('license','checkout','EDA_Simulator_Link'))
                error(message('EDALink:LegacyCodeFILManager:LegacyCodeFILManager:LicenseCheckout'));
            end


        end
    end

    methods(Access=protected)
        function setupProjManager(h)

            if isprop(h.mBuildInfo,'FPGATool')
                tool=h.mBuildInfo.FPGATool;
                switch tool
                case 'Xilinx Vivado'
                    h.mProjMgr=eda.internal.workflow.VivadoTclProjectManager;
                case 'Xilinx ISE'
                    h.mProjMgr=eda.internal.workflow.ISETclProjectManager;
                case 'Microchip Libero SoC'
                    h.mProjMgr=eda.internal.workflow.LiberoTclProjectManager;
                otherwise
                    h.mProjMgr=eda.internal.workflow.QuartusTclProjectManager;
                end
            else
                switch(h.mBuildInfo.BoardObj.Component.PartInfo.FPGAFamily)
                case{'Kintex7','Virtex7'}
                    h.mProjMgr=eda.internal.workflow.VivadoTclProjectManager;
                otherwise
                    h.mProjMgr=eda.internal.workflow.ISETclProjectManager;
                end
            end




            folder=h.mBuildInfo.FPGAProjectFolder;
            name=h.mBuildInfo.FPGAProjectName;


            h.mProjMgr.setProjectByName(folder,name);
        end

        function setupWorkflowInfo(h)

            filDir=h.mBuildInfo.OutputFolder;
            h.FilHdlDir=fullfile(filDir,'filsrc');

            h.LogFilePath=fullfile(filDir,[h.mBuildInfo.FPGAProjectName,'.log']);





            [~,bitName,bitExt]=fileparts(h.mBuildInfo.FPGAProgrammingFile);
            h.BitFile.FileName=[bitName,bitExt];
            h.BitFile.FullPath='';

            h.BuildStatus='';
        end

        function result=isExistingBitFile(h)
            result=false;


            if h.BuildOpt.FinalProcess.Run&&...
                strcmpi(h.BuildOpt.FinalProcess.Cmd,'BitGeneration')
                if exist(h.mBuildInfo.FPGAProgrammingFile,'file')==2
                    result=true;
                end
            end
        end

        function result=isExistingFolder(h)
            result=false;
            if exist(h.mBuildInfo.OutputFolder,'dir')==7
                result=true;
            end
        end

        function result=isExistingSysObj(h)
            result=false;

            ClassName=getMLSysObjClassName(h);
            FileName=[ClassName,'.m'];

            if exist(FileName,'file')==2
                result=true;
            end
        end

        function className=getMLSysObjClassName(h)
            if isempty(h.BuildOpt.MLSysObjClassName)
                className=[h.mBuildInfo.DUTName,'_fil'];
            else
                className=h.BuildOpt.MLSysObjClassName;
            end
        end

        function writeLogFile(h)


            fid=fopen(h.LogFilePath,'w+');
            if fid==-1
                error(message('EDALink:LegacyCodeFILManager:LegacyCodeFILManager:OpenFileError'));
            end

            mver=ver('matlab');

            fprintf(fid,dispFpgaMsg('File Name: %s'),h.LogFilePath);
            fprintf(fid,dispFpgaMsg('Created: %s'),datestr(now));
            fprintf(fid,dispFpgaMsg('Generated by %s %s \n'),...
            mver.Name,mver.Version);

            fprintf(fid,dispFpgaMsg('FPGA-in-the-Loop Summary'));
            fprintf(fid,dispFpgaMsg('Board: %s',2),h.mBuildInfo.Board);
            fprintf(fid,dispFpgaMsg('DUT frequency: %s',2),...
            h.mBuildInfo.FPGASystemClockFrequency);

            fprintf(fid,'%s\n',h.LogMsg);
            fclose(fid);
        end

        function displayStatus(h,msg,fmt)
            if nargin<3
                fmt='\n%s';
            end
            fprintf(fmt,dispFpgaMsg(msg));
            if h.DialogMode
                h.BuildStatus=[h.BuildStatus,sprintf('%s\n',msg)];
                if ishandle(h.DialogHandle)
                    wiz=h.DialogHandle.getSource;
                    wiz.showStatusMsg(h.BuildStatus,'overwrite');
                    h.DialogHandle.refresh;
                end
            end
        end
    end

    methods(Static,Access=protected)
        function fullDir=getFullDir(inputDir)
            orgDir=pwd;
            try
                cd(inputDir);
                fullDir=pwd;
                cd(orgDir);
            catch me
                cd(orgDir);
                error(message('EDALink:LegacyCodeFILManager:LegacyCodeFILManager:DirDoesNotExist',inputDir));
            end
        end
    end
end
