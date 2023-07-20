classdef Controller<handle





    properties(Access='protected')
        mTargetPrefView=[];
        mTargetPrefDialog=[];
        mWarningDialog=[];
        mErrorDialog=[];
        mQuestionDialog=[];
        mAddProcessorDialog=[];
        mFirstWarningDialog=[];
        mWaitbarHandle=[];

        mData=[];

        mConfigSet=[];
        mModel=[];
        mBlock=[];

        mIDEOptions=[];
        mPeripheralHandler=[];

        mErrWarnMesg=[];
        mQuestion=[];
        mNewProc=[];

        mHaveTarget=false;

        mLastException=[];
        mAssertionMessage=[];
        mCachedChipList=[];
    end


    methods(Access='protected')

        function h=Controller(configSet,block,action)
            h.mConfigSet=configSet;
            h.mModel=configSet.getModel();
            if~isequal(block,-1)
                h.mBlock=block;
            end
            h.mHaveTarget=true;
            adaptorFound=true;
            try
                h.initializeData(configSet);
            catch ME
                if strcmp(ME.identifier,'ERRORHANDLER:pjtgenerator:AdaptorNotFound')||...
                    strcmp(ME.identifier,'ERRORHANDLER:pjtgenerator:GetChipListPathFcnMissing')

                    adaptorFound=false;
                    assert(isempty(h.mData),'ERRORHANDLER:tgtpref:UnableToExtractTPBlockInfo');
                    if isequal(action,'loadFcn')
                        adaptorName=get_param(h.mModel,'AdaptorName');
                        lastWarnState=warning('off','backtrace');
                        u.modelname=get_param(h.mModel,'Name');
                        set_param(block,'UserData',u);
                        msgobj=linkfoundation.util.throwDeprecationMessage('AdaptorNotInstalled',adaptorName);
                        warning(msgobj);
                        warning(lastWarnState);
                    elseif any(strcmpi(action,{'copyFcn','initFcn','emptyFcn'}))
                        adaptorName=get_param(h.mModel,'AdaptorName');
                        lastWarnState=warning('off','backtrace');
                        msgobj=linkfoundation.util.throwDeprecationMessage('AdaptorNotInstalled',adaptorName);
                        warning(msgobj);
                        warning(lastWarnState);
                    elseif isequal(action,'preCopyFcn')
                        tag=get_param(block,'Tag');
                        adaptorName=linkfoundation.util.convertTPTagToAdaptorName(tag);
                        msgobj=linkfoundation.util.throwDeprecationMessage('AdaptorNotInstalledCopy',adaptorName);
                        error(msgobj);
                    elseif strcmpi(action,'openFcn')
                        DAStudio.delayedCallback(@h.delayedErrorFcn,h);
                    end
                else
                    rethrow(ME);
                end
            end

            if~isequal(action,'deleteFcn')&&~isempty(h.mData)&&...
                isequal(lower(h.mData.getCodeGenHookPoint()),'c2000')&&...
                ~exist('registertic2000.m','file')
                MSLDiagnostic('ERRORHANDLER:pjtgenerator:SupportPackageNotInstalled',...
                'TI C2000','TI C2000','TI C2000').reportAsWarning;
            end

            if~isequal(action,'deleteFcn')&&~isempty(h.mData)&&...
                isequal(lower(h.mData.getCodeGenHookPoint()),'c6000')&&...
                ~exist('registertic6000.m','file')
                MSLDiagnostic('ERRORHANDLER:pjtgenerator:SupportPackageNotInstalled',...
                'TI C6000','TI C6000','TI C6000').reportAsWarning;
            end

            if adaptorFound
                h.doAction(configSet,action);
            end
        end

        function ret=isSubsystemBuild(h)%#ok<MANU>
            tmpstk=dbstack;
            ret=(any(strcmp({tmpstk.name},'ss2mdl'))||...
            (any(strcmp({tmpstk.name},'makehdl'))));
        end


        function match=isequal(h,model,block)
            match=strcmpi(h.mModel,model)&&(block==h.mBlock);
        end


        function invalidateCachedChipList(h)
            h.mCachedChipList=[];
        end




        function initializePeripheralHandler(h)
            if(h.mData.hasPeripherals()&&h.mHaveTarget)&&...
                exist('registertic2000.m','file')
                h.mPeripheralHandler=tic2000.targetprefext.Peripheral;
            else
                h.mPeripheralHandler=[];
            end
        end


        function showTargetPrefDlg(h)
            if(isempty(h.mTargetPrefView))
                return;
            end
            if((isempty(h.mTargetPrefDialog)||~isa(h.mTargetPrefDialog,'DAStudio.Dialog'))&&isempty(h.mFirstWarningDialog))
                h.mTargetPrefDialog=DAStudio.Dialog(h.mTargetPrefView,'TargetPrefView','DLG_STANDALONE');
            else
                if(~isempty(h.mFirstWarningDialog))
                    h.mFirstWarningDialog.show;
                else
                    h.mTargetPrefDialog.show;
                    if(~isempty(h.mAddProcessorDialog))
                        if(isa(h.mAddProcessorDialog,'DAStudio.Dialog'))
                            h.mAddProcessorDialog.show();
                        end
                    end
                    if(~isempty(h.mErrorDialog))
                        if(isa(h.mErrorDialog,'DAStudio.Dialog'))
                            h.mErrorDialog.show();
                        end
                    end
                    if(~isempty(h.mWarningDialog))
                        if(isa(h.mWarningDialog,'DAStudio.Dialog'))
                            h.mWarningDialog.show();
                        end
                    end
                    if(~isempty(h.mQuestionDialog))
                        if(isa(h.mQuestionDialog,'DAStudio.Dialog'))
                            h.mQuestionDialog.show();
                        end
                    end
                end
            end
        end

        function updateTargetPrefViewForNewChip(h)










            h.invalidateCachedChipList();
            source=h.getDialogSource(h.mTargetPrefDialog);
            h.mData.save(source);
            h.updateViews();
            h.mTargetPrefDialog.setWidgetValue('TargetPrefBoard_ProcessorName',...
            h.mTargetPrefView.getMatchIdx(h.getChipNameList(),h.mData.getCurChipName()));
        end

        function closeViews(h)
            if(~isempty(h.mTargetPrefDialog))


                h.mTargetPrefDialog=[];
            end
            if(~isempty(h.mWarningDialog))
                if(isa(h.mWarningDialog,'DAStudio.Dialog'))
                    h.mWarningDialog.delete();
                end
                h.mWarningDialog=[];
            end
            if(~isempty(h.mErrorDialog))
                if(isa(h.mErrorDialog,'DAStudio.Dialog'))
                    h.mErrorDialog.delete();
                end
                h.mErrorDialog=[];
            end
            if(~isempty(h.mQuestionDialog))
                if(isa(h.mQuestionDialog,'DAStudio.Dialog'))
                    h.mQuestionDialog.delete();
                end
                h.mQuestionDialog=[];
            end
            if(~isempty(h.mAddProcessorDialog))
                if(isa(h.mQuestionDialog,'DAStudio.Dialog'))
                    h.mAddProcessorDialog.delete();
                end
                h.mAddProcessorDialog=[];
            end
        end

        function valueSplit=splitLines(h,value)%#ok<INUSL>
            if(isempty(value))
                valueSplit={''};
            else
                valueScaned=textscan(value,'%s','Delimiter','\n');
                if isempty(valueScaned)
                    valueSplit=value;
                else
                    valueSplit=valueScaned{1};
                end

                emptycells=cellfun(@isempty,valueSplit);
                if(any(emptycells))
                    valueSplit(emptycells)=[];
                end

                if(isempty(valueSplit))
                    valueSplit={''};
                end
            end
        end

        function updateConfigSet(h,configSet)

            csPropsIDE=h.getIDEConfigSetSettings();
            hChip=h.mData.getChip();
            if~isempty(hChip)
                csPropsChip=hChip.getConfigSetSettings(h.mData.getCurChipName(),...
                h.mData.getCurChipSubFamily(),...
                h.mData.getBoardType(),...
                h.mData.getStackSize());
            else
                csPropsChip={};
                MSLDiagnostic('ERRORHANDLER:pjtgenerator:SelectedProcNotFound',h.mData.getCurChipName()).reportAsWarning
            end
            hOs=linkfoundation.pjtgenerator.OS;
            hOs.loadOSParams(h.mData.getCurOS);

            h.mData.setOSBaseRatePriority(hOs.baseRatePriority);




            csProps=[hOs.configSetSettings;csPropsIDE;csPropsChip];
            ret=targetpref.checkAndSetActiveConfigSetSettings(configSet,csProps,true);%#ok<NASGU>



            set_param(configSet,'TargetPrefTimeStamp',datestr(now));
        end

        function source=getDialogSource(~,hDlg)
            source=hDlg.getSource().getConfigSet();
        end

    end


    methods(Access='public',Static)
        function h=get(varargin)
            if nargin<3
                return;
            end
            configSet=varargin{1};
            Block=varargin{2};
            CurAction=varargin{3};
            h=[];

            found=false;
            if configSet.isValidParam('TargetHardwareResourcesController')
                h=get_param(configSet,'TargetHardwareResourcesController');
                if(~isempty(h))
                    found=true;
                    h.mBlock=Block;
                end
            end

            if(found)

                h.doAction(configSet,CurAction);
            else
                h=targetpref.Controller(configSet,Block,CurAction);
                if configSet.isValidParam('TargetHardwareResourcesController')
                    set_param(configSet,'TargetHardwareResourcesController',h);
                end
            end
        end
    end



    methods(Access='public')

        function initializeData(h,configSet)
            h.mData=targetpref.Data(configSet,h.mBlock);
            h.initializePeripheralHandler();
            h.invalidateCachedChipList();
        end

        function createWaitbar(h,num)
            msg=DAStudio.message('ERRORHANDLER:tgtpref:TargetHWResourcesUIUpdating');
            h.mWaitbarHandle=waitbar(num,msg);
        end

        function ret=getWaitbar(h)
            ret=h.mWaitbarHandle;
        end

        function closeWaitbar(h)
            msg=DAStudio.message('ERRORHANDLER:tgtpref:TargetHWResourcesUIUpdated');
            waitbar(1,h.mWaitbarHandle,msg);
            close(h.mWaitbarHandle);
            h.mWaitbarHandle=[];
        end

        function setInternalIDEOptions(h,options)
            h.mIDEOptions=options;
        end

        function options=getInternalIDEOptions(h)
            options=h.mIDEOptions;
        end


        function updateViews(h)

            h.mTargetPrefDialog.refresh();
        end


        function h=modal(h)
            if(~isempty(h.mTargetPrefDialog))
                DAStudio.delayedCallback(@h.delayedWaitFor,h);
            end
        end

        function h=delayedWaitFor(h,varargin)
            waitfor(h.mTargetPrefDialog);
        end

        function name=getModel(h)
            name=h.mModel;
        end


        function createView(h)
            if(isempty(h.mTargetPrefView))
                h.mTargetPrefView=targetprefu.View;
                h.mTargetPrefView.setController(h);
            end
        end

        function view=getView(h)
            view=h.mTargetPrefView;
        end





        function varargout=showWarning(h,warningid,varargin)
            h.createView();
            h.mErrWarnMesg=DAStudio.message(['ERRORHANDLER:',warningid],varargin{:});
            h.setLastException('warning',warningid,h.mErrWarnMesg);
            if targetpref.showWarningErrorQuestionDialogs()
                h.mWarningDialog=DAStudio.Dialog(h.mTargetPrefView,'Warning','DLG_STANDALONE');
            end
            if(nargout>0)
                varargout{1}=h.mWarningDialog;
            end
        end

        function varargout=showWarningMsg(h,errormsg)
            h.createView();
            h.mErrWarnMesg=errormsg;
            h.setLastException('warning',[],h.mErrWarnMesg);
            if targetpref.showWarningErrorQuestionDialogs()
                h.mErrorDialog=DAStudio.Dialog(h.mTargetPrefView,'Warning','DLG_STANDALONE');
            end
            if(nargout>0)
                varargout{1}=h.mErrorDialog;
            end
        end

        function closeWarning(h,~)
            h.mWarningDialog=[];
        end

        function varargout=showError(h,errorid,varargin)
            h.createView();
            h.mErrWarnMesg=DAStudio.message(['ERRORHANDLER:',errorid],varargin{:});
            h.setLastException('error',errorid,h.mErrWarnMesg);
            if targetpref.showWarningErrorQuestionDialogs()
                h.mErrorDialog=DAStudio.Dialog(h.mTargetPrefView,'Error','DLG_STANDALONE');
            end
            if(nargout>0)
                varargout{1}=h.mErrorDialog;
            end
        end

        function varargout=showErrorMsg(h,errormsg)
            h.createView();
            h.mErrWarnMesg=errormsg;
            h.setLastException('error',[],h.mErrWarnMesg);
            if targetpref.showWarningErrorQuestionDialogs()
                h.mErrorDialog=DAStudio.Dialog(h.mTargetPrefView,'Error','DLG_STANDALONE');
            end
            if(nargout>0)
                varargout{1}=h.mErrorDialog;
            end
        end

        function closeError(h,~)
            h.mErrorDialog=[];
        end

        function showQuestion(h,title,promptId,choiceIds,defIdx,methodName,varargin)
            h.createView();
            h.mQuestion.Prompt=DAStudio.message(['ERRORHANDLER:',promptId],varargin{:});
            h.setLastException('question',promptId,h.mQuestion.Prompt);
            h.mQuestion.Title=title;
            for i=1:length(choiceIds)
                h.mQuestion.Choices{i}=DAStudio.message(['ERRORHANDLER:',choiceIds{i}]);
            end
            h.mQuestion.Default=h.mQuestion.Choices{defIdx};
            h.mQuestion.UserResponse='';
            h.mQuestion.Method=methodName;
            if targetpref.showWarningErrorQuestionDialogs()
                h.mQuestionDialog=DAStudio.Dialog(h.mTargetPrefView,'Question','DLG_STANDALONE');
                h.mQuestionDialog.setFocus(['QuestDlg_',h.mQuestion.Default]);
            else
                h.mQuestion.UserResponse=h.mQuestion.Default;
                if~isempty(h.mQuestion.Method)
                    h.(h.mQuestion.Method)();
                end
            end
        end

        function doAction(h,configSet,action)
            h.(action)(configSet);
        end

        function preCopyFcn(h,configSet)%#ok<INUSD>
        end

        function copyFcn(h,configSet)

            if h.mData.isTemplate()
                DAStudio.error('ERRORHANDLER:tgtpref:NoCopyTemplateLibrary');
            end
            if isequal(get_param(h.mModel,'BlockDiagramType'),'library')

                targetInfo=get_param(h.mBlock,'UserData');
                if isfield(targetInfo,'modelname')
                    targetInfo=get_param(targetInfo.modelname,'TargetHardwareResources');
                    config=Simulink.ConfigSet;
                    config.switchTarget('idelink_grt.tlc',[]);
                    set_param(config,'TargetHardwareResources',targetInfo);
                    set_param(h.mBlock,'UserData',config);
                end
                return
            end






            h.setSTF(configSet);



            if h.isSubsystemBuild()
                return
            end
            h.delayedCopyFcn(configSet);
        end

        function setSTF(h,configSet)%#ok<INUSL>
            curstf=get_param(configSet,'SystemTargetFile');
            if isequal(curstf,'idelink_ert.tlc')

            elseif ecoderinstalled()

                configSet.switchTarget('idelink_ert.tlc',[]);
            else
                configSet.switchTarget('idelink_grt.tlc',[]);
            end
        end

        function delayedErrorFcn(h,varargin)
            hDlg=DAStudio.DialogProvider;
            msg=linkfoundation.util.throwDeprecationMessage('AdaptorNotInstalled',...
            get_param(h.getModel(),'AdaptorName'));
            hDlg.errordlg(getString(msg),[h.getModel(),'/',get_param(h.mBlock,'Name')]);
        end

        function delayedCopyFcn(h,configSet)
            if~ishandle(h.mBlock)
                return;
            end
            h.initializeData(configSet);
            if~h.isDeprecationWarningDisabled()
                MSLDiagnostic('ERRORHANDLER:tgtpref:TGTPrefDeprecation').reportAsWarning;
            end
            if isa(configSet,'Simulink.ConfigSetRef')
                fhandle=h.showWarning('tgtpref:ConfigSetReferenceWarning');
                waitfor(fhandle);
                msg=DAStudio.message('ERRORHANDLER:tgtpref:TargetPrefCopyWarning');
                MSLDiagnostic('ERRORHANDLER:utils:AutoInitRejected',msg).reportAsWarning;
                return;
            end
            h.copyFcnConfirm(configSet);
            h.updateConfigSet(configSet);
            if~isempty(h.mBlock)
                inLib=strcmpi(get_param(bdroot(h.mBlock),'BlockDiagramType'),'library');
                targetInfo=get_param(h.mBlock,'UserData');
                if~inLib
                    if isfield(targetInfo,'modelname')
                        targetInfo=get_param(targetInfo.modelname,'TargetHardwareResources');
                    elseif isfield(targetInfo,'chipInfo')
                        targetInfo=h.mData.reduceTargetInfo(targetInfo);
                        targetInfo.tag=get_param(h.mBlock,'Tag');
                    elseif isa(targetInfo,'Simulink.ConfigSet')

                        targetInfo=get_param(targetInfo,'TargetHardwareResources');
                    else
                        assert(false,'Target Preferences block contains invalid data.');
                    end
                    set_param(configSet,'TargetHardwareResources',targetInfo);
                    if~h.isSubsystemBuild()
                        u.modelname=get_param(h.mModel,'Name');
                        set_param(h.mBlock,'UserData',u);
                    end
                end
            end

            linkfoundation.util.manageAdaptorName('set',h.getModel,...
            linkfoundation.util.convertTPTagToAdaptorName(h.getData.getTag));
        end

        function status=copyFcnConfirm(h,configSet)
            status=1;
            library=strcmp(get_param(h.mBlock,'library'),'on');
            if(library)



                [ide,board,proc]=targetpref.getDefaultIDEBoardProc();
                if(~isempty(ide)&&~isempty(board)&&~isempty(proc))
                    h.mData.setIDE(configSet,ide);
                    h.mData.setBoardType(configSet,board);
                    if(~strcmpi(h.mData.getCurChipName(),proc))
                        h.mData.setProcessor(proc);
                    end

                    h.invalidateCachedChipList();
                end
            end
            if(library)



                if(h.mData.isProcRegistered())
                    targetpref.setDefaultIDEBoardProc(h.mData.getCurAdaptorName(),...
                    h.mData.getBoardTypeDisplayName(),h.mData.getCurChipName());
                end
                set_param(h.mBlock,'library','off');
            end

            if(h.mData.needSave())
                h.mData.save(configSet);
            end

            h.mQuestion=[];
            h.mFirstWarningDialog=[];
        end

        function emptyFcn(h,configSet)%#ok<INUSD>
            h.mIDEOptions=h.getIDEOptions(false);
        end

        function loadFcn(h,configSet)
            if isempty(h.mData)||h.mData.isBlockInLibrary(configSet)||h.mData.isTemplate()||...
                isequal(get_param(configSet,'SystemTargetFile'),'modelrefsim.tlc')



                return;
            end
            if~h.isDeprecationWarningDisabled()
                warning(message('ERRORHANDLER:tgtpref:TGTPrefDeprecation'));
            end

            if~h.mData.isBlockInLibrary(configSet)
                linkfoundation.util.addTargetHardwareResourceComponent(configSet,h.mBlock,'load');
            else
                targetInfo=get_param(h.mBlock,'UserData');
                if isa(targetInfo,'Simulink.ConfigSet')

                elseif isfield(targetInfo,'chipInfo')
                    targetInfo=h.mData.reduceTargetInfo(targetInfo);
                    targetInfo.tag=get_param(h.mBlock,'Tag');

                    config=Simulink.ConfigSet;
                    config.switchTarget('idelink_grt.tlc',[]);
                    set_param(config,'TargetHardwareResources',targetInfo);
                    set_param(config,'AdaptorName',linkfoundation.util.convertTPTagToAdaptorName(targetInfo.tag))
                    set_param(h.mModel,'Lock','off')
                    set_param(h.mBlock,'UserData',config);
                    set_param(h.mModel,'Lock','on')
                else
                    assert(false,'Target Preferences block contains invalid data.');
                end
                return;
            end
            if targetpref.isTPBlockOlderThanR2007a(h.mBlock)
                targetpref.convertR2006bTPBlock(h.mBlock);
                h.initializeData(configSet);
            end


            if configSet.isValidParam('AdaptorName')
                adaptorName=get_param(configSet,'AdaptorName');
                linkfoundation.util.manageAdaptorName('set',h.getModel,adaptorName);
            end

            if~isempty(h.mBlock)


                inLib=strcmpi(get_param(bdroot(h.mBlock),'BlockDiagramType'),'library');
                libraryparam=get_param(h.mBlock,'library');
                if(~inLib&&strcmpi(libraryparam,'on'))
                    set_param(h.mBlock,'library','off');
                end
                if~inLib
                    targetInfo=get_param(h.mBlock,'UserData');
                    if isfield(targetInfo,'modelname')
                        if~isequal(get_param(h.mModel,'Name'),'targetInfo.modelname')
                            u.modelname=get_param(h.mModel,'Name');
                            set_param(h.mBlock,'UserData',u);
                        end
                    else

                        h.initializeData(configSet);


                        targetInfo=get_param(h.mBlock,'UserData');
                        targetInfo=h.mData.reduceTargetInfo(targetInfo);
                        targetInfo.tag=get_param(h.mBlock,'Tag');
                        set_param(configSet,'TargetHardwareResources',targetInfo);
                        if~h.isSubsystemBuild()
                            u.modelname=get_param(h.mModel,'Name');
                            set_param(h.mBlock,'UserData',u);
                        end
                    end
                end
            end

            h.mIDEOptions=h.getIDEOptions(false);
        end

        function initFcn(h,configSet)%#ok<INUSD>
            if h.mData.isTemplate()
                return;
            end

            opts.familyName='targetPrefs';
            opts.parameterName='';
            opts.parameterValue='';
            lf_registerBlockCallbackInfo(opts);
        end

        function openFcn(h,configSet)
            mdlName=get_param(h.mModel,'Name');
            if isempty(mdlName)
                mdlName=get_param(bdroot,'Name');
            end
            if isempty(h.mData)
                adaptorName=get_param(configSet,'AdaptorName');
                hDlg=DAStudio.DialogProvider;
                msg=linkfoundation.util.throwDeprecationMessage('AdaptorNotInstalled',adaptorName);
                hDlg.errordlg(getString(msg),mdlName);
                return;
            end
            if h.mData.isTemplate()
                hDlg=DAStudio.DialogProvider;
                msg=DAStudio.message('ERRORHANDLER:tgtpref:NoCopyTemplateLibrary');
                hDlg.errordlg(msg,mdlName);
                return;
            end
            if~isequal(get_param(configSet,'SystemTargetFile'),'idelink_ert.tlc')&&...
                ~isequal(get_param(configSet,'SystemTargetFile'),'idelink_grt.tlc')
                hDlg=DAStudio.DialogProvider;
                msg=DAStudio.message('ERRORHANDLER:tgtpref:TGTPrefOpenWrongSTFError');
                hDlg.errordlg(msg,mdlName);
                return;
            end
            if isequal(get_param(mdlName,'BlockDiagramType'),'library')
                return
            end
            h.mIDEOptions=h.getIDEOptions(false);
            configSet.openDialog();
            h.setTabToTargetHardwareResources();
        end

        function setTabToTargetHardwareResources(h)
            cs=getActiveConfigSet(h.mModel);
            configset.showParameterGroup(cs,{DAStudio.message('Simulink:dialog:CodeGeneration'),DAStudio.message('codertarget:build:CoderTargetName')},'Category');
            dlg=cs.getDialogHandle;
            dlg.setActiveTab('Tag_ConfigSet_RTW_Embedded_IDE_Tabs',1);
        end

        function deleteFcn(h,configSet)
            h.closeViews();


            linkfoundation.util.manageAdaptorName('delete',h.getModel);

            stf=get_param(configSet,'SystemTargetFile');
            if~isequal(stf,'idelink_ert.tlc')&&...
                ~isequal(stf,'idelink_grt.tlc')&&...
                configSet.isValidParam('TargetHardwareResources')
                configSet.detachComponent('Target Hardware Resources');
            end

            h.mBlock=[];





















        end

        function closeFcn(h,configSet)%#ok<INUSD>
            h.closeViews();
        end

        function preSaveFcn(h,configSet)%#ok<INUSD>
            if isempty(h.getData)
                adaptorName=linkfoundation.util.convertTPTagToAdaptorName(get_param(h.mBlock,'Tag'));
                msg=linkfoundation.util.throwDeprecationMessage('AdaptorNotInstalled',adaptorName);
                error(msg);
            end
            inLib=strcmpi(get_param(bdroot(h.mBlock),'BlockDiagramType'),'library');
            if~inLib
                targetInfo=get_param(h.mBlock,'UserData');
                if isfield(targetInfo,'modelname')&&...
                    ~isequal(get_param(h.mModel,'Name'),targetInfo.modelname)
                    targetInfo.modelname=get_param(h.mModel,'Name');
                    set_param(h.mBlock,'UserData',targetInfo);
                end
                if isfield(targetInfo,'version')
                    set_param(h.mBlock,'UserData',rmfield(targetInfo,'version'));
                end
            end
        end

        function postSaveFcn(h,configSet)%#ok<INUSD>

            linkfoundation.util.manageAdaptorName('set',h.getModel,...
            linkfoundation.util.convertTPTagToAdaptorName(h.getData.getTag));
        end

        function data=getData(h)
            data=h.mData;
        end

        function dispName=getDisplayName(h)
            dispName=[h.mModel,': Target Resource Data'];
        end

        function delete(h)
            h.closeViews();
            h.mTargetPrefView=[];
            h.mData=[];
        end

        function title=getErrorTitle(h)
            title=['Error: ',h.getDisplayName()];
        end

        function message=getWarningErrorMessage(h)
            message=h.mErrWarnMesg;
        end

        function title=getWarningTitle(h)
            title=['Warning: ',h.getDisplayName()];
        end


        function title=getQuestionTitle(h)
            title=h.mQuestion.Title;
        end

        function defAns=getQuestionDefaultAnswer(h)
            defAns=h.mQuestion.Default;
        end

        function choices=getQuestionChoices(h)
            choices=h.mQuestion.Choices;
        end

        function prompt=getQuestionPrompt(h)
            prompt=h.mQuestion.Prompt;
        end

        function showFirstWarningHelp(h,hView,hDlg,widTag,value,varargin)%#ok<INUSD>
            arg=h.getHelpArgs();
            helpview(arg{1},[arg{2},'change']);
        end

        function questionResponse(h,hView,hDlg,widTag,value,varargin)%#ok<INUSL>
            try
                value=eval(value);
                h.mQuestion.UserResponse=h.mQuestion.Choices{value};
            catch ex %#ok<NASGU>
                h.mQuestion.UserResponse='';
            end
            hView.dismissDialog(hDlg,'Question');
            if(~isempty(h.mQuestion.Method))

                h.(h.mQuestion.Method)();
                h.mQuestion=[];
                h.mQuestionDialog=[];
            end
        end

        function closeQuestion(h,hDlg)%#ok<INUSD>









            h.mQuestionDialog=[];
            h.mFirstWarningDialog=[];
        end


        function temp=getDynamicWidgetTemplate(h)%#ok<MANU>
            temp=struct('Name','',...
            'Type','',...
            'Enabled','',...
            'Visible','',...
            'Entries','',...
            'Value','',...
            'Tag','',...
            'Data','',...
            'RowSpan',[],...
            'ColSpan',[]);
        end


        function[val,error]=getNumericValue(h,val)%#ok<INUSL>
            try
                val=eval(val);
                error=~isnumeric(val)||numel(val)>1||val<=0;
            catch ex
                val=ex.message;
                error=true;
            end
        end

        function[val,error]=getValueFromHexStr(h,s,allowNeg)%#ok<INUSL>
            if(nargin<3)
                allowNeg=false;
            end
            error=false;
            f=strfind(s,'0x');
            if(~isempty(f))
                try
                    val=hex2dec(s(f(1)+2:end));
                catch ex %#ok<NASGU>
                    val=[];
                    error=true;
                end
            else

                val=str2num(s);%#ok<ST2NM>
                if(int32(val)==val)
                    val=int32(val);
                    if(~allowNeg)&&(val<0)
                        val=[];
                        error=true;
                    end
                else
                    val=[];
                    error=true;
                end
            end
        end

        function ret=isValidName(h,val)%#ok<INUSL>
            if isempty(val)
                ret=false;
            elseif val(1)=='.'
                ret=iscvar(val(2:end));
            else
                ret=iscvar(val);
            end
        end


        function ideRefresh(h,~,hDlg,widTag,varargin)%#ok<INUSD>

            h.mIDEOptions=h.getIDEOptions(true);

            h.applyTargetPrefView(hDlg);
        end

        function name=getIdeOptionName(h,idx)
            if(~isempty(h.mIDEOptions)&&(length(h.mIDEOptions)>=idx))
                name=h.mIDEOptions{idx}.Name;
            else
                name='';
            end
        end

        function enabled=isIdeOptionEnabled(h)
            enabled=~isempty(h.mIDEOptions);
        end

        function visible=isIdeOptionVisible(h,idx)
            visible=~isempty(h.mIDEOptions)&&...
            (length(h.mIDEOptions)>=idx)&&...
            h.mIDEOptions{idx}.Enabled;
        end

        function type=getIdeOptionType(h,idx)
            if(~isempty(h.mIDEOptions)&&(length(h.mIDEOptions)>=idx))
                type=h.mIDEOptions{idx}.Type;
            else
                type='text';
            end
        end

        function list=getIdeOptionList(h,idx)
            if(~isempty(h.mIDEOptions)&&(length(h.mIDEOptions)>=idx))
                if(length(h.mIDEOptions{idx}.Entries)>1)
                    assert(strcmpi(h.mIDEOptions{idx}.Type,'combobox'),h.getAssertionMessage());
                end
                list=h.mIDEOptions{idx}.Entries;
            else
                list={};
            end
        end

        function val=getIdeCurOption(h,idx)
            if(~isempty(h.mIDEOptions)&&(length(h.mIDEOptions)>=idx))
                val=h.mIDEOptions{idx}.Value;
            else
                val='';
            end
        end


        function ret=isTargetPrefDlgDisbled(h)
            ret=h.mData.isBlockInLibrary(h.mConfigSet);
        end

        function ret=isBoardTypeEnabled(h)%#ok<MANU>





            ret=true;
        end

        function ret=isProcessorChangeable(h)%#ok<MANU>






            ret=true;
        end

        function ret=isFactoryBoard(h)
            nameList=h.mData.getFactoryBoardList();
            if(isempty(nameList))
                ret=false;
            else
                found=find(strcmp(nameList,h.mData.getBoardType()),1);
                ret=~isempty(found);
            end
        end

        function ret=isClockVisible(h)
            ret=(h.mData.getClockSpeedInMHZ()>0);
        end

        function ret=isViewEnabled(h)

            ret=~h.mData.isBlockInLibrary(h.mConfigSet);
        end

        function ret=isAddProcessorEnabled(h)
            ret=length(h.getChipNameList)>1;
        end

        function ret=isEditProcessorEnabled(h)%#ok<MANU>
            ret=false;
        end

        function ret=isDeleteProcessorEnabled(h)
            ret=~h.mData.isFactoryChip();
        end

        function ret=isRTOSEnabled(h)

            ret=h.mData.getNumSupportOSConfig()>1;



            if(ret)
                ret=h.mHaveTarget||~strcmp(h.mData.getCurOS(),'None');
            end
        end

        function ret=isSectionAttrCommandsSupported(h)

            hChip=h.mData.getChip();
            ret=hChip.isSectionAttributesSupported(h.mData.getCurOS());
        end

        function ret=isMemoryBankRemovable(h,curMemBankIdx)
            ret=h.mData.isMemoryBankRemovable(curMemBankIdx);
        end

        function ret=isDeleteCustomSectionEnabled(h)
            ret=h.mData.getNumMemCustomSections()>0;
        end

        function ret=isCacheVisible(h)
            ret=h.mData.getNumCacheEntries()>0;
        end

        function setIDE(h,hView,hDlg,widTag,ideNameOffset,varargin)%#ok<INUSL>
            ideList=h.mData.getAdaptorNameList();
            if length(ideList)==ideNameOffset
                matlab.addons.supportpackage.internal.explorer.showSupportPackagesForBaseProducts('EC','tripwire');
            else
                h.createWaitbar(0.3);
                ideName=ideList{ideNameOffset+1};
                source=h.getDialogSource(hDlg);
                if(h.mData.setIDE(source,ideName))




                    hDlg.apply();


                    hDlg.setWidgetValue(widTag,hDlg.getWidgetValue(widTag));
                    h.updateConfigSet(source);
                    h.mIDEOptions=h.getIDEOptions(false);

                    h.invalidateCachedChipList();

                    h.initializePeripheralHandler();
                    h.applyTargetPrefView(hDlg);
                end
            end
        end

        function setIDEFirst(h,hView,hDlg,widTag,ideNameOffset,varargin)%#ok<INUSL>
            ideList=h.mData.getAdaptorNameList();
            ideName=ideList{ideNameOffset+1};
            source=h.getDialogSource(hDlg);
            if(h.mData.setIDE(source,ideName))
                h.mIDEOptions=h.getIDEOptions(false);

                h.invalidateCachedChipList();

                h.initializePeripheralHandler();
            end
            h.applyTargetPrefView(hDlg);
        end

        function setBoardType(h,hView,hDlg,widTag,boardTypeOffset,varargin)%#ok<INUSL>
            h.createWaitbar(0.3);
            hDlg.apply();
            boardList=h.mData.getBoardTypeList();
            boardName=boardList{boardTypeOffset+1};
            source=h.getDialogSource(hDlg);
            [userDataChange,tagChange]=h.mData.setBoardType(source,boardName);
            if(userDataChange||tagChange)


                hDlg.setWidgetValue(widTag,hDlg.getWidgetValue(widTag));
                h.updateConfigSet(source);
            end
            if(tagChange)
                h.mIDEOptions=h.getIDEOptions(false);
            end


            h.invalidateCachedChipList();

            if(userDataChange)

                h.initializePeripheralHandler();
            end
            h.applyTargetPrefView(hDlg);
        end

        function setBoardTypeFirst(h,hView,hDlg,widTag,boardTypeOffset,varargin)%#ok<INUSL>
            boardList=h.mData.getBoardTypeList();
            boardName=boardList{boardTypeOffset+1};
            source=h.getDialogSource(hDlg);
            [userDataChange,tagChange]=h.mData.setBoardType(source,boardName);
            if(tagChange)
                h.mIDEOptions=h.getIDEOptions(false);
            end
            if(userDataChange)

                h.initializePeripheralHandler();
            end
            h.applyTargetPrefView(hDlg);
        end

        function setProcessorName(h,hView,hDlg,widTag,procOffset,varargin)%#ok<INUSL>
            procList=h.getChipNameList();
            procName=procList{procOffset+1};
            source=h.getDialogSource(hDlg);
            h.setProcessor(source,procName);
            h.applyTargetPrefView(hDlg);
        end

        function setProcessor(h,configSet,procName)
            h.createWaitbar(0.3);
            h.mData.setProcessor(procName);
            hChip=h.mData.getChip();
            if(h.mData.hasPeripherals()&&h.mHaveTarget)&&...
                exist('registertic2000.m','file')
                h.mPeripheralHandler=tic2000.targetprefext.Peripheral;
            else
                h.mPeripheralHandler=[];
            end
            csProps=hChip.getConfigSetSettings(h.mData.getCurChipName(),...
            h.mData.getCurChipSubFamily(),...
            h.mData.getBoardType(),...
            h.mData.getStackSize());
            ret=targetpref.checkAndSetActiveConfigSetSettings(configSet,csProps,true);%#ok<NASGU>
            h.mTargetPrefView.mCurSelection.MemoryBank.Row=0;
        end

        function setProcessorNameFirst(h,hView,hDlg,widTag,procOffset,varargin)%#ok<INUSL>
            procList=h.getChipNameList();
            procName=procList{procOffset+1};
            h.mData.setProcessor(procName);
            if(h.mData.hasPeripherals()&&h.mHaveTarget)&&...
                exist('registertic2000.m','file')
                h.mPeripheralHandler=tic2000.targetprefext.Peripheral;
            else
                h.mPeripheralHandler=[];
            end
            h.applyTargetPrefView(hDlg);
        end

        function switchUnregisteredProcessor(h,hView,hDlg,widTag,value,varargin)%#ok<INUSL,INUSD>
            source=h.getDialogSource(hDlg);
            cs=source;
            AllKnownChips=value;
            if~isempty(AllKnownChips)
                h.setProcessor(cs,AllKnownChips{1});
            else
                h.setIDEFirst(hView,hDlg,widTag,0);
            end
            h.mData.save(cs);
            set_param(cs.getConfigSetSource,'TargetHardwareResources',...
            get_param(cs,'TargetHardwareResources'));
            set_param(cs.getConfigSetSource.getModel,'Dirty','on');
            h.applyTargetPrefView(hDlg);
        end


        function showFirstWarningDialog(h)
            h.createView();
            h.mQuestion.Title=[h.getDisplayName,': ',DAStudio.message('ERRORHANDLER:tgtpref:TargetPrefCopyTitle')];
            h.mQuestion.Choices={DAStudio.message('ERRORHANDLER:tgtpref:TargetCopyOkToChange'),...
            DAStudio.message('ERRORHANDLER:tgtpref:TargetCopyNoToChange')};
            h.mQuestion.Prompt=DAStudio.message('ERRORHANDLER:tgtpref:TargetCopyQuestion');
            h.mQuestion.UserResponse='';
            h.mQuestion.Default=h.mQuestion.Choices{1};
            h.mQuestion.Method=[];
            if targetpref.showWarningErrorQuestionDialogs()
                h.mFirstWarningDialog=DAStudio.Dialog(h.mTargetPrefView,'FirstWarning','DLG_STANDALONE');
            else
                h.mFirstWarningDialog=[];
                h.mQuestion.UserResponse=h.mQuestion.Default;
            end
        end



        function addProcessor(h,hView,hDlg,widTag,procTag,varargin)%#ok<INUSL,INUSD>
            h.mTargetPrefDialog=hDlg;
            h.createView();
            names=genvarname([h.getChipNameList(),h.mData.getCurChipName()]);
            h.mNewProc.Name=names{end};
            h.mNewProc.BasedOn=h.mData.getCurChipName();
            h.mNewProc.CompilerOption=h.mData.getCompilerOption();
            h.mNewProc.LinkerOption=h.mData.getLinkerOption();
            h.mAddProcessorDialog=DAStudio.Dialog(h.mTargetPrefView,'AddProcessor','DLG_STANDALONE');
        end

        function title=getAddProcessorTitle(h)
            title=['Add Processor: ',h.getDisplayName()];
        end

        function name=getAddProcessorNewName(h)
            assert(~isempty(h.mNewProc),h.getAssertionMessage());
            name=h.mNewProc.Name;
        end

        function setAddProcessorNewName(h,hView,hDlg,widTag,value,varargin)%#ok<INUSL>
            assert(~isempty(h.mNewProc),h.getAssertionMessage());
            if~isempty(value)
                h.mNewProc.Name=value;

            end
        end

        function setAddProcessorCompilerOption(h,hView,hDlg,widTag,value,varargin)%#ok<INUSL>
            assert(~isempty(h.mNewProc),h.getAssertionMessage());
            h.mNewProc.CompilerOption=h.splitLines(value);
        end

        function setAddProcessorLinkerOption(h,hView,hDlg,widTag,value,varargin)%#ok<INUSL>
            assert(~isempty(h.mNewProc),h.getAssertionMessage());
            h.mNewProc.LinkerOption=h.splitLines(value);
        end

        function namelist=getAddProcessorNameList(h)
            namelist=h.getChipNameList();
        end

        function name=getAddProcessorBasedOn(h)
            name=h.mNewProc.BasedOn;
        end

        function setAddProcessorBasedOn(h,hView,hDlg,widTag,value,varargin)%#ok<INUSL>
            procList=h.getChipNameList();
            procName=procList{value+1};
            h.mNewProc.BasedOn=procName;
            h.invalidateCachedChipList();



        end

        function option=getAddProcessorCompilerOption(h)
            option=h.mNewProc.CompilerOption;
        end

        function option=getAddProcessorLinkerOption(h)
            option=h.mNewProc.LinkerOption;
        end

        function[valid,errorstr]=validateAddProcessor(h,hDlg)%#ok<INUSD>
            foundChip=find(strcmp(h.getAddProcessorNameList(),h.getAddProcessorNewName()),1);
            valid=isempty(foundChip);
            if(~valid)
                errorstr=DAStudio.message('ERRORHANDLER:tgtpref:NewProcessorNotUnique',h.getAddProcessorNewName());
            else
                errorstr='';
            end
        end

        function[success,errorstr]=updateRegistryForNewProcessor(h,Name,BasedOn,CompilerOption,LinkerOption)
            assert(strcmp(BasedOn,h.mData.getCurChipName()),h.getAssertionMessage());
            tag=h.mData.getTag();
            newData=h.mData.copyForCustomChip(Name,BasedOn,CompilerOption,LinkerOption);
            [procInfo,toolInfo]=newData.createInfoForRegistry();
            [success,errorstr]=targetpref.registerNewProcessor(tag,procInfo,toolInfo);
        end

        function[valid,errorstr]=applyAddProcessor(h,hDlg)%#ok<INUSD>
            [valid,errorstr]=h.updateRegistryForNewProcessor(h.mNewProc.Name,...
            h.mNewProc.BasedOn,h.mNewProc.CompilerOption,...
            h.mNewProc.LinkerOption);
            source=h.getDialogSource(h.mTargetPrefDialog);
            if(valid)
                h.setProcessor(source,h.mNewProc.Name);
                h.mNewProc=[];
                h.mAddProcessorDialog=[];
                h.updateTargetPrefViewForNewChip();
            end
        end

        function closeAddProcessor(h,hDlg)%#ok<INUSD>
            h.mNewProc=[];
            h.mAddProcessorDialog=[];
        end


        function deleteProcessor(h,hView,hDlg,widTag,procOffset,varargin)%#ok<INUSL,INUSD>
            h.mTargetPrefDialog=hDlg;
            title=[h.getDisplayName,': ',DAStudio.message('ERRORHANDLER:tgtpref:DeleteProcessorTitle')];
            h.showQuestion(title,...
            'tgtpref:DeleteProcessorQuestion',...
            {'tgtpref:TargetCopyOkToChange','tgtpref:TargetCopyNoToChange'},...
            2,'deleteProcessorResponse',h.mData.getCurChipName());
        end

        function deleteProcessorResponse(h)
            if isempty(h.mQuestion.UserResponse)||strcmp(h.mQuestion.UserResponse,h.mQuestion.Default)
                h.mQuestion=[];
                h.mQuestionDialog=[];
                return;
            end
            h.mQuestion=[];
            h.mQuestionDialog=[];

            curlist=h.getChipNameList();
            curchip=h.mData.getCurChipName();
            idx=find(strcmp(curlist,curchip),1);
            if(idx<2)
                newproc=curlist{2};
            else
                newproc=curlist{idx-1};
            end
            source=h.getDialogSource(h.mTargetPrefDialog);
            h.setProcessor(source,newproc);
            [success,errorstr]=targetpref.deleteProcessorFromRegistry(h.mData.getTag(),curchip);

            if(~success)
                h.showWarning('tgtpref:ErrorDeleteProcessor',errorstr);
            end

            h.updateTargetPrefViewForNewChip();
        end


        function setClockSpeed(h,hView,hDlg,widTag,value,varargin)
            [value,error]=h.getNumericValue(value);
            if(error)
                h.showError('tgtpref:InvalidCPUClock');
                hDlg.setWidgetValue(widTag,sprintf('%g',h.mData.getClockSpeedInMHZ()));
            else
                h.mData.setClockSpeed(value);


                if~isempty(regexp(h.mData.getCurChipName,'(F|C|R)28\d+(|_cpu|_cla)','match'))


                    updatePeripherals(h,hView,hDlg,'Clocking','AutoSetPllSettings','Clocking_SysCLKControl_UICallback');
                end
            end
            h.applyTargetPrefView(hDlg);
        end

        function updatePeripherals(h,hView,hDlg,periph_name_to_update,periph_property_name,periph_callback_name)
            targetPeripherals=h.mData.getPeripherals;
            peripheral_list=fieldnames(targetPeripherals.properties.prompt);

            PeripheralHints=hView.mController.getPeripheralHints('TargetPrefPeripherals_');

            periph_index=find(cellfun(@any,strfind(peripheral_list,periph_name_to_update)));
            for i=1:numel(periph_index)


                periph_property_name_idx=...
                find(cellfun(@any,strfind(fieldnames(targetPeripherals.properties.prompt.(peripheral_list{periph_index(i)})),periph_property_name)));
                hintRec.Data={peripheral_list{periph_index(i)},periph_property_name};

                cur_widTag_det=(PeripheralHints{periph_index(i)}{periph_property_name_idx});
                cur_widTag=cur_widTag_det.Tag;

                if iscell(targetPeripherals.properties.fields.(peripheral_list{periph_index(i)}).(periph_property_name))
                    curValue=find(strcmp(targetPeripherals.properties.fields.(peripheral_list{periph_index(i)}).(periph_property_name),...
                    targetPeripherals.value.(peripheral_list{periph_index(i)}).(periph_property_name)))-1;
                else
                    switch targetPeripherals.properties.fields.(peripheral_list{periph_index(i)}).(periph_property_name)
                    case 'on/off'
                        if strcmp(targetPeripherals.value.(peripheral_list{periph_index(i)}).(periph_property_name),'on')
                            curValue=1;
                        else
                            curValue=0;
                        end
                    otherwise
                        curValue=num2str(targetPeripherals.value.(peripheral_list{periph_index(i)}).(periph_property_name));
                    end
                end
                h.mPeripheralHandler.(periph_callback_name)(h,hView,hDlg,cur_widTag,curValue,periph_index(i),...
                periph_property_name_idx,h.mData,h.mData.getPeripherals,hintRec);
            end
        end

        function setOperatingSystem(h,hView,hDlg,widTag,value,varargin)%#ok<INUSL>
            osList=h.mData.getSupportedOSList();
            assert(value>=0&&value<numel(osList),h.getAssertionMessage());
            h.mData.setCurOS(osList{value+1});

            hDlg.setWidgetValue('TargetPrefSection_CompilerSectionMap',h.mData.getMemCompilerSectionName(1));
            if(h.mData.getNumMemCustomSections()>0)
                hDlg.setWidgetValue('TargetPrefSection_CompilerSectionMap',h.mData.getMemCustomSectionName(1));
            end


            hOS=linkfoundation.pjtgenerator.OS;
            hOS.loadOSParams(h.mData.getCurOS);

            h.mData.setOSBaseRatePriority(hOS.baseRatePriority);


            ret=targetpref.checkAndSetActiveConfigSetSettings(h.mConfigSet,hOS.configSetSettings,true);%#ok<NASGU>
            h.applyTargetPrefView(hDlg);
        end

        function setBoardSourceFiles(h,hView,hDlg,widTag,value,varargin)%#ok<INUSL>
            h.mData.setBoardSourceFiles(h.splitLines(value));
            h.applyTargetPrefView(hDlg);
        end

        function setIncludePaths(h,hView,hDlg,widTag,value,varargin)%#ok<INUSL>
            h.mData.setIncludePaths(h.splitLines(value));
            h.applyTargetPrefView(hDlg);
        end

        function setLibrariesLittleEndian(h,hView,hDlg,widTag,value,allLibTag,varargin)%#ok<INUSL>
            h.mData.setLibrariesLittleEndian(h.splitLines(value));
            hDlg.setWidgetValue(allLibTag,h.mData.getAllLibraries());
            h.applyTargetPrefView(hDlg);
        end

        function setLibrariesBigEndian(h,hView,hDlg,widTag,value,allLibTag,varargin)%#ok<INUSL>
            h.mData.setLibrariesBigEndian(h.splitLines(value));
            hDlg.setWidgetValue(allLibTag,h.mData.getAllLibraries());
            h.applyTargetPrefView(hDlg);
        end

        function setInitFunction(h,hView,hDlg,widTag,value,varargin)%#ok<INUSL>
            h.mData.setInitFunction(h.splitLines(value));
            h.applyTargetPrefView(hDlg);
        end

        function setTerminateFunction(h,hView,hDlg,widTag,value,varargin)%#ok<INUSL>
            h.mData.setTerminateFunction(h.splitLines(value));
            h.applyTargetPrefView(hDlg);
        end

        function show=showMemory(h)
            show=h.mData.isRealTime();
        end

        function show=showSection(h)
            show=h.mData.isRealTime();
        end

        function show=showPeripherals(h)
            show=h.mData.hasPeripherals()&&h.mHaveTarget&&...
            exist('registertic2000.m','file');
            if show
                assert(~isempty(h.mPeripheralHandler),h.getAssertionMessage());
            end
        end

        function show=showRTOS(h)

            show=~strcmp(h.mData.getCurOS(),'None');
        end

        function ret=isRTOSDynamicTasksEnabled(h)
            ret=h.mData.getNumRTOSHeaps()>0;
        end


        function setIDEOption(h,hView,hDlg,widTag,curValue,idx,varargin)%#ok<INUSL>
            if(idx==1)&&(~strcmpi(h.mIDEOptions{1}.Value,h.mIDEOptions{1}.Entries{curValue+1}))
                h.mIDEOptions{1}.Value=h.mIDEOptions{1}.Entries{curValue+1};
                h.mIDEOptions{2}.Entries=h.mIDEOptions{2}.Data{curValue+1};
                h.mIDEOptions{2}.Value=h.mIDEOptions{2}.Data{curValue+1}{1};
                hDlg.refresh();
            else
                h.mIDEOptions{idx}.Value=h.mIDEOptions{idx}.Entries{curValue+1};
            end
            h.applyTargetPrefView(hDlg);
        end


        function addMemoryBank(h,hView,hDlg,widTag,tableTag,varargin)%#ok<INUSL>
            useMemIdx=hDlg.getSelectedTableRow(tableTag)+1;
            addedIdx=h.mData.addMemoryBank(useMemIdx);
            source=h.getDialogSource(hDlg);
            h.mData.save(source);
            h.mTargetPrefView.mCurSelection.MemoryBank.Row=addedIdx-1;
            h.mTargetPrefView.mCustomMemBanks=h.mData.getAllMemoryBankNames();
            hDlg.enableApplyButton(true);
            hDlg.setFocus(widTag);
            h.applyTargetPrefView(hDlg);
        end

        function deleteMemoryBank(h,hView,hDlg,widTag,tableTag,varargin)%#ok<INUSL>
            curMemIdx=hDlg.getSelectedTableRow(tableTag)+1;
            assert(h.isMemoryBankRemovable(curMemIdx),h.getAssertionMessage());
            h.mData.moveAllSectionsAwayFrom(curMemIdx);
            prevIdx=h.mData.deleteMemoryBank(curMemIdx);
            source=h.getDialogSource(hDlg);
            h.mData.save(source);
            h.mTargetPrefView.mCurSelection.MemoryBank.Row=prevIdx-1;
            h.mTargetPrefView.mCustomMemBanks=h.mData.getAllMemoryBankNames();
            hDlg.enableApplyButton(true);
            hDlg.setFocus(widTag);
            h.applyTargetPrefView(hDlg);
        end

        function setMemoryBankName(h,hView,hDlg,widTag,memIdx,val,varargin)%#ok<INUSL>
            assert(h.isMemoryBankRemovable(memIdx),h.getAssertionMessage());
            if(~h.isValidName(val))
                hDlg.setTableItemValue(widTag,memIdx-1,0,h.mData.getMemoryBankName(memIdx));
                h.showError('tgtpref:InvalidName',val);
            else
                found=find(strcmp(h.mData.getAllMemoryBankNames(),val),1);
                if(~isempty(found))
                    h.showError('tgtpref:UniqueMemoryBank',val);
                    hDlg.setTableItemValue(widTag,memIdx-1,0,h.mData.getMemoryBankName(memIdx));
                else
                    source=h.getDialogSource(hDlg);
                    h.mData.setMemoryBankName(source,memIdx,val);
                end
            end

            if(~isempty(h.mTargetPrefView.mCustomMemBanks))
                h.mTargetPrefView.mCustomMemBanks=[];
            else
                h.mTargetPrefView.mCustomMemBanks=h.mData.getAllMemoryBankNames();
            end
            h.applyTargetPrefView(hDlg);
        end

        function setMemoryBankAddress(h,hView,hDlg,widTag,memIdx,val)%#ok<INUSL>
            [value,error]=h.getValueFromHexStr(val);
            if(error)
                h.showError('tgtpref:InvalidAddress',val);
            else
                source=h.getDialogSource(hDlg);
                h.mData.setMemoryBankAddr(source,memIdx,value);
            end

            hDlg.setTableItemValue(widTag,memIdx-1,1,sprintf('0x%08x',h.mData.getMemoryBankAddr(memIdx)));
            h.applyTargetPrefView(hDlg);
        end

        function setMemoryBankLength(h,hView,hDlg,widTag,memIdx,val)%#ok<INUSL>
            [value,error]=h.getValueFromHexStr(val);
            if(error)
                h.showError('tgtpref:InvalidLength',val);
            else
                source=h.getDialogSource(hDlg);
                h.mData.setMemoryBankLength(source,memIdx,value);
            end

            hDlg.setTableItemValue(widTag,memIdx-1,2,sprintf('0x%08x',h.mData.getMemoryBankLength(memIdx)));
            h.applyTargetPrefView(hDlg);
        end

        function setMemoryBankContents(h,hView,hDlg,widTag,memIdx,val)%#ok<INUSL>
            assert(h.mData.isMemoryBankContentChangeable(memIdx),h.getAssertionMessage());
            bankContents=h.mData.getMemoryBankContentsChoices();
            assert(val>0&&val<=numel(bankContents),h.getAssertionMessage());
            minavail=h.mData.WillHaveRequiredBanks(memIdx,bankContents{val});
            if(minavail)
                source=h.getDialogSource(hDlg);
                h.mData.setMemoryBankContents(source,memIdx,bankContents{val});
                if(~isempty(h.mTargetPrefView.mCustomMemBanks))
                    h.mTargetPrefView.mCustomMemBanks=[];
                else
                    h.mTargetPrefView.mCustomMemBanks=h.mData.getAllMemoryBankNames();
                end
            else
                h.showError('tgtpref:MinBankConfig',bankContents{val});
                hDlg.setTableItemValue(widTag,memIdx-1,3,h.mData.getMemoryBankContents(memIdx));
            end
            h.applyTargetPrefView(hDlg);
        end

        function setCacheConfig(h,hDlg,widTag,cacheIdx,valIdx)%#ok<INUSL>
            assert(h.isCacheVisible(),h.getAssertionMessage());
            assert(cacheIdx>0&&cacheIdx<=h.mData.getNumCacheEntries(),h.getAssertionMessage());
            cacheConfigs=h.mData.getDefaultCacheConfigEntriesForLevel(cacheIdx);
            assert(valIdx>0&&valIdx<=numel(cacheConfigs),h.getAssertionMessage());
            source=h.getDialogSource(hDlg);
            h.mData.setCurCacheConfig(source,cacheIdx,cacheConfigs{valIdx});
            h.applyTargetPrefView(hDlg);
        end


        function ret=canCompilerSectionHaveMultiPlacement(h,sectionName)

            hChip=h.mData.getChip();
            ret=hChip.supportsMultipleCompilerSections();
            if(ret)


                if(sectionName(1)=='.')
                    lookFor=sectionName(2:end);
                else
                    lookFor=sectionName;
                end
                found=find(strcmp({'heap','stack'},lookFor),1);
                ret=isempty(found);
            end
        end

        function addCustomSection(h,hView,hDlg,widTag,treeTag,varargin)%#ok<INUSL>
            useSection=hDlg.getWidgetValue(treeTag);
            addedName=h.mData.addCustomSection(useSection);
            source=h.getDialogSource(hDlg);
            h.mData.save(source);
            hDlg.setWidgetValue(treeTag,addedName);
            hDlg.enableApplyButton(true);
            h.applyTargetPrefView(hDlg);
        end

        function deleteCustomSection(h,hView,hDlg,widTag,treeTag,varargin)%#ok<INUSL>
            curSection=hDlg.getWidgetValue(treeTag);
            names=h.mData.getMemCustomSectionNames();
            last=strcmp(curSection,names{end});


            if(last)&&(numel(names)>1)
                hDlg.setWidgetValue(treeTag,names{end-1});
            end
            h.mData.deleteCustomSection(curSection);
            source=h.getDialogSource(hDlg);
            h.mData.save(source);
            hDlg.enableApplyButton(true);

            h.applyTargetPrefView(hDlg);
        end

        function setSectionPlacement(h,hView,hDlg,widTag,value,idx,compSectionName,varargin)%#ok<INUSD>
            if(numel(value)<1)

                curVal=hView.getMatchIdx(h.mData.getMemoryBankNamesForSection(idx),...
                h.mData.getMemCompilerSectionPlacement(idx));
                hDlg.setWidgetValue(widTag,curVal);
            else
                banks=h.mData.getMemoryBankNamesForSection(idx);
                placement={banks{value+1}};%#ok<CCAT1>
                h.mData.setMemCompilerSectionPlacement(idx,placement);
            end
            h.applyTargetPrefView(hDlg);
        end

        function setSectionAttributes(h,hView,hDlg,widTag,value,idx,compSectionName,varargin)%#ok<INUSD,INUSL>
            h.mData.setMemCompilerSectionAttributes(idx,{value});
            h.applyTargetPrefView(hDlg);
        end

        function setSectionCommands(h,hView,hDlg,widTag,value,idx,compSectionName,varargin)%#ok<INUSD,INUSL>
            h.mData.setMemCompilerSectionCommands(idx,{value});
            h.applyTargetPrefView(hDlg);
        end

        function setCustomSectionPlacement(h,hView,hDlg,widTag,value,idx,varargin)
            if(numel(value)<1)

                curVal=hView.getMatchIdx(h.mData.getMemoryBankNamesForCustomSection(idx),...
                h.mData.getMemCustomSectionPlacement(idx));
                hDlg.setWidgetValue(widTag,curVal);
            else
                banks=h.mData.getMemoryBankNamesForCustomSection(idx);
                placement={banks{value+1}};%#ok<CCAT1>
                h.mData.setMemCustomSectionPlacement(idx,placement);
            end
            h.applyTargetPrefView(hDlg);
        end

        function setCustomSectionName(h,hView,hDlg,widTag,value,idx,varargin)%#ok<INUSL>
            if(~h.isValidName(value))
                hDlg.setWidgetValue(widTag,h.mData.getMemCustomSectionName(idx));
                h.showError('tgtpref:InvalidName',value);
            else
                found=find(strcmp(h.mData.getAllSectionNames(),value),1);
                if(~isempty(found))
                    h.showError('tgtpref:UniqueSectionName',value);
                    hDlg.setWidgetValue(widTag,h.mData.getMemCustomSectionName(idx));
                else
                    h.mData.setCustomSectionName(idx,value);
                end
            end
            h.applyTargetPrefView(hDlg);
        end

        function setCustomSectionContent(h,hView,hDlg,widTag,value,idx,varargin)%#ok<INUSL>
            contents=h.mData.getCustomSectionContentsChoices();
            newContent=contents{value+1};
            if(~strcmp(newContent,h.mData.getMemCustomSectionContents(idx)))
                h.mData.setMemCustomSectionContents(idx,contents{value+1});
                banks=h.mData.getMemoryBankNamesForCustomSection(idx);
                placement={banks{1}};%#ok<CCAT1>
                h.mData.setMemCustomSectionPlacement(idx,placement);

                if(~isempty(h.mTargetPrefView.mCustomMemBanks))
                    h.mTargetPrefView.mCustomMemBanks=[];
                else
                    h.mTargetPrefView.mCustomMemBanks=h.mData.getAllMemoryBankNames();
                end
            end
            h.applyTargetPrefView(hDlg);
        end

        function setCustomSectionAttributes(h,hView,hDlg,widTag,value,idx,varargin)%#ok<INUSL>
            h.mData.setMemCustomSectionAttributes(idx,{value});
            h.applyTargetPrefView(hDlg);
        end

        function setCustomSectionCommands(h,hView,hDlg,widTag,value,idx,varargin)%#ok<INUSL>
            h.mData.setMemCustomSectionCommands(idx,{value});
            h.applyTargetPrefView(hDlg);
        end



        function setRTOSHeapCreate(h,hView,hDlg,widTag,idx,val)%#ok<INUSL>
            BanksForHeap=h.mData.getMemoryBankNamesForRTOSData();
            h.mData.setRTOSCreateHeap(BanksForHeap{idx},val);

            hDlg.enableApplyButton(true);

            if(~isempty(h.mTargetPrefView.mCustomMemBanks))
                h.mTargetPrefView.mCustomMemBanks=[];
            else
                h.mTargetPrefView.mCustomMemBanks=h.mData.getAllMemoryBankNames();
            end

        end

        function setRTOSHeapLabel(h,hView,hDlg,widTag,idx,val)%#ok<INUSL>
            BanksForHeap=h.mData.getMemoryBankNamesForRTOSData();
            if(h.isValidName(val))
                curLabels=h.mData.getAllRTOSHeapLabels();
                found=find(strcmp(curLabels,val),1);
                if(~isempty(found))
                    h.showError('tgtpref:InvalidLabel',val);
                else
                    h.mData.setRTOSHeapLabelFor(BanksForHeap{idx},val);
                end
            end
            hDlg.setTableItemValue(widTag,idx-1,1,h.mData.getRTOSHeapLabelFor(BanksForHeap{idx}));

        end

        function setRTOSHeapSize(h,hView,hDlg,widTag,idx,val)%#ok<INUSL>
            BanksForHeap=h.mData.getMemoryBankNamesForRTOSData();
            [value,error]=h.getValueFromHexStr(val);
            if(error)
                h.showError('tgtpref:InvalidSize',val);
            else
                h.mData.setRTOSHeapSizeFor(BanksForHeap{idx},value);
            end

            hDlg.setTableItemValue(widTag,idx-1,2,sprintf('0x%08x',h.mData.getRTOSHeapSizeFor(BanksForHeap{idx})));

        end

        function setRTOSDataPlacement(h,hView,hDlg,widTag,offset,varargin)%#ok<INUSL>
            bankNames=h.mData.getMemoryBankNamesForRTOSData();
            h.mData.setRTOSDataPlacement(bankNames{offset+1});
            h.applyTargetPrefView(hDlg);
        end

        function setRTOSCodePlacement(h,hView,hDlg,widTag,offset,varargin)%#ok<INUSL>
            bankNames=h.mData.getMemoryBankNamesForRTOSCode();
            h.mData.setRTOSCodePlacement(bankNames{offset+1});
            h.applyTargetPrefView(hDlg);
        end

        function setRTOSStackSize(h,hView,hDlg,widTag,val,varargin)%#ok<INUSL>
            [value,error]=h.getValueFromHexStr(val);
            if(error)
                h.showError('tgtpref:InvalidSize',val);
                hDlg.setWidgetValue(widTag,h.mData.getRTOSStackSize());
            else
                h.mData.setRTOSStackSize(value);
            end
            h.applyTargetPrefView(hDlg);
        end

        function setRTOSStaticTasks(h,hView,hDlg,widTag,offset,varargin)%#ok<INUSL>
            bankNames=h.mData.getMemoryBankNamesForRTOSData();
            h.mData.setRTOSStaticTasks(bankNames{offset+1});
            h.applyTargetPrefView(hDlg);
        end

        function setRTOSDynamicTasks(h,hView,hDlg,widTag,offset,varargin)%#ok<INUSL>
            bankNames=h.mData.getMemoryBankNamesForRTOSDynamicStack();
            h.mData.setRTOSDynamicTasks(bankNames{offset+1});
            h.applyTargetPrefView(hDlg);
        end

        function setOSSchedulingMode(h,hView,hDlg,widTag,offset,varargin)%#ok<INUSL>
            osModes=h.mData.getOSSchedulingModes();
            h.mData.setOSSchedulingMode(osModes{offset+1});
            h.applyTargetPrefView(hDlg);
        end

        function ret=getConcurrentTaskMode(h)
            val=get_param(h.mModel,'ConcurrentTasks');
            ret=strcmpi(val,'on');
        end

        function setOSBaseRatePriority(h,hView,hDlg,widTag,value,varargin)%#ok<INUSL>
            [value,error]=h.getNumericValue(value);
            if(error)
                h.showError('tgtpref:InvalidBaseRatePriority');
                hDlg.setWidgetValue(widTag,sprintf('%g',h.mData.getOSBaseRatePriority()));
            else
                h.mData.setOSBaseRatePriority(value);
            end
            h.applyTargetPrefView(hDlg);
        end


        function assertMsg=getAssertionMessage(h)
            if(isempty(h.mAssertionMessage))
                h.mAssertionMessage=DAStudio.message('ERRORHANDLER:tgtpref:DataInconsistent');
            end
            assertMsg=h.mAssertionMessage;
        end

        function hints=getPeripheralHints(h,tagPrefix)
            hints=h.mPeripheralHandler.getViewHints(h,h.mData,tagPrefix);
        end

        function handlePeripheral(h,hView,hDlg,widTag,curValue,peripheralIdx,widgetIdx,varargin)

            h.mPeripheralHandler.checkAndSet(h,hView,hDlg,widTag,curValue,peripheralIdx,widgetIdx,varargin{:});
            h.applyTargetPrefView(hDlg);
        end


        function[valid,errorstr]=validateTargetPrefView(h,hDlg)%#ok<INUSD>
            valid=h.mData.isProcRegistered();
            if~valid
                errorstr=DAStudio.message('ERRORHANDLER:tgtpref:InvalidProcNeedChange',h.mData.getCurChipName(),h.mData.getBoardType());
            else
                errorstr='';
            end
            if(h.mData.needSave())
                [valid,errorstr]=h.mData.validateMemorySetting();
                if(~valid)
                    return;
                end
            end
        end

        function[valid,errorstr]=applyTargetPrefView(h,hDlg)
            valid=true;
            errorstr='';
            if(h.isTargetPrefDlgDisbled())
                return;
            end
            if(h.isIdeOptionEnabled())
                if(h.isIdeOptionVisible(1))
                    h.mData.setIDEOption(1,h.mIDEOptions{1}.Value);
                end
                if(h.isIdeOptionVisible(2))
                    h.mData.setIDEOption(2,h.mIDEOptions{2}.Value);
                end
                if isa(hDlg,'DAStudio.Dialog')
                    hDlg.refresh();
                end
            end

            if isa(hDlg,'DAStudio.Dialog')
                configSet=h.getDialogSource(hDlg);
            else
                configSet=h.getDialogSource(h.mTargetPrefDialog);
            end

            h.mData.save(configSet);




            set_param(configSet,'TargetPrefTimeStamp',datestr(now));

            valid=true;
            errorstr='';
        end

        function closeTargetPrefView(h,hDlg)%#ok<INUSD>

            h.closeViews();
        end

        function[valid,errorstr]=validate(h,hDlg,dlgName)
            switch(dlgName)
            case 'TargetPrefView',
                [valid,errorstr]=h.validateTargetPrefView(hDlg);
            case 'AddProcessor',
                [valid,errorstr]=h.validateAddProcessor(hDlg);
            otherwise,
                valid=true;
                errorstr='';
            end
        end

        function[valid,errorstr]=apply(h,hDlg,dlgName)
            switch(dlgName)
            case 'TargetPrefView',
                [valid,errorstr]=h.applyTargetPrefView(hDlg);
            case 'AddProcessor',
                [valid,errorstr]=h.applyAddProcessor(hDlg);
            otherwise,
                valid=true;
                errorstr='';
            end
        end

        function close(h,hDlg,dlgName)
            switch(dlgName)
            case 'TargetPrefView',
                h.closeTargetPrefView(hDlg);
            case 'AddProcessor',
                h.closeAddProcessor(hDlg);
            case{'Question','FirstWarning'},
                h.closeQuestion(hDlg);
            case 'Error',
                h.closeError(hDlg);
            case 'Warning',
                h.closeWarning(hDlg);
            end
        end


        function hDlg=getTgtPrefDialog(h)
            tp='Code Generation/Coder Target';
            set_param(h.mConfigSet,'CurrentDlgPage',tp);
            h.mConfigSet.refreshDialog();
            hDlg=DAStudio.ToolRoot.getOpenDialogs();
        end

        function setLastException(h,type,id,mesg)
            if(isempty(id))
                h.mLastException=struct('Type',type,'MessageID','','Message',mesg);
            else
                h.mLastException=struct('Type',type,'MessageID',id,'Message',mesg);
            end
        end

        function ex=getLastException(h)
            ex=h.mLastException;
        end

        function resetLastException(h)
            h.mLastException=[];
        end

        function retChipNameList=getChipNameList(h)
            if isempty(h.mCachedChipList)
                h.mCachedChipList=h.mData.getChipNameList();
            end
            retChipNameList=h.mCachedChipList;
        end

        function disableWarning=isDeprecationWarningDisabled(h)%#ok<MANU>
            disableWarning=~isempty(getenv('TARGETPREFBLK_TESTMODE'));
        end

    end

end
