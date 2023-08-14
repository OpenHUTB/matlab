



classdef CodeInfoLoader<sldv.code.internal.CodeInfoFileInfo
    methods(Access=public)



        function fileDb=openDb(this,modelName,sldvOptions,createDir)
            if nargin<3
                sldvOptions=[];
            end

            if nargin<4
                createDir=true;
            end

            if sldv.code.internal.feature('storeIRinSLDD')
                slddPath=sldv.code.internal.CodeInfoLoader.getDataDictionaryPath(modelName,createDir,sldvOptions);
                fileDb=sldv.code.internal.CodeInfoDataDictionary(slddPath,this);
                fileDb.readDb();
            else
                matPath=sldv.code.internal.CodeInfoLoader.getMatFilePath(modelName,createDir,sldvOptions);
                fileDb=sldv.code.internal.CodeInfoMatFile(matPath,this);
                hasInfo=fileDb.readDb();
                if~hasInfo

                    slddPath=sldv.code.internal.CodeInfoLoader.getDataDictionaryPath(modelName,createDir,sldvOptions);
                    if isfile(slddPath)

                        slddDb=sldv.code.internal.CodeInfoDataDictionary(slddPath,this);


                        hasInfo=slddDb.readDb();
                        if hasInfo
                            fileDb.setDb(slddDb.getDb());
                        end
                    end
                end
            end
        end







        function codeDb=loadCodeDb(this,model,sldvOptions)
            if nargin<3
                sldvOptions=[];
            end

            createDir=false;
            dd=this.openDb(model,sldvOptions,createDir);
            codeDb=dd.getDb();
            dd.close();
        end
    end

    methods(Static,Access=private)



        function ddPath=getDataDictionaryPath(model,createDir,sldvOptions)
            if nargin<3
                sldvOptions=[];
            end
            ddPath=Sldv.utils.settingsFilename('$ModelName$_sldv_cc',...
            'off','.sldd',model,false,createDir,sldvOptions);
            if isempty(regexp(ddPath,'\.sldd$','once'))
                ddPath=[ddPath,'.sldd'];
            end
        end



        function matPath=getMatFilePath(modelH,createDir,sldvOptions)


            if slavteng('feature','SILReuseTranslation')
                isXIL=false;

                if strcmp('TestGeneration',sldvOptions.Mode)&&~Sldv.utils.Options.isTestgenTargetForModel(sldvOptions)
                    isXIL=true;
                end

                filePath=sldvprivate('getSldvCacheDIR',modelH,[],sldvOptions.Mode,isXIL);

                Sldv.utils.createXILCacheDirForSLDV(filePath);

                modelName=get_param(modelH,'name');
                matPath=fullfile(filePath,[modelName,'_sldv_cc.mat']);

                return;
            end
            matPath=Sldv.utils.settingsFilename('$ModelName$_sldv_cc',...
            'off','.mat',modelH,false,createDir,sldvOptions);
        end
    end
end


