classdef ReportView<Simulink.packagedmodel.inspect.ContentInspector




    methods(Access=public)
        function this=ReportView(slxcFile)
            this=this@Simulink.packagedmodel.inspect.ContentInspector();
            this.MyPkgFile=slxcFile;
            this.MyData=containers.Map('KeyType','char','ValueType','any');
            this.MyModelName='';
        end
    end

    methods(Access=protected)
        function validationChecks(this)

            if~slInternal('verifyPackagedModelReadPermissions',this.MyPkgFile)
                DAStudio.error('Simulink:cache:noReadPermissionsForReport',this.MyPkgFile);
            end


            Simulink.packagedmodel.checkSLXCCompatibility(this.MyPkgFile);
        end

        function initializeRelease(this,release)
            this.MyData(release)=containers.Map('KeyType','char','ValueType','any');
        end

        function storeStruct(this,release,platform,aStruct)
            p=this.MyData(release);
            p(platform)=aStruct;%#ok<NASGU>
        end

        function result=constructSimTargetText(~,release,platform)
            simTargetID=['simTarget_',release,'_',platform];
            simTargetText=DAStudio.message('Simulink:cache:reportSupportsSimTarget');
            result=sprintf('<li id="%s">%s</li>\n',simTargetID,simTargetText);
        end

        function result=constructRapidTargetText(~,release,platform)
            rapidTargetID=['rapidTarget_',release,'_',platform];
            rapidText=DAStudio.message('Simulink:cache:reportSupportsRapidAccel');
            result=sprintf('<li id="%s">%s</li>\n',rapidTargetID,rapidText);
        end

        function result=constructAccelTargetText(~,release,platform)
            accelTargetID=['accelTarget_',release,'_',platform];
            accelText=DAStudio.message('Simulink:cache:reportSupportsAccel');
            result=sprintf('<li id="%s">%s</li>\n',accelTargetID,accelText);
        end

        function result=constructVarCacheText(~,release,platform)
            varCacheTargetID=['varCacheTarget_',release,'_',platform];
            varCacheText=DAStudio.message('Simulink:cache:reportSupportsVarCache');
            result=sprintf('<li id="%s">%s</li>\n',varCacheTargetID,varCacheText);
        end

        function result=constructWebViewText(~,release,platform)
            webViewTargetID=['webViewTarget_',release,'_',platform];
            webViewText=DAStudio.message('Simulink:cache:reportSupportsWebView');
            result=sprintf('<li id="%s">%s</li>\n',webViewTargetID,webViewText);
        end

        function result=constructSLDVText(~,release,platform,mode)
            switch(mode)
            case 'SLDV_TG'
                msgID='Simulink:cache:reportSupportsTestGeneration';
                targetIDRoot='sldvTGTarget_';
            case 'SLDV_PP'
                msgID='Simulink:cache:reportSupportsPropertyProving';
                targetIDRoot='sldvPPTarget_';
            case 'SLDV_DED'
                msgID='Simulink:cache:reportSupportsDesignErrorDetection';
                targetIDRoot='sldvDEDTarget_';
            case 'SLDV_XIL_TG'
                msgID='Simulink:cache:reportSupportsSILTestGeneration';
                targetIDRoot='sldvXILTGTarget_';
            otherwise
                result='';
                return;
            end
            sldvTargetID=[targetIDRoot,release,'_',platform];
            sldvText=DAStudio.message(msgID);
            result=sprintf('<li id="%s">%s</li>\n',sldvTargetID,sldvText);
        end
    end
end


