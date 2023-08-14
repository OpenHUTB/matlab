classdef OptionSet<pslink.verifier.OptionSet




    methods(Access=public)




        function self=OptionSet(varargin)
            self=self@pslink.verifier.OptionSet(varargin{:});
            self.tplFlags=cell(0,2);
            self.tplElemFlags=cell(0,2);
        end




        function delete(~)
        end




        function[ovwOpts,archiveInfo]=fixSrcFiles(self,ovwOpts,pslinkOptions)

            originalFolder=pwd;
            cObj=onCleanup(@()cd(originalFolder));
            tempFolder=tempname;
            mkdir(tempFolder);
            cd(tempFolder);


            archiveFiles=unzip(self.packageName);
            archiveInfo=struct();
            archiveInfo.Files=archiveFiles;
            archiveInfo.PathMap=[];

            for ii=1:numel(archiveFiles)
                idx=endsWith(self.fileInfo.source,archiveFiles{ii});
                if any(idx)
                    currFile=fullfile('..','..',archiveFiles{ii});
                    self.fileInfo.source{idx}=currFile;
                else


                    [archivePath,baseName,ext]=fileparts(archiveFiles{ii});
                    fileName=[baseName,ext];
                    idx=endsWith(self.fileInfo.source,[filesep,fileName]);

                    if sum(idx)==1
                        origFile=self.fileInfo.source{idx};
                        origPath=fileparts(origFile);


                        if isempty(archiveInfo.PathMap)
                            archiveInfo.PathMap=containers.Map('KeyType','char','ValueType','char');
                        end
                        archiveInfo.PathMap(origPath)=archivePath;

                        currFile=fullfile('..','..',archiveFiles{ii});
                        self.fileInfo.source{idx}=currFile;
                    end
                end
            end


            if pslinkOptions.EnableAdditionalFileList&&numel(pslinkOptions.AdditionalFileList)>0
                for ii=1:numel(pslinkOptions.AdditionalFileList)
                    currFile=pslinkOptions.AdditionalFileList{ii};
                    if exist(currFile,'file')==2
                        idx=strcmpi(self.fileInfo.source,currFile);
                        if any(idx)
                            [~,fName,fExt]=fileparts(currFile);
                            self.fileInfo.source{idx}=['.',filesep,fName,fExt];
                        end
                    else
                        error('pslink:badAdditionalSourceListFile',...
                        message('polyspace:gui:pslink:badAdditionalSourceListFile',...
                        strrep(currFile,'\','\\')).getString())
                    end
                end
            end
        end




        function ovwOpts=fixIncludes(self,ovwOpts,archiveInfo)%#ok<INUSL>
            archiveFolders=unique(fileparts(archiveInfo.Files));
            fieldName='include';
            if isfield(ovwOpts,fieldName)
                for ii=1:numel(archiveFolders)
                    if~isempty(archiveFolders{ii})
                        idx=endsWith(ovwOpts.(fieldName),archiveFolders{ii});
                        if any(idx)
                            currFolder=fullfile('..','..',archiveFolders{ii});
                            ovwOpts.(fieldName){idx}=currFolder;
                        end
                    end
                end



                for ii=1:numel(ovwOpts.(fieldName))
                    currentInclude=ovwOpts.(fieldName){ii};
                    if~startsWith(currentInclude,'..')


                        if~isempty(archiveInfo.PathMap)&&...
                            archiveInfo.PathMap.isKey(currentInclude)
                            ovwOpts.(fieldName){ii}=fullfile('..','..',archiveInfo.PathMap(currentInclude));
                        else
                            ovwOpts.(fieldName){ii}=[];
                        end
                    end
                end
            end
        end




        function getTypeInfo(self,systemName,sysDirInfo)
            self.typeInfo=pssharedprivate('getTypeInfo',systemName,...
            pslink.verifier.ec.Coder.CODER_ID,sysDirInfo.SystemCodeGenDir,sysDirInfo.ModelRefCodeGenDir);
        end




        function getTplFlags(self,modelLang)
            if strcmpi(modelLang,'C')

                self.tplFlags={...
                '-lang',{'C'};...
                '-D',{'main=main_rtwec','__restrict__='};...
                '-boolean-types',{'boolean_T'};...
                '-signed-integer-overflows',{'warn-with-wrap-around'};...
                '-allow-negative-operand-in-shift',{};...
                '-mbd',{}...
                };
            else

                self.tplFlags={...
                '-lang',{'CPP'};...
                '-D',{'main=main_rtwec','__restrict__='};...
                '-signed-integer-overflows',{'warn-with-wrap-around'};...
                '-allow-negative-operand-in-shift',{};...
                '-mbd',{}...
                };
            end
        end





        function hasError=checkConfiguration(self,systemName,pslinkOptions)


            if~isempty(self.coderObj)
                opts.isMdlRef=self.coderObj.isMdlRef;
                opts.CheckConfigBeforeAnalysis=pslinkOptions.CheckConfigBeforeAnalysis;
            end
            [ResultDescription,ResultDetails,ResultType,hasError]=pslink.verifier.ec.Coder.checkOptions(systemName,opts);
            pssharedprivate('printCheckOptionsResults',ResultDescription,ResultDetails,ResultType);
        end





        function packageName=getPackageName(self)
            configSet=getActiveConfigSet(bdroot(self.coderObj.slSystemName));
            isPackaged=get_param(configSet,'PackageGeneratedCodeAndArtifacts');
            if~strcmpi(isPackaged,'on')
                error('pslink:invalidIsPackagedSetting',message('polyspace:gui:pslink:invalidIsPackagedSetting').getString())
            end

            packageName=get_param(configSet,'PackageName');
            if isempty(packageName)

                sysDirInfo=pslink.util.Helper.getConfigDirInfo(self.coderObj.slSystemName,pslink.verifier.ec.Coder.CODER_ID);
                packageName=[sysDirInfo.SystemCodeGenName,'.zip'];
            end
            [path,file,ext]=fileparts(packageName);
            if isempty(ext)
                ext='.zip';
            end
            if isempty(path)
                packageName=fullfile(Simulink.fileGenControl('get','CodeGenFolder'),[file,ext]);
            end
            if exist(packageName,'file')==0
                error('pslink:missingFile',message('polyspace:gui:pslink:missingFile',strrep(packageName,'\','\\')).getString())
            end
        end




        function packageName=appendToArchive(self,pslinkOptions,isMdlRef)
            packageName=self.packageName;
            polyspaceFolder='polyspace';


            originalFolder=pwd;
            cObj=onCleanup(@()cd(originalFolder));
            tempFolder=tempname;
            mkdir(tempFolder);
            cd(tempFolder);


            [~,baseFolder]=fileparts(fileparts(packageName));
            startFolder=fullfile(tempFolder,baseFolder);


            psFiles={...
            self.optionsFileName,...
            self.drsFileName,...
            self.lnkFileName...
            };
            if isMdlRef
                psFolderName=fullfile(startFolder,[polyspaceFolder,'_',self.coderObj.slModelName]);
            else
                psFolderName=fullfile(startFolder,polyspaceFolder);
            end


            archiveFiles=unzip(packageName);
            extractFolders={};
            for ii=1:numel(archiveFiles)
                if contains(archiveFiles{ii},filesep)
                    extractFolders{end+1}=strtok(archiveFiles{ii},filesep);%#ok<AGROW>
                else
                    extractFolders{end+1}=pwd;%#ok<AGROW>
                end
            end
            extractFolders=unique(extractFolders);


            if~isfolder(psFolderName)
                mkdir(psFolderName);
            end
            for ii=1:numel(psFiles)
                psTargetFile=fullfile(psFolderName,psFiles{ii});
                if isfile(psTargetFile)
                    delete(psTargetFile);
                end
                if isfile(psFiles{ii})
                    movefile(psFiles{ii},psFolderName);
                else
                    warning('pslink:missingFile',...
                    message('polyspace:gui:pslink:missingFile',strrep(psFiles{ii},'\','\\')).getString());
                end
            end


            if pslinkOptions.EnableAdditionalFileList&&numel(pslinkOptions.AdditionalFileList)>0
                for ii=1:numel(pslinkOptions.AdditionalFileList)
                    if exist(pslinkOptions.AdditionalFileList{ii},'file')==2

                        copyfile(pslinkOptions.AdditionalFileList{ii},psFolderName,'f');
                    end
                end
            end

            zip(packageName,extractFolders);
        end
    end

    methods(Access=protected)



        function writeLinksDataFile(self)
            if~isempty(self.dataLinkInfo)
                pslink.util.LinksData.writeNewDataLinkFile(self.dataLinkInfo,self.lnkFileName,pslink.verifier.ec.Coder.CODER_NAME);
            end
        end
    end

    methods(Static=true)




        function ovwOpts=fixOptsFromSettings(ovwOpts,pslinkOptions)
            if pslinkOptions.AutoStubLUT
                ovwOpts.stub_ec_lut='true';
            else
                ovwOpts.stub_ec_lut='false';
            end
        end
    end
end



