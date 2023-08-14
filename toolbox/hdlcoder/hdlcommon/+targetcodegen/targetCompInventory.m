



classdef targetCompInventory<handle
    properties(SetAccess=protected,GetAccess=protected)
targetCompMap

targetFilesBasePath
pathToTargetFiles

codegenDir
librarySettings
fileExt
    end

    methods(Access=private)
        function this=targetCompInventory(codegenDir,librarySettings,prefix,ext,deviceInfo)
            this.targetCompMap=containers.Map('KeyType','char','ValueType','any');

            this.codegenDir=codegenDir;
            [family,device]=this.getTargetFamilyDevice(deviceInfo);
            this.librarySettings=librarySettings;
            this.fileExt=ext;
            this.targetFilesBasePath=sprintf('%s%s%s%s%s',prefix,...
            filesep,family,filesep,device);
            currDir=pwd;
            targetDir=this.getCodegendir;
            this.createDirIfNeeded(targetDir);
            if~targetcodegen.targetCodeGenerationUtils.isNFPMode()
                cd(targetDir);
                this.createDirIfNeeded(this.targetFilesBasePath);
                cd(currDir);
            end
        end
    end

    methods(Access=public)
        function codegendir=getCodegendir(this)
            codegendir=this.codegenDir;
        end

        function flag=contains(this,comp)
            flag=this.targetCompMap.isKey(comp);
        end

        function count=getCount(this,comp)
            count=this.targetCompMap(comp).count;
        end

        function module=getModule(this,comp)
            module=this.targetCompMap(comp).module;
        end

        function path=getPath(this,comp)
            path=this.targetCompMap(comp).path;
        end

        function projPath=getXilinxProjectPath(this,latencyFreq,isFreqDriven)
            currDir=pwd;
            targetDir=this.getCodegendir;
            cd(targetDir);
            cd(this.targetFilesBasePath);
            pathToProject=this.appendLatencyFreqDir(pwd,latencyFreq,isFreqDriven);
            this.createDirIfNeeded(pathToProject);
            cd(pathToProject);
            projPath=sprintf('%s_coregen.cgp',tempname(pwd));
            cd(currDir);
        end

        function blockPath=getBlockPath(this,latencyFreq,isFreqDriven)
            blockPath=this.appendLatencyFreqDir(this.targetFilesBasePath,latencyFreq,isFreqDriven);
        end

        function blockPath=appendLatencyFreqDir(~,basePath,latencyFreq,isFreqDriven)
            if(isFreqDriven)
                forl='F';
            else
                forl='L';
            end
            blockPath=sprintf('%s%s%s%d',basePath,filesep,forl,latencyFreq);
        end

        function comps=getComps(this)
            comps=this.targetCompMap.keys;
        end

        function add(this,comp,module,latencyFreq,isFreqDriven,extraDir,num)
            if(nargin<6)
                num=1;
            end

            if this.contains(comp)
                compData=this.targetCompMap(comp);
                compData.count=compData.count+num;
                this.targetCompMap(comp)=compData;
            else
                compData=targetcodegen.targetCompInventory.createCompData();
                compData.count=num;
                compData.module=module;
                compData.path=fullfile(this.getBlockPath(latencyFreq,isFreqDriven),extraDir);
                this.targetCompMap(comp)=compData;
            end
        end

        function setResourceUsage(this,comp,resourceUsage,achievedFreq,achievedLatency)
            if this.targetCompMap.isKey(comp)&&isempty(this.targetCompMap(comp).resource)
                compData=this.targetCompMap(comp);
                compData.resource=resourceUsage;
                compData.achievedFreq=achievedFreq;
                compData.achievedLatency=achievedLatency;
                this.targetCompMap(comp)=compData;
            end
        end

        function resourceUsage=getResourceUsage(this,comp)
            resourceUsage=[];
            if this.targetCompMap.isKey(comp)
                resourceUsage=this.targetCompMap(comp).resource;
            end
        end

        function achievedFreq=getAchievedFreq(this,comp)
            achievedFreq=-1;
            if this.targetCompMap.isKey(comp)
                achievedFreq=this.targetCompMap(comp).achievedFreq;
            end
        end

        function achievedLatency=getAchievedLatency(this,comp)
            achievedLatency=-1;
            if this.targetCompMap.isKey(comp)
                achievedLatency=this.targetCompMap(comp).achievedLatency;
            end
        end

        function dir=getExtraPathToGeneratedFiles(~)
            dir='';
        end

        function setPathToFiles(this)
            comps=this.getComps();
            this.pathToTargetFiles={};
            for i=1:length(comps)
                comp=comps{i};
                pathToFile=fullfile(this.targetCompMap(comp).path,comp);



                targetDir=this.getCodegendir;
                hexFile=sprintf('%s%s%s.hex',targetDir,filesep,pathToFile);
                if exist(hexFile,'file')
                    copyfile(hexFile,targetDir,'f');
                end
                pathToFile=strrep(pathToFile,'\','/');
                this.pathToTargetFiles{end+1}=pathToFile;
            end
        end

        function pathToFiles=getPathToFiles(this)
            pathToFiles=this.pathToTargetFiles;
        end

        function targetFileNames=getTargetFileNames(this)
            ext=this.getExtension;
            pathToFiles=this.getPathToFiles;
            targetFileNames={};
            for i=1:length(pathToFiles)
                targetFileNames{end+1}=sprintf('%s%s',pathToFiles{i},ext);%#ok<AGROW>
            end
        end

        function files=getNgcFileList(this)
            entityFiles=this.getPathToFiles;
            ngcFiles={};
            for i=1:length(entityFiles)
                [path,basename,~]=fileparts(entityFiles{i});
                pathToFile=sprintf('%s%s%s.ngc',path,filesep,basename);
                pathToFile=strrep(pathToFile,'\','/');
                ngcFiles{end+1}=pathToFile;%#ok<AGROW>
            end
            files=ngcFiles';
        end

        function basePath=getXilinxProjectPathBase(this,latencyFreq,isFreqDriven)
            fullPathToProjectFile=this.getXilinxProjectPath(latencyFreq,isFreqDriven);
            basePath=fileparts(fullPathToProjectFile);
        end

        function librarySettings=getLibrarySettings(this)
            librarySettings=this.librarySettings;
        end

        function ext=getExtension(this)
            ext=this.fileExt;
        end

    end

    methods(Static)
        function createDirIfNeeded(aDir)
            aDir=strrep(aDir,'\','/');
            if~exist(aDir,'dir')
                mkdir(aDir);
            end
        end

        function[family,device]=getTargetFamilyDevice(targetDeviceInfo)
            if isempty(targetDeviceInfo)
                family='unspecified';
                device='unspecified';
                return;
            end
            if~isempty(targetDeviceInfo{1})
                family=strrep(targetDeviceInfo{1},' ','_');
            else
                family='unspecified';
            end
            if length(targetDeviceInfo)>1&&~isempty(targetDeviceInfo{2})
                device=strrep(targetDeviceInfo{2},' ','_');
            else
                device='unspecified';
            end
        end

        function compData=createCompData()
            compData.count=0;
            compData.module='';
            compData.resource={};
            compData.path='';
            compData.achievedFreq=-1;
            compData.achievedLatency=-1;
        end

        function writeIncrementCodegenArtifacts(extraArgsFile,extraArgs)
            fid=fopen(extraArgsFile,'w');
            if fid~=-1
                fprintf(fid,'%s',extraArgs);
                fclose(fid);
            end
        end

        function skip=checkIncrementCodegenArtifacts(extraArgsFile,extraArgs)
            if(~exist(extraArgsFile,'file'))
                skip=false;
            else
                fstr=fileread(extraArgsFile);
                if(isequal(extraArgs,fstr))
                    skip=true;
                else
                    skip=false;
                end
            end
        end

        function inventory=createInventoryWithHDLCoderDriver(hC)
            codegendir=hC.hdlGetCodegendir;
            fc=hC.getParameter('FloatingPointTargetConfiguration');
            librarySettings=fc.LibrarySettings;
            prefix='Xilinx';
            if targetcodegen.targetCodeGenerationUtils.isAlteraMode()
                prefix='Altera';
            end
            ext=hC.PirInstance.getHDLFileExtension;
            if(hC.getParameter('generateTargetComps'))
                inventory=targetcodegen.targetCompInventory(codegendir,librarySettings,prefix,ext,hdlgetdeviceinfo);
            else
                inventory=[];
            end
        end
    end
end


