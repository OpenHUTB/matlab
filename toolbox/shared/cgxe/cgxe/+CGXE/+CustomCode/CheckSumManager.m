


classdef CheckSumManager<handle
    properties(Constant,Hidden)
        VarName='customCodeChecksum'
        FileName='customcodechecksum.mat'
    end

    properties


CacheDirectory

SourceInfo

Changed
FrontEndOptions
    end

    methods

        function obj=CheckSumManager(feOpts,name,cacheDirectory,customCodeLib)
            if nargin<1
                feOpts=[];
            end

            if nargin<2
                name='';
            end

            if nargin<3
                cacheDirectory='';
            end

            if nargin<4
                customCodeLib=[];
            end

            obj.Changed=false;
            obj.CacheDirectory=cacheDirectory;

            if~isempty(feOpts)
                feOpts=CGXE.CustomCode.CheckSumInfo.setupOptions(feOpts.deepCopy());
            end
            obj.FrontEndOptions=feOpts;


            obj.SourceInfo=CGXE.CustomCode.CheckSumManager.getCached(name);

            if isempty(obj.SourceInfo)&&~isempty(customCodeLib)

                try
                    sourceInfoBytes=cgxe('getCustomCodeCheckSumInfo',customCodeLib);
                    if~isempty(sourceInfoBytes)
                        sourceInfo=getArrayFromByteStream(sourceInfoBytes);

                        if isa(sourceInfo,'containers.Map')
                            obj.SourceInfo=sourceInfo;
                            CGXE.CustomCode.CheckSumManager.setCached(name,obj.SourceInfo);
                        end
                    end
                catch


                end
            end

            if isempty(obj.SourceInfo)
                if~obj.loadInfo()
                    obj.SourceInfo=CGXE.CustomCode.CheckSumManager.newCached(name);
                else
                    CGXE.CustomCode.CheckSumManager.setCached(name,obj.SourceInfo);
                end
            end
        end


        function delete(obj)
            if obj.Changed
                obj.saveInfo();
            end
        end







        function chkSum=computeCompilerCheckSum(obj,chkSum)
            chkSum=CGXE.Utils.md5(chkSum,obj.FrontEndOptions.Language.LanguageMode);
            chkSum=CGXE.Utils.md5(chkSum,obj.FrontEndOptions.Language.LanguageExtra);
            chkSum=CGXE.Utils.md5(chkSum,obj.FrontEndOptions.Preprocessor.Defines);
        end


        function[chkSum,changed]=computeCheckSum(obj,chkSum,srcFile,isFile,srcRawTokens)
            if nargin<5
                srcRawTokens='';
            end
            feOpts=obj.FrontEndOptions;
            changed=false;
            if~isempty(feOpts)
                checksumInfoKey=CGXE.CustomCode.CheckSumManager.computeCheckSumInfoKey(srcFile,feOpts);
                if obj.SourceInfo.isKey(checksumInfoKey)
                    srcFileInfo=obj.SourceInfo(checksumInfoKey);
                    if isa(srcFileInfo,'CGXE.CustomCode.CheckSumInfo')&&...
                        srcFileInfo.isUpToDate(isFile,feOpts)
                        fileCheckSum=srcFileInfo.Checksum;
                        chkSum=CGXE.Utils.md5(chkSum,fileCheckSum);
                        return
                    end
                end


                srcFileInfo=CGXE.CustomCode.CheckSumInfo(srcFile,isFile,feOpts,srcRawTokens);
                chkSum=CGXE.Utils.md5(chkSum,srcFileInfo.Checksum);

                obj.SourceInfo(checksumInfoKey)=srcFileInfo;
                changed=true;
                obj.Changed=true;
            else

                fileChk=CGXE.CustomCode.CheckSumInfo.computeTextChecksum(srcFile,isFile);
                chkSum=CGXE.Utils.md5(chkSum,fileChk);
            end
        end


        function[chkSum]=computeLibCheckSum(obj,chkSum,libFile)


            libFileInfo=dir(libFile);
            chkSum=CGXE.Utils.md5(chkSum,libFileInfo.date,libFileInfo.bytes);
        end






        function bytes=getSourceInfoAsBytes(obj)
            if~isempty(obj.SourceInfo)
                bytes=getByteStreamFromArray(obj.SourceInfo);
            else
                bytes=uint8([]);
            end
        end
    end

    methods(Access=private)


        function fileExists=loadInfo(obj)
            fileExists=false;
            if~isempty(obj.CacheDirectory)
                chkFile=[obj.CacheDirectory,filesep,CGXE.CustomCode.CheckSumManager.FileName];
                if isfile(chkFile)
                    chkVarName=CGXE.CustomCode.CheckSumManager.VarName;
                    chkFileContents=load(chkFile,chkVarName);
                    if isfield(chkFileContents,chkVarName)&&...
                        isa(chkFileContents.(chkVarName),'containers.Map')
                        obj.SourceInfo=chkFileContents.(chkVarName);
                    end
                    fileExists=true;
                end
            end
        end


        function saveInfo(obj)
            if obj.Changed&&~isempty(obj.CacheDirectory)


                if~exist(obj.CacheDirectory,'dir')
                    return
                end


                chkFile=[obj.CacheDirectory,filesep,CGXE.CustomCode.CheckSumManager.FileName];
                [status,details]=fileattrib(chkFile);
                if status&&~details.UserWrite
                    fileattrib(chkFile,'+w');
                end


                chkVarName=CGXE.CustomCode.CheckSumManager.VarName;
                eval([chkVarName,'= obj.SourceInfo;']);
                save(chkFile,chkVarName);
            end
        end
    end

    methods(Static=true,Hidden=true)



        function cachedInfo=newCached(name)
            cachedInfo=containers.Map('KeyType','char','ValueType','any');
            if~isempty(name)
                cache=CGXE.CustomCode.CheckSumManager.getMemoryCache();
                cache(name)=cachedInfo;%#ok
            end
        end



        function setCached(name,info)
            if~isempty(name)
                cache=CGXE.CustomCode.CheckSumManager.getMemoryCache();
                cache(name)=info;%#ok
            end
        end




        function cachedInfo=getCached(name)
            if isempty(name)
                cachedInfo=[];
            else
                cache=CGXE.CustomCode.CheckSumManager.getMemoryCache();
                if cache.isKey(name)
                    cachedInfo=cache(name);
                else
                    cachedInfo=[];
                end
            end

        end






        function cache=getMemoryCache(clearCache)
            if nargin<1
                clearCache=false;
            end

            persistent chkSumCache;
            if isempty(chkSumCache)||clearCache
                chkSumCache=containers.Map('KeyType','char','ValueType','any');


                mlock();
            end
            cache=chkSumCache;
        end





        function checksumInfoKey=computeCheckSumInfoKey(srcFile,feOpts)
            checksumInfoKey=srcFile;
            if~isempty(feOpts.Preprocessor.IncludeDirs)
                listOfIncludeDirs=sprintf('%s',feOpts.Preprocessor.IncludeDirs{:});
                checksumInfoKey=[checksumInfoKey,listOfIncludeDirs];
            end
            if~isempty(feOpts.Preprocessor.Defines)
                listOfDefines=sprintf('%s',feOpts.Preprocessor.Defines{:});
                checksumInfoKey=[checksumInfoKey,listOfDefines];
            end
            if~isempty(feOpts.Preprocessor.UnDefines)
                listOfUnDefines=sprintf('%s',feOpts.Preprocessor.UnDefines{:});
                checksumInfoKey=[checksumInfoKey,listOfUnDefines];
            end
        end
    end
end


