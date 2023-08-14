classdef ROTHTargetHook<coder.oneclick.TargetHook








    properties(Access=private)
        ModelsToClose;
        RefMdls;
        RefMdlsOrigCS;
    end

    properties(Access=private)
        TopModelExtModeParamsOrigVal;
    end

    properties(Constant,Access=private)


        ExtModeParamsToRestore={'ExtMode',...
        'ExtModeMexArgs',...
        'ExtModeTransport'};
    end

    methods

        function this=ROTHTargetHook(varargin)
            this@coder.oneclick.TargetHook(varargin{:});
            this.RefMdlsOrigCS=containers.Map;
        end

        function downloadAndRunTargetExecutable(this)


            h=realtime.BuildExtension.loadBuildExtensionMatfile(this.ModelName);
            bDir=RTW.getBuildDir(this.ModelName);
            h.BuildExtension.downloadAndRun(bDir.BuildDirectory,this.ModelName);
        end


        function visible=areExtModeOptionsVisible(this)%#ok<MANU>
            visible=false;
        end

        function configureModelIfNecessary(this)

            topModel=this.ModelName;




            extModeParams=coder.oneclick.ROTHTargetHook.ExtModeParamsToRestore;
            origParamVals=cell(1,length(extModeParams));
            for i=1:length(extModeParams)
                origParamVals{i}=get_param(topModel,extModeParams{i});
            end
            this.TopModelExtModeParamsOrigVal=origParamVals;




            if~coder.oneclick.Utils.isSimulinkCoderInstalledAndLicensed

                deliverNotification=false;
                if coder.oneclick.Utils.isModelRTT(topModel)





                    realtime.internal.checkModelTargetSetting(topModel);
                else
                    this.configureModelForRTT();
                    deliverNotification=true;
                end






                this.configureRefMdlsForRTT();


                if deliverNotification
                    editor=GLUE2.Util.findAllEditors(topModel);
                    if~isempty(editor)
                        notificationID='Simulink:Extmode:OneClickModelIsConfiguredNotificationMsg';
                        notificationMsg=DAStudio.message(notificationID,this.getHardwareName);
                        editor.deliverInfoNotification(notificationID,notificationMsg);
                    end
                end
            else

                configureModelIfNecessary@coder.oneclick.TargetHook(this);
            end



            realtime.internal.checkModelTargetSetting(topModel);
        end

        function configureExternalModeSettings(this)

            setExtModeSettingsString=this.getToolsInfo.SetExtModeSettings;
            fcn=str2func(setExtModeSettingsString(2:end));
            fcn(this.ModelName);
        end

        function enableExtMode(this)


            targetInfo=this.getTargetInfo;
            assert(~isempty(targetInfo),['getTargetInfo should not ',...
            'have returned empty. Expected a hardware to have been ',...
            'been selected before enabling external mode.']);
            toolsInfo=this.getToolsInfo;
            assert(~isempty(toolsInfo),['getToolsInfo should not ',...
            'have returned empty. Expected a hardware to have been ',...
            'been selected before enabling external mode.']);






            setExtModeSettingsString=toolsInfo.SetExtModeSettings;
            if isempty(setExtModeSettingsString)
                DAStudio.error('Simulink:Extmode:OneClickExternalModeNotSupported',...
                this.getHardwareName);
            else
                assert((ischar(setExtModeSettingsString)&&...
                (setExtModeSettingsString(1)=='@')),...
                ['Expected SetExtModeSettings to be a string and start with "@". ',...
                'However, it''s value is "%s".'],setExtModeSettingsString);
            end



            tgtData=get_param(this.ModelName,'TargetExtensionData');
            assert(~isempty(tgtData),['TargetExtensionData should ',...
            'not be empty. Expected a hardware to have been ',...
            'been selected before enabling external mode.']);
            if isfield(tgtData,'Enable_LEGO_to_LEGO_communication')&&...
                tgtData.Enable_LEGO_to_LEGO_communication






            end


            enableExtMode@coder.oneclick.TargetHook(this);
        end

        function preExtModeConnectAction(this)

            targetInfo=this.getTargetInfo;
            if(targetInfo.ExtModeConnectPause>0)
                pause(targetInfo.ExtModeConnectPause);
            end
        end

        function hardwareName=getHardwareName(this)
            hardwareName=get_param(this.ModelName,'TargetExtensionPlatform');
        end


        function delete(this)



            for idx=1:length(this.RefMdls)
                mdl=this.RefMdls{idx};
                if~bdIsLoaded(mdl)
                    continue;
                end
                tmpCS=getActiveConfigSet(mdl);
                if this.RefMdlsOrigCS.isKey(mdl)
                    origCS=this.RefMdlsOrigCS(mdl);
                    if~eq(origCS,tmpCS)
                        origCS.unlock;
                        slInternal('restoreOrigConfigSetForBuild',...
                        get_param(mdl,'Handle'),origCS,tmpCS);
                    end


                    set_param(mdl,'dirty','off');
                end
            end



            if~isempty(this.ModelName)&&bdIsLoaded(this.ModelName)
                origDirty=get_param(this.ModelName,'dirty');
                extModeParams=coder.oneclick.ROTHTargetHook.ExtModeParamsToRestore;
                for i=1:length(extModeParams)
                    set_param(this.ModelName,extModeParams{i},...
                    this.TopModelExtModeParamsOrigVal{i});
                end
                set_param(this.ModelName,'dirty',origDirty);
            end


            slprivate('close_models',this.ModelsToClose);
        end
    end

    methods(Access=private)
        function targetInfo=getTargetInfo(this)
            platformName=get_param(this.ModelName,'TargetExtensionPlatform');
            if strcmp(platformName,'None')

                targetInfo=[];
            else
                targetInfo=realtime.TargetInfo(...
                realtime.getDataFileName('targetInfo',platformName),...
                platformName,this.ModelName);
            end
        end

        function toolsInfo=getToolsInfo(this)
            platformName=get_param(this.ModelName,'TargetExtensionPlatform');
            if strcmp(platformName,'None')

                toolsInfo=[];
            else
                toolsInfo=realtime.ToolsInfo(...
                realtime.getDataFileName('toolsInfo',platformName),...
                platformName,this.ModelName);
            end
        end

        function configureModelForRTT(this)

            waitbarTitle=...
            DAStudio.message('Simulink:Extmode:OneClickModelConfiguringModelTitle');
            waitbarMsg=...
            DAStudio.message('Simulink:Extmode:OneClickModelConfiguringModelMsg',...
            this.ModelName);
            waitBarH=waitbar(0,waitbarMsg,'Name',waitbarTitle,...
            'Visible','off');




            ax=findall(waitBarH,'Type','Axes');
            htext=get(ax,'Title');
            set(htext,'interpreter','none');


            closeWaitBar=onCleanup(@()close(waitBarH));
            set(waitBarH,'Visible','on');
            waitbar(0.1,waitBarH);



            origDirtyFlag=get_param(this.ModelName,'Dirty');


            csname='Run on Hardware Configuration';
            rttcs=getConfigSet(this.ModelName,csname);
            attachedNewCSToModel=false;
            if isempty(rttcs)
                attachedNewCSToModel=true;
                modelHandle=get_param(this.ModelName,'Handle');
                origCS=getActiveConfigSet(this.ModelName);
                resolvedOrigCS=origCS;
                while isa(resolvedOrigCS,'Simulink.ConfigSetRef'),
                    resolvedOrigCS=resolvedOrigCS.getRefConfigSet();
                end
                rttcs=resolvedOrigCS.copy;
                rttcs.Name=csname;
                slInternal('substituteTmpConfigSetForBuild',...
                modelHandle,origCS,rttcs);
            end



            waitbar(0.3,waitBarH);




            cs=getActiveConfigSet(this.ModelName);
            cs.switchTarget('realtime.tlc','');


            waitbar(0.4,waitBarH);


            page=DAStudio.message('realtime:build:ConfigRunOnHardware');
            set_param(cs,'CurrentDlgPage',page);
            waitbar(0.6,waitBarH);
            cs.openDialog;
            waitbar(1,waitBarH);
            delete(closeWaitBar);



            internalTestingHWToSelect=getenv('AUTO_SELECT_ROTH_TARGET_FOR_TESTING');
            if~isempty(internalTestingHWToSelect)

                this.selectHardwareForInternalTesting(cs,internalTestingHWToSelect);
            end


            this.waitUntilCSDialogIsClosed(cs);




            if coder.oneclick.ROTHTargetHook.isModelConfiguredForRTT(this.ModelName)


                realtime.setModelForRTT(cs,true);


                modelSuccessfullyConfigured=true;
            else
                modelSuccessfullyConfigured=false;
            end

            if~modelSuccessfullyConfigured



                if attachedNewCSToModel
                    slInternal('restoreOrigConfigSetForBuild',...
                    modelHandle,origCS,rttcs);
                end


                set_param(this.ModelName,'Dirty',origDirtyFlag);


                error(message('realtime:build:ModelNotConfiguredForHardware',this.ModelName));
            end
        end

        function waitUntilCSDialogIsClosed(this,cs)
            csTitle=DAStudio.message('RTW:configSet:titleCp');
            csActiveStr=DAStudio.message('RTW:configSet:titleStrActive');

            csDialogTitle=sprintf('%s %s/%s %s',...
            csTitle,this.ModelName,cs.Name,csActiveStr);
            while(true)
                pause(0.1);
                drawnow;
                if~coder.oneclick.ROTHTargetHook.isCSDialogStillVisible(csDialogTitle)
                    break;
                end
            end
        end

        function configureRefMdlsForRTT(this)



            topModel=this.ModelName;


            [allMdls,mdlRefBlks]=find_mdlrefs(topModel,'MatchFilter',@Simulink.match.internal.filterOutCodeInactiveVariantSubsystemChoices);
            this.RefMdls=allMdls(1:end-1);
            if isempty(this.RefMdls)
                return
            end




            openModels=find_system('type','block_diagram');
            csTop=getActiveConfigSet(topModel);
            for idx=1:length(this.RefMdls)
                mdl=this.RefMdls{idx};
                load_system(mdl);

                if coder.oneclick.ROTHTargetHook.isModelConfiguredForRTT(mdl)



                    continue
                end






                if isequal(get_param(mdl,'Dirty'),'on')
                    DAStudio.error('Simulink:slbuild:unsavedMdlRefs',mdl,mdlRefBlks{idx});
                end


                origCS=getActiveConfigSet(mdl);
                this.RefMdlsOrigCS(mdl)=origCS;
                resolvedOrigCS=origCS;
                while isa(resolvedOrigCS,'Simulink.ConfigSetRef'),
                    resolvedOrigCS=resolvedOrigCS.getRefConfigSet();
                end
                tmpCS=resolvedOrigCS.copy;
                slInternal('substituteTmpConfigSetForBuild',...
                get_param(mdl,'Handle'),origCS,tmpCS);
                origCS.lock;



                tmpCS.switchTarget('realtime.tlc','');
                tmpCS.detachComponent('Run on Hardware');
                ccTop=csTop.getComponent('Run on Hardware');
                tmpCS.attachComponent(ccTop.copy);











                set_param(mdl,'LifeSpan',get_param(topModel,'LifeSpan'));



                realtime.setModelForRTT(tmpCS,true);


                set_param(mdl,'Dirty','off');
            end


            this.ModelsToClose=setdiff(find_system('type','block_diagram'),...
            openModels);
        end

        function selectHardwareForInternalTesting(this,cs,internalTestingHWToSelect)

            csTitle=DAStudio.message('RTW:configSet:titleCp');
            csActiveStr=DAStudio.message('RTW:configSet:titleStrActive');

            csDialogTitle=sprintf('%s %s/%s %s',...
            csTitle,this.ModelName,cs.Name,csActiveStr);
            tr=DAStudio.ToolRoot;
            dlgs=tr.getOpenDialogs;
            for k=1:length(dlgs)
                dlg=dlgs(k);
                if ishandle(dlg)&&isa(dlg.getSource,'Simulink.ConfigSet')
                    if strcmp(dlg.getTitle,csDialogTitle)
                        imd=DAStudio.imDialog.getIMWidgets(dlg);

                        if slfeature('UnifiedTargetHardwareSelection')
                            tag='Tag_ConfigSet_RTW_TargetHardware';
                        else
                            tag='Tag_ConfigSet_RTT_Settings_TargetSelection';
                        end
                        targetHardwareCombo=find(imd,'Tag',tag);

                        hwIdx=find(strcmp(targetHardwareCombo.getAllItems,...
                        internalTestingHWToSelect))-1;
                        targetHardwareCombo.select(hwIdx);
                        imd.clickOk(dlg);
                    end
                end
            end
        end
    end


    methods(Static,Access=private)

        function isConfigured=isModelConfiguredForRTT(mdl)



            isConfigured=...
            strcmp(get_param(mdl,'SystemTargetFile'),'realtime.tlc')&&...
            ~strcmp(get_param(mdl,'TargetExtensionPlatform'),'None');
        end

        function isOpen=isCSDialogStillVisible(csDialogTitle)
            isOpen=false;
            tr=DAStudio.ToolRoot;
            dlgs=tr.getOpenDialogs;
            for k=1:length(dlgs)
                dlg=dlgs(k);
                if ishandle(dlg)&&isa(dlg.getSource,'Simulink.ConfigSet')
                    if strcmp(dlg.getTitle,csDialogTitle)
                        isOpen=true;
                        break;
                    end
                end
            end
        end
    end
end




