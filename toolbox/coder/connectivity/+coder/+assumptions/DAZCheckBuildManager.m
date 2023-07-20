classdef(Hidden=true)DAZCheckBuildManager<coder.assumptions.CheckBuildManager








    methods(Access=public)

        function this=DAZCheckBuildManager(aComponentBuildInfo,aConfigInterface,aComponentName,aCAPath,aStartDir,isHost)

            this=this@coder.assumptions.CheckBuildManager(...
            aComponentBuildInfo,aConfigInterface,aComponentName,aCAPath,aStartDir,isHost);
        end

        function addToLibrary(this,aBuildInfo,componentArgs,lXilCompInfo)



            purelyIntegerCode=this.ConfigInterface.getParam('PurelyIntegerCode');

            if strcmp(purelyIntegerCode,'off')


                if componentArgs.CoderAssumptionsDAZCheckEnabled

                    if this.isDAZCheckSupported(lXilCompInfo)


                        dazCheckStatus=coder.assumptions.DAZCheckStatus.Enabled;
                    else


                        dazCheckStatus=coder.assumptions.DAZCheckStatus.DisabledAuto;
                    end
                else


                    dazCheckStatus=coder.assumptions.DAZCheckStatus.DisabledByFramework;
                end

                this.addDAZFileAndDefine(aBuildInfo,dazCheckStatus);
            end
        end
    end

    methods(Static,Access=private)

        function addDAZFileAndDefine(aBuildInfo,dazCheckStatus)

            xilSrcPath=rtw.pil.RtIOStreamApplicationFramework.getXILSrcPath;
            aBuildInfo.addSourceFiles(coder.assumptions.CoderAssumptions.getStaticFile_FLT,xilSrcPath);


            caCheckDAZDefineName='CA_CHECK_DAZ_ENABLED';
            aBuildInfo.addDefines(sprintf('%s=%d',caCheckDAZDefineName,dazCheckStatus),'OPTS');
        end
    end


    methods(Access=private)

        function isSupported=isDAZCheckSupported(this,lXilCompInfo)

            if this.IsHost

                isSupported=true;
            else

                caBuildInfo=this.getEmptyLibraryBuildInfo(lXilCompInfo);

                dazEnabled=coder.assumptions.DAZCheckStatus.Enabled;
                this.addDAZFileAndDefine(caBuildInfo,dazEnabled);

                [~,isSupported]=evalc('this.trapDoCompile(caBuildInfo, lXilCompInfo);');
            end
        end
    end
end
