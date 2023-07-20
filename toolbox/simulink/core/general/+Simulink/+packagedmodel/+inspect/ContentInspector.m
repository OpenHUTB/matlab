classdef(Abstract)ContentInspector<handle




    properties(GetAccess=public,SetAccess=protected)
MyPkgFile
MyData
MyModelName
    end

    methods(Access=public)
        function result=populate(this)
            this.validationChecks();


            [~,relCreated]=slInternal('isSLXCCompatible',this.MyPkgFile);
            preR2018a=(string(relCreated)<"R2018a");


            this.readDataFromSLXC(preR2018a,'MAT');

            this.readDataFromSLXC(preR2018a,'XML');

            result=this.MyData;
        end

        function result=getModelName(this)
            result=this.MyModelName;
        end
    end

    methods(Access=private)

        function readDataFromSLXC(this,preR2018a,type)

            [masterInfo,masterModel]=this.getMasterInfo(preR2018a,type);%#ok<ASGLU>

            if isempty(masterInfo)
                return;
            end


            this.storeModelName(type,masterInfo);
            builtin('_checkSLCacheFileRenamed',this.MyPkgFile,this.MyModelName);

            releaseMap=this.getReleaseMap(type,masterInfo);
            releases=keys(releaseMap);


            for relIndex=1:length(releases)
                release=releases{relIndex};



                this.initializeRelease(release);
                platforms=this.getPlatforms(type,releaseMap,release);


                for platIndex=1:length(platforms)
                    platform=platforms{platIndex};



                    [extraInfo,infoModel]=this.getExtraInfo(preR2018a,type,release,platform);%#ok<ASGLU>

                    aStruct.SIM=this.getSimTarget(extraInfo,release,platform,type);
                    aStruct.RAPID=this.getRapidTarget(extraInfo,release,platform,type);
                    aStruct.ACCEL=this.getAccelTarget(extraInfo,release,platform,type);
                    aStruct.VARCACHE=this.getVarCache(extraInfo,release,platform,type);
                    aStruct.SLDV_TG=this.getSLDV(extraInfo,release,platform,slcache.Modes.SLDV_TG);
                    aStruct.SLDV_PP=this.getSLDV(extraInfo,release,platform,slcache.Modes.SLDV_PP);
                    aStruct.SLDV_DED=this.getSLDV(extraInfo,release,platform,slcache.Modes.SLDV_DED);
                    aStruct.SLDV_XIL_TG=this.getSLDV(extraInfo,release,platform,slcache.Modes.SLDV_XIL_TG);
                    aStruct.CODER=this.getCoderTarget(extraInfo,release);
                    aStruct.SLWEBVIEW=this.getWebView(extraInfo,release,platform,type);

                    this.storeStruct(release,platform,aStruct);
                end
            end
        end


        function[info,mf0Model]=getMasterInfo(this,preR2018a,type)

            mf0Model=[];
            info=[];

            try
                switch(type)
                case 'MAT'
                    info=slInternal('getPackagedModelMasterInformation',this.MyPkgFile);
                case 'XML'
                    [info,mf0Model]=builtin('_getSLCacheMasterInformation',this.MyPkgFile);
                otherwise
                    assert(['invalid type specified: ',type]);
                end
            catch ME


                if(preR2018a&&strcmp(type,'MAT'))||...
                    (~preR2018a&&strcmp(type,'XML'))
                    rethrow(ME);
                end
            end
        end


        function[info,mf0Model]=getExtraInfo(this,preR2018a,type,release,platform)

            mf0Model=[];
            info=[];

            try
                switch(type)
                case 'MAT'
                    info=slInternal('getPackagedModelExtraInformation',this.MyPkgFile,release,platform);
                case 'XML'
                    [info,mf0Model]=builtin('_getSLCacheExtraInformation',this.MyPkgFile,release,platform);
                otherwise
                    assert(['invalid type specified: ',type]);
                end
            catch ME


                if(preR2018a&&strcmp(type,'MAT'))||...
                    (~preR2018a&&strcmp(type,'XML'))
                    rethrow(ME);
                end
            end
        end


        function storeModelName(this,type,masterInfo)
            switch(type)
            case 'MAT'
                this.MyModelName=masterInfo.getModelName();
            case 'XML'
                this.MyModelName=masterInfo.modelName;
            otherwise
                assert(['invalid type specified: ',type]);
            end
        end


        function result=getReleaseMap(~,type,masterInfo)
            switch(type)
            case 'MAT'
                result=masterInfo.ReleaseMap;
            case 'XML'
                result=masterInfo.entries;
            otherwise
                assert(['invalid type specified: ',type]);
            end
        end


        function result=getPlatforms(~,type,releaseMap,release)
            switch(type)
            case 'MAT'
                result=releaseMap(release);
            case 'XML'
                platformSet=releaseMap.getByKey(release).platforms;
                result=platformSet.toArray;
            otherwise
                assert(['invalid type specified: ',type]);
            end
        end


        function simSupport=getSimTarget(this,extraInfo,release,platform,type)

            if strcmp(type,'XML')
                isSimSupported=extraInfo.supportsMode(slcache.Modes.SIM);
            else
                isSimSupported=extraInfo.supportsModelReferenceSimTarget();
            end
            if isSimSupported
                simSupport=this.constructSimTargetText(release,platform);
            else
                simSupport='';
            end
        end


        function rapidSupport=getRapidTarget(this,extraInfo,release,platform,type)

            if strcmp(type,'XML')
                isRapidSupported=extraInfo.supportsMode(slcache.Modes.RAPID);
            else
                isRapidSupported=extraInfo.supportsRapidAccelerator();
            end
            if isRapidSupported
                rapidSupport=this.constructRapidTargetText(release,platform);
            else
                rapidSupport='';
            end
        end


        function accelSupport=getAccelTarget(this,extraInfo,release,platform,type)


            if string(release)<"R2017b"
                isAccelSupported=false;
            else
                if strcmp(type,'XML')
                    isAccelSupported=extraInfo.supportsMode(slcache.Modes.ACCEL);
                else
                    isAccelSupported=extraInfo.supportsAccelerator();
                end
            end

            if isAccelSupported
                accelSupport=this.constructAccelTargetText(release,platform);
            else
                accelSupport='';
            end
        end

        function varCacheSupport=getVarCache(this,extraInfo,release,platform,type)


            if string(release)<"R2018a"
                isVarCacheSupported=false;
            else
                if strcmp(type,'XML')
                    isVarCacheSupported=extraInfo.supportsMode(slcache.Modes.VARCACHE);
                else
                    isVarCacheSupported=extraInfo.supportsVarCache();
                end
            end

            if slfeature('SLDataDictionaryRobustVarRef')<2||~isVarCacheSupported
                varCacheSupport='';
            else
                varCacheSupport=this.constructVarCacheText(release,platform);
            end
        end

        function webViewSupport=getWebView(this,extraInfo,release,platform,type)


            if string(release)<"R2022b"||strcmp(type,'MAT')
                isWebViewSupported=false;
            else
                if strcmp(type,'XML')
                    isWebViewSupported=extraInfo.supportsMode(slcache.Modes.SLWEBVIEW);
                else
                    isWebViewSupported=false;
                end
            end

            if~isWebViewSupported
                webViewSupport='';
            else
                webViewSupport=this.constructWebViewText(release,platform);
            end
        end

        function sldvSupport=getSLDV(this,extraInfo,release,platform,mode)
            if string(release)<"R2019b"
                isSldvSupported=false;
            else
                isSldvSupported=extraInfo.supportsMode(mode);
            end


            if slfeature('SLDVCacheInSLXC')<1||~isSldvSupported
                sldvSupport='';
            else
                sldvSupport=this.constructSLDVText(release,platform,mode);
            end
        end

        function coderSupport=getCoderTarget(~,extraInfo,release)


            if string(release)<"R2019b"||extraInfo.coderTargets.Size==0
                coderSupport=[];
            else

                arr=extraInfo.coderTargets.toArray();
                coderSupport=repmat(struct('targetSuffix','',...
                'context','',...
                'folderConfig',''),size(arr));
                for i=1:length(arr)

                    if contains(arr(i).targetMapKey,'CODER_TOP')
                        coderSupport(i).context=DAStudio.message(...
                        'Simulink:cache:reportStandaloneContext');
                    else
                        coderSupport(i).context=DAStudio.message(...
                        'Simulink:cache:reportModelRefContext');
                    end

                    if strcmp(arr(i).folderConfig,'ModelSpecific')
                        coderSupport(i).folderConfig=DAStudio.message(...
                        'Simulink:FileGen:ModelSpecificFolderSetName');
                        coderSupport(i).targetSuffix=arr(i).targetSuffix;
                    else
                        coderSupport(i).folderConfig=DAStudio.message(...
                        'Simulink:FileGen:TargetEnvironmentFolderSetName');
                        hwDevice=regexprep(arr(i).targetSuffix,['_',arr(i).STFName],'');
                        coderSupport(i).targetSuffix=DAStudio.message(...
                        'Simulink:cache:reportTargetText',arr(i).STFName,...
                        hwDevice);
                    end
                    coderSupport(i).arr=arr(i);
                end

                [~,ind]=sort({coderSupport.targetSuffix});
                coderSupport=coderSupport(ind);
            end
        end
    end


    methods(Access=protected)
        validationChecks(this)
        initializeRelease(this,release)
        storeStruct(this,release,platform,aStruct)
        result=constructSimTargetText(this,release,platform)
        result=constructRapidTargetText(this,release,platform)
        result=constructAccelTargetText(this,release,platform)
        result=constructVarCacheText(this,release,platform)
        result=constructSLDVText(this,release,platform,mode)
        result=constructWebViewText(this,release,paltform,mode)
    end
end


