function[varargout]=modeladvisorutil2(methods,varargin)




    switch methods
    case 'validateChecksBeingRun'
        varargout{1}=false;
        if isempty(varargin)
            return;
        else
            checkId=varargin{1};

            varargout{1}=Advisor.RegisterCGIRInspectors.getInstance.verifyRun(checkId);
        end
    case 'validateEnableDesignInspector'
        varargout{1}=Advisor.RegisterCGIRInspectors.getInstance.anyInspectorsRegistered();
        return;
    case 'addToCGIRResults'

    case 'addToCGIRResultsText'
        Advisor.RegisterCGIRInspectorResults.getInstance.addTextResults(varargin{1}{1},varargin{2:end});
    case 'addToCGIRResultsTags'
        Advisor.RegisterCGIRInspectorResults.getInstance.addTagsResults(varargin{1}{1},varargin{2:end});
    case 'ValidateLicense'
        [varargout{1},varargout{2}]=loc_validateChecks(varargin{1});
    case 'WarnOldCheckID'
        if 0
            warning('Simulink:ModelAdvisor:ObsoleteCheckID',...
            ['The Model Advisor check ID ',varargin{1},' is not '...
            ,'recommended. Use ',varargin{2},' instead.']);%#ok<UNRCH>
        end
    case 'ProcessCallbackFcn'
        callInterface=varargin{1};
        maobj=varargin{2};
        callbackFunctionName=callInterface{1};
        if length(callInterface)>2
            argsList={};
            for i=3:2:length(callInterface)
                switch callInterface{i+1}
                case 'string'
                    argsList{end+1}=callInterface{i};
                case 'token'
                    if~isempty(strfind(callInterface{i},'%<SystemName>'))
                        argsList{end+1}=strrep(callInterface{i},'%<SystemName>',maobj.SystemName);
                    elseif~isempty(strfind(callInterface{i},'%<System>'))
                        argsList{end+1}=strrep(callInterface{i},'%<System>',maobj.System);
                    end
                end
            end
            if nargout>0
                varargout{1}=feval(callbackFunctionName,argsList{:});
            else
                feval(callbackFunctionName,argsList{:});
            end
        else
            if nargout>0
                varargout{1}=feval(callbackFunctionName);
            else
                feval(callbackFunctionName);
            end
        end
    case 'filereadutf8'
        filename=varargin{1};

        [fid,errmessage]=fopen(filename,'r','n','utf-8');
        if fid==(-1)
            error(message('MATLAB:fileread:cannotOpenFile',filename,errmessage));
        end
        try

            contents=fread(fid,'*char')';
        catch exception

            fclose(fid);
            throw(exception);
        end

        fclose(fid);
        varargout{1}=contents;
    case 'BringMAToForeground'
        mdladvObj=Simulink.ModelAdvisor.getActiveModelAdvisorObj;
        if isa(mdladvObj,'Simulink.ModelAdvisor')
            if nargin>1
                nodeIndex=str2double(varargin{1});
                if nodeIndex>0
                    nodeObj=mdladvObj.TaskAdvisorCellArray{nodeIndex};
                else
                    nodeObj=mdladvObj.TaskAdvisorRoot;
                end
                nodeObj.viewReport;
            else
                mdladvObj.displayExplorer;
            end
        end
    case 'ClearHighlitedResultObjs'
        mdladvObj=Simulink.ModelAdvisor.getActiveModelAdvisorObj;

        if~isempty(mdladvObj.ProjectResultMapData)
            mapdata=mdladvObj.ProjectResultMapData.keys;
        else
            mapdata={};
        end
        fadestyle=sf('find','all','style.name','fade');
        for i=1:length(mapdata)
            try
                temp=Simulink.ID.getHandle(mapdata{i});
            catch
                continue;
            end
            if isa(temp,'Stateflow.Object')
                if isa(temp,'Stateflow.Chart')||isa(temp,'Stateflow.State')||isa(temp,'Stateflow.Transition')
                    sf('SetAltStyle',fadestyle,temp.ID);
                end
            elseif strcmp(get_param(temp,'Type'),'block_diagram')

            else
                set_param(temp,'HiliteAncestors','fade');
            end

            if isa(mdladvObj.ResultGUI,'DAStudio.Informer')
                if isa(temp,'Stateflow.Object')
                    h=temp;
                else
                    h=get_param(temp,'object');
                end
                mdladvObj.ResultGUI.mapData(h,'');
            end
        end


        mdladvObj.ProjectResultMapData=containers.Map('KeyType','char','ValueType','any');


    case 'CloseResultGUICallback'
        mdladvObj=Simulink.ModelAdvisor.getActiveModelAdvisorObj;

        if strcmp(get_param(bdroot(mdladvObj.System),'ReqHilite'),'on')
            return;
        end
        modeladvisorprivate('modeladvisorutil2','ClearHighlitedResultObjs');









        if isa(mdladvObj,'Simulink.ModelAdvisor')

            machine=find(sfroot,'-isa','Stateflow.Machine','-and','Name',bdroot(mdladvObj.SystemName));
            if~isempty(machine)
                machineID=machine.id;

                sf('ClearAltStyles',machineID);
                sf('Redraw',machineID);
            end
            set_param(bdroot(mdladvObj.System),'HiliteAncestors','off');
            mdladvObj.TaskAdvisorRoot.updateStates('refreshME');
        end











    case 'CancelHighlighting'


        ma=Simulink.ModelAdvisor.getActiveModelAdvisorObj();

        if isa(ma,'Simulink.ModelAdvisor')
            ma.AtticData.HighlightingCanceled=true;
        end

    case 'getDateString'

        varargout{1}=loc_getDateString(varargin{1});

    case 'CloseResultGUI'
        if nargin>1
            systemName=varargin{1};
            am=Advisor.Manager.getInstance;
            applicationObj=am.getApplication('Root',systemName,...
            'Legacy',true,'MultiMode',false,'token','MWAdvi3orAPICa11');

            if~isempty(applicationObj)
                mdladvObj=applicationObj.getRootMAObj();

                Simulink.ModelAdvisor.getActiveModelAdvisorObj(mdladvObj);
            else
                mdladvObj=[];
            end
        else

            mdladvObj=Simulink.ModelAdvisor.getActiveModelAdvisorObj;
        end
        if isa(mdladvObj,'Simulink.ModelAdvisor')

            callstack=dbstack;
            if~isempty(callstack)
                for i=length(callstack):-1:1
                    if strcmp('runTaskAdvisor',callstack(i).name)
                        return;
                    end
                end
            end

            memenus=mdladvObj.MEmenus;
            if isa(memenus.ShowInformerGUI,'DAStudio.Action')
                memenus.ShowInformerGUI.on='off';
            end
        end
    case 'GetSelectMenuForTaskAdvsiorNode'
        taskadvisornode=varargin{1};

        InfoStruct.selectVisible=false;
        InfoStruct.selectEnable='off';
        InfoStruct.selectmsg=DAStudio.message('Simulink:tools:MASelectAll2');

        InfoStruct.deselectVisible=false;
        InfoStruct.deselectEnable='off';
        InfoStruct.deselectmsg=DAStudio.message('Simulink:tools:MADeselectAll');

        InfoStruct.runTaskAdvisorVisible=false;
        InfoStruct.runTaskAdvisorEnable='off';
        InfoStruct.runTaskAdvisormsg=DAStudio.message('Simulink:tools:MARunSelectedChecks');


        InfoStruct.run2failureVisible=false;
        InfoStruct.run2failureEnable='off';
        if isempty(taskadvisornode)
            InfoStruct.run2failuremsg=DAStudio.message('Simulink:tools:MARunToFailure');
        else
            InfoStruct.run2failuremsg=getRunToFailureLabel(taskadvisornode.ID);
        end



        InfoStruct.continueVisible=false;
        InfoStruct.continueEnable='off';
        InfoStruct.continuemsg=DAStudio.message('Simulink:tools:MAContinue');

        InfoStruct.resetVisible=false;
        InfoStruct.resetEnable='off';

        InfoStruct.getCheckIDEnable='off';
        InfoStruct.getCheckIDVisible=true;

        InfoStruct.getTaskIDEnable='off';
        InfoStruct.getTaskIDVisible=false;

        if isa(taskadvisornode,'ModelAdvisor.Group')
            InfoStruct.resetmsg=DAStudio.message('Simulink:tools:MAReset');
        else
            InfoStruct.resetmsg=DAStudio.message('Simulink:tools:MAResetThisTask');
        end

        if isa(taskadvisornode,'ModelAdvisor.Task')
            InfoStruct.selectmsg=DAStudio.message('Simulink:tools:MASelect');
            InfoStruct.deselectmsg=DAStudio.message('Simulink:tools:MADeselect');
            if isa(taskadvisornode.getParent,'ModelAdvisor.Procedure')
                InfoStruct.runTaskAdvisormsg=DAStudio.message('Simulink:tools:MARunThisTask');
            else
                InfoStruct.runTaskAdvisormsg=DAStudio.message('Simulink:tools:MARunThisCheck');
            end
            InfoStruct.resetVisible=true;
            if isa(taskadvisornode.getParent,'ModelAdvisor.Procedure')&&taskadvisornode.EnableReset
                InfoStruct.resetEnable='on';
            end
            if taskadvisornode.Enable
                InfoStruct.getTaskIDVisible=true;

                if taskadvisornode.Selected
                    InfoStruct.selectVisible=true;
                    InfoStruct.selectEnable='off';
                    InfoStruct.deselectVisible=true;
                    InfoStruct.deselectEnable='on';
                    InfoStruct.runTaskAdvisorVisible=true;
                    InfoStruct.runTaskAdvisorEnable='on';
                    InfoStruct.checkIDEnable='on';
                    InfoStruct.getCheckIDEnable='on';
                    InfoStruct.getCheckIDVisible=true;


                    if modeladvisorutil2('IamInsideRunToFailScope',taskadvisornode)
                        InfoStruct.continueVisible=true;
                        InfoStruct.continueEnable='on';
                    end

                    InfoStruct.getTaskIDEnable='on';
                else
                    InfoStruct.selectVisible=true;
                    InfoStruct.selectEnable='on';
                    InfoStruct.deselectVisible=true;
                    InfoStruct.deselectEnable='off';
                    InfoStruct.runTaskAdvisorVisible=true;
                    InfoStruct.runTaskAdvisorEnable='off';
                    InfoStruct.getCheckIDEnable='off';
                    InfoStruct.getCheckIDVisible=true;
                end
            else
                InfoStruct.runTaskAdvisorVisible=true;
                if taskadvisornode.Selected
                    InfoStruct.runTaskAdvisorVisible=true;
                    InfoStruct.runTaskAdvisorEnable='on';
                end
            end


            if~taskadvisornode.ShowCheckbox
                InfoStruct.selectVisible=false;
                InfoStruct.selectEnable='off';
                InfoStruct.deselectVisible=false;
                InfoStruct.deselectEnable='off';
                InfoStruct.getCheckIDVisible=false;
                InfoStruct.getCheckIDEnable='off';
                InfoStruct.getTaskIDEnable='off';
                InfoStruct.getTaskIDVisible=false;
            end

            if taskadvisornode.MACIndex<=0
                InfoStruct.runTaskAdvisorEnable='off';
            end
        elseif isa(taskadvisornode,'ModelAdvisor.Procedure')

            if isempty(taskadvisornode.getParent)
                InfoStruct.resetVisible=true;
                InfoStruct.resetEnable='on';
            end
            InfoStruct.selectmsg=DAStudio.message('Simulink:tools:MASelect');
            InfoStruct.deselectmsg=DAStudio.message('Simulink:tools:MADeselect');
            InfoStruct.run2failureVisible=true;
            InfoStruct.resetVisible=true;
            InfoStruct.getCheckIDEnable='off';
            InfoStruct.getCheckIDVisible=false;
            childObjs=taskadvisornode.getAllChildren;
            if~isempty(childObjs)&&~childObjs{1}.Enable


                InfoStruct.run2failureEnable='off';
            else
                InfoStruct.run2failureEnable='on';
            end
            if taskadvisornode.ShowCheckbox
                if taskadvisornode.Selected
                    InfoStruct.selectVisible=true;
                    InfoStruct.selectEnable='off';
                    InfoStruct.deselectVisible=true;
                    InfoStruct.deselectEnable='on';
                else
                    InfoStruct.selectVisible=true;
                    InfoStruct.selectEnable='on';
                    InfoStruct.deselectVisible=true;
                    InfoStruct.deselectEnable='off';
                end
            end
        elseif isa(taskadvisornode,'ModelAdvisor.Group')

            if isempty(taskadvisornode.getParent)
                InfoStruct.resetEnable='on';
            end
            if~strcmp(taskadvisornode.ID,'com.mathworks.cgo.group')
                InfoStruct.resetVisible=true;
            end
            if taskadvisornode.Enable
                InfoStruct.selectVisible=true;
                InfoStruct.selectEnable='on';
                InfoStruct.deselectVisible=true;
                InfoStruct.deselectEnable='on';
                InfoStruct.runTaskAdvisorVisible=true;
                InfoStruct.runTaskAdvisorEnable='on';
                InfoStruct.getCheckIDEnable='on';
                InfoStruct.getCheckIDVisible=true;
                InfoStruct.getTaskIDEnable='on';
                InfoStruct.getTaskIDVisible=true;

                if strcmp(taskadvisornode.ID,'SysRoot')
                    InfoStruct.selectEnable='off';
                    InfoStruct.deselectEnable='off';
                    InfoStruct.runTaskAdvisorEnable='off';
                    InfoStruct.getCheckIDEnable='off';
                    InfoStruct.getTaskIDEnable='off';
                end
            else
                if taskadvisornode.Selected
                    InfoStruct.runTaskAdvisorEnable='on';
                    InfoStruct.runTaskAdvisorVisible=true;
                end
            end
        end
        varargout{1}=InfoStruct;
    case 'PromptConfigurationSaveDialogIfDirty'
        mdladvObj=varargin{1};
        userCancel=false;
        if mdladvObj.ConfigUIDirty
            warnmsg=DAStudio.message('Simulink:tools:MADouWantSaveConfigChange');


            if~desktop('-inuse')||feature('noFigureWindows')
                response=DAStudio.message('Simulink:tools:MANo');
            else
                response=questdlg(warnmsg,DAStudio.message('Simulink:tools:MAWarning'),...
                DAStudio.message('Simulink:tools:MAYes'),...
                DAStudio.message('Simulink:tools:MANo'),...
                DAStudio.message('Simulink:tools:MACancel'),...
                DAStudio.message('Simulink:tools:MAYes'));
            end
            if strcmp(response,DAStudio.message('Simulink:tools:MAYes'))

                userCancel=false;
                ModelAdvisor.ConfigUI.openSaveDlg;
            elseif strcmp(response,DAStudio.message('Simulink:tools:MANo'))

                userCancel=false;
            else
                userCancel=true;
            end
        end
        varargout{1}=userCancel;
    case 'ShowConfigurationOnStatusBar'

        mdladvObj=varargin{1};
        if~isempty(mdladvObj.ConfigFilePath)
            if isa(mdladvObj.MAExplorer,'DAStudio.Explorer')
                mdladvObj.MAExplorer.setStatusMessage(DAStudio.message('Simulink:tools:MALoadedConfigurationFromDisk',mdladvObj.ConfigFilePath));
            end
            if isa(mdladvObj.ConfigUIWindow,'DAStudio.Explorer')
                mdladvObj.ConfigUIWindow.setStatusMessage(DAStudio.message('Simulink:tools:MALoadedConfigurationFromDisk',mdladvObj.ConfigFilePath));
            end
        end
    case 'UpdateConfigUIWindowTitle'

        mdladvObj=varargin{1};
        if isa(mdladvObj.ConfigUIWindow,'DAStudio.Explorer')
            me=mdladvObj.ConfigUIWindow;
            if isempty(mdladvObj.ConfigFilePath)
                ConfigName='Untitled';
            else
                ConfigName=mdladvObj.ConfigFilePath;
            end

            [~,shortName,shortExt]=fileparts(ConfigName);
            ShortConfigName=[shortName,shortExt];
            me.Title=[DAStudio.message('Simulink:tools:MACETitle'),' - ',ConfigName];
            mdladvObj.setConfigUIDirty(mdladvObj.ConfigUIDirty);
            me.setTreeTitle(DAStudio.message('Simulink:tools:MACETreeTitle',ShortConfigName));
        end
    case 'UpdatePasteMenuToolbar'






        mdladvObj=Simulink.ModelAdvisor.getActiveModelAdvisorObj;

        if isempty(mdladvObj.ConfigUICopyObj)||mdladvObj.EdittimeViewMode
            loc_enableAction(mdladvObj,'ConfigF_paste',0);
        else
            loc_enableAction(mdladvObj,'ConfigF_paste',1);
        end
    case 'UpdateUndoRedoMenuToolbar'



        mdladvObj=Simulink.ModelAdvisor.getActiveModelAdvisorObj;
        if ModelAdvisor.ConfigUI.stackoperation('undo_times')>0
            loc_enableAction(mdladvObj,'ConfigE_undo',1);
        else
            loc_enableAction(mdladvObj,'ConfigE_undo',0);
        end
        if ModelAdvisor.ConfigUI.stackoperation('redo_times')>0
            loc_enableAction(mdladvObj,'ConfigE_redo',1);
        else
            loc_enableAction(mdladvObj,'ConfigE_redo',0);
        end
    case 'UpdateConfigUIMenuToolbar'
        me=varargin{1};
        imme=DAStudio.imExplorer(me);
        selectedNode=Advisor.Utils.convertMCOS(imme.getCurrentTreeNode);
        mdladvObj=Simulink.ModelAdvisor.getActiveModelAdvisorObj;

        if~isa(selectedNode,'ModelAdvisor.ConfigUI')
            loc_enableAction(mdladvObj,'ConfigF_copy',0);
            loc_enableAction(mdladvObj,'ConfigF_paste',0);
            loc_enableAction(mdladvObj,'ConfigF_cut',0);
            loc_enableAction(mdladvObj,'ConfigF_delete',0);
            loc_enableAction(mdladvObj,'ConfigF_moveup',0);
            loc_enableAction(mdladvObj,'ConfigF_movedown',0);
            loc_enableAction(mdladvObj,'ConfigF_newfolder',0);
        else
            if isempty(mdladvObj.ConfigUICopyObj)
                loc_enableAction(mdladvObj,'ConfigF_paste',0);
            else
                loc_enableAction(mdladvObj,'ConfigF_paste',1);
            end

            if isempty(selectedNode.ParentObj)
                loc_enableAction(mdladvObj,'ConfigF_copy',0);
                loc_enableAction(mdladvObj,'ConfigF_cut',0);
                loc_enableAction(mdladvObj,'ConfigF_delete',0);
                loc_enableAction(mdladvObj,'ConfigF_moveup',0);
                loc_enableAction(mdladvObj,'ConfigF_movedown',0);
                loc_enableAction(mdladvObj,'ConfigE_enable',0);
                loc_enableAction(mdladvObj,'ConfigE_disable',0);
            else
                loc_enableAction(mdladvObj,'ConfigF_copy',1);
                loc_enableAction(mdladvObj,'ConfigF_cut',1);
                loc_enableAction(mdladvObj,'ConfigF_delete',1);
                if strcmp(selectedNode.ParentObj.Childrenobj{1}.ID,selectedNode.ID)

                    loc_enableAction(mdladvObj,'ConfigF_moveup',0);
                else
                    loc_enableAction(mdladvObj,'ConfigF_moveup',1);
                end
                if strcmp(selectedNode.ParentObj.Childrenobj{end}.ID,selectedNode.ID)

                    loc_enableAction(mdladvObj,'ConfigF_movedown',0);
                else
                    loc_enableAction(mdladvObj,'ConfigF_movedown',1);
                end
                if selectedNode.Enable
                    loc_enableAction(mdladvObj,'ConfigE_enable',0);
                    loc_enableAction(mdladvObj,'ConfigE_disable',1);
                else
                    loc_enableAction(mdladvObj,'ConfigE_enable',1);
                    loc_enableAction(mdladvObj,'ConfigE_disable',0);
                end
            end
            if ModelAdvisor.ConfigUI.stackoperation('undo_times')>0
                loc_enableAction(mdladvObj,'ConfigE_undo',1);
            else
                loc_enableAction(mdladvObj,'ConfigE_undo',0);
            end
            if ModelAdvisor.ConfigUI.stackoperation('redo_times')>0
                loc_enableAction(mdladvObj,'ConfigE_redo',1);
            else
                loc_enableAction(mdladvObj,'ConfigE_redo',0);
            end
            loc_enableAction(mdladvObj,'ConfigF_newfolder',1);
            if mdladvObj.EdittimeViewMode
                loc_enableAction(mdladvObj,'ConfigF_copy',0);
                loc_enableAction(mdladvObj,'ConfigF_paste',0);
                loc_enableAction(mdladvObj,'ConfigF_cut',0);
                loc_enableAction(mdladvObj,'ConfigF_delete',0);
                loc_enableAction(mdladvObj,'ConfigF_moveup',0);
                loc_enableAction(mdladvObj,'ConfigF_movedown',0);
                loc_enableAction(mdladvObj,'ConfigF_newfolder',0);
                loc_enableAction(mdladvObj,'ConfigE_redo',0);
                loc_enableAction(mdladvObj,'ConfigE_undo',0);
                loc_enableAction(mdladvObj,'ConfigE_enable',0);
                loc_enableAction(mdladvObj,'ConfigE_disable',0);
            end
        end



        if isempty(mdladvObj.ConfigFilePath)
            loc_enableAction(mdladvObj,'Configm_resetConfigUI',0);
            loc_enableAction(mdladvObj,'m_resetConfigUI',0);
            if~isempty(mdladvObj.PreferenceConfigFilePath)
                loc_enableAction(mdladvObj,'Configm_resetConfigUI',1);
                loc_enableAction(mdladvObj,'m_resetConfigUI',1);
            end
        else
            loc_enableAction(mdladvObj,'Configm_resetConfigUI',1);
            loc_enableAction(mdladvObj,'m_resetConfigUI',1);
        end
        modeladvisorutil2('UpdateSetConfigUIMenu',mdladvObj);
    case 'UpdateSetConfigUIMenu'
        mdladvObj=varargin{1};


        [~,name1,ext1]=fileparts(mdladvObj.ConfigFilePath);
        [~,name2,ext2]=fileparts(mdladvObj.PreferenceConfigFilePath);
        if strcmp([name1,ext1],[name2,ext2])
            loc_enableAction(mdladvObj,'Configm_setConfigUI',0);
            loc_enableAction(mdladvObj,'m_setConfigUI',0);
        else
            loc_enableAction(mdladvObj,'Configm_setConfigUI',1);
            loc_enableAction(mdladvObj,'m_setConfigUI',1);
        end
        if isempty(mdladvObj.ConfigFilePath)
            loc_enableAction(mdladvObj,'m_setConfigUIforMdl',0);
        else
            cs=getActiveConfigSet(bdroot(mdladvObj.System));
            m_setConfigUIforMdlStatus=1;
            if cs.isValidParam('ModelAdvisorConfigurationFile')
                [~,name3,ext3]=fileparts(cs.get_param('ModelAdvisorConfigurationFile'));
                if strcmp(strcat(name3,ext3),strcat(name1,ext1))
                    m_setConfigUIforMdlStatus=0;
                end
            end
            loc_enableAction(mdladvObj,'m_setConfigUIforMdl',m_setConfigUIforMdlStatus);
        end
    case 'getMAObjFromDAExplorer'
        me=varargin{1};
        rootObj=me.getRoot;
        if isa(rootObj,'ModelAdvisor.Node')
            maobj=rootObj.MAObj;
        elseif isa(rootObj,'ModelAdvisor.ConfigUI')
            maobj=rootObj.MAObj;
        else
            maobj=Simulink.ModelAdvisor.getActiveModelAdvisorObj;
        end
        varargout{1}=maobj;
    case 'UpdateMEMenuToolbar'
        me=varargin{1};
        imme=DAStudio.imExplorer(me);
        mdladvObj=modeladvisorprivate('modeladvisorutil2','getMAObjFromDAExplorer',me);
        if mdladvObj.isSleeping
            return;
        end
        selectedNode=Advisor.Utils.convertMCOS(imme.getCurrentTreeNode);
        menuStruct=modeladvisorprivate('modeladvisorutil2','GetSelectMenuForTaskAdvsiorNode',selectedNode);

        if isfield(mdladvObj.MEMenus,'m_setConfigUI')&&isfield(mdladvObj.MEMenus,'m_resetConfigUI')
            if isempty(mdladvObj.ConfigFilePath)
                mdladvObj.MEMenus.m_setConfigUI.enabled='off';
                mdladvObj.MEMenus.m_resetConfigUI.enabled='off';
                if~isempty(mdladvObj.PreferenceConfigFilePath)
                    mdladvObj.MEMenus.m_resetConfigUI.enabled='on';
                end
            else
                mdladvObj.MEMenus.m_setConfigUI.enabled='on';
                mdladvObj.MEMenus.m_resetConfigUI.enabled='on';
            end
        end
        mdladvObj.MEMenus.Select.text=menuStruct.selectmsg;
        mdladvObj.MEMenus.Select.enabled=menuStruct.selectEnable;
        if menuStruct.selectVisible
            mdladvObj.MEMenus.Select.visible='on';
        else
            mdladvObj.MEMenus.Select.visible='off';
        end
        mdladvObj.MEMenus.Deselect.text=menuStruct.deselectmsg;
        mdladvObj.MEMenus.Deselect.enabled=menuStruct.deselectEnable;
        if menuStruct.deselectVisible
            mdladvObj.MEMenus.Deselect.visible='on';
        else
            mdladvObj.MEMenus.Deselect.visible='off';
        end
        mdladvObj.MEMenus.run.text=menuStruct.runTaskAdvisormsg;
        mdladvObj.MEMenus.run.enabled=menuStruct.runTaskAdvisorEnable;
        if menuStruct.runTaskAdvisorVisible
            mdladvObj.MEMenus.run.visible='on';
        else
            mdladvObj.MEMenus.run.visible='off';
        end
        mdladvObj.MEMenus.continue.text=menuStruct.continuemsg;
        mdladvObj.MEMenus.continue.enabled=menuStruct.continueEnable;
        if menuStruct.continueVisible
            mdladvObj.MEMenus.continue.visible='on';
        else
            mdladvObj.MEMenus.continue.visible='off';
        end
        mdladvObj.MEMenus.runToFail.text=menuStruct.run2failuremsg;
        mdladvObj.MEMenus.runToFail.enabled=menuStruct.run2failureEnable;
        if menuStruct.run2failureVisible
            mdladvObj.MEMenus.runToFail.visible='on';
        else
            mdladvObj.MEMenus.runToFail.visible='off';
        end
        mdladvObj.MEMenus.Reset.text=menuStruct.resetmsg;
        mdladvObj.MEMenus.Reset.enabled=menuStruct.resetEnable;
        if menuStruct.resetVisible
            mdladvObj.MEMenus.Reset.visible='on';
        else
            mdladvObj.MEMenus.Reset.visible='off';
        end

        mdladvObj.MEMenus.getCheckID.enabled=menuStruct.getCheckIDEnable;
        if menuStruct.getCheckIDVisible
            mdladvObj.MEMenus.getCheckID.visible='on';
        else
            mdladvObj.MEMenus.getCheckID.visible='off';
        end
        if(isa(selectedNode,'ModelAdvisor.Task'))
            mdladvObj.MEMenus.getCheckID.text=DAStudio.message('ModelAdvisor:engine:SendIDToWorkspace');
        else
            mdladvObj.MEMenus.getCheckID.text=DAStudio.message('ModelAdvisor:engine:SendIDsToWorkspace');
        end

        mdladvObj.MEMenus.getTaskID.enabled=menuStruct.getTaskIDEnable;
        if menuStruct.getTaskIDVisible
            mdladvObj.MEMenus.getTaskID.visible='on';
        else
            mdladvObj.MEMenus.getTaskID.visible='off';
        end
        if(isa(selectedNode,'ModelAdvisor.Task'))
            mdladvObj.MEMenus.getTaskID.text=DAStudio.message('ModelAdvisor:engine:SendInstanceIDToWorkspace');
        else
            mdladvObj.MEMenus.getTaskID.text=DAStudio.message('ModelAdvisor:engine:SendInstanceIDsToWorkspace');
        end
        InfoStruct.getTaskIDEnable='off';
        InfoStruct.getTaskIDVisible=false;%#ok<STRNU>

        modeladvisorutil2('UpdateSetConfigUIMenu',mdladvObj);
        if(isa(selectedNode,'ModelAdvisor.Node'))
            selectedNode.updateResultGUI;
        end
    case 'GetIconForModelAdvisorCheck'
        mdladvCheck=varargin{1};
        if isnumeric(mdladvCheck)&&mdladvCheck<0
            imagename='task_failed.png';
        elseif isa(mdladvCheck,'ModelAdvisor.Check')
            if~mdladvCheck.RunComplete
                imagename='task_failed.png';
            elseif mdladvCheck.Success
                imagename='task_passed.png';
            elseif mdladvCheck.ErrorSeverity==0
                imagename='task_warning.png';
            else
                imagename='task_failed.png';
            end
        else
            if~mdladvCheck.RunComplete
                imagename='task_failed.png';
            else
                imagename='task_passed.png';
            end
        end
        varargout{1}=imagename;
    case 'LoadGenerateInfo'
        mdladvObj=varargin{1};
        varargout{1}=mdladvObj.Database.loadLatestData('geninfo');
    case 'SaveGenerateInfo'
        mdladvObj=varargin{1};
        mdladvObj.Database.saveMAGeninfoData(varargin{2},varargin{3},varargin{4},...
        varargin{5},varargin{6},varargin{7},varargin{8});
    case 'emitHTMLforMAElements'
        outputString='';
        for i=1:nargin-1
            if(isa(varargin{i},'ModelAdvisor.FormatTemplate'))
                varargin{i}=varargin{i}.emitContent;
            end
            elementObjs=varargin{i};
            if isa(elementObjs,'Advisor.Element')
                tmpCache='';
                for idx=1:length(elementObjs)
                    tmpCache=[tmpCache,elementObjs(idx).emitHTML];
                end
                outputString=[outputString,tmpCache];
            else
                outputString=[outputString,elementObjs];
            end
        end
        varargout{1}=outputString;
    case 'createTANFromCheck'
        varargout{1}=loc_createTANFromCheck(varargin{1},varargin{2},varargin{3});
    case 'shallWeStopatFailOntheNode'
        taskObj=varargin{1};
        checkOrInformerObj=varargin{2};
        if~checkOrInformerObj.RunComplete||...
            isa(checkOrInformerObj,'ModelAdvisor.Check')&&~checkOrInformerObj.Success&&((checkOrInformerObj.ErrorSeverity>0)||strcmp(taskObj.Severity,'Required'))
            varargout{1}=true;
        else
            varargout{1}=false;
        end
    case 'IamInsideRunToFailScope'
        taskadvisornode=varargin{1};
        insideScope=false;
        if isa(taskadvisornode.getParent,'ModelAdvisor.Procedure')&&...
            isa(taskadvisornode.MAObj,'Simulink.ModelAdvisor')&&...
            isa(taskadvisornode.MAObj.R2FStop,'ModelAdvisor.Node')&&...
            isa(taskadvisornode.MAObj.R2FStart,'ModelAdvisor.Procedure')
            while~isempty(taskadvisornode.getParent)
                if strcmp(taskadvisornode.getParent.ID,taskadvisornode.MAObj.R2FStart.ID)
                    insideScope=true;
                    break
                else
                    taskadvisornode=taskadvisornode.getParent;
                end
            end
        end
        varargout{1}=insideScope;
    case 'createReportHeaderSection'
        PerfTools.Tracer.logMATLABData('MAGroup','Create Report Header Section',true);
        varargout{1}=loc_createReportHeaderSection(varargin{:});
        PerfTools.Tracer.logMATLABData('MAGroup','Create Report Header Section',false);
    case 'getNodeSummaryInfo'
        if~isempty(varargin{1})
            [varargout{1},varargout{2}]=loc_getNodeSummaryInfo(varargin{1});
        else
            [varargout{1},varargout{2}]=loc_getNodeSummaryInfoChecks(varargin{2},varargin{3});
        end
    case 'emitHTMLforTaskNode'
        if nargin>2
            recordCellArray=varargin{2};
        else

            recordCellArray=varargin{1}.MAObj.CheckCellArray;
        end
        counterStructure=modeladvisorprivate('modeladvisorutil2','getNodeSummaryInfo',varargin{1});
        [varargout{1},varargout{2}]=loc_emitHTMLforTaskNode(varargin{1},recordCellArray,...
        counterStructure.generateTime,false,0,'');
    case 'CreateIgnorePortion'
        varargout{1}=loc_CreateIgnorePortion(varargin{1});
    case 'CompileModel'
        l_compileModel(varargin{1});
    case 'CompileModelForCodegen'
        l_compileModelForCodegen(varargin{1});
    case 'TerminateModelCompile'
        varargout{1}=l_termmodelcompile(varargin{1});
    case 'CGIRModel'
        l_cgirModel(varargin{1});
    case 'TermCGIRModelCompile'
        l_termcgirModel(varargin{1});
    case 'CopyObjToStruct'


        PerfTools.Tracer.logMATLABData('MAGroup','Convert Obj to Struct',true);
        varargout{1}=locCopyStruct(varargin{1},varargin{2});
        PerfTools.Tracer.logMATLABData('MAGroup','Convert Obj to Struct',false);
    case 'GetReportNameForTaskNode'
        taskNode=varargin{1};

        if nargin>2
            WorkDir=varargin{2};
        elseif isprop(taskNode.MAObj.AtticData,'WorkDir')
            WorkDir=taskNode.MAObj.AtticData.WorkDir;
        else
            WorkDir=taskNode.MAObj.getWorkDir;
        end

        if~isempty(taskNode.ReportName)
            reportName=fullfile(WorkDir,taskNode.ReportName);
        else
            reportName=fullfile(WorkDir,['report_',num2str(taskNode.Index),'.html']);
        end
        varargout{1}=reportName;
    case 'SaveTaskAdvisorInfo'
        mdladvObj=varargin{1};
        if isa(mdladvObj,'Simulink.ModelAdvisor')
            mdladvObj.Database.saveMASessionData;
        end
    case 'SaveTaskAdvisorMiniInfo'
        mdladvObj=varargin{1};

        if isa(mdladvObj,'Simulink.ModelAdvisor')&&isa(mdladvObj.Database,'ModelAdvisor.Repository')
            if exist(mdladvObj.Database.FileLocation,'file')
                mdladvObj.Database.saveMAMiniSessionData;
            end
        end
    case 'ResetRoot'
        mdladvObj=varargin{1}.MAObj;

        if isa(mdladvObj.ListExplorer,'DAStudio.Explorer')
            mdladvObj.ListExplorer.delete;
        end
        if~isempty(mdladvObj.ConfigFilePath)
            [~,configFileName,~]=fileparts(mdladvObj.ConfigFilePath);
            mdladvObj.activateConfiguration(configFileName);
            mdladvObj=Simulink.ModelAdvisor.getActiveModelAdvisorObj;
        else


            am=Advisor.Manager.getInstance;
            cacheResetData=am.slCustomizationDataStructure;

            if~isempty(cacheResetData)

                if length(cacheResetData.taskCellArray)<length(mdladvObj.TaskCellArray)||...
                    length(cacheResetData.TaskAdvisorCellArray)<length(mdladvObj.TaskAdvisorCellArray)
                    DAStudio.error('ModelAdvisor:engine:MACachedDataOutdated');
                end
            else
                DAStudio.error('ModelAdvisor:engine:MACachedDataOutdated');
            end



            locCopyStructBackToObj(cacheResetData.taskCellArray,mdladvObj.TaskCellArray);
            locCopyStructBackToObj(cacheResetData.TaskAdvisorCellArray,mdladvObj.TaskAdvisorCellArray);
        end


        for i=1:length(mdladvObj.TaskAdvisorCellArray)


            if isa(mdladvObj.TaskAdvisorCellArray{i},'ModelAdvisor.Procedure')&&(isa(mdladvObj.TaskAdvisorCellArray{i}.getParent,'ModelAdvisor.Group')&&~isa(mdladvObj.TaskAdvisorCellArray{i}.getParent,'ModelAdvisor.Procedure'))...
                &&~isempty(mdladvObj.TaskAdvisorCellArray{i}.getParent.getParent)
                mdladvObj.TaskAdvisorCellArray{i}.ShowCheckbox=true;
            end
        end


        mdladvObj.R2FStart={};
        mdladvObj.R2FStop={};
        mdladvObj.Breakpoint={};


        mdladvObj.Database.saveMASessionData;

        mdladvObj.Database.deleteData('allrptinfo');

        ed=DAStudio.EventDispatcher;
        ed.broadcastEvent('MESleep');
        mdladvObj.TaskAdvisorRoot.updateStates('refreshME');
        ed.broadcastEvent('MEWake');
    case 'IsErrorFatal'

        taskObj=varargin{1};
        if(taskObj.State<ModelAdvisor.CheckStatus.Warning)
            varargout{1}=false;
            return
        end
        if isa(taskObj.Check,'ModelAdvisor.Check')
            checkOrInformerObj=taskObj.Check;
        elseif taskObj.MACIndex<0
            checkOrInformerObj.RunComplete=false;
        else
            checkOrInformerObj.RunComplete=true;
        end
        if~checkOrInformerObj.RunComplete||...
            isa(checkOrInformerObj,'ModelAdvisor.Check')&&~checkOrInformerObj.Success&&((checkOrInformerObj.ErrorSeverity>0)||strcmp(taskObj.Severity,'Required'))
            varargout{1}=true;
        else
            varargout{1}=false;
        end
    case 'MakeTagCompatible'
        varargout{1}=loc_MakeTagCompatible(varargin{1});
    case 'embedImagesInHTML'
        htmlSource=varargin{1};
        [warningImg,passedImg,failedImg,notrunImg,minusImg,task_disabledImg,infoImg,justifyImg,errorImg]=getDataURLs();
        htmlSource=regexprep(htmlSource,'src="task_disabled.png"',task_disabledImg);
        htmlSource=regexprep(htmlSource,'src="icon_task.png"',notrunImg);
        htmlSource=regexprep(htmlSource,'src="no_compile_16.png"',notrunImg);
        htmlSource=regexprep(htmlSource,'src="compile_16.png"',notrunImg);
        htmlSource=regexprep(htmlSource,'src="larger_compile_16.png"',notrunImg);
        htmlSource=regexprep(htmlSource,'src="task_passed.png"',passedImg);
        htmlSource=regexprep(htmlSource,'src="task_warning.png"',warningImg);
        htmlSource=regexprep(htmlSource,'src="task_failed.png"',failedImg);
        htmlSource=regexprep(htmlSource,'src="failed_16.png"',failedImg);
        htmlSource=regexprep(htmlSource,'src="minus.png"',minusImg);
        htmlSource=regexprep(htmlSource,'src="info_icon.png"',infoImg);
        htmlSource=regexprep(htmlSource,'src="justified_16.png"',justifyImg);
        htmlSource=regexprep(htmlSource,'src="abort_16.png"',errorImg);
        htmlSource=[htmlSource,'<span name = "EmbedImages" id="EmbedImages"></span>'];
        varargout{1}=htmlSource;
    case 'getDataURLImages'
        [warningImg,passedImg,failedImg,notrunImg,minusImg,task_disabledImg,infoImg,justifyImg,errorImg]=getDataURLs();
        varargout{1}={warningImg,passedImg,failedImg,notrunImg,minusImg,task_disabledImg,infoImg,justifyImg,errorImg};
    case 'MakeTagLowercase'
        out=varargin{1};
        tags=regexp(out,'</?\w+[\s>]','match');
        tags=unique(tags);
        for k=1:length(tags)
            out=strrep(out,tags{k},lower(tags{k}));
        end
        varargout{1}=out;
    case 'CellArrayFinder'


        inputCell=varargin{1};
        opts=varargin{2};
        varargout{1}=loc_commonFind(inputCell,opts);
    case 'SetFolderCSH'
        varargout{1}=set_folder_CSHParam(varargin{1});
    case 'CleanWarnErrorDlgs'
        mdladvObj=varargin{1};
        for i=1:length(mdladvObj.DialogCellArray)
            if ishandle(mdladvObj.DialogCellArray{i})
                close(mdladvObj.DialogCellArray{i});
            end
        end
        mdladvObj.DialogCellArray={};
    case 'ReadConfigPrefFileInfo'
        PrefFile=fullfile(prefdir,'mdladvprefs.mat');
        if exist(PrefFile,'file')
            mdladvprefs=load(PrefFile);
        else
            mdladvprefs.ConfigPrefs.FilePath='';
        end
        if isfield(mdladvprefs,'ConfigPrefs')&&...
            isfield(mdladvprefs.ConfigPrefs,'FilePath')&&...
            exist(mdladvprefs.ConfigPrefs.FilePath,'file')
            FilePath=mdladvprefs.ConfigPrefs.FilePath;
        else
            FilePath='';
        end
        FilePathInfo.name=FilePath;
        if~isempty(FilePath)
            dirInfo=dir(FilePath);
            FilePathInfo.date=dirInfo.date;
        else
            FilePathInfo.date='';
        end
        varargout{1}=FilePathInfo;
    case 'GetConfigFileName'
        maobj=varargin{1};









        PrefFile=fullfile(prefdir,'mdladvprefs.mat');
        if exist(PrefFile,'file')
            mdladvprefs=load(PrefFile);
            if isfield(mdladvprefs,'ConfigPrefs')&&isfield(mdladvprefs.ConfigPrefs,'FilePath')
                maobj.PreferenceConfigFilePath=mdladvprefs.ConfigPrefs.FilePath;
            end
        end

        ConfigsetConfigFilePath='';
        cs=getActiveConfigSet(bdroot(maobj.SystemName));
        if cs.isValidParam('ModelAdvisorConfigurationFile')
            ConfigsetConfigFilePath=cs.get_param('ModelAdvisorConfigurationFile');
        end

        if~strcmp(maobj.CustomTARootID,'_modeladvisor_')
            ConfigFile='';
        elseif strcmp(maobj.StartConfigFilePath,'_empty_')
            ConfigFile='';
        elseif~isempty(maobj.StartConfigFilePath)
            ConfigFile=maobj.StartConfigFilePath;
        elseif~isempty(ConfigsetConfigFilePath)
            ConfigFile=ConfigsetConfigFilePath;
        elseif~isempty(maobj.APIConfigFilePath)
            ConfigFile=maobj.APIConfigFilePath;
        else
            ConfigFile=maobj.PreferenceConfigFilePath;
        end
        if exist(ConfigFile,'file')
            if isempty(which(ConfigFile))
                varargout{1}=ConfigFile;
            else
                varargout{1}=which(ConfigFile);
            end
        else
            varargout{1}=ConfigFile;
        end
    case 'loadConfigPref'
        maobj=varargin{1};
        ConfigFile=modeladvisorutil2('GetConfigFileName',maobj);
        if exist(ConfigFile,'file')
            maobj.isUserLoaded=false;
            maobj.loadConfiguration(ConfigFile);
        elseif~isempty(ConfigFile)
            MSLDiagnostic('Simulink:tools:MAUnableLoadPrefConfiguration',ConfigFile).reportAsWarning;
        else
            maobj.ConfigFilePath='';
        end
    case 'SetActiveConfigAsPref'
        maobj=Simulink.ModelAdvisor.getActiveModelAdvisorObj;
        ConfigFilePath=maobj.ConfigFilePath;
        ModelAdvisor.setDefaultConfiguration(ConfigFilePath,maobj);
        warndlgHandle=warndlg(DAStudio.message('Simulink:tools:MASetDefaultConfig',ConfigFilePath));
        set(warndlgHandle,'Tag','MASetDefaultConfig');
        warndlg('Model Advisor default configuration will be deprecated in a few releases.');

    case 'SetActiveConfigForModel'
        maobj=Simulink.ModelAdvisor.getActiveModelAdvisorObj;
        ConfigFilePath=maobj.ConfigFilePath;
        ModelAdvisor.setModelConfiguration(bdroot,ConfigFilePath);
        modeladvisorutil2('UpdateSetConfigUIMenu',maobj);
        cs=getActiveConfigSet(bdroot);
        configset.highlightParameter(cs,'ModelAdvisorConfigurationFile');
    case 'refreshAdvisorConfigurationForEditTime'

        editControl=edittimecheck.EditTimeEngine.getInstance();
        editControl.refreshConfiguration;

        open_bd=find_system('type','block_diagram');
        for i=1:length(open_bd)

            if~bdIsLibrary(open_bd{i})

                if strcmp(edittime.getAdvisorChecking(open_bd{i}),'on')
                    edittime.setAdvisorChecking(getfullname(open_bd{i}),'off');
                    drawnow;
                    edittime.setAdvisorChecking(getfullname(open_bd{i}),'on');


                    numBuckets=0;
                    while(performance.cooperativeTaskManager.getNumPendingTasks>0)
                        numBuckets=numBuckets+1;
                        performance.cooperativeTaskManager.finishAllTasks;


                        pause(0.15);
                    end

                    if ismac
                        edittime.setAdvisorChecking(getfullname(open_bd{i}),'off');
                        drawnow;
                        edittime.setAdvisorChecking(getfullname(open_bd{i}),'on');
                    end

                    root=sfroot;
                    machine=root.find('-isa','Stateflow.Machine','Name',getfullname(open_bd{i}));
                    if~isempty(machine)
                        sf('SetMALintStatus',false,machine.Id);
                        sf('SetMALintStatus',true,machine.Id);
                    end
                end
            end
        end
    case 'DeleteConfigPref'
        ModelAdvisor.setDefaultConfiguration('');
    case 'CheckNonEmptyConfig'
        maobj=varargin{1};
        if isempty(maobj.ConfigUIRoot.getChildren)
            dlghandle=warndlg(DAStudio.message('Simulink:tools:MACEUnableSaveEmptyConfig'));
            set(dlghandle,'Tag','ma_warn_emptyconfig');
            varargout{1}=true;
        else
            varargout{1}=false;
        end
    case 'WaitbarCancelBtnCallback'
        maobj=Simulink.ModelAdvisor.getActiveModelAdvisorObj;
        if~isempty(maobj)&&ishandle(maobj.Waitbar)
            maobj.UserCancel=true;
            delete(maobj.Waitbar);
        end
    case 'createToolbar'
        me=varargin{1};
        am=varargin{2};
        tb=varargin{3};
        browsertag=varargin{4};
        if nargin>5
            maobj=varargin{5};
        else
            maobj=Simulink.ModelAdvisor.getActiveModelAdvisorObj;
        end
        if maobj.isSleeping
            return;
        end
        sys=maobj.SystemName;
        if strcmp(maobj.CustomTARootID,'_modeladvisor_')&&strcmp(browsertag,'MA')
            if Advisor.Utils.license('test','Distrib_Computing_Toolbox')==1
                callback=['Simulink.ModelAdvisor.runInBackgroundCB(''',sys,''')'];
                defaultMode=maobj.RunInBackground;
                if defaultMode
                    defaultMode='On';
                    iconpath=fullfile(matlabroot,'toolbox','simulink','simulink','modeladvisor','resources','runinbackground.png');
                else
                    defaultMode='Off';
                    iconpath=fullfile(matlabroot,'toolbox','simulink','simulink','modeladvisor','resources','runinforeground.png');
                end
                maobj.Toolbar.RunInBackground=am.createAction(me,'Text',DAStudio.message('ModelAdvisor:engine:ToolbarButtonBackgroundName'),...
                'Callback',callback,'toolTip',DAStudio.message('ModelAdvisor:engine:ToolbarButtonBackgroundTooltip'),...
                'Icon',iconpath,...
                'ToggleAction','on','On',defaultMode);
                tb.addAction(maobj.Toolbar.RunInBackground);
                tb.addSeparator;
            else

                maobj.RunInBackground=false;
            end

            SID=Simulink.ID.getSID(maobj.SystemName);
            maobj.Toolbar.runCheck=am.createAction(me,'icon',fullfile(matlabroot,'toolbox','simulink','simulink','modeladvisor','resources','run_small.png'),'Text',DAStudio.message('ModelAdvisor:engine:ToolbarRunChecks'),'Callback',['ModelAdvisorLite.GUIModelAdvisorLite.runSelectedNode(''',SID,''')']);
            tb.addAction(maobj.Toolbar.runCheck);
            tb.addSeparator;
            maobj.Toolbar.openReport=am.createAction(me,'icon',fullfile(matlabroot,'toolbox','simulink','simulink','modeladvisor','resources','report_lite.png'),'Text',DAStudio.message('ModelAdvisor:engine:ToolbarOpenReport'),'Callback',['ModelAdvisorLite.GUIModelAdvisorLite.openReport(''',SID,''')']);
            tb.addAction(maobj.Toolbar.openReport);
            if isfield(maobj.MEMenus,'ShowInformerGUI')&&(strcmp(maobj.TaskAdvisorRoot.ID,'SysRoot')||strcmp(maobj.TaskAdvisorRoot.ID,'CommandLineRun'))
                tb.addAction(maobj.MEMenus.ShowInformerGUI);
            end
            tb.addSeparator;
            maobj.Toolbar.launchLiteUI=am.createAction(me,'icon',fullfile(matlabroot,'toolbox','simulink','simulink','modeladvisor','resources','min.png'),'Text',DAStudio.message('ModelAdvisor:engine:ToolbarSwitchToLiteUI'),'Callback',['ModelAdvisorLite.GUIModelAdvisorLite.switchToLiteMode(''',SID,''')']);
            tb.addAction(maobj.Toolbar.launchLiteUI);
            tb.addSeparator;
        end


        if strcmp(browsertag,'MACB')
            iconpath=fullfile(matlabroot,'toolbox','simulink','simulink','modeladvisor','resources');

            F_copy=am.createAction(me,'Text',DAStudio.message('Simulink:tools:MACopy'),'Icon',fullfile(iconpath,'copy.png'),'Callback','ModelAdvisor.ConfigUI.copygui;','Accel','CTRL+C','toolTip',DAStudio.message('Simulink:tools:MACECopyMsg'));
            maobj.MEMenus.ConfigF_copyLib=F_copy;
            tb.addAction(F_copy);

            tb.addSeparator;
        end

        maobj.Toolbar.findPrompt=am.createToolBarText(tb);
        maobj.Toolbar.findPrompt.setText([' ',DAStudio.message('Simulink:tools:MAFind'),': ']);
        tb.addWidget(maobj.Toolbar.findPrompt);
        filterCriteriaComboBoxWidget=am.createToolBarComboBox(tb);
        filterCriteriaComboBoxWidget.setEnabled(1);
        filterCriteriaComboBoxWidget.setVisible(1);
        filterCriteriaComboBoxWidget.setEditable(1);


        filterCriteriaComboBoxSize.Width=125;
        filterCriteriaComboBoxSize.Height=20;
        filterCriteriaComboBoxWidget.setMinimumSize(filterCriteriaComboBoxSize.Width,...
        filterCriteriaComboBoxSize.Height);
        filterCriteriaComboBoxWidget.setMinimumSize(filterCriteriaComboBoxSize.Width,...
        filterCriteriaComboBoxSize.Height);

        filterCriteriaComboBoxWidget.setToolTip(DAStudio.message('Simulink:tools:MASearchNameDescription'));
        schema.prop(filterCriteriaComboBoxWidget,'Listener','handle');
        filterCriteriaComboBoxWidget.Listener=handle.listener(filterCriteriaComboBoxWidget,'ReturnPressedEvent',['Simulink.ModelAdvisor.findCheck(''',browsertag,''',''down'')']);
        maobj.Toolbar.filterCriteriaComboBoxWidget=filterCriteriaComboBoxWidget;
        tb.addWidget(maobj.Toolbar.filterCriteriaComboBoxWidget);
        maobj.Toolbar.E_select1=am.createAction(me,'icon',fullfile(matlabroot,'toolbox','simulink','simulink','modeladvisor','resources','find_next.png'),'Text',DAStudio.message('Simulink:tools:MAFindNext'),'Callback',['Simulink.ModelAdvisor.findCheck(''',browsertag,''',''down'')']);
        maobj.Toolbar.E_select2=am.createAction(me,'icon',fullfile(matlabroot,'toolbox','simulink','simulink','modeladvisor','resources','find_previous.png'),'Text',DAStudio.message('Simulink:tools:MAFindPrevious'),'Callback',['Simulink.ModelAdvisor.findCheck(''',browsertag,''',''up'')']);
        findText=am.createToolBarText(tb);
        me.UserData.filterCriteriaComboBoxWidget=filterCriteriaComboBoxWidget;
        me.UserData.toolbar=tb;
        me.UserData.findText=findText;
        tb.addAction(maobj.Toolbar.E_select2);
        tb.addAction(maobj.Toolbar.E_select1);
        tb.addSeparator;
        tb.addWidget(findText);

        if slfeature('EditTimeChecking')&&Advisor.Utils.license('test','SL_Verification_Validation')==1&&strcmp(browsertag,'MACE')

            maobj.Toolbar.viewPrompt=am.createToolBarText(tb);
            maobj.Toolbar.viewPrompt.setText([' ',DAStudio.message('ModelAdvisor:engine:SelectView'),': ']);
            tb.addWidget(maobj.Toolbar.viewPrompt);

            viewComboBoxWidget=am.createToolBarComboBox(tb);
            viewComboBoxWidget.setEnabled(1);
            viewComboBoxWidget.setVisible(1);
            viewComboBoxWidget.setEditable(0);
            viewComboBoxSize.Width=175;
            viewComboBoxSize.Height=20;
            viewComboBoxWidget.setMinimumSize(viewComboBoxSize.Width,viewComboBoxSize.Height);
            viewComboBoxWidget.setMinimumSize(viewComboBoxSize.Width,viewComboBoxSize.Height);
            viewComboBoxWidget.setToolTip(DAStudio.message('ModelAdvisor:engine:SelectViewTip'));


            viewComboBoxWidget.insertItems(0,DAStudio.message('ModelAdvisor:engine:FullView'));
            viewComboBoxWidget.insertItems(1,DAStudio.message('ModelAdvisor:engine:EdittimeView'));

            schema.prop(viewComboBoxWidget,'Listener','handle');
            viewComboBoxWidget.Listener=handle.listener(viewComboBoxWidget,'SelectionChangedEvent',@(s,e)loc_viewChangeCB(s,e));

            maobj.Toolbar.viewComboBoxWidget=viewComboBoxWidget;

            tb.addWidget(maobj.Toolbar.viewComboBoxWidget);
            tb.addSeparator;
        end
        mp=ModelAdvisor.Preferences;
        if mp.ShowProfiler
            maobj.Toolbar.StartProfile=am.createAction(me,'Text','Start','Callback','Advisor.internal.Profile.SwitchCB');
            tb.addAction(maobj.Toolbar.StartProfile);
            tb.addSeparator;
            maobj.Toolbar.ViewProfileReport=am.createAction(me,'Text','View Profile Report','Callback','Advisor.internal.Profile.View');
            tb.addAction(maobj.Toolbar.ViewProfileReport);
            tb.addSeparator;
        end
    case 'SelectFilterView'
        loc_viewChange(varargin{1});
    case 'emitInputParameter'
        varargout{1}=loc_emitInputParameter(varargin{1});
    case 'FeatureControl'
        varargout{1}=loc_featurecontrol(varargin{1});
    case 'InsideInactiveVariantBlock'
        varargout{1}=loc_InsideInactiveVariantBlock(varargin{1});
    case 'checkSlprjFolder'
        loc_rtw_check_slprj_dir(varargin{1});
    case 'DefaultMAUI'
        PrefFile=fullfile(prefdir,'mdladvprefs.mat');

        if length(varargin)==1
            DefaultMAType=varargin{1};
            if~(strcmpi(DefaultMAType,'MAStandardUI')||strcmpi(DefaultMAType,'MADashboard'))
                DAStudio.error('ModelAdvisor:engine:invalidDefaultMAType');
            end
        end
        if exist(PrefFile,'file')
            mdladvprefs=load(PrefFile);
            if length(varargin)==1
                save(PrefFile,'DefaultMAType','-append');
            else
                if isfield(mdladvprefs,'DefaultMAType')
                    varargout{1}=mdladvprefs.DefaultMAType;
                else
                    varargout{1}='MAStandardUI';
                end
            end
        else
            if length(varargin)==1
                save(PrefFile,'DefaultMAType');
            else
                varargout{1}='MAStandardUI';
            end
        end
    case 'qeQueryMdlAdvTestEnv'



        mode=varargin{1};




        qeMdlAdvTestMode.verifyTextDiff=false;

        if~isempty(mode)
            if isfield(qeMdlAdvTestMode,mode)
                if evalin('base','exist(''qeMdlAdvTestMode'', ''var'')')&&...
                    evalin('base','isstruct(qeMdlAdvTestMode)')
                    temp=evalin('base','qeMdlAdvTestMode');
                else
                    temp='';
                end
                if isfield(temp,mode)
                    outFlag=temp.(mode);
                else
                    outFlag=qeMdlAdvTestMode.(mode);
                end
            else
                DAStudio.error('Simulink:tools:MAInvalidParam',...
                ' one of the registered MdlAdv test mode');
            end
            varargout{1}=outFlag;
            varargout{2}='';
        else


            varargout{1}=false;
            varargout{2}=qeMdlAdvTestMode;
        end
    case 'ToggleTreatAsMdlref'
        mdladvObj=Simulink.ModelAdvisor.getActiveModelAdvisorObj;
        memenus=mdladvObj.MEmenus;
        if isfield(memenus,'s_treatasmdlref')&&isprop(memenus.s_treatasmdlref,'on')
            if strcmp(memenus.s_treatasmdlref.on,'on')
                mdladvObj.TreatAsMdlref=true;
            else
                mdladvObj.TreatAsMdlref=false;
            end
        end
    case 'PopupOptionDlg'
        mdladvObj=Simulink.ModelAdvisor.getActiveModelAdvisorObj;
        maOpt=ModelAdvisor.MAOptions(bdroot(getfullname(mdladvObj.SystemName)));
        maOpt.show;

    case 'dynamic_detach_node'
        parentObj=varargin{1};
        childrenObj=varargin{2};
        dynamic_detach_children(parentObj,childrenObj);
    case 'dynamic_attach_node'
        parentObj=varargin{1};
        childrenObj=varargin{2};
        dynamic_attach_children(parentObj,childrenObj);
    case 'shuffleReport'
        rptContents=varargin{1};
        varargout{1}=loc_shuffleReport(rptContents);
    case 'generate_collapsible_JS'
        varargout{1}=loc_getJSFunctionCodeCollapse(varargin{1});
    case 'CSSFormatting'
        if isempty(varargin)
            varargout{1}=loc_getModelAdvisorCSS('ModelAdvisor.css');
        else
            varargout{1}=loc_getModelAdvisorCSS(varargin{1});
        end
    case 'CalculateTreeInitStatus'
        varargout{1}=loc_calculateInitStatus(varargin{1});
    case 'InMixProcedureGroupCase'
        varargout{1}=loc_InMixProcedureGroupCase(varargin{1});
    case 'ConvertTreeToCellArray'

        treeRoot=copy(varargin{1});
        treeRoot.Index=0;
        treeList={};
        treeList=travel_tree(treeList,treeRoot,1);
        varargout{1}=treeRoot;
        varargout{2}=treeList;
    case 'TrimUnusedTrees'

        treeRoot=copy(varargin{1});
        treeRoot.Index=0;
        forest=varargin{2};
        treeList={};
        treeList=travel_tree_2(treeList,treeRoot,forest,1);
        varargout{1}=treeRoot;
        varargout{2}=treeList;
    case 'DeepCopy'
        SourceObj=varargin{1};
        DestObj=SourceObj;
        if~isempty(SourceObj)
            if iscell(SourceObj)
                copiedObj=cell(1,length(SourceObj));
                for j=1:length(SourceObj)
                    copiedObj{j}=copy(SourceObj{j});
                end
            else
                copiedObj=copy(SourceObj);
            end
            DestObj=copiedObj;
        end
        varargout{1}=DestObj;
    case 'GetEdittimeTasks'
        mdladvObj=Simulink.ModelAdvisor.getActiveModelAdvisorObj;
        if isempty(mdladvObj)
            needCreateTempMAObj=true;
            origdir=pwd;
            tempdir=tempname;
            mkdir(tempdir);
            cd(tempdir);
            newmodel=new_system;
            mdladvObj=Simulink.ModelAdvisor.getModelAdvisor(newmodel);
        else
            needCreateTempMAObj=false;
        end

        [foundObjs,parentGroup,toplevelChildren]=find_edittime_checks(mdladvObj,false);
        [foundObjs,~,~]=prioritizeEditTimeTasks(foundObjs,parentGroup,toplevelChildren,mdladvObj);

        etTasks={};
        for i=1:length(foundObjs)
            for j=1:length(foundObjs{i})
                etTasks{end+1}=foundObjs{i}{j}.ID;
            end
        end
        varargout{1}=etTasks;

        if needCreateTempMAObj
            close_system(newmodel);
            cd(origdir);
            rmdir(tempdir,'s');
        end

    case 'NeedGrayoutEffect'
        NodeObj=varargin{1};
        if isa(NodeObj,'ModelAdvisor.Task')&&isa(NodeObj.ParentObj,'ModelAdvisor.Procedure')&&~NodeObj.Enable
            varargout{1}=true;
        else
            varargout{1}=false;
        end
    otherwise
        DAStudio.error('Simulink:tools:MAUnknownMethod',methods);
    end

    function[objList,count]=travel_tree(objList,startNode,count)
        for i=1:length(startNode.ChildrenObj)
            copyObj=copy(startNode.ChildrenObj{i});
            copyObj.Index=count;
            copyObj.ParentObj=startNode;

            startNode.addChildren(copyObj);
            count=count+1;
            startNode.ChildrenObj{i}=copyObj;
            objList{end+1}=copyObj;
            [objList,count]=travel_tree(objList,startNode.ChildrenObj{i},count);
        end

        function[objList,count]=travel_tree_2(objList,startNode,forest,count)
            for i=1:length(startNode.ChildrenObj)
                copyObj=copy(forest{startNode.ChildrenObj{i}});
                copyObj.Index=count;
                copyObj.ParentObj=startNode.Index;
                count=count+1;
                startNode.ChildrenObj{i}=copyObj.Index;
                objList{end+1}=copyObj;
                [objList,count]=travel_tree_2(objList,copyObj,forest,count);
            end


            function rootStatus=loc_calculateInitStatus(treeRoot)
                ch=treeRoot.getChildren;
                SelectedCounter=0;
                DeselectedCounter=0;
                MixedCounter=0;
                for i=1:length(ch)
                    if isa(ch(i),'ModelAdvisor.Task')
                        if ch(i).Selected
                            SelectedCounter=SelectedCounter+1;
                        else
                            DeselectedCounter=DeselectedCounter+1;
                        end
                    else
                        subTreeStatus=loc_calculateInitStatus(ch(i));
                        if subTreeStatus==0
                            MixedCounter=MixedCounter+1;
                        elseif subTreeStatus==1
                            SelectedCounter=SelectedCounter+1;
                        else
                            DeselectedCounter=DeselectedCounter+1;
                        end
                    end
                end
                if loc_InMixProcedureGroupCase(treeRoot)
                    rootStatus=2;
                elseif MixedCounter>0||(SelectedCounter>0&&DeselectedCounter>0)
                    treeRoot.InTriState=true;
                    treeRoot.Selected=true;
                    rootStatus=0;
                elseif SelectedCounter>0
                    treeRoot.InTriState=false;
                    treeRoot.Selected=true;
                    rootStatus=1;
                else
                    treeRoot.InTriState=false;
                    treeRoot.Selected=false;
                    rootStatus=2;
                end

                function dynamic_detach_children(parentObj,childrenObj)
                    if isa(parentObj,'ModelAdvisor.Group')&&ismember(childrenObj.ID,parentObj.Children)
                        newChildren={};
                        newChildrenObj={};
                        if isempty(parentObj.OrigChildren)
                            parentObj.OrigChildren=parentObj.Children;
                        end
                        for i=1:length(parentObj.Children)
                            if strcmp(parentObj.Children{i},childrenObj.ID)

                            else
                                newChildren{end+1}=parentObj.Children{i};%#ok<*AGROW>
                                newChildrenObj{end+1}=parentObj.ChildrenObj{i};
                            end
                        end
                        parentObj.Children=newChildren;
                        parentObj.ChildrenObj=newChildrenObj;
                    end

                    function dynamic_attach_children(parentObj,childrenObj)
                        if isa(parentObj,'ModelAdvisor.Group')&&ismember(childrenObj.ID,parentObj.OrigChildren)&&~ismember(childrenObj.ID,parentObj.Children)
                            newChildren={};
                            newChildrenObj={};
                            j=1;
                            for i=1:length(parentObj.OrigChildren)
                                if strcmp(parentObj.OrigChildren{i},childrenObj.ID)

                                    newChildren{end+1}=childrenObj.ID;
                                    newChildrenObj{end+1}=childrenObj;
                                elseif~isempty(parentObj.Children)&&strcmp(parentObj.OrigChildren{i},parentObj.Children{j})
                                    newChildren{end+1}=parentObj.Children{j};
                                    newChildrenObj{end+1}=parentObj.ChildrenObj{j};
                                    j=j+1;
                                end
                            end
                            parentObj.Children=newChildren;
                            parentObj.ChildrenObj=newChildrenObj;
                        end

                        function outputCell=loc_commonFind(inputCell,opts)


























                            listDB=cell(1,numel(inputCell));
                            outputCell={};
                            if~isfield(opts,'regexp')
                                opts.regexp=false;
                            end

                            if~isfield(opts,'field')||~isfield(opts,'Identifier')
                                error(message('ModelAdvisor:engine:missRequiredFields','''field''','''Identifier''','opts'));
                            end


                            needCheckIsProp=strcmp(opts.field,'MAC');
                            for i=1:length(inputCell)
                                if needCheckIsProp&&~isprop(inputCell{i},opts.field)
                                    listDB{i}='';
                                else
                                    listDB{i}=inputCell{i}.(opts.field);
                                end
                            end

                            if ischar(opts.Identifier)

                                checkObjIndex=[];
                                if opts.regexp
                                    tempOut=regexp(listDB,opts.Identifier);


                                    for i=1:length(tempOut)
                                        if~isempty(tempOut{i})
                                            checkObjIndex(end+1)=i;
                                        end
                                    end
                                else
                                    checkObjIndex=find(strcmp(listDB,opts.Identifier));
                                end
                                if~isempty(checkObjIndex)

                                    outputCell=inputCell(checkObjIndex);
                                end
                            elseif isnumeric(opts.Identifier)
                                checkID=opts.Identifier;
                                if(0<checkID)&&(checkID<=length(inputCell))
                                    outputCell=inputCell(checkID);
                                end
                            end


                            function TAN=loc_createTANFromCheck(checkCellArray,index,IDPrefix)
                                TAN=ModelAdvisor.Task([IDPrefix,checkCellArray{index}.ID]);
                                TAN.DisplayName=checkCellArray{index}.Title;
                                TAN.Description=checkCellArray{index}.TitleTips;
                                TAN.MAC=checkCellArray{index}.ID;
                                TAN.Enable=checkCellArray{index}.Enable;


                                function htmlSource=loc_createReportHeaderSection(this,rerunMode,fromTaskAdvisorNode,generateTime,varargin)
                                    if nargin>4
                                        noSyncCounter=varargin{1};
                                        alltimestampsync=noSyncCounter==0;
                                    else


                                        alltimestampsync=true;
                                    end

                                    try
                                        model=getfullname(this.System);
                                        cr=newline;
                                        htmlSource='';
                                        htmlSource=[htmlSource,'<!DOCTYPE html>',cr];
                                        htmlSource=[htmlSource,'<html>',cr];
                                        htmlSource=[htmlSource,'<head>',cr];
                                        htmlSource=[htmlSource,'<meta http-equiv="X-UA-Compatible" content="IE=8" /> ',cr];

                                        htmlSource=[htmlSource,this.AtticData.CharSetDef,cr];
                                        if~isempty(this.CustomObject)&&~isempty(this.CustomObject.ReportTitle)
                                            htmlSource=[htmlSource,'<title>',modeladvisorprivate('modeladvisorutil2','ProcessCallbackFcn',this.CustomObject.ReportPageTitleCallback,this),'</title>  ',cr];
                                            rptTitle=this.CustomObject.ReportTitle;



                                        elseif strcmp(this.TaskAdvisorRoot.ID,'com.mathworks.cgo.group')
                                            htmlSource=[htmlSource,'<title>',DAStudio.message('RTW:configSet:CGARptfor'),' ''',model,'''</title>  ',cr];
                                            rptTitle=DAStudio.message('Simulink:tools:CGAReport');
                                        else
                                            htmlSource=[htmlSource,'<title>',DAStudio.message('ModelAdvisor:engine:MAReportfor',['''',model,'''']),'</title>  ',cr];
                                            rptTitle=DAStudio.message('ModelAdvisor:engine:MAReport');
                                        end



                                        style=ModelAdvisor.Element;
                                        style.setTag('style');
                                        style.setAttribute('type','text/css');
                                        style.setContent(loc_getModelAdvisorCSS('ModelAdvisorReport.css'));
                                        htmlSource=[htmlSource,style.emitHTML,cr];


                                        if isa(fromTaskAdvisorNode,'ModelAdvisor.Group')&&~Advisor.Options.getOption('PrettyPrint')&&...
                                            loc_featurecontrol('ReportControlPanel')
                                            style=ModelAdvisor.Element;
                                            style.setTag('style');
                                            style.setAttribute('type','text/css');
                                            style.setContent(loc_getModelAdvisorCSS('ModelAdvisorControlPanel.css'));
                                            htmlSource=[htmlSource,style.emitHTML,cr];


                                        elseif isempty(fromTaskAdvisorNode)&&~Advisor.Options.getOption('PrettyPrint')&&...
                                            loc_featurecontrol('ReportControlPanel')
                                            style=ModelAdvisor.Element;
                                            style.setTag('style');
                                            style.setAttribute('type','text/css');
                                            style.setContent(loc_getModelAdvisorCSS('ModelAdvisorControlPanelNoTOC.css'));
                                            htmlSource=[htmlSource,style.emitHTML,cr];
                                        end

                                        javascript=loc_getReportJS();

                                        javascriptColl=loc_getJSFunctionCodeCollapse(this);


                                        htmlSource=[htmlSource,'<script type="text/javascript"> <!-- ',javascript,javascriptColl,' --></script>'];

                                        htmlSource=[htmlSource,'</head>  ',cr];
                                        if isempty(javascriptColl)
                                            htmlSource=[htmlSource,'<body onload="updateHyperlink()">  ',cr];
                                        else
                                            htmlSource=[htmlSource,'<body onload="updateHyperlink(); expandCollapseAllOnLoad();">  ',cr];
                                        end


                                        top=ModelAdvisor.Element('span','id','top');
                                        htmlSource=[htmlSource,top.emitHTML];




                                        htmlSource=[htmlSource,loc_CreateIgnorePortion('<div id="Container">'),cr];



                                        treatAsMdlRefRequired=strcmp(this.CustomTARootID,'_SYSTEM_By Product_Simulink Code Inspector')||...
                                        exist(fullfile(matlabroot,'toolbox','slci','slci','+simulink','+internal','+customization','internalCustomizationSLCI.p'),'file')||...
                                        exist(fullfile(matlabroot,'toolbox','slci','slci','+simulink','+internal','+customization','internalCustomizationSLCI.m'),'file');
                                        variantInfoRequired=false;
                                        if Advisor.Utils.license('test','SL_Verification_Validation')
                                            appObj=Advisor.Manager.getApplication('ID',this.ApplicationID,'token','MWAdvi3orAPICa11');
                                            if isa(appObj,'Advisor.Application')
                                                variantInfoRequired=~isempty(appObj.VariantManager.getActiveVariantName);
                                            else
                                                variantInfoRequired=false;
                                            end
                                        end

                                        numRows=2;
                                        if~(alltimestampsync&&isempty(this.ConfigFilePath))
                                            numRows=numRows+1;
                                        end
                                        if treatAsMdlRefRequired||variantInfoRequired
                                            numRows=numRows+1;
                                        end
                                        rptTitleTable=ModelAdvisor.Table(numRows,2);
                                        rptTitleTable.setBorder(0);
                                        rptTitleTable.setAttribute('width','100%');
                                        if rerunMode&&isa(fromTaskAdvisorNode,'ModelAdvisor.Node')
                                            [~,~,ext]=fileparts(get_param(bdroot(model),'fileName'));
                                            rptTitleTable.setHeading(ModelAdvisor.Text([rptTitle,' - ','<font color="#800000">',bdroot(model),ext,'</font>'],{'bold'}));
                                        else
                                            rptTitleTable.setHeading(ModelAdvisor.Text(rptTitle,{'bold'}));
                                        end
                                        rptTitleTable.setHeadingAlign('center');
                                        SLversion=num2str(get_param(0,'version'));
                                        rptTitleTable.setEntry(1,1,ModelAdvisor.Text([DAStudio.message('Simulink:tools:SLVersion'),': ','<font color="#800000">',SLversion,'</font>'],{'bold'}));
                                        rptTitleTable.setEntry(1,2,ModelAdvisor.Text([DAStudio.message('Simulink:tools:MdlVersion'),': ','<font color="#800000">',get_param(bdroot(model),'ModelVersion'),'</font>'],{'bold'}));
                                        if this.IsLibrary
                                            LibPrefix=[' (',DAStudio.message('ModelAdvisor:engine:Library'),')'];
                                        else
                                            LibPrefix='';
                                        end
                                        rptTitleTable.setEntry(2,1,ModelAdvisor.Text([DAStudio.message('Simulink:tools:MASystem'),LibPrefix,': ','<font color="#800000">',model,'</font>'],{'bold'}));
                                        if generateTime~=0
                                            generateTimeStr=loc_getDateString(generateTime);
                                        else
                                            generateTimeStr=DAStudio.message('Simulink:tools:MANotApplicable');
                                        end
                                        rptTitleTable.setEntry(2,2,ModelAdvisor.Text([DAStudio.message('Simulink:tools:MACurrentrun'),': ','<font color="#800000">',generateTimeStr,'</font>'],{'bold'}));
                                        rptTitleTable.setEntryAlign(1,2,'right');
                                        rptTitleTable.setEntryAlign(2,2,'right');
                                        if~alltimestampsync
                                            infoIcon=ModelAdvisor.Image;
                                            infoIcon.setImageSource('info_icon.png');
                                            if noSyncCounter==1
                                                noSyncCheckCountString=ModelAdvisor.Text([' ',DAStudio.message('Simulink:tools:MAOneCheckNotSyncRpt',loc_getDateString(generateTimeStr))]);
                                            else
                                                noSyncCheckCountString=ModelAdvisor.Text([' ',DAStudio.message('Simulink:tools:MAMoreCheckNotSyncRpt',num2str(noSyncCounter),loc_getDateString(generateTimeStr))]);
                                            end
                                            rptTitleTable.setEntry(3,1,[infoIcon,noSyncCheckCountString]);
                                        end
                                        if~isempty(this.ConfigFilePath)
                                            [~,configname,configext]=fileparts(this.ConfigFilePath);
                                            configFilePathInRpt=[configname,configext];
                                            if length(configFilePathInRpt)>25
                                                configFilePathInRpt=['...',configFilePathInRpt(end-25:end)];
                                            end
                                            rptTitleTable.setEntry(3,2,ModelAdvisor.Text([' ',DAStudio.message('Simulink:tools:MACETitleInRpt'),': <font color="#800000">',configFilePathInRpt,'</font>'],{'bold'}));
                                            rptTitleTable.setEntryAlign(3,2,'right');
                                        end
                                        if this.treatAsMdlref
                                            treatAsMdlref=DAStudio.message('ModelAdvisor:engine:on');
                                        else
                                            treatAsMdlref=DAStudio.message('ModelAdvisor:engine:off');
                                        end
                                        if treatAsMdlRefRequired
                                            rptTitleTable.setEntry(numRows,1,ModelAdvisor.Text([DAStudio.message('ModelAdvisor:engine:TreatAsRefMdl'),': ','<font color="#800000">',treatAsMdlref,'</font>'],{'bold'}));
                                            rptTitleTable.setEntryAlign(numRows,2,'right');
                                        end

                                        if variantInfoRequired
                                            rptTitleTable.setEntry(numRows,2,ModelAdvisor.Text([DAStudio.message('ModelAdvisor:engine:Variant'),': ','<font color="#800000">',appObj.VariantManager.getActiveVariantName,'</font>'],{'bold'}));
                                            rptTitleTable.setEntryAlign(numRows,2,'right');
                                        end



                                        if(isempty(fromTaskAdvisorNode)||isa(fromTaskAdvisorNode,'ModelAdvisor.Group'))&&~Advisor.Options.getOption('PrettyPrint')&&...
                                            loc_featurecontrol('ReportControlPanel')
                                            controlPanel=loc_createControlPanel(fromTaskAdvisorNode);

                                            htmlSource=[htmlSource,cr,...
                                            loc_CreateIgnorePortion(controlPanel.emitHTML),cr,...
                                            loc_CreateIgnorePortion(['<div class="ReportContent" id="',model,'">']),...
                                            rptTitleTable.emitHTML];
                                        else
                                            htmlSource=[htmlSource,loc_CreateIgnorePortion(['<div class="ReportContent" id="',model,'">']),rptTitleTable.emitHTML];
                                        end
                                    catch E
                                        disp(E.message);
                                        DAStudio.error('Simulink:tools:MAModelNotRdyForGenReport');
                                    end




                                    function dateString=loc_getDateString(timeInfo)

                                        locale=feature('locale');
                                        lang=locale.messages;

                                        if strncmpi(lang,'ja',2)||strncmp(lang,'zh_CN',5)||strncmpi(lang,'ko_KR',5)
                                            dateString=datestr(timeInfo,'yyyy/mm/dd HH:MM:SS');
                                        else
                                            dateString=datestr(timeInfo);
                                        end





                                        function controlPanel=loc_createControlPanel(taskObj)


                                            controlPanel=ModelAdvisor.Element('div','id','ControlPanel');





                                            collapseControl=ModelAdvisor.Element('div',...
                                            'id','HidePanelControl',...
                                            'title',DAStudio.message('ModelAdvisor:engine:ControlPanelMinimizeCPTitle'),...
                                            'onclick','hideControlPanel(this)',...
                                            'onmouseover','this.style.cursor=''pointer''');
                                            tempDiv=ModelAdvisor.Element('div',...
                                            'id','HidePanelControlInner');
                                            tempDiv.setContent('&#9664;');
                                            collapseControl.setContent(tempDiv);

                                            controlPanel.addContent(collapseControl);





                                            [warningImg,passedImg,failedImg,notrunImg,~,~,~,justifyImg,errorImg]=getDataURLs();


                                            filteringControls=ModelAdvisor.Element('div','id','ControlsCheckFiltering');


                                            filteringHeading=ModelAdvisor.Element('h2');
                                            filteringHeading.setContent(DAStudio.message('ModelAdvisor:engine:ControlPanelFilteringHeading'));
                                            filteringControls.addContent(filteringHeading);


                                            table=ModelAdvisor.Table(7,2);
                                            table.setAttribute('id','CPFilteringTable');
                                            index=find(strcmp('class',table.TagAttributes(:,1)));
                                            if~isempty(index)
                                                table.TagAttributes(index,:)=[];
                                            end


                                            passedInput=ModelAdvisor.Element('input',...
                                            'id','Passed Checkbox',...
                                            'checked','checked',...
                                            'onclick','updateVisibleChecks(this)',...
                                            'type','checkbox');
                                            passedInput.IsSingletonTag=true;
                                            tempImg=ModelAdvisor.Image;
                                            tempImg.setImageSource(passedImg(6:end-2));
                                            table.setEntry(1,1,[passedInput,tempImg,ModelAdvisor.Text([' ',DAStudio.message('ModelAdvisor:engine:CmdAPIPassed')])]);




                                            failedInput=ModelAdvisor.Element('input',...
                                            'id','Failed Checkbox',...
                                            'checked','checked',...
                                            'onclick','updateVisibleChecks(this)',...
                                            'type','checkbox');
                                            failedInput.IsSingletonTag=true;
                                            tempImg=ModelAdvisor.Image;
                                            tempImg.setImageSource(failedImg(6:end-2));
                                            table.setEntry(2,1,[failedInput,tempImg,ModelAdvisor.Text([' ',DAStudio.message('ModelAdvisor:engine:CmdAPIFailed')])]);




                                            warningInput=ModelAdvisor.Element('input',...
                                            'id','Warning Checkbox',...
                                            'checked','checked',...
                                            'onclick','updateVisibleChecks(this)',...
                                            'type','checkbox');
                                            warningInput.IsSingletonTag=true;
                                            tempImg=ModelAdvisor.Image;
                                            tempImg.setImageSource(warningImg(6:end-2));
                                            table.setEntry(3,1,[warningInput,tempImg,ModelAdvisor.Text([' ',DAStudio.message('ModelAdvisor:engine:CmdAPIWarning')])]);




                                            notRunInput=ModelAdvisor.Element('input',...
                                            'id','Not Run Checkbox',...
                                            'checked','checked',...
                                            'onclick','updateVisibleChecks(this)',...
                                            'type','checkbox');
                                            notRunInput.IsSingletonTag=true;
                                            tempImg=ModelAdvisor.Image;
                                            tempImg.setImageSource(notrunImg(6:end-2));
                                            table.setEntry(4,1,[notRunInput,tempImg,ModelAdvisor.Text([' ',DAStudio.message('ModelAdvisor:engine:CmdAPINotRun')])]);




                                            justifiedInput=ModelAdvisor.Element('input',...
                                            'id','Justified Checkbox',...
                                            'checked','checked',...
                                            'onclick','updateVisibleChecks(this)',...
                                            'type','checkbox');
                                            justifiedInput.IsSingletonTag=true;
                                            tempImg=ModelAdvisor.Image;
                                            tempImg.setImageSource(justifyImg(6:end-2));
                                            table.setEntry(5,1,[justifiedInput,tempImg,ModelAdvisor.Text([' ',DAStudio.message('ModelAdvisor:engine:CmdAPIJustified')])]);


                                            incompleteInput=ModelAdvisor.Element('input',...
                                            'id','Incomplete Checkbox',...
                                            'checked','checked',...
                                            'onclick','updateVisibleChecks(this)',...
                                            'type','checkbox');
                                            incompleteInput.IsSingletonTag=true;
                                            tempImg=ModelAdvisor.Image;
                                            tempImg.setImageSource(errorImg(6:end-2));
                                            table.setEntry(6,1,[incompleteInput,tempImg,ModelAdvisor.Text([' ',DAStudio.message('ModelAdvisor:engine:CmdAPIIncomplete')])]);





                                            filteringControls.addContent(table);


                                            div=ModelAdvisor.Element('div','id','TextFilter');
                                            onfocusFct=['if (this.value==''',DAStudio.message('ModelAdvisor:engine:ControlPanelSearch'),...
                                            '''){ this.value=''''; this.style.color=''black'';}'];
                                            onblurFct=['if (this.value==''''){ this.value=''',...
                                            DAStudio.message('ModelAdvisor:engine:ControlPanelSearch'),...
                                            '''; this.style.color=''gray'';}'];
                                            searchInput=ModelAdvisor.Element('input',...
                                            'id','TxtFilterInput',...
                                            'onkeyup','filterByText(event)',...
                                            'onfocus',onfocusFct,...
                                            'onblur',onblurFct,...
                                            'value',DAStudio.message('ModelAdvisor:engine:ControlPanelSearch'),...
                                            'type','text',...
                                            'title',DAStudio.message('ModelAdvisor:engine:ControlPanelSearchTooltip'));
                                            searchInput.IsSingletonTag=true;
                                            div.addContent(searchInput);
                                            filteringControls.addContent(div);

                                            controlPanel.addContent(filteringControls);




                                            if isa(taskObj,'ModelAdvisor.Group')
                                                TOC=ModelAdvisor.Element('div','id','ControlsTOC');


                                                TOCHeading=ModelAdvisor.Element;
                                                TOCHeading.setTag('h2');
                                                TOCHeading.setContent(DAStudio.message('ModelAdvisor:engine:ControlPanelTOCHeading'));
                                                TOC.addContent(TOCHeading);

                                                TOCScrollArea=ModelAdvisor.Element('div','id','TOCScrollableArea');

                                                [mainTOCEntry,subEntries]=loc_createControlPanelTOC(taskObj,'');

                                                TOCScrollArea.addContent(mainTOCEntry);
                                                if~isempty(subEntries)
                                                    TOCScrollArea.addContent(subEntries);
                                                end

                                                TOC.addContent(TOCScrollArea);
                                                controlPanel.addContent(TOC);
                                            end


                                            viewControls=ModelAdvisor.Element('div','id','ControlsView');

                                            viewHeading=ModelAdvisor.Element;
                                            viewHeading.setTag('h2');
                                            viewHeading.setContent(DAStudio.message('ModelAdvisor:engine:ControlPanelViewHeading'));
                                            viewControls.addContent(viewHeading);


                                            toTop=ModelAdvisor.Element('div','class','ControlPanelTextControl',...
                                            'title',DAStudio.message('ModelAdvisor:engine:ControlPanelToTopTitle'),...
                                            'onmouseover','this.style.cursor=''pointer''',...
                                            'onclick','navigateToElement(''top'')');
                                            tempImg=ModelAdvisor.Image;
                                            tempImg.setImageSource('data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABIAAAARAQMAAADqlG66AAAAA3NCSVQICAjb4U/gAAAABlBMVEX///9Tktdg+Ox4AAAAAnRSTlMA/1uRIrUAAAAJcEhZcwAACxIAAAsSAdLdfvwAAAAWdEVYdENyZWF0aW9uIFRpbWUAMTIvMTgvMDiz53+6AAAAGHRFWHRTb2Z0d2FyZQBBZG9iZSBGaXJld29ya3NPsx9OAAAEEXRFWHRYTUw6Y29tLmFkb2JlLnhtcAA8P3hwYWNrZXQgYmVnaW49IiAgICIgaWQ9Ilc1TTBNcENlaGlIenJlU3pOVGN6a2M5ZCI/Pgo8eDp4bXBtZXRhIHhtbG5zOng9ImFkb2JlOm5zOm1ldGEvIiB4OnhtcHRrPSJBZG9iZSBYTVAgQ29yZSA0LjEtYzAzNCA0Ni4yNzI5NzYsIFNhdCBKYW4gMjcgMjAwNyAyMjozNzozNyAgICAgICAgIj4KICAgPHJkZjpSREYgeG1sbnM6cmRmPSJodHRwOi8vd3d3LnczLm9yZy8xOTk5LzAyLzIyLXJkZi1zeW50YXgtbnMjIj4KICAgICAgPHJkZjpEZXNjcmlwdGlvbiByZGY6YWJvdXQ9IiIKICAgICAgICAgICAgeG1sbnM6eGFwPSJodHRwOi8vbnMuYWRvYmUuY29tL3hhcC8xLjAvIj4KICAgICAgICAgPHhhcDpDcmVhdG9yVG9vbD5BZG9iZSBGaXJld29ya3MgQ1MzPC94YXA6Q3JlYXRvclRvb2w+CiAgICAgICAgIDx4YXA6Q3JlYXRlRGF0ZT4yMDA4LTEyLTE4VDIyOjA2OjAxWjwveGFwOkNyZWF0ZURhdGU+CiAgICAgICAgIDx4YXA6TW9kaWZ5RGF0ZT4yMDA4LTEyLTE4VDIyOjA4OjQzWjwveGFwOk1vZGlmeURhdGU+CiAgICAgIDwvcmRmOkRlc2NyaXB0aW9uPgogICAgICA8cmRmOkRlc2NyaXB0aW9uIHJkZjphYm91dD0iIgogICAgICAgICAgICB4bWxuczpkYz0iaHR0cDovL3B1cmwub3JnL2RjL2VsZW1lbnRzLzEuMS8iPgogICAgICAgICA8ZGM6Zm9ybWF0PmltYWdlL3BuZzwvZGM6Zm9ybWF0PgogICAgICA8L3JkZjpEZXNjcmlwdGlvbj4KICAgPC9yZGY6UkRGPgo8L3g6eG1wbWV0YT4KICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgIAogICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgCiAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICA9F2ciAAAAIElEQVQImWNgQAP8f5A4BxgYGB8wMDB/YGBg/4EmhwAAvEcFqqXqgcsAAAAASUVORK5CYII=');
                                            tempImg.setAttribute('id','CPToTopImg');
                                            toTop.addContent(tempImg);
                                            toTop.addContent(DAStudio.message('ModelAdvisor:engine:ControlPanelToTop'));
                                            viewControls.addContent(toTop);


                                            checkDetails=ModelAdvisor.Element('div',...
                                            'id','ExpandCollapseAll','class','ControlPanelTextControl',...
                                            'onmouseover','this.style.cursor=''pointer''',...
                                            'onclick','expandCollapseAll(this)',...
                                            'title',DAStudio.message('ModelAdvisor:engine:ControlPanelCheckDetailsCollTitle'));




                                            checkDetails.addContent(DAStudio.message('ModelAdvisor:engine:ControlPanelCheckDetailsCollapse'));
                                            viewControls.addContent(checkDetails);

                                            controlPanel.addContent(viewControls);



                                            function[TOCEntry,subLevelEntries]=loc_createControlPanelTOC(taskObj,levelID)


                                                subLevelEntries=[];


                                                TOCEntry=ModelAdvisor.Element('div',...
                                                'class','ControlPanelTextControl','onmouseover','this.style.cursor=''pointer''',...
                                                'onclick',['navigateToElement(''FolderControl_',taskObj.ID,''')']);
                                                TOCEntry.addContent([levelID,' ',taskObj.DisplayName]);


                                                if length(regexp(levelID,'[\.]{1}','start'))<3

                                                    ChildObjects=taskObj.ChildrenObj;

                                                    subLevelID=0;

                                                    for n=1:length(ChildObjects)
                                                        if isa(ChildObjects{n},'ModelAdvisor.Group')
                                                            subLevelID=subLevelID+1;

                                                            if~isempty(levelID)
                                                                tmpLevelStr=[levelID,'.',num2str(subLevelID)];
                                                            else
                                                                tmpLevelStr=num2str(subLevelID);
                                                            end
                                                            [tempTOCEntry,tempTOCSubLevelEntry]=loc_createControlPanelTOC(ChildObjects{n},tmpLevelStr);

                                                            if isempty(subLevelEntries)
                                                                subLevelEntries=tempTOCEntry;
                                                                if~isempty(tempTOCSubLevelEntry)
                                                                    subLevelEntries=[subLevelEntries,tempTOCSubLevelEntry];
                                                                end
                                                            else
                                                                subLevelEntries(end+1)=tempTOCEntry;
                                                                if~isempty(tempTOCSubLevelEntry)
                                                                    subLevelEntries=[subLevelEntries,tempTOCSubLevelEntry];
                                                                end
                                                            end
                                                        end
                                                    end
                                                end

                                                function[counterStructure,summaryTable]=loc_getNodeSummaryInfo(fromTaskAdvisorNode)
                                                    childrenObjlist=fromTaskAdvisorNode.getAllChildren;
                                                    counterStructure=[];
                                                    counterStructure.Index=fromTaskAdvisorNode.Index;
                                                    counterStructure.allCt=0;
                                                    counterStructure.passCt=0;
                                                    counterStructure.warnCt=0;
                                                    counterStructure.failCt=0;
                                                    counterStructure.nrunCt=0;
                                                    counterStructure.generateTime=0;
                                                    enumList=enumeration(ModelAdvisor.CheckStatus.NotRun);
                                                    for i=1:length(enumList)
                                                        st=[char(enumList(i)),'Ct'];
                                                        counterStructure.(st)=0;
                                                    end
                                                    for childrenObjlistCt=1:length(childrenObjlist)
                                                        curChildObj=childrenObjlist{childrenObjlistCt};
                                                        if curChildObj.MACIndex~=0
                                                            if curChildObj.MACIndex>0
                                                                curentCheck=curChildObj.Check;
                                                            else
                                                                curentCheck=-1;
                                                            end
                                                            st=[char(curChildObj.State),'Ct'];
                                                            counterStructure.(st)=counterStructure.(st)+1;
                                                            switch curChildObj.State
                                                            case ModelAdvisor.CheckStatus.NotRun
                                                                counterStructure.nrunCt=counterStructure.nrunCt+1;
                                                            case ModelAdvisor.CheckStatus.Passed
                                                                counterStructure.passCt=counterStructure.passCt+1;
                                                            case ModelAdvisor.CheckStatus.Failed
                                                                counterStructure.failCt=counterStructure.failCt+1;
                                                            case ModelAdvisor.CheckStatus.Warning
                                                                counterStructure.warnCt=counterStructure.warnCt+1;


                                                            end

                                                            if counterStructure.generateTime<curChildObj.RunTime
                                                                counterStructure.generateTime=curChildObj.RunTime;
                                                            end
                                                        end
                                                    end
                                                    counterStructure.allCt=0;
                                                    for i=1:length(enumList)
                                                        st=[char(enumList(i)),'Ct'];
                                                        counterStructure.allCt=counterStructure.allCt+counterStructure.(st);

                                                        images(i)=ModelAdvisor.Image;
                                                        [~,name,ext]=fileparts(ModelAdvisor.CheckStatusUtil.getIcon(enumList(i),'task'));
                                                        images(i).setImageSource([name,ext]);
                                                    end


                                                    runSummaryTable=ModelAdvisor.Table(1,8);
                                                    runSummaryTable.setBorder(0);
                                                    runSummaryTable.setAttribute('width','60%');


                                                    enumList=enumList(enumList~=ModelAdvisor.CheckStatus.Informational);
                                                    for i=1:length(enumList)
                                                        j=length(enumList)-i+1;
                                                        runSummaryTable.setColHeading(i,ModelAdvisor.CheckStatusUtil.getText(enumList(j)));

                                                        st=[char(enumList(j)),'Ct'];
                                                        runSummaryTable.setEntry(1,i,[ModelAdvisor.Text('&#160;&#160;'),images(enumList(j)+1),ModelAdvisor.Text([' ',num2str(counterStructure.(st))])]);
                                                    end

                                                    runSummaryTable.setColHeading(length(enumList)+1,DAStudio.message('Simulink:tools:MATotal'));
                                                    runSummaryTable.setEntry(1,length(enumList)+1,ModelAdvisor.Text([' ',num2str(counterStructure.allCt)]));

                                                    LineBreak=ModelAdvisor.LineBreak;
                                                    summaryTable=[LineBreak.emitHTML,'<font color="#800000"><b>',DAStudio.message('Simulink:tools:MARunSummary'),'</b></font>',LineBreak.emitHTML,runSummaryTable.emitHTML];
                                                    if fromTaskAdvisorNode.MAObj.ShowActionResultInRpt
                                                        summaryTable='';
                                                    end



                                                    function[counterStructure,summaryTable]=loc_getNodeSummaryInfoChecks(recordCellArray,orderedCheckIndex)
                                                        counterStructure=[];
                                                        counterStructure.allCt=0;
                                                        counterStructure.passCt=0;
                                                        counterStructure.warnCt=0;
                                                        counterStructure.failCt=0;
                                                        counterStructure.nrunCt=0;
                                                        counterStructure.generateTime=0;
                                                        enumList=enumeration(ModelAdvisor.CheckStatus.NotRun);
                                                        for i=1:length(enumList)
                                                            st=[char(enumList(i)),'Ct'];
                                                            counterStructure.(st)=0;
                                                        end
                                                        for i=1:length(orderedCheckIndex)
                                                            curChildObj=recordCellArray{orderedCheckIndex{i}};
                                                            st=[char(curChildObj.status),'Ct'];
                                                            counterStructure.(st)=counterStructure.(st)+1;
                                                            switch curChildObj.status
                                                            case ModelAdvisor.CheckStatus.NotRun
                                                                counterStructure.nrunCt=counterStructure.nrunCt+1;
                                                            case ModelAdvisor.CheckStatus.Passed
                                                                counterStructure.passCt=counterStructure.passCt+1;
                                                            case ModelAdvisor.CheckStatus.Failed
                                                                counterStructure.failCt=counterStructure.failCt+1;
                                                            case ModelAdvisor.CheckStatus.Warning
                                                                counterStructure.warnCt=counterStructure.warnCt+1;
                                                            otherwise
                                                                counterStructure.nrunCt=counterStructure.nrunCt+1;
                                                            end




                                                        end

                                                        counterStructure.allCt=0;
                                                        for i=1:length(enumList)
                                                            st=[char(enumList(i)),'Ct'];
                                                            counterStructure.allCt=counterStructure.allCt+counterStructure.(st);

                                                            images(i)=ModelAdvisor.Image;
                                                            [~,name,ext]=fileparts(ModelAdvisor.CheckStatusUtil.getIcon(enumList(i),'task'));
                                                            images(i).setImageSource([name,ext]);
                                                        end


                                                        runSummaryTable=ModelAdvisor.Table(1,8);
                                                        runSummaryTable.setBorder(0);
                                                        runSummaryTable.setAttribute('width','60%');


                                                        enumList=enumList(enumList~=ModelAdvisor.CheckStatus.Informational);
                                                        for i=1:length(enumList)
                                                            j=length(enumList)-i+1;
                                                            runSummaryTable.setColHeading(i,ModelAdvisor.CheckStatusUtil.getText(enumList(j)));

                                                            st=[char(enumList(j)),'Ct'];
                                                            runSummaryTable.setEntry(1,i,[ModelAdvisor.Text('&#160;&#160;'),images(enumList(j)+1),ModelAdvisor.Text([' ',num2str(counterStructure.(st))])]);
                                                        end
                                                        runSummaryTable.setColHeading(length(enumList)+1,DAStudio.message('Simulink:tools:MATotal'));
                                                        runSummaryTable.setEntry(1,length(enumList)+1,ModelAdvisor.Text([' ',num2str(counterStructure.allCt)]));
                                                        LineBreak=ModelAdvisor.LineBreak;
                                                        summaryTable=[LineBreak.emitHTML,'<font color="#800000"><b>',DAStudio.message('Simulink:tools:MARunSummary'),'</b></font>',LineBreak.emitHTML,runSummaryTable.emitHTML];






                                                        function[resultHTML,dsyncCount]=loc_emitHTMLforTaskNode(this,~,generateTime,needWriteCurrentString,level,FolderNumbering)

                                                            cr=sprintf('\n');
                                                            indentDivOpen=loc_CreateIgnorePortion('<div class="subsection">');
                                                            indentDivClose=loc_CreateIgnorePortion('</div>');
                                                            dsyncCount=0;
                                                            if isa(this,'ModelAdvisor.Task')
                                                                if this.MACIndex~=0
                                                                    htmlSource='';

                                                                    if this.MACIndex>0
                                                                        DefineNameStr=['CheckRecord_',num2str(this.Check.Index)];
                                                                    else
                                                                        DefineNameStr='CheckRecord_-1';
                                                                    end

                                                                    htmlSource=[htmlSource,'<a name="',DefineNameStr,'"></a>'];






                                                                    [~,b,c]=fileparts(this.getDisplayIcon);
                                                                    if strcmp(b,'task_warning_h')
                                                                        b='task_warning';
                                                                    end
                                                                    imageLink=['<img src="',b,c,'" />&#160;'];
                                                                    if~strcmp(this.Severity,'Optional')
                                                                        requirestring=[' (',DAStudio.message('Simulink:tools:MARequired'),')'];
                                                                    else
                                                                        requirestring='';
                                                                    end
                                                                    if(this.RunTime~=0)&&(this.RunTime<generateTime)&&(this.State~=ModelAdvisor.CheckStatus.NotRun)
                                                                        outofdatewarn=loc_CreateIgnorePortion([' (',loc_getDateString(this.RunTime),')']);
                                                                        dsyncCount=dsyncCount+1;
                                                                    else
                                                                        outofdatewarn='';



                                                                    end



                                                                    checkHeader=ModelAdvisor.Element('div','class','CheckHeader',...
                                                                    'id',['Header_',this.MAC]);
                                                                    checkHeader.addContent(loc_CreateIgnorePortion(imageLink));
                                                                    checkHeading=ModelAdvisor.Element('span','class','CheckHeading',...
                                                                    'id',['Heading_',this.MAC]);
                                                                    checkHeading.addContent(this.Displayname);
                                                                    checkHeader.addContent(checkHeading);
                                                                    checkHeader.addContent(loc_CreateIgnorePortion(requirestring));
                                                                    checkHeader.addContent(loc_CreateIgnorePortion(outofdatewarn));
                                                                    htmlSource=[htmlSource,checkHeader.emitHTML];




                                                                    divClose=loc_CreateIgnorePortion('</div>');
                                                                    hrStr=[cr,'<p><hr /></p>  '];
                                                                    if(this.State~=ModelAdvisor.CheckStatus.NotRun)
                                                                        if this.MACIndex<0
                                                                            resultHTML=[htmlSource,indentDivOpen,['<p />',ModelAdvisor.Text(DAStudio.message('Simulink:tools:MAMissCorrespondCheck',this.MAC),{'fail'}).emitHTML],indentDivClose];
                                                                        else
                                                                            resultHTML=[htmlSource,this.Check.ResultInHTML];
                                                                            if this.MAObj.ShowActionResultInRpt
                                                                                resultHTML=[resultHTML,loc_emitActionResult(this.Check)];
                                                                            end
                                                                        end
                                                                        if this.MACIndex<0

                                                                            divOpen=loc_CreateIgnorePortion(['<div name = "Failed Check" id = "Failed Check" class="FailedCheck" style="margin-left: ',num2str(level*5),'pt;"> ']);
                                                                            resultHTML=[divOpen,hrStr,resultHTML,divClose];
                                                                        elseif(this.Check.Success||this.Check.status=='Passed')
                                                                            divOpen=loc_CreateIgnorePortion(['<div name = "Passed Check"  id = "Passed Check" class="PassedCheck" style="margin-left: ',num2str(level*5),'pt;">']);
                                                                            resultHTML=[divOpen,hrStr,resultHTML,divClose];
                                                                        elseif(this.Check.status=='Justified')
                                                                            divOpen=loc_CreateIgnorePortion(['<div name = "Justified Check"  id = "Justified Check" class="JustifiedCheck" style="margin-left: ',num2str(level*5),'pt;">']);
                                                                            resultHTML=[divOpen,hrStr,resultHTML,divClose];
                                                                        elseif(~(this.Check.ErrorSeverity))
                                                                            divOpen=loc_CreateIgnorePortion(['<div name = "Warning Check" id = "Warning Check" class="WarningCheck" style="margin-left: ',num2str(level*5),'pt;"> ']);
                                                                            resultHTML=[divOpen,hrStr,resultHTML,divClose];
                                                                        else
                                                                            divOpen=loc_CreateIgnorePortion(['<div name = "Failed Check" id = "Failed Check" class="FailedCheck" style="margin-left: ',num2str(level*5),'pt;"> ']);
                                                                            resultHTML=[divOpen,hrStr,resultHTML,divClose];
                                                                        end
                                                                    else
                                                                        resultHTML=[htmlSource,indentDivOpen,'<p />',DAStudio.message('Simulink:tools:MANotRunMsg')];
                                                                        if this.MAObj.IsLibrary&&~this.MAObj.CheckCellArray{this.MACIndex}.SupportLibrary&&~modeladvisorprivate('modeladvisorutil2','FeatureControl','ForceRunOnLibrary')
                                                                            resultHTML=[resultHTML,'. ',DAStudio.message('ModelAdvisor:engine:CheckNotSupportLibrary')];
                                                                        end
                                                                        resultHTML=[resultHTML,indentDivClose];
                                                                        divOpen=loc_CreateIgnorePortion(['<div name = "Not Run Check" id = "Not Run Check" class="NotRunCheck" style="margin-left: ',num2str(level*5),'pt;"> ']);
                                                                        resultHTML=[divOpen,hrStr,resultHTML,divClose];
                                                                    end
                                                                else
                                                                    resultHTML='';
                                                                end
                                                            else

                                                                [counterStructure,~]=loc_getNodeSummaryInfo(this);
                                                                resultCountStr='';
                                                                if(level>0)
                                                                    resultCountStr=[resultCountStr,'<span class = "SubResultsSummary" id= "SubResults_',this.ID,'" >'];
                                                                    enumList=enumeration(ModelAdvisor.CheckStatus.NotRun);

                                                                    enumList=enumList(enumList~=ModelAdvisor.CheckStatus.Informational);
                                                                    for i=1:length(enumList)
                                                                        j=length(enumList)-i+1;
                                                                        [~,name,ext]=fileparts(ModelAdvisor.CheckStatusUtil.getIcon(enumList(j),'task'));
                                                                        st=[char(enumList(j)),'Ct'];
                                                                        resultCountStr=[resultCountStr,'&#160;&#160;<img src="',name,ext,'" />',num2str(counterStructure.(st))];
                                                                    end
                                                                    resultCountStr=[resultCountStr,'</span>',cr];








                                                                end

                                                                spanFolderCtrl=ModelAdvisor.Element('span','class','FolderControl',...
                                                                'id',['FolderControl_',this.ID],...
                                                                'onclick',['MATableShrink(this,''',this.ID,''')'],...
                                                                'onmouseover','this.style.cursor = ''pointer''');
                                                                controlImg=Advisor.Image;
                                                                controlImg.setImageSource('minus.png');
                                                                spanFolderCtrl.setContent(controlImg);

                                                                spanStr=spanFolderCtrl.emitHTML;
                                                                for i=1:level
                                                                    spanStr=['&#160; ',spanStr];
                                                                end
                                                                spanStr=loc_CreateIgnorePortion(spanStr);
                                                                level=level+2;
                                                                sectionTitle=['<br /><br /><font color="#800000"><b>',spanStr,...
                                                                FolderNumbering,' ',this.DisplayName,'</b></font>',resultCountStr];

                                                                resultHTML=loc_CreateIgnorePortion(sectionTitle);


                                                                folderContentDivStartTag=loc_CreateIgnorePortion(['<div name = "',this.ID,'"  id = "',this.ID,'" class="FolderContent">']);


                                                                hiddenOutput=ModelAdvisor.Element('div','class','EmptyFolderMessage','style','display:none;');
                                                                hiddenOutput.setContent(DAStudio.message('ModelAdvisor:engine:ReportAllChecksHidden'));
                                                                resultHTML=[resultHTML,folderContentDivStartTag,loc_CreateIgnorePortion(hiddenOutput.emitHTML)];

                                                                subFolderNumbering=0;
                                                                for i=1:length(this.ChildrenObj)
                                                                    if isa(this.ChildrenObj{i},'ModelAdvisor.Group')
                                                                        subFolderNumbering=subFolderNumbering+1;
                                                                    end

                                                                    if isempty(FolderNumbering)
                                                                        tempFolderNumbering=num2str(subFolderNumbering);
                                                                    else
                                                                        tempFolderNumbering=[FolderNumbering,'.',num2str(subFolderNumbering)];
                                                                    end

                                                                    [subNodeResult,subNodedsyncCount]=...
                                                                    loc_emitHTMLforTaskNode(this.ChildrenObj{i},[],...
                                                                    generateTime,needWriteCurrentString,level,...
                                                                    tempFolderNumbering);

                                                                    dsyncCount=dsyncCount+subNodedsyncCount;
                                                                    resultHTML=[resultHTML,subNodeResult];
                                                                end
                                                                resultHTML=[resultHTML,loc_CreateIgnorePortion('</div>')];
                                                            end

                                                            function outputStr=loc_CreateIgnorePortion(inputStr)
                                                                outputStr=['<!-- mdladv_ignore_start -->',inputStr,'<!-- mdladv_ignore_finish -->'];



                                                                function l_compileModel(this)
                                                                    sess=Simulink.CMI.EIAdapter(Simulink.EngineInterfaceVal.byFiat);
                                                                    try
                                                                        engintMode=modeladvisorprivate('modeladvisorutil2','FeatureControl','EngineInterfaceCompileMode');
                                                                        rootModel=getfullname(bdroot(this.System));



                                                                        set_param(rootModel,'ModelUpgradeActive','on');

                                                                        if~strcmp(get_param(rootModel,'SimulationStatus'),'initializing')
                                                                            prepModel=[];
                                                                            if this.TreatAsMdlref
                                                                                this.recordCoverageFlag=get_param(rootModel,'RecordCoverage');
                                                                                dirtyFlag=get_param(rootModel,'Dirty');


                                                                                set_param(rootModel,'isMACompile','on');
                                                                                set_param(rootModel,'RecordCoverage','off');
                                                                                set_param(rootModel,'Dirty',dirtyFlag);



                                                                                obj=get_param(rootModel,'Object');
                                                                                obj.init('MDLREF_NORMAL');
                                                                            elseif engintMode
                                                                                this.recordCoverageFlag=get_param(rootModel,'RecordCoverage');
                                                                                dirtyFlag=get_param(rootModel,'Dirty');
                                                                                interface=get_param(rootModel,'Object');


                                                                                set_param(rootModel,'isMACompile','on');
                                                                                set_param(rootModel,'RecordCoverage','off');
                                                                                set_param(rootModel,'Dirty',dirtyFlag);

                                                                                init(interface,'COMMAND_LINE','UpdateBDOnly','on');
                                                                            else
                                                                                feval(rootModel,[],[],[],'compile');
                                                                            end
                                                                            this.NeedTermination=true;
                                                                            this.NormalModeConfiguration=prepModel;
                                                                        else
                                                                            this.NeedTermination=false;
                                                                        end

                                                                        set_param(rootModel,'ModelUpgradeActive','off');
                                                                        this.HasCompiled=true;
                                                                    catch E
                                                                        if engintMode||this.TreatAsMdlref
                                                                            set_param(rootModel,'RecordCoverage',this.recordCoverageFlag);
                                                                            set_param(rootModel,'Dirty',dirtyFlag);
                                                                            set_param(rootModel,'isMACompile','off');
                                                                        end

                                                                        set_param(rootModel,'ModelUpgradeActive','off');

                                                                        rethrow(E);
                                                                    end
                                                                    delete(sess);






                                                                    function l_compileModelForCodegen(this)
                                                                        sess=Simulink.CMI.EIAdapter(Simulink.EngineInterfaceVal.byFiat);
                                                                        try
                                                                            engintMode=modeladvisorprivate('modeladvisorutil2','FeatureControl','EngineInterfaceCompileMode');
                                                                            rootModel=getfullname(bdroot(this.System));

                                                                            set_param(rootModel,'ModelUpgradeActive','on');

                                                                            if~strcmp(get_param(rootModel,'SimulationStatus'),'initializing')
                                                                                prepModel=[];
                                                                                if this.TreatAsMdlref
                                                                                    this.recordCoverageFlag=get_param(rootModel,'RecordCoverage');
                                                                                    dirtyFlag=get_param(rootModel,'Dirty');


                                                                                    set_param(rootModel,'RecordCoverage','off');
                                                                                    set_param(rootModel,'Dirty',dirtyFlag);


                                                                                    prepModel=Simulink.ModelReference.internal.NormalModeConfiguration(rootModel);

                                                                                    modelObj=get_param(rootModel,'Object');
                                                                                    modelObj.init('RTW');
                                                                                elseif engintMode
                                                                                    this.recordCoverageFlag=get_param(rootModel,'RecordCoverage');
                                                                                    dirtyFlag=get_param(rootModel,'Dirty');


                                                                                    set_param(rootModel,'RecordCoverage','off');
                                                                                    set_param(rootModel,'Dirty',dirtyFlag);

                                                                                    modelObj=get_param(rootModel,'Object');
                                                                                    modelObj.init('RTW');
                                                                                else
                                                                                    feval(rootModel,[],[],[],'compileForCodegen');
                                                                                end
                                                                                this.NeedTermination=true;
                                                                                this.NormalModeConfiguration=prepModel;
                                                                            else
                                                                                this.NeedTermination=false;
                                                                            end

                                                                            set_param(rootModel,'ModelUpgradeActive','off');
                                                                            this.HasCompiledForCodegen=true;
                                                                        catch E
                                                                            if engintMode||this.TreatAsMdlref
                                                                                set_param(rootModel,'RecordCoverage',this.recordCoverageFlag);
                                                                                set_param(rootModel,'Dirty',dirtyFlag);
                                                                            end

                                                                            set_param(rootModel,'ModelUpgradeActive','off');

                                                                            rethrow(E);
                                                                        end
                                                                        delete(sess);

                                                                        function l_cgirModel(this)
                                                                            try
                                                                                rootModel=getfullname(bdroot(this.System));
                                                                                this.HasCGIRed=true;
                                                                                rtwgen_tlc_dirFlag=exist(fullfile(this.getWorkDir,'rtwgen_tlc'),'dir');
                                                                                dotRTWFlag=exist(fullfile(this.getWorkDir,[bdroot(this.System),'.rtw']),'file');
                                                                                origPath=path;

                                                                                [mdlFitforCGIR,~]=ModelAdvisor.Common.modelAdvisor_CGIRCheckSetting(bdroot(this.System));
                                                                                if~mdlFitforCGIR



                                                                                    return;
                                                                                else
                                                                                    addpath(this.getWorkDir);
                                                                                    evalc("rtwgen(rootModel,'OutputDirectory',this.getWorkDir)");
                                                                                    path(origPath);
                                                                                end

                                                                                rtwprivate('destroyRTWContext',rootModel);

                                                                                removeTempFiles(this,rtwgen_tlc_dirFlag,dotRTWFlag);
                                                                                rtwgen(rootModel,'TerminateCompile','on');
                                                                            catch E
                                                                                removeTempFiles(this,rtwgen_tlc_dirFlag,dotRTWFlag);
                                                                                rtwgen(rootModel,'TerminateCompile','on');
                                                                                this.HasCGIRed=false;
                                                                                path(origPath);
                                                                                rethrow(E);
                                                                            end

                                                                            function removeTempFiles(this,rtwgen_tlc_dirFlag,dotRTWFlag)
                                                                                if(~rtwgen_tlc_dirFlag)
                                                                                    [~,~,~]=rmdir(fullfile(this.getWorkDir,'rtwgen_tlc'),'s');
                                                                                end
                                                                                if~dotRTWFlag&&exist(fullfile(this.getWorkDir,[bdroot(this.System),'.rtw']),'file')
                                                                                    delete(fullfile(this.getWorkDir,[bdroot(this.System),'.rtw']));
                                                                                end



                                                                                function l_termcgirModel(this)
                                                                                    this.HasCGIRed=false;

                                                                                    function errormsg=l_termmodelcompile(this)
                                                                                        sess=Simulink.CMI.EIAdapter(Simulink.EngineInterfaceVal.byFiat);%#ok<NASGU>
                                                                                        try
                                                                                            engintMode=modeladvisorprivate('modeladvisorutil2','FeatureControl','EngineInterfaceCompileMode');
                                                                                            if this.NeedTermination
                                                                                                if this.TreatAsMdlref
                                                                                                    rootModel=getfullname(bdroot(this.System));

                                                                                                    obj=get_param(rootModel,'Object');
                                                                                                    obj.term;

                                                                                                    dirtyFlag=get_param(rootModel,'Dirty');
                                                                                                    set_param(rootModel,'RecordCoverage',this.recordCoverageFlag);
                                                                                                    set_param(rootModel,'Dirty',dirtyFlag);
                                                                                                    set_param(rootModel,'isMACompile','off');
                                                                                                elseif engintMode
                                                                                                    rootModel=getfullname(bdroot(this.System));
                                                                                                    interface=get_param(rootModel,'Object');
                                                                                                    term(interface);

                                                                                                    dirtyFlag=get_param(rootModel,'Dirty');
                                                                                                    set_param(rootModel,'RecordCoverage',this.recordCoverageFlag);
                                                                                                    set_param(rootModel,'Dirty',dirtyFlag);
                                                                                                    set_param(rootModel,'isMACompile','off');
                                                                                                else
                                                                                                    feval(getfullname(bdroot(this.System)),[],[],[],'term');
                                                                                                end
                                                                                            end
                                                                                            errormsg='';
                                                                                            this.HasCompiled=false;
                                                                                            this.HasCompiledForCodegen=false;
                                                                                        catch E
                                                                                            errormsg=E.message;


                                                                                            if strcmpi(get_param(bdroot(this.System),'SimulationStatus'),'stopped')
                                                                                                this.HasCompiled=false;
                                                                                                this.HasCompiledForCodegen=false;
                                                                                            end
                                                                                        end

                                                                                        function outputStruct=locCopyStruct(inputStruct,fields)
                                                                                            outputStruct={};



















                                                                                            if~isempty(inputStruct)
                                                                                                outputStruct=cell(1,length(inputStruct));
                                                                                                for j=1:length(fields)
                                                                                                    currentfield=fields{j};
                                                                                                    if strcmp(currentfield,'InputParameters')

                                                                                                        for i=1:length(inputStruct)


                                                                                                            if isempty(inputStruct{i}.InputParameters)
                                                                                                                outputStruct{i}.InputParameters={};
                                                                                                            else
                                                                                                                for k=1:length(inputStruct{i}.InputParameters)
                                                                                                                    if isa(inputStruct{i}.InputParameters{k},'ModelAdvisor.InputParameter')
                                                                                                                        outputStruct{i}.InputParameters{k}=copy(inputStruct{i}.InputParameters{k});
                                                                                                                        if strcmp(inputStruct{i}.InputParameters{k}.Type,'PushButton')
                                                                                                                            outputStruct{i}.InputParameters{k}.Entries={};
                                                                                                                        end
                                                                                                                    else
                                                                                                                        outputStruct{i}.InputParameters{k}=inputStruct{i}.InputParameters{k};
                                                                                                                    end
                                                                                                                end
                                                                                                            end
                                                                                                        end
                                                                                                    elseif strcmp(currentfield,'ActionResultInHTML')
                                                                                                        for i=1:length(inputStruct)
                                                                                                            if isa(inputStruct{i},'ModelAdvisor.Check')&&isa(inputStruct{i}.Action,'ModelAdvisor.Action')
                                                                                                                outputStruct{i}.ActionResultInHTML=inputStruct{i}.Action.ResultInHTML;
                                                                                                            else
                                                                                                                outputStruct{i}.ActionResultInHTML='not exist';
                                                                                                            end
                                                                                                        end
                                                                                                    elseif strcmp(currentfield,'Check')
                                                                                                        for i=1:length(inputStruct)
                                                                                                            if isa(inputStruct{i},'ModelAdvisor.Task')&&~isempty(inputStruct{i}.Check)
                                                                                                                resultIncellFormat=locCopyStruct({inputStruct{i}.Check},{'ID','Title','Visible','Enable','Value','RunComplete','Selected','Success','ResultInHTML','InputParameters','ErrorSeverity','ActionResultInHTML','ProjectResultData','ReportStyle','CacheResultInHTMLForNewCheckStyle'});
                                                                                                                outputStruct{i}.Check=resultIncellFormat{1};
                                                                                                            else
                                                                                                                outputStruct{i}.Check=[];
                                                                                                            end
                                                                                                        end








                                                                                                    else
                                                                                                        for i=1:length(inputStruct)
                                                                                                            outputStruct{i}.(currentfield)=inputStruct{i}.(currentfield);
                                                                                                        end
                                                                                                    end
                                                                                                end
                                                                                            end

                                                                                            function locCopyStructBackToObj(inputStruct,inputObjs)
                                                                                                switch class(inputObjs{1})
                                                                                                case 'ModelAdvisor.FactoryGroup'
                                                                                                    fields={'Selected','Published','Visible','Enable','Value','State','InternalState','ShowCheckbox'};
                                                                                                case{'ModelAdvisor.Group','ModelAdvisor.Procedure'}
                                                                                                    fields={'Selected','Published','Visible','Enable','Value','State','InternalState','ShowCheckbox','Check'};
                                                                                                case 'ModelAdvisor.Check'
                                                                                                    fields={'ID','Title','Visible','Enable','Value','RunComplete','Selected','Success','ResultInHTML','InputParameters','ErrorSeverity','ActionResultInHTML','ProjectResultData'};
                                                                                                otherwise
                                                                                                    if isa(inputObjs{1},'ModelAdvisor.Check')
                                                                                                        fields={'ID','Title','Visible','Enable','Value','RunComplete','Selected','Success','ResultInHTML','InputParameters','ErrorSeverity','ActionResultInHTML','ProjectResultData'};
                                                                                                    end
                                                                                                end

                                                                                                fields2=setdiff(fields,{'Selected','SelectedByTask'});
                                                                                                for i=1:length(inputObjs)
                                                                                                    sourceData=locate_obj_from_AdvisorManager(inputStruct,inputObjs{i}.ID);
                                                                                                    if isa(inputObjs{i},'ModelAdvisor.Node')&&isa(inputObjs{i}.getParent,'ModelAdvisor.Procedure')
                                                                                                        loopfields=fields;
                                                                                                    else
                                                                                                        loopfields=fields2;
                                                                                                    end
                                                                                                    for j=1:length(loopfields)
                                                                                                        if isprop(inputObjs{i},loopfields{j})
                                                                                                            if strcmp(loopfields{j},'Check')
                                                                                                                checkObj=inputObjs{i}.Check;

                                                                                                                am=Advisor.Manager.getInstance;
                                                                                                                checkStruct=am.slCustomizationDataStructure.checkCellArray{checkObj.Index};
                                                                                                                if~isempty(checkObj)&&~isempty(checkStruct)
                                                                                                                    locCopyStructBackToObj({checkStruct},{checkObj});
                                                                                                                end
                                                                                                            else
                                                                                                                inputObjs{i}.(loopfields{j})=sourceData.(loopfields{j});
                                                                                                            end
                                                                                                        elseif strcmp(loopfields{j},'ActionResultInHTML')
                                                                                                            if~isempty(sourceData.Action)
                                                                                                                inputObjs{i}.Action.ResultInHTML=sourceData.Action.ResultInHTML;
                                                                                                            end
                                                                                                        end
                                                                                                    end
                                                                                                end

                                                                                                function output=locate_obj_from_AdvisorManager(inputStruct,ID)
                                                                                                    for i=1:numel(inputStruct)
                                                                                                        if strcmp(inputStruct{i}.ID,ID)
                                                                                                            output=inputStruct{i};
                                                                                                            return
                                                                                                        end
                                                                                                    end


                                                                                                    function loc_enableAction(mdladvObj,actionName,action)
                                                                                                        if isa(mdladvObj,'Simulink.ModelAdvisor')&&isfield(mdladvObj.MEMenus,actionName)
                                                                                                            dasActionObj=mdladvObj.MEMenus.(actionName);
                                                                                                            if isa(dasActionObj,'DAStudio.Action')
                                                                                                                if action
                                                                                                                    dasActionObj.enabled='on';
                                                                                                                else
                                                                                                                    dasActionObj.enabled='off';
                                                                                                                end
                                                                                                            end
                                                                                                        end



                                                                                                        function folderObj=set_folder_CSHParam(folderObj)
                                                                                                            switch(folderObj.ID)
                                                                                                            case '_SYSTEM_By Product'
                                                                                                                folderObj.CSHParameters.MapKey='ma.simulink';
                                                                                                                folderObj.CSHParameters.TopicID='by_product_overview';
                                                                                                            case '_SYSTEM_By Product_Simulink'
                                                                                                                folderObj.CSHParameters.MapKey='ma.simulink';
                                                                                                                folderObj.CSHParameters.TopicID='simulink_overview';






                                                                                                            case '_SYSTEM_By Product_Simulink Coder'
                                                                                                                folderObj.CSHParameters.MapKey='ma.rtw';
                                                                                                                folderObj.CSHParameters.TopicID='rtw_overview';
                                                                                                            case '_SYSTEM_By Product_Embedded Coder'
                                                                                                                folderObj.CSHParameters.MapKey='ma.ecoder';
                                                                                                                folderObj.CSHParameters.TopicID='ecoder_overview';

                                                                                                            case '_SYSTEM_By Product_Simulink Check'
                                                                                                                folderObj.CSHParameters.MapKey='ma.slvnv';
                                                                                                                folderObj.CSHParameters.TopicID='slvnv_overview';
                                                                                                            case '_SYSTEM_By Product_Simulink Code Inspector'
                                                                                                                folderObj.CSHParameters.MapKey='ma.slci';
                                                                                                                folderObj.CSHParameters.TopicID='ma_slci_overview';
                                                                                                            case '_SYSTEM_By Product_Simulink Control Design'
                                                                                                                folderObj.CSHParameters.MapKey='ma.slcontrol';
                                                                                                                folderObj.CSHParameters.TopicID='mathworks.slcontrol.byproduct';
                                                                                                            case['_SYSTEM_By Product_Simulink Check_',loc_safe_dastudio_message('ModelAdvisor:metricchecks:MetricByTaskGroup')]
                                                                                                                folderObj.CSHParameters.MapKey='ma.metricchecks';
                                                                                                                folderObj.CSHParameters.TopicID='ma_metricchecks_overview';
                                                                                                            case['_SYSTEM_By Product_Simulink Check_',loc_safe_dastudio_message('Simulink:tools:ModelingStandards')]
                                                                                                                folderObj.CSHParameters.MapKey='ma.slvnv';
                                                                                                                folderObj.CSHParameters.TopicID='modeling_standards_overview';
                                                                                                            case['_SYSTEM_By Product_Simulink Check_',loc_safe_dastudio_message('Simulink:tools:ModelingStandards'),'_',loc_safe_dastudio_message('ModelAdvisor:do178b:DO178BChecks')]
                                                                                                                folderObj.CSHParameters.MapKey='ma.do178b';
                                                                                                                folderObj.CSHParameters.TopicID='com.mw.slvnv.do178bgroup';
                                                                                                            case['_SYSTEM_By Product_Simulink Check_',loc_safe_dastudio_message('Simulink:tools:ModelingStandards'),'_',loc_safe_dastudio_message('ModelAdvisor:iec61508:IEC61508Checks')]
                                                                                                                folderObj.CSHParameters.MapKey='ma.iec61508';
                                                                                                                folderObj.CSHParameters.TopicID='com.mw.slvnv.iec61508group';
                                                                                                            case['_SYSTEM_By Product_Simulink Check_',loc_safe_dastudio_message('Simulink:tools:ModelingStandards'),'_',loc_safe_dastudio_message('ModelAdvisor:styleguide:ByProductMAABChecks')]
                                                                                                                folderObj.CSHParameters.MapKey='ma.mw.jmaab';
                                                                                                                folderObj.CSHParameters.TopicID='mab_overview';
                                                                                                            case['_SYSTEM_By Product_Simulink Check_',loc_safe_dastudio_message('Simulink:tools:ModelingStandards'),'_',loc_safe_dastudio_message('ModelAdvisor:jmaab:ByProductJMAABChecks')]
                                                                                                                folderObj.CSHParameters.MapKey='ma.mw.jmaab';
                                                                                                                folderObj.CSHParameters.TopicID='jmaab_overview';
                                                                                                            case '_SYSTEM_By Product_Simulink Requirements'
                                                                                                                folderObj.CSHParameters.MapKey='ma.reqconsistency';
                                                                                                                folderObj.CSHParameters.TopicID='simulink_requirements_ma_overview';
                                                                                                            case['_SYSTEM_By Product_Simulink Requirements_',loc_safe_dastudio_message('Slvnv:consistency:groupEntry')]
                                                                                                                folderObj.CSHParameters.MapKey='ma.reqconsistency';
                                                                                                                folderObj.CSHParameters.TopicID='reqconsistency_overview';
                                                                                                            case '_SYSTEM_By Product_DO Qualification Kit'
                                                                                                                folderObj.CSHParameters.MapKey='ma.doqualkit';
                                                                                                                folderObj.CSHParameters.TopicID='doqualkits.bugreport.overview';
                                                                                                            case '_SYSTEM_By Product_IEC Certification Kit'
                                                                                                                folderObj.CSHParameters.MapKey='ma.ieccertkit';
                                                                                                                folderObj.CSHParameters.TopicID='ieccertkits.bugreport.overview';
                                                                                                            case '_SYSTEM_By Product_SimEvents'
                                                                                                                folderObj.CSHParameters.MapKey='ma.simevents';
                                                                                                                folderObj.CSHParameters.TopicID='simevents_overview';
                                                                                                            case '_SYSTEM_By Product_Simscape'
                                                                                                                folderObj.CSHParameters.MapKey='ma.simscape';
                                                                                                                folderObj.CSHParameters.TopicID='mathworks.simscape.byproduct';
                                                                                                            case '_SYSTEM_By Product_Simulink Design Verifier'
                                                                                                                folderObj.CSHParameters.MapKey='ma.sldv';
                                                                                                                folderObj.CSHParameters.TopicID='mathworks.sldv.byproduct';
                                                                                                            case['_SYSTEM_By Product_Simulink Design Verifier_',loc_safe_dastudio_message('Sldv:ModelAdvisor:sl_customization:DesignErrorDetection')]
                                                                                                                folderObj.CSHParameters.MapKey='ma.sldv';
                                                                                                                folderObj.CSHParameters.TopicID='mathworks.sldv.DED';
                                                                                                            case '_SYSTEM_By Product_HDL Coder'
                                                                                                                folderObj.CSHParameters.MapKey='hdlmodelchecker';
                                                                                                                folderObj.CSHParameters.TopicID='hdlmodelchecker_help_button';
                                                                                                            case['_SYSTEM_By Product_HDL Coder_',loc_safe_dastudio_message('HDLShared:hdlmodelchecker:cat_Model_Level_Checks')]
                                                                                                                folderObj.CSHParameters.MapKey='hdlmodelchecker';
                                                                                                                folderObj.CSHParameters.TopicID='com.mathworks.HDL.ModelChecker.Group_Model_Level_Checks';
                                                                                                            case['_SYSTEM_By Product_HDL Coder_',loc_safe_dastudio_message('HDLShared:hdlmodelchecker:cat_Subsystem_Level_Checks')]
                                                                                                                folderObj.CSHParameters.MapKey='hdlmodelchecker';
                                                                                                                folderObj.CSHParameters.TopicID='com.mathworks.HDL.ModelChecker.Group_Subsystem_Level_Checks';
                                                                                                            case['_SYSTEM_By Product_HDL Coder_',loc_safe_dastudio_message('HDLShared:hdlmodelchecker:cat_Block_Level_Checks')]
                                                                                                                folderObj.CSHParameters.MapKey='hdlmodelchecker';
                                                                                                                folderObj.CSHParameters.TopicID='com.mathworks.HDL.ModelChecker.Group_Block_Level_Checks';
                                                                                                            case['_SYSTEM_By Product_HDL Coder_',loc_safe_dastudio_message('HDLShared:hdlmodelchecker:cat_NativeFloatingPoint_Checks')]
                                                                                                                folderObj.CSHParameters.MapKey='hdlmodelchecker';
                                                                                                                folderObj.CSHParameters.TopicID='com.mathworks.HDL.ModelChecker.Group_NativeFloatingPoint_Checks';
                                                                                                            case['_SYSTEM_By Product_HDL Coder_',loc_safe_dastudio_message('HDLShared:hdlmodelchecker:cat_IndustryStandards_Checks')]
                                                                                                                folderObj.CSHParameters.MapKey='hdlmodelchecker';
                                                                                                                folderObj.CSHParameters.TopicID='com.mathworks.HDL.ModelChecker.Group_IndustryStandards_Checks';
                                                                                                            case '_SYSTEM_By Product_Simulink PLC Coder'
                                                                                                                folderObj.CSHParameters.MapKey='plcmodeladvisor';
                                                                                                                folderObj.CSHParameters.TopicID='plcmodeladvisor_help_button';
                                                                                                            case['_SYSTEM_By Product_Simulink PLC Coder_',loc_safe_dastudio_message('plccoder:modeladvisor:ModelLevelChecksName')]
                                                                                                                folderObj.CSHParameters.MapKey='plcmodeladvisor';
                                                                                                                folderObj.CSHParameters.TopicID='com.mathworks.PLC.ModelAdvisor.Group_ModelLevelChecks';
                                                                                                            case['_SYSTEM_By Product_Simulink PLC Coder_',loc_safe_dastudio_message('plccoder:modeladvisor:SubsystemLevelChecksName')]
                                                                                                                folderObj.CSHParameters.MapKey='plcmodeladvisor';
                                                                                                                folderObj.CSHParameters.TopicID='com.mathworks.PLC.ModelAdvisor.Group_ModelLevelChecks';
                                                                                                            case['_SYSTEM_By Product_Simulink PLC Coder_',loc_safe_dastudio_message('plccoder:modeladvisor:BlockLevelChecksName')]
                                                                                                                folderObj.CSHParameters.MapKey='plcmodeladvisor';
                                                                                                                folderObj.CSHParameters.TopicID='com.mathworks.PLC.ModelAdvisor.Group_SubsystemLevelChecks';
                                                                                                            case['_SYSTEM_By Product_Simulink PLC Coder_',loc_safe_dastudio_message('plccoder:modeladvisor:IndustryStandardChecksName')]
                                                                                                                folderObj.CSHParameters.MapKey='plcmodeladvisor';
                                                                                                                folderObj.CSHParameters.TopicID='com.mathworks.PLC.ModelAdvisor.Group_IndustryStandardChecks';
                                                                                                            case '_SYSTEM_By Product_AUTOSAR Blockset'
                                                                                                                folderObj.CSHParameters.MapKey='autosar';
                                                                                                                folderObj.CSHParameters.TopicID='autosar_checks_main';
                                                                                                            case '_SYSTEM_By Task'
                                                                                                                folderObj.CSHParameters.MapKey='ma.simulink';
                                                                                                                folderObj.CSHParameters.TopicID='by_task_overview';
                                                                                                            case '_SYSTEM_By Task_Data Transfer Efficiency'
                                                                                                                folderObj.CSHParameters.MapKey='ma.simulink';
                                                                                                                folderObj.CSHParameters.TopicID='data_transfer_efficiency_overview';
                                                                                                            case '_SYSTEM_By Task_com.slci.SLCIGroup'
                                                                                                                folderObj.CSHParameters.MapKey='ma.slci';
                                                                                                                folderObj.CSHParameters.TopicID='ma_slci_overview';
                                                                                                            case '_SYSTEM_By Task_ModelAdvisor:Task:PerformanceAndAccuracy'
                                                                                                                folderObj.CSHParameters.MapKey='ma.simulink';
                                                                                                                folderObj.CSHParameters.TopicID='sim_performance_accuracy_overview';
                                                                                                            case '_SYSTEM_By Task_ModelAdvisor:Task:RuntimeAccuracy'
                                                                                                                folderObj.CSHParameters.MapKey='ma.simulink';
                                                                                                                folderObj.CSHParameters.TopicID='sim_runtime_accuracy__diagnostics_overview';
                                                                                                            case '_SYSTEM_By Task_ModelAdvisor:Task:DataStoreBlocks'
                                                                                                                folderObj.CSHParameters.MapKey='ma.simulink';
                                                                                                                folderObj.CSHParameters.TopicID='sim_data_store_blocks';
                                                                                                            case '_SYSTEM_By Task_Model Referencing'
                                                                                                                folderObj.CSHParameters.MapKey='ma.simulink';
                                                                                                                folderObj.CSHParameters.TopicID='model_ref_overview';
                                                                                                            case '_SYSTEM_By Task_SimplifiedInit'
                                                                                                                folderObj.CSHParameters.MapKey='ma.simulink';
                                                                                                                folderObj.CSHParameters.TopicID='migrating_to_simplified_initialization_mode_overview';
                                                                                                            case '_SYSTEM_By Task_Model Updates'
                                                                                                                folderObj.CSHParameters.MapKey='ma.simulink';
                                                                                                                folderObj.CSHParameters.TopicID='upgrade_sl_ver_overview';
                                                                                                            case '_SYSTEM_By Task_Managing Library Links and Variants'
                                                                                                                folderObj.CSHParameters.MapKey='ma.simulink';
                                                                                                                folderObj.CSHParameters.TopicID='managing_lib_links_overview';

                                                                                                            case '_SYSTEM_By Task_ModelMetrics'
                                                                                                                folderObj.CSHParameters.MapKey='ma.metricchecks';
                                                                                                                folderObj.CSHParameters.TopicID='ma_metricchecks_overview';
                                                                                                            case '_SYSTEM_By Task_ModelMetrics:Count'
                                                                                                                folderObj.CSHParameters.MapKey='ma.metricchecks';
                                                                                                                folderObj.CSHParameters.TopicID='ma_metricchecks_count';
                                                                                                            case '_SYSTEM_By Task_ModelMetrics:Complexity'
                                                                                                                folderObj.CSHParameters.MapKey='ma.metricchecks';
                                                                                                                folderObj.CSHParameters.TopicID='ma_metricchecks_complexity';
                                                                                                            case '_SYSTEM_By Task_ModelMetrics:Readability'
                                                                                                                folderObj.CSHParameters.MapKey='ma.metricchecks';
                                                                                                                folderObj.CSHParameters.TopicID='ma_metricchecks_readability';

                                                                                                            case '_SYSTEM_By Task_do178'
                                                                                                                folderObj.CSHParameters.MapKey='ma.simulink';
                                                                                                                folderObj.CSHParameters.TopicID='mdl_std_do178b_overview';
                                                                                                            case '_SYSTEM_By Task_DO178B:Requirements'
                                                                                                                folderObj.CSHParameters.MapKey='ma.simulink';
                                                                                                                folderObj.CSHParameters.TopicID='mdl_std_do178b_requirements';
                                                                                                            case '_SYSTEM_By Task_DO178B:Simulink'
                                                                                                                folderObj.CSHParameters.MapKey='ma.simulink';
                                                                                                                folderObj.CSHParameters.TopicID='mdl_std_do178b_simulink';
                                                                                                            case '_SYSTEM_By Task_DO178B:Stateflow'
                                                                                                                folderObj.CSHParameters.MapKey='ma.simulink';
                                                                                                                folderObj.CSHParameters.TopicID='mdl_std_do178b_stateflow';
                                                                                                            case '_SYSTEM_By Task_DO178B:LibraryLinks'
                                                                                                                folderObj.CSHParameters.MapKey='ma.simulink';
                                                                                                                folderObj.CSHParameters.TopicID='mdl_std_do178b_liblinks';
                                                                                                            case '_SYSTEM_By Task_DO178B:MdlRef'
                                                                                                                folderObj.CSHParameters.MapKey='ma.simulink';
                                                                                                                folderObj.CSHParameters.TopicID='mdl_std_do178b_mdlref';
                                                                                                            case '_SYSTEM_By Task_DO178B:BugReport'
                                                                                                                folderObj.CSHParameters.MapKey='ma.simulink';
                                                                                                                folderObj.CSHParameters.TopicID='mdl_std_do178b_bugreport';

                                                                                                            case '_SYSTEM_By Task_IEC61508'
                                                                                                                folderObj.CSHParameters.MapKey='ma.simulink';
                                                                                                                folderObj.CSHParameters.TopicID='mdl_std_iec61508_overview';
                                                                                                            case '_SYSTEM_By Task_IEC62304'
                                                                                                                folderObj.CSHParameters.MapKey='ma.simulink';
                                                                                                                folderObj.CSHParameters.TopicID='mdl_std_iec62304_overview';
                                                                                                            case '_SYSTEM_By Task_Requirement consistency checking'
                                                                                                                folderObj.CSHParameters.MapKey='ma.simulink';
                                                                                                                folderObj.CSHParameters.TopicID='req_consistency_checking_overview';
                                                                                                            case '_SYSTEM_By Task_mathworks.slcontrolgroup'
                                                                                                                folderObj.CSHParameters.MapKey='ma.slcontrol';
                                                                                                                folderObj.CSHParameters.TopicID='mathworks.slcontrolgroup';

                                                                                                            case '_SYSTEM_By Task_ISO26262'
                                                                                                                folderObj.CSHParameters.MapKey='ma.simulink';
                                                                                                                folderObj.CSHParameters.TopicID='iso26262_overview';
                                                                                                            case '_SYSTEM_By Task_ISO25119'
                                                                                                                folderObj.CSHParameters.MapKey='ma.simulink';
                                                                                                                folderObj.CSHParameters.TopicID='iso25119_overview';
                                                                                                            case '_SYSTEM_By Task_EN50128'
                                                                                                                folderObj.CSHParameters.MapKey='ma.simulink';
                                                                                                                folderObj.CSHParameters.TopicID='en50128_overview';
                                                                                                            case '_SYSTEM_By Task_misra_c'
                                                                                                                folderObj.CSHParameters.MapKey='ma.simulink';
                                                                                                                folderObj.CSHParameters.TopicID='misra_guidelines_overview';
                                                                                                            case '_SYSTEM_By Task_security'
                                                                                                                folderObj.CSHParameters.MapKey='ma.simulink';
                                                                                                                folderObj.CSHParameters.TopicID='security_guidelines_overview';
                                                                                                            case '_SYSTEM_By Task_ModelingUsingBuses'
                                                                                                                folderObj.CSHParameters.MapKey='ma.simulink';
                                                                                                                folderObj.CSHParameters.TopicID='modeling_using_buses_overview';
                                                                                                            case '_SYSTEM_By Task_Code_generation_efficiency'
                                                                                                                folderObj.CSHParameters.MapKey='ma.simulink';
                                                                                                                folderObj.CSHParameters.TopicID='code_generation_efficiency_overview';
                                                                                                            case '_SYSTEM_By Task_ModelingSinglePrecision'
                                                                                                                folderObj.CSHParameters.MapKey='ma.simulink';
                                                                                                                folderObj.CSHParameters.TopicID='modeling_single_precision_overview';
                                                                                                            case '_SYSTEM_By Task_SimEvents model upgrade checking'
                                                                                                                folderObj.CSHParameters.MapKey='ma.simevents';
                                                                                                                folderObj.CSHParameters.TopicID='simevents_overview';
                                                                                                            case '_SYSTEM_By Task_Modeling_Physical_Systems'
                                                                                                                folderObj.CSHParameters.MapKey='ma.simscape';
                                                                                                                folderObj.CSHParameters.TopicID='mathworks.simscape.bytask';
                                                                                                            case '_SYSTEM_By Task_File Integrity'
                                                                                                                folderObj.CSHParameters.MapKey='ma.simulink';
                                                                                                                folderObj.CSHParameters.TopicID='SimulinkFileIntegrityGroup';
                                                                                                            case '_SYSTEM_By Task_Units_Inconsistencies'
                                                                                                                folderObj.CSHParameters.MapKey='ma.simulink';
                                                                                                                folderObj.CSHParameters.TopicID='MAUnitInconsTaskTitle';
                                                                                                            case '_SYSTEM_By Task_com.mathworks.sldv.compatgroup'
                                                                                                                folderObj.CSHParameters.MapKey='ma.sldv';
                                                                                                                folderObj.CSHParameters.TopicID='mathworks.sldv.compatgroup';
                                                                                                            case '_SYSTEM_By Task_com.mathworks.sldv.DesignErrorDetectionGroup'
                                                                                                                folderObj.CSHParameters.MapKey='ma.sldv';
                                                                                                                folderObj.CSHParameters.TopicID='mathworks.sldv.DED';
                                                                                                            case '_SYSTEM_By Task_S-function_Checks'
                                                                                                                folderObj.CSHParameters.MapKey='ma.simulink';
                                                                                                                folderObj.CSHParameters.TopicID='sfunction_checks';
                                                                                                            case '_SYSTEM_By Task_RowMajor'
                                                                                                                folderObj.CSHParameters.MapKey='ma.ecoder';
                                                                                                                folderObj.CSHParameters.TopicID='row_major_code_generation_overview';
                                                                                                            otherwise

                                                                                                            end



                                                                                                            function message=loc_safe_dastudio_message(msgID)
                                                                                                                try
                                                                                                                    message=DAStudio.message(msgID);
                                                                                                                catch ME %#ok<NASGU>
                                                                                                                    message='not found';
                                                                                                                end














                                                                                                                function[isValid,isCustomCheck]=loc_validateChecks(checkFcnName)
                                                                                                                    isValid=false;%#ok<NASGU>
                                                                                                                    isCustomCheck=true;
                                                                                                                    persistent builtinCheckFcnNames;
                                                                                                                    if isempty(builtinCheckFcnNames)
                                                                                                                        builtinCheckFcnNames={...
                                                                                                                        fullfile(matlabroot,'toolbox','simulink','simulink','modeladvisor','+internalcustomization','customizationModelAdvisorMain'),...
                                                                                                                        fullfile(matlabroot,'toolbox','simulink','simulink','modeladvisor','fixpt','+internalcustomization','customizationFixpt'),...
                                                                                                                        fullfile(matlabroot,'toolbox','simulink','core','general','@slCustomizer','customizationSimulink'),...
                                                                                                                        fullfile(matlabroot,'toolbox','simulink','core','general','+internalcustomization','registerModelAdvisorCallbacks'),...
                                                                                                                        fullfile(matlabroot,'toolbox','simulink','simulink','upgradeadvisor','+internalcustomization','customizationUpgradeAdvisor'),...
                                                                                                                        fullfile(matlabroot,'toolbox','simulink','core','units','+internalcustomization','customizationUnitsModelAdvisor'),...
                                                                                                                        fullfile(matlabroot,'toolbox','simulink','core','model_transformer','+internalcustomization','customizationMdlTransformer'),...
                                                                                                                        fullfile(matlabroot,'toolbox','simulink','core','clone_detection','+internalcustomization','customizationCloneDetection'),...
                                                                                                                        fullfile(matlabroot,'toolbox','slcheck','styleguide','+internalcustomization','customizationStyleGuide'),...
                                                                                                                        fullfile(matlabroot,'toolbox','slrequirements','slrequirements','+simulink','+internal','+customization','customizationSimulinkRequirements'),...
                                                                                                                        fullfile(matlabroot,'toolbox','slcheck','do178b','+internalcustomization','customizationDO178b'),...
                                                                                                                        fullfile(matlabroot,'toolbox','slcheck','iec61508','+internalcustomization','customizationIEC61508'),...
                                                                                                                        fullfile(matlabroot,'toolbox','slcheck','highintegrity','+internalcustomization','customizationHISM'),...
                                                                                                                        fullfile(matlabroot,'toolbox','slvnv','misra','sl_customization'),...
                                                                                                                        fullfile(matlabroot,'toolbox','slcheck','mametrics','+internalcustomization','customizationMetricChecks'),...
                                                                                                                        fullfile(matlabroot,'toolbox','hdlcoder','hdlcoder','hdlwa','+simulink','+internal','+customization','customizationWorkflowAdvisor'),...
                                                                                                                        fullfile(matlabroot,'toolbox','hdlcoder','hdlcommon','modelcheckeradvisor','+simulink','+internal','+customization','customizationModelChecker'),...
                                                                                                                        fullfile(matlabroot,'toolbox','hdlcoder','hdlssc','hdlsscworkflowadvisor','+simulink','+internal','+customization','customizationHDLSSCAdvisor'),...
                                                                                                                        fullfile(matlabroot,'toolbox','fixpoint','fpca','@slCustomizer','customizationFPCA'),...
                                                                                                                        fullfile(matlabroot,'toolbox','rtw','targets','AUTOSAR','adk','sl_customization'),...
                                                                                                                        fullfile(matlabroot,'toolbox','simulink','simulink','modeladvisor','misra','+internalcustomization','customization_MISRA_C_2012'),...
                                                                                                                        fullfile(matlabroot,'toolbox','simulink','simulink','modeladvisor','security','+internalcustomization','customization_security'),...
                                                                                                                        fullfile(matlabroot,'toolbox','slcontrol','slctrlutil','+simulink','+internal','+customization','slcontrol_customization'),...
                                                                                                                        fullfile(matlabroot,'toolbox','slci','slci','+simulink','+internal','+customization','internalCustomizationSLCI'),...
                                                                                                                        fullfile(matlabroot,'toolbox','simulink','simulink','performance','performancea','+simulink','+internal','+customization','customizationPerformanceAdvisor'),...
                                                                                                                        fullfile(matlabroot,'toolbox','simevents','simevents','@slCustomizer','customizationSimEvents'),...
                                                                                                                        fullfile(matlabroot,'toolbox','physmod','simscape','simscape','m','sl_customization'),...
                                                                                                                        fullfile(matlabroot,'toolbox','physmod','simscape','advisor','m','+simulink','+internal','+customization','customizationSimscapePerformanceAdvisor'),...
                                                                                                                        fullfile(matlabroot,'toolbox','physmod','elec','advisor','m','+simulink','+internal','+customization','customizationSimscapeElectricalPerformanceAdvisor'),...
                                                                                                                        fullfile(matlabroot,'toolbox','physmod','sh','advisor','m','+simulink','+internal','+customization','customizationSimscapeFluidsPerformanceAdvisor'),...
                                                                                                                        fullfile(matlabroot,'toolbox','physmod','sdl','advisor','m','+simulink','+internal','+customization','customizationSimscapeDrivelinePerformanceAdvisor'),...
                                                                                                                        fullfile(matlabroot,'toolbox','qualkits','iec','+simulink','+internal','+customization','customizationIECCertkit'),...
                                                                                                                        fullfile(matlabroot,'toolbox','qualkits','do','+simulink','+internal','+customization','customizationDOQualkit'),...
                                                                                                                        fullfile(matlabroot,'toolbox','coder','foundation','build','tools','registry','+simulink','+internal','+customization','customizationCoderFoundation'),...
                                                                                                                        fullfile(matlabroot,'toolbox','target','codertarget','+simulink','+internal','+customization','customizationCoderTarget'),...
                                                                                                                        fullfile(matlabroot,'toolbox','aeroblks','aeroblksutilities','+internalcustomization','customizationAeroblks'),...
                                                                                                                        fullfile(matlabroot,'toolbox','sldv','sldv','+simulink','+internal','+customization','modelAdvisorSLDV'),...
                                                                                                                        fullfile(matlabroot,'toolbox','coder','advisor','+internal','+customization','customizationCGA'),...
                                                                                                                        fullfile(matlabroot,'toolbox','dsp','dsputilities','+simulink','+internal','+customization','dspMdlAdvisor'),...
                                                                                                                        fullfile(matlabroot,'toolbox','shared','spcuilib','@slCustomizer','customizationScopes'),...
                                                                                                                        fullfile(matlabroot,'toolbox','simulink','blocks','sb2sl','+internalcustomization','customizationSb2Sl'),...
                                                                                                                        fullfile(matlabroot,'toolbox','simulink','core','sfuncheck','+internalcustomization','customizationSFunctionAnalyzer'),...
                                                                                                                        fullfile(matlabroot,'toolbox','simulink','core','sfuncheck','+internalcustomization','customizationSFcnMexAnalyzer'),...
                                                                                                                        fullfile(matlabroot,'toolbox','simulink','core','sortingcheck','+internalcustomization','customizationSortingCheck'),...
                                                                                                                        fullfile(matlabroot,'toolbox','simulink','core','sortingcheck','+internalcustomization','customizationDSMRTWSortingCheck'),...
                                                                                                                        fullfile(matlabroot,'toolbox','coder','autosar','+internalcustomization','customizationAUTOSARChecks'),...
                                                                                                                        fullfile(matlabroot,'toolbox','serdes','upgradeadvisor','+simulink','+internal','+customization','customizationSerdes'),...
                                                                                                                        fullfile(matlabroot,'toolbox','slrealtime','simulink','advisor','+simulink','+internal','+customization','customizationRealTimeAdvisor'),...
                                                                                                                        fullfile(matlabroot,'toolbox','shared','matlab_system_block','upgrade_advisor','+systemblock','customizationSystemObjectTask'),...
                                                                                                                        fullfile(matlabroot,'toolbox','plccoder','modeladvisor','+internalcustomization','customizationPLCModelAdvisor'),...
                                                                                                                        fullfile(matlabroot,'toolbox','sl_variants','advisor_checks','checks','m','+internalcustomization','customizationVariants'),...
                                                                                                                        fullfile(matlabroot,'toolbox','simrf','simrf','advisor','+simulink','+internal','+customization','customizationSimRF'),...
                                                                                                                        fullfile(matlabroot,'toolbox','shared','sigbldr','+internal','+customization','customizationSignalBuilder')...
                                                                                                                        ,fullfile(matlabroot,'toolbox','slcheck','model_refactoring','+internalcustomization','customizationModelRefactoring')...
                                                                                                                        ,fullfile(matlabroot,'toolbox','ec_cdg','slcheck','sl_customization')...
                                                                                                                        ,fullfile(matlabroot,'toolbox','stateflow','modeladvisor','+internalcustomization','setupStateflowUpgradeAdvisorChecks')...
                                                                                                                        ,fullfile(matlabroot,'toolbox','slcheck_edittime_sdp','ml','+internalcustomization','customizationSDP')
                                                                                                                        };
                                                                                                                    end


                                                                                                                    if Advisor.Utils.license('test','SL_Verification_Validation')==1
                                                                                                                        SLVVlicenseValid=true;
                                                                                                                    else
                                                                                                                        SLVVlicenseValid=false;
                                                                                                                    end
                                                                                                                    if SLVVlicenseValid
                                                                                                                        builtinCheckFcnNames{end+1}=fullfile(matlabroot,'toolbox','slcheck','slcheckdemos','advisordemos','sl_customization');
                                                                                                                    end

                                                                                                                    builtinCheckFcnNames=lower(builtinCheckFcnNames);

                                                                                                                    origcheckFcnName=checkFcnName;

                                                                                                                    checkFcnName=lower(checkFcnName(1:end-2));


                                                                                                                    mlrootwork=[lower(fullfile(matlabroot,'work')),filesep];
                                                                                                                    supportPackageRoot=lower(matlabshared.supportpkg.internal.getSupportPackageRootNoCreate);
                                                                                                                    if strncmpi(checkFcnName,[matlabroot,filesep],length([matlabroot,filesep]))&&...
                                                                                                                        ~strncmp(checkFcnName,mlrootwork,length(mlrootwork))

                                                                                                                        if ismember(checkFcnName,builtinCheckFcnNames)
                                                                                                                            isValid=true;
                                                                                                                            isCustomCheck=false;
                                                                                                                        else
                                                                                                                            isValid=false;

                                                                                                                            if~isValid
                                                                                                                                MSLDiagnostic('Simulink:tools:MASlcustomizeInsideMlroot',origcheckFcnName).reportAsWarning;
                                                                                                                            end
                                                                                                                        end
                                                                                                                    elseif~isempty(supportPackageRoot)&&strncmp(checkFcnName,supportPackageRoot,length(supportPackageRoot))
                                                                                                                        isValid=true;
                                                                                                                        isCustomCheck=false;
                                                                                                                    else
                                                                                                                        isValid=true;
                                                                                                                    end

                                                                                                                    function loc_rtw_check_slprj_dir(anchorDir)
                                                                                                                        markerFile=fullfile(anchorDir,'slprj','sl_proj.tmw');
                                                                                                                        if exist(markerFile,'file')
                                                                                                                            fid=fopen(markerFile,'r');
                                                                                                                            if fid==-1
                                                                                                                                DAStudio.error('RTW:utility:fileIOError',makerFile,'open');
                                                                                                                            end
                                                                                                                            line1=fgetl(fid);%#ok<NASGU>
                                                                                                                            line2=fgetl(fid);
                                                                                                                            fclose(fid);

                                                                                                                            if isequal(line2,-1)


                                                                                                                                currSlprjVer='1';
                                                                                                                            else
                                                                                                                                currSlprjVer=regexp(line2,'slprjVersion:\s+(\S+)','tokens');
                                                                                                                                currSlprjVer=currSlprjVer{1}{1};
                                                                                                                            end

                                                                                                                            latestSlprjVer=coder.internal.folders.MarkerFile.getCurrentVersion();

                                                                                                                            if~strcmp(latestSlprjVer,currSlprjVer)

                                                                                                                                errMsg=DAStudio.message('ModelAdvisor:engine:slprjVerIncompatible');
                                                                                                                                btn1=DAStudio.message('RTW:buildProcess:slprjVerDlgBtn1');
                                                                                                                                btn2=DAStudio.message('RTW:buildProcess:slprjVerDlgBtn2');


                                                                                                                                if~desktop('-inuse')||feature('noFigureWindows')
                                                                                                                                    response=btn1;
                                                                                                                                else
                                                                                                                                    response=questdlg(errMsg,...
                                                                                                                                    DAStudio.message('ModelAdvisor:engine:slprjVerDlgTitle'),...
                                                                                                                                    btn1,btn2,btn1);
                                                                                                                                end
                                                                                                                                if isempty(response)||strcmp(response,btn2)
                                                                                                                                    DAStudio.error('ModelAdvisor:engine:MAOpeningAborted');

                                                                                                                                elseif strcmp(response,btn1)
                                                                                                                                    [s,w]=rmdir(fullfile(anchorDir,'slprj'),'s');
                                                                                                                                    if~s
                                                                                                                                        DAStudio.error('RTW:utility:removeError',w);
                                                                                                                                    end



                                                                                                                                    delete(['*',coder.internal.modelRefUtil('','getBinExt',true),'.',mexext]);
                                                                                                                                    delete(['*',coder.internal.modelRefUtil('','getBinExt',false),'.',mexext]);
                                                                                                                                end
                                                                                                                            end
                                                                                                                        end





                                                                                                                        function isInside=loc_InsideInactiveVariantBlock(block)
                                                                                                                            if ishandle(block)
                                                                                                                                block=getfullname(block);
                                                                                                                            end
                                                                                                                            isInside=false;
                                                                                                                            parentSubsystem=get_param(block,'Parent');
                                                                                                                            while~isempty(parentSubsystem)&&~isempty(get_param(parentSubsystem,'Parent'))
                                                                                                                                if strcmp(get_param(block,'BlockType'),'SubSystem')
                                                                                                                                    active=get_param(parentSubsystem,'ActiveVariant');
                                                                                                                                    if~isempty(active)
                                                                                                                                        if~strcmp(active,get_param(block,'VariantControl'))
                                                                                                                                            isInside=true;
                                                                                                                                            break
                                                                                                                                        end
                                                                                                                                    end
                                                                                                                                end
                                                                                                                                block=parentSubsystem;
                                                                                                                                parentSubsystem=get_param(parentSubsystem,'Parent');
                                                                                                                            end

                                                                                                                            function output=loc_emitInputParameter(check)
                                                                                                                                output='';
                                                                                                                                if~isempty(check.InputParameters)&&check.EmitInputParametersToReport



                                                                                                                                    isVisible=true(size(check.InputParameters));
                                                                                                                                    if~check.EmitInvisibleInputParametersToReport
                                                                                                                                        for n=1:length(check.InputParameters)


                                                                                                                                            if~isstruct(check.InputParameters{n})&&check.InputParameters{n}.Visible==false
                                                                                                                                                isVisible(n)=false;
                                                                                                                                            end
                                                                                                                                        end
                                                                                                                                    end

                                                                                                                                    visibleInputParameters=check.InputParameters(isVisible);

                                                                                                                                    if~isempty(visibleInputParameters)
                                                                                                                                        TableHeading=ModelAdvisor.Text(DAStudio.message('ModelAdvisor:engine:InputParamSelection'),{'bold'});

                                                                                                                                        Table=ModelAdvisor.Table(length(visibleInputParameters),2);
                                                                                                                                        Table.setColHeading(1,DAStudio.message('Simulink:tools:MAName'));
                                                                                                                                        Table.setColHeading(2,DAStudio.message('ModelAdvisor:engine:Value'));
                                                                                                                                        for i=1:length(visibleInputParameters)
                                                                                                                                            if isstruct(visibleInputParameters{i})&&~(isfield(visibleInputParameters{i},'Name')...
                                                                                                                                                &&isfield(visibleInputParameters{i},'Type')&&isfield(visibleInputParameters{i},'Value'))

                                                                                                                                            else
                                                                                                                                                Table.setEntry(i,1,loc_escapeHTMLtags(visibleInputParameters{i}.Name));
                                                                                                                                                switch visibleInputParameters{i}.Type
                                                                                                                                                case{'String','Enum','ComboBox','BlockConstraint','RadioButton'}
                                                                                                                                                    Table.setEntry(i,2,loc_escapeHTMLtags(visibleInputParameters{i}.Value));
                                                                                                                                                case 'Bool'
                                                                                                                                                    if visibleInputParameters{i}.Value
                                                                                                                                                        boolstr='true';
                                                                                                                                                    else
                                                                                                                                                        boolstr='false';
                                                                                                                                                    end
                                                                                                                                                    Table.setEntry(i,2,boolstr);
                                                                                                                                                case{'PushButton','Table','BlockTypeWithParameter'}
                                                                                                                                                    Table.setEntry(i,2,'N/A');
                                                                                                                                                case 'Number'
                                                                                                                                                    Table.setEntry(i,2,num2str(visibleInputParameters{i}.Value));
                                                                                                                                                case{'BlockType'}
                                                                                                                                                    Table.setEntry(i,2,loc_escapeHTMLtags(visibleInputParameters{i}.exportXML));
                                                                                                                                                end
                                                                                                                                            end
                                                                                                                                        end
                                                                                                                                        output=loc_CreateIgnorePortion(['<!-- inputparam_section_start -->'...
                                                                                                                                        ,'<H5>',TableHeading.emitHTML,'</H5>',Table.emitHTML...
                                                                                                                                        ,'<!-- inputparam_section_finish -->']);
                                                                                                                                    end
                                                                                                                                end

                                                                                                                                function output=loc_emitActionResult(check)
                                                                                                                                    output='';
                                                                                                                                    if isa(check,'ModelAdvisor.Check')&&isa(check.Action,'ModelAdvisor.Action')&&~isempty(check.Action.ResultInHTML)
                                                                                                                                        Heading=ModelAdvisor.Text(DAStudio.message('ModelAdvisor:engine:ActionLog'),{'bold'});
                                                                                                                                        output=loc_CreateIgnorePortion(['<!-- actionresult_section_start -->'...
                                                                                                                                        ,'<div class="subsection"><H5>',Heading.emitHTML,'</H5>',check.Action.ResultInHTML,'</div>'...
                                                                                                                                        ,'<!-- actionresult_section_finish -->']);
                                                                                                                                    end


                                                                                                                                    function outputStr=loc_escapeHTMLtags(inputStr)
                                                                                                                                        outputStr=inputStr;
                                                                                                                                        outputStr=strrep(outputStr,'<','&lt;');
                                                                                                                                        outputStr=strrep(outputStr,'>','&gt;');















                                                                                                                                        function output=loc_featurecontrol(featurename)
                                                                                                                                            output=false;
                                                                                                                                            ModelAdvisorFeatureControlExist=evalin('base','exist(''ModelAdvisorFeatureControl'',''var'')');
                                                                                                                                            if ModelAdvisorFeatureControlExist
                                                                                                                                                ModelAdvisorFeatureControl=evalin('base','ModelAdvisorFeatureControl');
                                                                                                                                            else
                                                                                                                                                ModelAdvisorFeatureControl.Accordion=false;
                                                                                                                                                ModelAdvisorFeatureControl.EmitInputParameter=true;
                                                                                                                                                ModelAdvisorFeatureControl.SupportLibrary=true;
                                                                                                                                                ModelAdvisorFeatureControl.ForceRunOnLibrary=false;
                                                                                                                                                ModelAdvisorFeatureControl.RptGenChecks='Simulink';
                                                                                                                                                ModelAdvisorFeatureControl.SupportExclusions=true;
                                                                                                                                                ModelAdvisorFeatureControl.ExclusionMasterMenu=true;
                                                                                                                                                ModelAdvisorFeatureControl.ExclusionCheckSelector=true;
                                                                                                                                                ModelAdvisorFeatureControl.EngineInterfaceCompileMode=true;
                                                                                                                                                ModelAdvisorFeatureControl.NoSlvnvInstall=false;
                                                                                                                                                ModelAdvisorFeatureControl.ReportControlPanel=true;
                                                                                                                                                ModelAdvisorFeatureControl.DDRestorePoint=true;
                                                                                                                                                ModelAdvisorFeatureControl.CompressedMACEFormat=true;
                                                                                                                                                ModelAdvisorFeatureControl.fixedPointUtilityScope=false;
                                                                                                                                            end
                                                                                                                                            if isfield(ModelAdvisorFeatureControl,featurename)
                                                                                                                                                output=ModelAdvisorFeatureControl.(featurename);
                                                                                                                                            else
                                                                                                                                                ModelAdvisorFeatureControl.Accordion=false;
                                                                                                                                                ModelAdvisorFeatureControl.EmitInputParameter=true;
                                                                                                                                                ModelAdvisorFeatureControl.SupportLibrary=true;
                                                                                                                                                ModelAdvisorFeatureControl.ForceRunOnLibrary=false;
                                                                                                                                                ModelAdvisorFeatureControl.RptGenChecks='Simulink';
                                                                                                                                                ModelAdvisorFeatureControl.SupportExclusions=true;
                                                                                                                                                ModelAdvisorFeatureControl.ExclusionMasterMenu=true;
                                                                                                                                                ModelAdvisorFeatureControl.ExclusionCheckSelector=true;
                                                                                                                                                ModelAdvisorFeatureControl.EngineInterfaceCompileMode=true;
                                                                                                                                                ModelAdvisorFeatureControl.NoSlvnvInstall=false;
                                                                                                                                                ModelAdvisorFeatureControl.ReportControlPanel=true;
                                                                                                                                                ModelAdvisorFeatureControl.DDRestorePoint=true;
                                                                                                                                                ModelAdvisorFeatureControl.CompressedMACEFormat=true;
                                                                                                                                                ModelAdvisorFeatureControl.fixedPointUtilityScope=false;
                                                                                                                                                ModelAdvisorFeatureControl.GenerateAdvisorReport=false;
                                                                                                                                                if isfield(ModelAdvisorFeatureControl,featurename)
                                                                                                                                                    output=ModelAdvisorFeatureControl.(featurename);
                                                                                                                                                end
                                                                                                                                            end

                                                                                                                                            function[warningImg,passedImg,failedImg,notrunImg,minusImg,task_disabledImg,infoImg,justifyImg,errorImg]=getDataURLs()
                                                                                                                                                warningImg='src="data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAACXBIWXMAAAsTAAALEwEAmpwYAAAAAXNSR0IArs4c6QAAAARnQU1BAACxjwv8YQUAAAD3SURBVHgBzZI7EsFQFIb/I4oQRTSUsgOlNlqPGTtgB+yAHRg9Ywka/c0WFGp0aCgYxuvIZcwk8phkRuGr7uPc///P3AP8NVY9vbBqmgirSQRdiIrWApNhL01RTXUQB9FQDel+Wi/5tFmynWInTF2PnIDuSlu6q/kC1FxBHunIXDqRBKQ7GJ5iArX9UngTXJUe/NFJu/ZDBaQ7EZoIgtAStYwZKEA3ZeLcnzcrnLerLw3uuvcfd/vbKIExIsCgcnl6sFwJSHErS0rDOUqjuUeAiMeuFhxDEw2G8RmuVwtyaGIJvNmb02M2+RJ80MDuvxjnNT8wwy94AjZHSy+aGaDFAAAAAElFTkSuQmCC" ';
                                                                                                                                                passedImg='src="data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAACXBIWXMAAAsTAAALEwEAmpwYAAAAAXNSR0IArs4c6QAAAARnQU1BAACxjwv8YQUAAAHTSURBVHgBrVO9ThtBEP7mLomDFEWXpEhFbD9BlC5SUGynSkdSpoiOMt2lovXdG0CqpEpIR2cXtPxJSNAgIyoaOKBBAuEzDRYSHmb29hYbRAWjk3a1O9/PzM4B9wy6dRIHAeBFBJpioJInUIfBHeAyQZyldxL4yatwwJgRYGAvGETEPGBLlDFxgubprMM4dPIyAtNv2T0dYid2e9L9mOw+o1FKsdzf0nPP2q4IOFZFHnLEziJRJXiDuDaNF6XnUo0/k5daEMBXcMCaidFQEgUvhi0069P4WJ3QlAADL3IEYu/tKIa5IFLwUtg2a+doG6vpWu7KRzjkgA3BXrSJ3WhT7JY1h6sG3BLwOLYE/GluEt1+TxSkUqaqI2BbatY/s4ot1MofaNEqK7gxN8lduS8aWti1JSDV9ev8d6TZQU4y1XbKjf9fRPmMhvsCMxfOAf0TVuxnh6pkSDSsMrLzHuNWUMeKw06fv2e6axo3jnp5Au2dBVPWtarzkAGDdzqV16+WBCGx/7d4SjYvQeZjvmGAvJ9oHs/mj1GETlZtrCeA9zDTODoSlJuQe/xA8+RPce6PMK+cr6NempfWBJr/7LH/+skjjy4uORWKX/IzfUPc3cBDxhXE6LNA6WFItQAAAABJRU5ErkJggg==" ';
                                                                                                                                                failedImg='src="data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAACXBIWXMAAAsTAAALEwEAmpwYAAAAAXNSR0IArs4c6QAAAARnQU1BAACxjwv8YQUAAAEDSURBVHgBrVIxCsJAENwVGzux1MZCxDKg+AYVLHxBYmXjI/IECxsr4wsshPgHEUkZxCJNLCWdnWf2SI41uYBBpzhud2fm9vYO4EcgD9x+18QXruJtvYAfCCHsiXfd5QwSsQNfIDaxUpMKF7emMxhdfOgsljkR5ahGHER0XKNrKoNYbGfJ3CQbSw3Kq0I1idu0hIc91JotrQHhtllLToI6N1Agku5Uyqc1jgpoQMTH+aRi2uvEhQZ0cmMwVDHtdYPVGvDWedu6QRI+ZkBPpBNzg+c95INUHUTcKCsuGGBAi/yJR6NnAYotlIHA+djzHfWVS5kkYmBXAJmIC2lrBYi4+C94A/a+eag5PUw2AAAAAElFTkSuQmCC" ';
                                                                                                                                                notrunImg='src="data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAACXBIWXMAAAsTAAALEwEAmpwYAAAAAXNSR0IArs4c6QAAAARnQU1BAACxjwv8YQUAAADhSURBVHgBtZI/CoMwFIdfQg/QyU3o4ubopjdw8gS9heANdOsVegGv0A66F3RzqOCkU92ypUYSCM0flOIHIY/k5cdHEoA/QaLI8/y9TBdLb48xTtI0fZkCqOd5wMYv8zxDXdes/FBKkyzLnmIPy43TNMEwDNrBOSOEHkVRXMXCSQ5wHAd83wcdYRiuc9M00LbtbSnvSgAz4KpGxnFcTYwGQRBYA7gBaAN2GOgDXNeFKIqsAVVVmQ3YhnTjWgghZgP2AocbsE9lNYjjWHuwLEvouk5ZVwxkvS3IX7mH7ezptfMFbNhwT85bFwwAAAAASUVORK5CYII=" ';

                                                                                                                                                minusImg='src="data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAACXBIWXMAAAsTAAALEwEAmpwYAAAABGdBTUEAALGOfPtRkwAAACBjSFJNAAB6JQAAgIMAAPn/AACA6QAAdTAAAOpgAAA6mAAAF2+SX8VGAAAAhklEQVR42mL8//8/AyUAIICYGCgEAAFEsQEAAUSxAQABxIIu0NTURDBQ6urqGGFsgABiwaagpqYOp+aWliYUPkAAUewFgACi2ACAAGLBKcGCafafP/8wxAACCKcB2BRjAwABRLEXAAKIYgMAAoiFmKjCBwACiJHSzAQQQBR7ASCAKDYAIMAAUtQUow+YsTsAAAAASUVORK5CYII=" ';
                                                                                                                                                task_disabledImg='src="data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAIAAACQkWg2AAAA0klEQVR42mN8+PAhAymAkWQNqzf0EK/azDAUpAFIIYv+//8HxoIy/jMyfPx0d+3q4+bm5ugasKpm+Pfn45eHKBouX74MlNPR0WT4z3Dl6nU0l2hrK378/BDdBoTZYOMhBsMFcNvAwHDlChE2gIz/DwwzhOsRFgIF/6PaYGoQCDFVR1sV5Idrt9Fs0NKU/fT1KZIG/UCI2f8ZQKYy/gcbDzYYKvifAVWDQSBI5t8fqDY4A6wfog1Fg6qSFjHRjNBw6exHIpMGSAMw8UHClEhAcmoFACLZqO1i9O7+AAAAAElFTkSuQmCC"';
                                                                                                                                                infoImg='src="data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAACXBIWXMAAAsTAAALEwEAmpwYAAAKTWlDQ1BQaG90b3Nob3AgSUNDIHByb2ZpbGUAAHjanVN3WJP3Fj7f92UPVkLY8LGXbIEAIiOsCMgQWaIQkgBhhBASQMWFiApWFBURnEhVxILVCkidiOKgKLhnQYqIWotVXDjuH9yntX167+3t+9f7vOec5/zOec8PgBESJpHmomoAOVKFPDrYH49PSMTJvYACFUjgBCAQ5svCZwXFAADwA3l4fnSwP/wBr28AAgBw1S4kEsfh/4O6UCZXACCRAOAiEucLAZBSAMguVMgUAMgYALBTs2QKAJQAAGx5fEIiAKoNAOz0ST4FANipk9wXANiiHKkIAI0BAJkoRyQCQLsAYFWBUiwCwMIAoKxAIi4EwK4BgFm2MkcCgL0FAHaOWJAPQGAAgJlCLMwAIDgCAEMeE80DIEwDoDDSv+CpX3CFuEgBAMDLlc2XS9IzFLiV0Bp38vDg4iHiwmyxQmEXKRBmCeQinJebIxNI5wNMzgwAABr50cH+OD+Q5+bk4eZm52zv9MWi/mvwbyI+IfHf/ryMAgQAEE7P79pf5eXWA3DHAbB1v2upWwDaVgBo3/ldM9sJoFoK0Hr5i3k4/EAenqFQyDwdHAoLC+0lYqG9MOOLPv8z4W/gi372/EAe/tt68ABxmkCZrcCjg/1xYW52rlKO58sEQjFu9+cj/seFf/2OKdHiNLFcLBWK8ViJuFAiTcd5uVKRRCHJleIS6X8y8R+W/QmTdw0ArIZPwE62B7XLbMB+7gECiw5Y0nYAQH7zLYwaC5EAEGc0Mnn3AACTv/mPQCsBAM2XpOMAALzoGFyolBdMxggAAESggSqwQQcMwRSswA6cwR28wBcCYQZEQAwkwDwQQgbkgBwKoRiWQRlUwDrYBLWwAxqgEZrhELTBMTgN5+ASXIHrcBcGYBiewhi8hgkEQcgIE2EhOogRYo7YIs4IF5mOBCJhSDSSgKQg6YgUUSLFyHKkAqlCapFdSCPyLXIUOY1cQPqQ28ggMor8irxHMZSBslED1AJ1QLmoHxqKxqBz0XQ0D12AlqJr0Rq0Hj2AtqKn0UvodXQAfYqOY4DRMQ5mjNlhXIyHRWCJWBomxxZj5Vg1Vo81Yx1YN3YVG8CeYe8IJAKLgBPsCF6EEMJsgpCQR1hMWEOoJewjtBK6CFcJg4Qxwicik6hPtCV6EvnEeGI6sZBYRqwm7iEeIZ4lXicOE1+TSCQOyZLkTgohJZAySQtJa0jbSC2kU6Q+0hBpnEwm65Btyd7kCLKArCCXkbeQD5BPkvvJw+S3FDrFiOJMCaIkUqSUEko1ZT/lBKWfMkKZoKpRzame1AiqiDqfWkltoHZQL1OHqRM0dZolzZsWQ8ukLaPV0JppZ2n3aC/pdLoJ3YMeRZfQl9Jr6Afp5+mD9HcMDYYNg8dIYigZaxl7GacYtxkvmUymBdOXmchUMNcyG5lnmA+Yb1VYKvYqfBWRyhKVOpVWlX6V56pUVXNVP9V5qgtUq1UPq15WfaZGVbNQ46kJ1Bar1akdVbupNq7OUndSj1DPUV+jvl/9gvpjDbKGhUaghkijVGO3xhmNIRbGMmXxWELWclYD6yxrmE1iW7L57Ex2Bfsbdi97TFNDc6pmrGaRZp3mcc0BDsax4PA52ZxKziHODc57LQMtPy2x1mqtZq1+rTfaetq+2mLtcu0W7eva73VwnUCdLJ31Om0693UJuja6UbqFutt1z+o+02PreekJ9cr1Dund0Uf1bfSj9Rfq79bv0R83MDQINpAZbDE4Y/DMkGPoa5hpuNHwhOGoEctoupHEaKPRSaMnuCbuh2fjNXgXPmasbxxirDTeZdxrPGFiaTLbpMSkxeS+Kc2Ua5pmutG003TMzMgs3KzYrMnsjjnVnGueYb7ZvNv8jYWlRZzFSos2i8eW2pZ8ywWWTZb3rJhWPlZ5VvVW16xJ1lzrLOtt1ldsUBtXmwybOpvLtqitm63Edptt3xTiFI8p0in1U27aMez87ArsmuwG7Tn2YfYl9m32zx3MHBId1jt0O3xydHXMdmxwvOuk4TTDqcSpw+lXZxtnoXOd8zUXpkuQyxKXdpcXU22niqdun3rLleUa7rrStdP1o5u7m9yt2W3U3cw9xX2r+00umxvJXcM970H08PdY4nHM452nm6fC85DnL152Xlle+70eT7OcJp7WMG3I28Rb4L3Le2A6Pj1l+s7pAz7GPgKfep+Hvqa+It89viN+1n6Zfgf8nvs7+sv9j/i/4XnyFvFOBWABwQHlAb2BGoGzA2sDHwSZBKUHNQWNBbsGLww+FUIMCQ1ZH3KTb8AX8hv5YzPcZyya0RXKCJ0VWhv6MMwmTB7WEY6GzwjfEH5vpvlM6cy2CIjgR2yIuB9pGZkX+X0UKSoyqi7qUbRTdHF09yzWrORZ+2e9jvGPqYy5O9tqtnJ2Z6xqbFJsY+ybuIC4qriBeIf4RfGXEnQTJAntieTE2MQ9ieNzAudsmjOc5JpUlnRjruXcorkX5unOy553PFk1WZB8OIWYEpeyP+WDIEJQLxhP5aduTR0T8oSbhU9FvqKNolGxt7hKPJLmnVaV9jjdO31D+miGT0Z1xjMJT1IreZEZkrkj801WRNberM/ZcdktOZSclJyjUg1plrQr1zC3KLdPZisrkw3keeZtyhuTh8r35CP5c/PbFWyFTNGjtFKuUA4WTC+oK3hbGFt4uEi9SFrUM99m/ur5IwuCFny9kLBQuLCz2Lh4WfHgIr9FuxYji1MXdy4xXVK6ZHhp8NJ9y2jLspb9UOJYUlXyannc8o5Sg9KlpUMrglc0lamUycturvRauWMVYZVkVe9ql9VbVn8qF5VfrHCsqK74sEa45uJXTl/VfPV5bdra3kq3yu3rSOuk626s91m/r0q9akHV0IbwDa0b8Y3lG19tSt50oXpq9Y7NtM3KzQM1YTXtW8y2rNvyoTaj9nqdf13LVv2tq7e+2Sba1r/dd3vzDoMdFTve75TsvLUreFdrvUV99W7S7oLdjxpiG7q/5n7duEd3T8Wej3ulewf2Re/ranRvbNyvv7+yCW1SNo0eSDpw5ZuAb9qb7Zp3tXBaKg7CQeXBJ9+mfHvjUOihzsPcw83fmX+39QjrSHkr0jq/dawto22gPaG97+iMo50dXh1Hvrf/fu8x42N1xzWPV56gnSg98fnkgpPjp2Snnp1OPz3Umdx590z8mWtdUV29Z0PPnj8XdO5Mt1/3yfPe549d8Lxw9CL3Ytslt0utPa49R35w/eFIr1tv62X3y+1XPK509E3rO9Hv03/6asDVc9f41y5dn3m978bsG7duJt0cuCW69fh29u0XdwruTNxdeo94r/y+2v3qB/oP6n+0/rFlwG3g+GDAYM/DWQ/vDgmHnv6U/9OH4dJHzEfVI0YjjY+dHx8bDRq98mTOk+GnsqcTz8p+Vv9563Or59/94vtLz1j82PAL+YvPv655qfNy76uprzrHI8cfvM55PfGm/K3O233vuO+638e9H5ko/ED+UPPR+mPHp9BP9z7nfP78L/eE8/sl0p8zAAAABGdBTUEAALGOfPtRkwAAACBjSFJNAAB6JQAAgIMAAPn/AACA6QAAdTAAAOpgAAA6mAAAF2+SX8VGAAACX0lEQVR42pyTvU9TURjGf/e2JaVFcrEtSEm61DTpQKqpCcQ0hEESEsMgMQ4mDsaEkYGJ0ck4MbAJAztBWOQvsAOxkWAIVgNNUBSlvf0gbe+9vR89DtUrlcQYz3jy/N73vM95XkkIwcWzsbktsm8/ky+oqFUNgPBAgGQ8TCYd4/7sXemiXvpVILeTFavruxwclUmNJhiKRJA9Pmp1nbNihWJJpVpRuZkcZGVpXuoqkNvJimcvsgSCClOTYzR1i0qtSa2uU28YNLUWmm5iGCa1yneuhX1srS1KADLA6vougaDCzPSEC7csm4czKZ48uIUsQcu0sR2Bvy/CaclkbmFZAMgbm9vi4KjM1OQY5WrD7RxSekmPjjB2I0aoX1Atf8OybYQQ+IMhdt+fsbG5LTzR65mnkaEoiqJ0PfvTlwqaZpLbO+blq9c4joXX60f2eJEkCRA4dgtvvqByezx+aebpiQSPZtMA7H88Ibd3jMfnd933+nrJF1Rktaq5bl807EOh6Ioto0FLr+FYhnsne3pQq1rHxD/hlmnz5t0J/3K84YEAZ8UKAo8LW5aD7bT/CrYdk/BAADkZD1MsqZfg4cgVVzwyfPVSAdvSScbDyJl0jGpFxTBMFxZCMDked8V3JkY7Xds2AEK0MY06mXSsk8S5hWWxf3iOvy/Cr2hHB/sZHurHNjXK5RL5w694fH4CfYPojRKphMLK0rzk7sK9x8/FacnEHwwhSfLvWds2wrF/Bh9Mo0400tMdZYCttUUplVBonp9iGue0HbPzXbIXSZZxnBZ6QyWVUFy4axv/d51/DABGnnJocWG90gAAAABJRU5ErkJggg=="';
                                                                                                                                                justifyImg='src="data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAACXBIWXMAAAsTAAALEwEAmpwYAAAAAXNSR0IArs4c6QAAAARnQU1BAACxjwv8YQUAAADqSURBVHgBpZKvC8JAFMffZAPFslXTLBYNitVimBYx+A/of+CibYs2rcZVg4gYBYtFUJdWLFsxb0UUDOod3Insx43dBw7e4/i++753T3h/AQ5ywIlIAuvsgb65QPB8JQpUpQimVoNhU8W5QFooT7fg+XdIg1yQwDcHOKYtsMToRb1VwXHw+LlMNQMkRrbXzi10F1kAvWSPOyDnJSpuL/aRLsWoAvPDFeolBWy9i/M4cawDxGh5BOvkJopjHRDMnQMs/hy4kx4+afNQgSzQRVKMFXMLCWgbiRPqYNZv4AsW6GsNrRp2kBXuGXwAIu1X3q8Yjd0AAAAASUVORK5CYII=" ';
                                                                                                                                                errorImg='src="data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAACXBIWXMAAAsTAAALEwEAmpwYAAAAAXNSR0IArs4c6QAAAARnQU1BAACxjwv8YQUAAAEQSURBVHgBrVI7csIwEH3rMK7dZdI5J0jKZNLQJJM+aRPICRJuEG7gI+Ch5QD8ChoGOnwEOobONRgvWo0QDB9jD7xGK+3u05P2AReC9g+4XPbgLn5VWAXDN2WRykS4SevUHk9PEvDbSwUpB+rUw3HEcLhOnVFwQMCvz+pWCpBLN1WpOwwtAb8/+UicScbNh0qW7j0NBrGjtwn9F2gWeCgt/iRwjKYHFAWhIkvJbB712mwBt3fZjfMZ8PUpkb+jwIAJZ7FXYxTwVCV8fH+gAKKtgpRCFMcOQeIGynVx7lapVa60BDJPUFrLTQC2lrafSL1xA8y1TCWSW+GH+kesbGu0K5WxxBub8UJ/cihP1WqviTVjXFeRN9ClYgAAAABJRU5ErkJggg==" ';


                                                                                                                                                function rptContents=loc_shuffleReport(rptContents)


                                                                                                                                                    rptContents=regexprep(rptContents,'<!-- mdladv_ignore_start -->(.*?)<!-- mdladv_ignore_finish -->','');

                                                                                                                                                    rptContents=regexprep(rptContents,'\s\s\n<!-- LocalWords:(.*?)>','');






                                                                                                                                                    idx=regexp(rptContents,'<hr\s?/?>','ignorecase');

                                                                                                                                                    if isempty(idx)
                                                                                                                                                        idx=regexp(rptContents,'<h[1-6]>','ignorecase');
                                                                                                                                                    end
                                                                                                                                                    if~isempty(idx)
                                                                                                                                                        rptContents=rptContents(idx(1):end);
                                                                                                                                                    end


                                                                                                                                                    rptContents=strrep(rptContents,'<p><hr /></p>','');


                                                                                                                                                    rptContents=regexprep(rptContents,['(\s*?)<a name="CheckRecord_([^<>"]*?)"></a>',...
                                                                                                                                                    '<div name = "([^<>"]*?)"(\s*?)id = "([^<>"]*?)"(\s*?)class = "([^<>"]*?)"></div>',...
                                                                                                                                                    '<div class="CheckHeader" id="Header_([^<>"]*?)">(\s?)',...
                                                                                                                                                    '<span class="CheckHeading" id="Heading_([^<>"]*?)">(\s?)',...
                                                                                                                                                    '([^<>]*?)</span>(\s?)</div>'],'$12');

                                                                                                                                                    rptContents=regexprep(rptContents,['(\s*?)<a name="CheckRecord_([^<>"]*?)"></a>',...
                                                                                                                                                    '<div name = "([^<>"]*?)"(\s*?)id = "([^<>"]*?)"(\s*?)class = "([^<>"]*?)">',...
                                                                                                                                                    '<div class="CheckHeader" id="Header_([^<>"]*?)">(\s?)',...
                                                                                                                                                    '<span class="CheckHeading" id="Heading_([^<>"]*?)">(\s?)',...
                                                                                                                                                    '([^<>]*?)</span>(\s?)</div>'],'$12');

                                                                                                                                                    rptContents=regexprep(rptContents,...
                                                                                                                                                    '(\s*?)<[aA] NAME="CheckRecord_([^<>"]*?)" /><font size="\+1"><b>(\s*?)([^<>]*?)</b></font>','$4');
                                                                                                                                                    rptContents=regexprep(rptContents,['(\s*?)<a name="CheckRecord_([^<>"]*?)"></a><div class="CheckHeader" id="Header_([^<>"]*?)">(\s?)',...
                                                                                                                                                    '<span class="CheckHeading" id="Heading_([^<>"]*?)">(\s?)',...
                                                                                                                                                    '([^<>]*?)</span>(\s?)</div>'],'$7');


                                                                                                                                                    rptContents=strrep(rptContents,DAStudio.message('ModelAdvisor:engine:CGIRChecksNoteRefMdlBuild'),'');



                                                                                                                                                    rptContents=regexprep(rptContents,'matlab: modeladvisorprivate hiliteSystem(''USE_SID:','matlab: Simulink.ID.hilite(''');


                                                                                                                                                    rptContents=loc_MakeTagCompatible(rptContents);


                                                                                                                                                    rptContents=regexprep(rptContents,'MathWorks Automotive Advisory Board Guideline','');
                                                                                                                                                    rptContents=regexprep(rptContents,'MathWorks Automotive Advisory Board Checks','');





                                                                                                                                                    rptContents=regexprep(rptContents,'<hr WIDTH="50%" ALIGN = "left"  SIZE="2"></hr>','');
                                                                                                                                                    rptContents=regexprep(rptContents,'<br>_________________________________________________________________________________________','');
                                                                                                                                                    rptContents=regexprep(rptContents,'<br />_________________________________________________________________________________________','');
                                                                                                                                                    rptContents=regexprep(rptContents,'<[aA] NAME="CheckRecord_(\w*)"','<a name="CheckRecord_SerialNumber"');

                                                                                                                                                    rptContents=regexprep(rptContents,'<[a|A] href="matlab: modeladvisorprivate hiliteSystem (\w*) (\w*)">','<a href="matlab: modeladvisorprivate hiliteSystem $1 SerialNumber">');
                                                                                                                                                    rptContents=regexprep(rptContents,'hiliteLine(.*?)>','hiliteLine lineHandle">');


                                                                                                                                                    rptContents=regexprep(rptContents,'%20',' ');
                                                                                                                                                    rptContents=regexprep(rptContents,'<a href = "matlab: modeladvisorprivate openSimprmAdvancedPage (\w+) ''(\w+)'' ">','<a href = "matlab: modeladvisorprivate openSimprmAdvancedPage $1 ''$2''">');
                                                                                                                                                    rptContents=regexprep(rptContents,'<a href ="matlab: modeladvisorprivate openSimprmAdvancedPage','<a href = "matlab: modeladvisorprivate openSimprmAdvancedPage');
                                                                                                                                                    rptContents=regexprep(rptContents,'<a href = "matlab: modeladvisorprivate openSimprmAdvancedPage (\w+) ''(\w+)\s(\w+)/(\w+)'' ">','<a href = "matlab: modeladvisorprivate openSimprmAdvancedPage $1 ''$2 $3/$4''">');
                                                                                                                                                    rptContents=regexprep(rptContents,'<a href = "matlab: modeladvisorprivate openSimprmAdvancedPage (\w+) ''(\w+)\s(\w+)/(\w+) (\w+)'' ">','<a href = "matlab: modeladvisorprivate openSimprmAdvancedPage $1 ''$2 $3/$4 $5''">');
                                                                                                                                                    rptContents=regexprep(rptContents,'<a href = "matlab: modeladvisorprivate openSimprmAdvancedPage (\w+) ''(\w+)/(\w+)'' ">','<a href = "matlab: modeladvisorprivate openSimprmAdvancedPage $1 ''$2/$3''">');
                                                                                                                                                    rptContents=regexprep(rptContents,'<a href = "matlab: modeladvisorprivate openSimprmAdvancedPage (\w+) ''(\w+)/(\w+) (\w+)'' ">','<a href = "matlab: modeladvisorprivate openSimprmAdvancedPage $1 ''$2/$3 $4''">');
                                                                                                                                                    rptContents=regexprep(rptContents,'<a href = "matlab: modeladvisorprivate openSimprmAdvancedPage (\w+) ''(\w+) (\w+)'' ">','<a href = "matlab: modeladvisorprivate openSimprmAdvancedPage $1 ''$2 $3''">');
                                                                                                                                                    rptContents=regexprep(rptContents,'<br/>_________________________________________________________________________________________<br/><br/> <b>Check Exclusions Rules</b><br/>','');
                                                                                                                                                    rptContents=regexprep(rptContents,'<H5>Check Exclusions Rules</H5>','','ignorecase');


                                                                                                                                                    rptContents=regexprep(rptContents,'<p([^<>]*?) align="([^<>]*?)"','<p$1');
                                                                                                                                                    rptContents=regexprep(rptContents,'<p([^<>]*?) style="text-align:right"','<p$1>');
                                                                                                                                                    rptContents=regexprep(rptContents,'<p([^<>]*?) style="text-align:center"','<p$1>');
                                                                                                                                                    rptContents=regexprep(rptContents,'<p([^<>]*?)style="([^<>"]*?)text-align:center','<p$1style="$2>');
                                                                                                                                                    rptContents=regexprep(rptContents,'<p([^<>]*?)style="([^<>"]*?)text-align:right','<p$1style="$2>');






                                                                                                                                                    rptContents=regexprep(rptContents,'<span name = "EmbedImages" id="EmbedImages"></span>','');


                                                                                                                                                    rptContents=regexprep(rptContents,'<th([^<>]*?)>','<td$1>');
                                                                                                                                                    rptContents=regexprep(rptContents,'</th>','</td>');


                                                                                                                                                    rptContents=regexprep(rptContents,'<td([^<>]+?) valign="(top|middle|bottom)"','<td$1');


                                                                                                                                                    rptContents=regexprep(rptContents,['<(ul|ol|table)([^<>]*) ',...
                                                                                                                                                    'id="([a-zA-Z0-9-]{36})"([^<>]*) dataCollapse="(off|on)"([^<>]*?)( style="margin-top:0pt;margin-bottom:0pt;"|)'],...
                                                                                                                                                    '<$1$2$4$6');
                                                                                                                                                    rptContents=regexprep(rptContents,' class="SystemdefinedCollapse"','');
                                                                                                                                                    rptContents=regexprep(rptContents,'class="([^<>"]+) SystemdefinedCollapse"','class="$1"');
                                                                                                                                                    rptContents=regexprep(rptContents,'class="SystemdefinedCollapse ([^<>"]+)"','class="$1"');
                                                                                                                                                    rptContents=regexprep(rptContents,'class="([^<>"]+) SystemdefinedCollapse([^<>"]+)"','class="$1$2"');
                                                                                                                                                    rptContents=regexprep(rptContents,'<span([^<>]*) class="SDCollapseControl"([^<>]*)>([^<>]+?)</span>([\s]*)<(br /|br)>','');


                                                                                                                                                    rptContents=regexprep(rptContents,'<span onclick="collapseAll([^>]+?)>([\s]*)<img([^>]+?)>([\s]*)</span>([\s]?)','');
                                                                                                                                                    rptContents=regexprep(rptContents,'<div([^<>]*) id="([a-zA-Z0-9-]{36})"([^<>]*) class="AllCollapse"([^>]+?)>','<div$1 id="UUID"$3 class="AllCollapse"$4>');
                                                                                                                                                    rptContents=regexprep(rptContents,'<div([^<>]*?) id="([a-zA-Z0-9-]{36})" style="display:(''''|none);(margin-left:18px;|)"','<div$1 id="UUID2"');
                                                                                                                                                    rptContents=regexprep(rptContents,'<(p|table)([^<>]*?) style="margin-top:0; margin-bottom:0;( margin-left:18px;|)"','<$1$2');


                                                                                                                                                    rptContents=regexprep(rptContents,'<table([^<>]*) class="(AdvTableNoBorder|AdvTable)"','<table$1');
                                                                                                                                                    rptContents=regexprep(rptContents,'<table([^<>]*) class="([^<>"]+) (AdvTableNoBorder|AdvTable)"','<table$1 class="$2"');
                                                                                                                                                    rptContents=regexprep(rptContents,'<table([^<>]*) class="(AdvTableNoBorder|AdvTable) ([^<>"]+)"','<table$1 class="$2"');
                                                                                                                                                    rptContents=regexprep(rptContents,'<table([^<>]*) class="([^<>"]+) (AdvTableNoBorder|AdvTable)([^<>"]+)"','<table$1 class="$2$4"');
                                                                                                                                                    rptContents=regexprep(rptContents,'<td([^<>]*) class="AdvTableColHeading"','<td$1');



                                                                                                                                                    rptContents=regexprep(rptContents,'(<br>(\n)?){2,}','<br>');


                                                                                                                                                    rptContents=regexprep(rptContents,'transition((#\w+\))','transition');


                                                                                                                                                    rptContents=regexprep(rptContents,' title="([^"]+?)"','');


                                                                                                                                                    rptContents=strtrim(rptContents);


                                                                                                                                                    [i,j]=regexp(rptContents,' at [0-9]+','once');
                                                                                                                                                    if~isempty(i)
                                                                                                                                                        rptContents(i:j)=[];
                                                                                                                                                    end


                                                                                                                                                    function out=loc_MakeTagCompatible(rptContents)

                                                                                                                                                        out=regexprep(rptContents,'<hr />','<hr>','preservecase');
                                                                                                                                                        out=regexprep(out,'<br />','<br>','preservecase');
                                                                                                                                                        out=regexprep(out,'<p />','<p>','preservecase');
                                                                                                                                                        out=regexprep(out,'<td (\w+)=(\w+)>','<td $1="$2">','preservecase');

                                                                                                                                                        out=strrep(out,'&#160;','&nbsp;');
                                                                                                                                                        out=regexprep(out,'</li>','','preservecase');


                                                                                                                                                        function JSFct=loc_getJSFunctionCodeCollapse(~)
                                                                                                                                                            try
                                                                                                                                                                am=Advisor.Manager.getInstance;
                                                                                                                                                                JSFct=fileread([am.cmdRoot,filesep,'private',filesep,'AdvisorCollapsible.js']);

                                                                                                                                                                JSFct=regexprep(JSFct,'***less***',DAStudio.message('Advisor:engine:CollapseLess'));
                                                                                                                                                                JSFct=regexprep(JSFct,'***more***',DAStudio.message('Advisor:engine:CollapseMore'));
                                                                                                                                                                JSFct=regexprep(JSFct,'***items***',DAStudio.message('Advisor:engine:CollapseItems'));
                                                                                                                                                                JSFct=regexprep(JSFct,'***rows***',DAStudio.message('Advisor:engine:CollapseRows'));
                                                                                                                                                                JSFct=regexprep(JSFct,'***ControlPanelCheckDetailsCollapse***',DAStudio.message('ModelAdvisor:engine:ControlPanelCheckDetailsCollapse'));
                                                                                                                                                                JSFct=regexprep(JSFct,'***ControlPanelCheckDetailsExpand***',DAStudio.message('ModelAdvisor:engine:ControlPanelCheckDetailsExpand'));
                                                                                                                                                            catch
                                                                                                                                                                JSFct='';
                                                                                                                                                            end

                                                                                                                                                            function JSFct=loc_getReportJS()
                                                                                                                                                                try
                                                                                                                                                                    JSFct=fileread([matlabroot,filesep,'toolbox',filesep,'simulink',filesep,...
                                                                                                                                                                    'simulink',filesep,'modeladvisor',filesep,'private',filesep,'Advisortranslate.js']);

                                                                                                                                                                    JSFct=regexprep(JSFct,'***Keywords***',DAStudio.message('ModelAdvisor:engine:ControlPanelSearch'));
                                                                                                                                                                catch
                                                                                                                                                                    JSFct='';
                                                                                                                                                                end



                                                                                                                                                                function css=loc_getModelAdvisorCSS(fileName)

                                                                                                                                                                    try
                                                                                                                                                                        css=fileread([matlabroot,filesep,'toolbox',filesep,'simulink',filesep,...
                                                                                                                                                                        'simulink',filesep,'modeladvisor',filesep,'private',filesep,fileName]);
                                                                                                                                                                    catch
                                                                                                                                                                        css='';
                                                                                                                                                                    end


                                                                                                                                                                    function loc_viewChangeCB(s,~)
                                                                                                                                                                        loc_viewChange(s.getCurrentText);

                                                                                                                                                                        function loc_viewChange(filter)

                                                                                                                                                                            mdladvObj=Simulink.ModelAdvisor.getActiveModelAdvisorObj;
                                                                                                                                                                            origDirty=mdladvObj.ConfigUIDirty;
                                                                                                                                                                            maGUI=mdladvObj.MAExplorer;
                                                                                                                                                                            maceGUI=mdladvObj.ConfigUIWindow;
                                                                                                                                                                            if isa(maceGUI,'DAStudio.Explorer')
                                                                                                                                                                                MAMode=false;
                                                                                                                                                                                me=maceGUI;
                                                                                                                                                                            else
                                                                                                                                                                                MAMode=true;
                                                                                                                                                                                me=maGUI;
                                                                                                                                                                            end

                                                                                                                                                                            rootNodeObj=Advisor.Utils.convertMCOS(me.getRoot);


                                                                                                                                                                            newMode=~strcmp(filter,DAStudio.message('ModelAdvisor:engine:FullView'));
                                                                                                                                                                            if newMode==mdladvObj.EdittimeViewMode
                                                                                                                                                                                return
                                                                                                                                                                            end


                                                                                                                                                                            if strcmp(filter,DAStudio.message('ModelAdvisor:engine:FullView'))
                                                                                                                                                                                mdladvObj.EdittimeViewMode=false;
                                                                                                                                                                                for i=1:length(mdladvObj.ConfigUICellarray)
                                                                                                                                                                                    mdladvObj.ConfigUICellarray{i}.Visible=mdladvObj.atticdata.FullViewVisibility(i);
                                                                                                                                                                                end
                                                                                                                                                                            else
                                                                                                                                                                                mdladvObj.atticdata.FullViewModeChildrenList={};
                                                                                                                                                                                [foundObjs,parentGroup,toplevelChildren]=find_edittime_checks(mdladvObj,MAMode);
                                                                                                                                                                                [foundObjs,~,~]=prioritizeEditTimeTasks(foundObjs,parentGroup,toplevelChildren,mdladvObj);
                                                                                                                                                                                FullViewVisibility=false(1,length(mdladvObj.ConfigUICellarray));
                                                                                                                                                                                fastRef=mdladvObj.ConfigUICellarray;
                                                                                                                                                                                for i=1:length(fastRef)
                                                                                                                                                                                    FullViewVisibility(i)=fastRef{i}.Visible;
                                                                                                                                                                                    fastRef{i}.Visible=false;
                                                                                                                                                                                end
                                                                                                                                                                                mdladvObj.atticdata.FullViewVisibility=FullViewVisibility;
                                                                                                                                                                                foundObjsFlatList={};
                                                                                                                                                                                for i=1:length(foundObjs)
                                                                                                                                                                                    foundObjsFlatList=[foundObjsFlatList,foundObjs{i}{:}];
                                                                                                                                                                                end
                                                                                                                                                                                for i=1:length(foundObjsFlatList)
                                                                                                                                                                                    setVisibility(foundObjsFlatList(i));
                                                                                                                                                                                end
                                                                                                                                                                                mdladvObj.EdittimeViewMode=true;
                                                                                                                                                                            end

                                                                                                                                                                            if~isempty(rootNodeObj.ChildrenObj)
                                                                                                                                                                                rootNodeObj.ChildrenObj=rootNodeObj.ChildrenObj(~cellfun('isempty',rootNodeObj.ChildrenObj));
                                                                                                                                                                            end

                                                                                                                                                                            mdladvObj.ConfigUIDirty=origDirty;
                                                                                                                                                                            ed=DAStudio.EventDispatcher;
                                                                                                                                                                            ed.broadcastEvent('HierarchyChangedEvent',rootNodeObj);
                                                                                                                                                                            ed.broadcastEvent('PropertyChangedEvent',rootNodeObj);

                                                                                                                                                                            modeladvisorprivate('modeladvisorutil2','UpdateConfigUIMenuToolbar',me);

                                                                                                                                                                            function setVisibility(node)
                                                                                                                                                                                node.Visible=true;
                                                                                                                                                                                while~isempty(node.getParent)
                                                                                                                                                                                    node=node.getParent;
                                                                                                                                                                                    setVisibility(node);
                                                                                                                                                                                end

                                                                                                                                                                                function[foundObjs,parentGroup,toplevelChildren]=find_edittime_checks(maobj,MAMode)

                                                                                                                                                                                    edittime_checklist=edittime_checks(maobj);

                                                                                                                                                                                    foundObjs={};
                                                                                                                                                                                    parentGroup={};
                                                                                                                                                                                    toplevelChildren={};
                                                                                                                                                                                    if MAMode
                                                                                                                                                                                        for i=1:length(maobj.TaskAdvisorCellArray)
                                                                                                                                                                                            if isa(maobj.TaskAdvisorCellArray{i},'ModelAdvisor.Task')
                                                                                                                                                                                                idMatching=maobj.TaskAdvisorCellArray{i}.Check.ID;
                                                                                                                                                                                                if~isempty(ModelAdvisor.convertCheckID(idMatching))
                                                                                                                                                                                                    idMatching=ModelAdvisor.convertCheckID(idMatching);
                                                                                                                                                                                                end
                                                                                                                                                                                                if ismember(idMatching,edittime_checklist)
                                                                                                                                                                                                    foundObj=maobj.TaskAdvisorCellArray{i};
                                                                                                                                                                                                    parentObj=[];
                                                                                                                                                                                                    grandParentObj=foundObj.getParent;
                                                                                                                                                                                                    while~strcmp(maobj.TaskAdvisorRoot.ID,grandParentObj.ID)
                                                                                                                                                                                                        parentObj=grandParentObj;
                                                                                                                                                                                                        grandParentObj=grandParentObj.getParent;
                                                                                                                                                                                                    end
                                                                                                                                                                                                    if~isempty(parentObj)
                                                                                                                                                                                                        groupIndex=length(parentGroup)+1;
                                                                                                                                                                                                        for j=1:length(parentGroup)
                                                                                                                                                                                                            if strcmp(parentGroup{j}.ID,parentObj.ID)
                                                                                                                                                                                                                groupIndex=j;
                                                                                                                                                                                                            end
                                                                                                                                                                                                        end
                                                                                                                                                                                                        if length(foundObjs)<groupIndex
                                                                                                                                                                                                            foundObjs{groupIndex}{1}=foundObj;
                                                                                                                                                                                                        else
                                                                                                                                                                                                            foundObjs{groupIndex}{end+1}=foundObj;
                                                                                                                                                                                                        end
                                                                                                                                                                                                        if groupIndex>length(parentGroup)
                                                                                                                                                                                                            parentGroup{end+1}=parentObj;
                                                                                                                                                                                                            toplevelChildren{end+1}=parentObj.ID;
                                                                                                                                                                                                        end
                                                                                                                                                                                                    end
                                                                                                                                                                                                end
                                                                                                                                                                                            end
                                                                                                                                                                                        end
                                                                                                                                                                                    else
                                                                                                                                                                                        if~isempty(maobj.ConfigUICellArray)
                                                                                                                                                                                            configUIisStruct=isstruct(maobj.ConfigUICellArray{1});
                                                                                                                                                                                        else
                                                                                                                                                                                            configUIisStruct=false;
                                                                                                                                                                                        end
                                                                                                                                                                                        for i=1:length(maobj.ConfigUICellArray)
                                                                                                                                                                                            idMatching=maobj.ConfigUICellArray{i}.MAC;
                                                                                                                                                                                            if~isempty(ModelAdvisor.convertCheckID(idMatching))
                                                                                                                                                                                                idMatching=ModelAdvisor.convertCheckID(idMatching);
                                                                                                                                                                                                maobj.ConfigUICellArray{i}.MAC=idMatching;
                                                                                                                                                                                            end
                                                                                                                                                                                            if~isempty(idMatching)&&ismember(idMatching,edittime_checklist)
                                                                                                                                                                                                foundObj=maobj.ConfigUICellArray{i};
                                                                                                                                                                                                parentObj=[];
                                                                                                                                                                                                if configUIisStruct
                                                                                                                                                                                                    grandParentObj=foundObj.ParentObj;
                                                                                                                                                                                                else
                                                                                                                                                                                                    grandParentObj=foundObj.getParent;
                                                                                                                                                                                                end
                                                                                                                                                                                                if isempty(grandParentObj)
                                                                                                                                                                                                    continue;
                                                                                                                                                                                                end
                                                                                                                                                                                                while(~isempty(grandParentObj)&&~strcmp(maobj.ConfigUIRoot.ID,grandParentObj.ID))
                                                                                                                                                                                                    parentObj=grandParentObj;
                                                                                                                                                                                                    if configUIisStruct
                                                                                                                                                                                                        grandParentObj=grandParentObj.ParentObj;
                                                                                                                                                                                                    else
                                                                                                                                                                                                        grandParentObj=grandParentObj.getParent;
                                                                                                                                                                                                    end
                                                                                                                                                                                                end


                                                                                                                                                                                                if isempty(parentObj)
                                                                                                                                                                                                    parentObj=foundObj;
                                                                                                                                                                                                end
                                                                                                                                                                                                groupIndex=length(parentGroup)+1;
                                                                                                                                                                                                for j=1:length(parentGroup)
                                                                                                                                                                                                    if strcmp(parentGroup{j}.ID,parentObj.ID)
                                                                                                                                                                                                        groupIndex=j;
                                                                                                                                                                                                    end
                                                                                                                                                                                                end
                                                                                                                                                                                                if length(foundObjs)<groupIndex
                                                                                                                                                                                                    foundObjs{groupIndex}{1}=foundObj;
                                                                                                                                                                                                else
                                                                                                                                                                                                    foundObjs{groupIndex}{end+1}=foundObj;
                                                                                                                                                                                                end
                                                                                                                                                                                                if groupIndex>length(parentGroup)
                                                                                                                                                                                                    parentGroup{end+1}=parentObj;
                                                                                                                                                                                                    toplevelChildren{end+1}=parentObj.ID;
                                                                                                                                                                                                end
                                                                                                                                                                                            end
                                                                                                                                                                                        end
                                                                                                                                                                                    end

                                                                                                                                                                                    function[foundObjs,parentGroup,toplevelChildren]=prioritizeEditTimeTasks(foundObjs,parentGroup,toplevelChildren,mdladvObj)


                                                                                                                                                                                        numTopCustomFolders=0;
                                                                                                                                                                                        customFoldersIndex=[];
                                                                                                                                                                                        customFolderFound=false;
                                                                                                                                                                                        byTaskFound=false;
                                                                                                                                                                                        for i=1:length(toplevelChildren)
                                                                                                                                                                                            if(strcmp(toplevelChildren{i},'_SYSTEM_By Task'))
                                                                                                                                                                                                byTaskFound=true;
                                                                                                                                                                                            end
                                                                                                                                                                                            if(~strcmp(toplevelChildren{i},'_SYSTEM_By Task')&&...
                                                                                                                                                                                                ~strcmp(toplevelChildren{i},'_SYSTEM_By Product')&&...
                                                                                                                                                                                                ~strcmp(toplevelChildren{i},'com.mathworks.cgo.group'))
                                                                                                                                                                                                customFolderFound=true;
                                                                                                                                                                                                numTopCustomFolders=numTopCustomFolders+1;
                                                                                                                                                                                                customFoldersIndex=[customFoldersIndex,i];
                                                                                                                                                                                            end
                                                                                                                                                                                        end

                                                                                                                                                                                        clearIdx=[];

                                                                                                                                                                                        remainingChecks=edittime_checks(mdladvObj);
                                                                                                                                                                                        for i=1:length(customFoldersIndex)
                                                                                                                                                                                            if isempty(remainingChecks)
                                                                                                                                                                                                clearIdx=[clearIdx,customFoldersIndex(i)];
                                                                                                                                                                                            end
                                                                                                                                                                                            checksInFolder=cellfun(@(x)getfield(x,'MAC'),foundObjs{customFoldersIndex(i)},'UniformOutput',false);
                                                                                                                                                                                            remainingChecks=setdiff(remainingChecks,checksInFolder);
                                                                                                                                                                                        end

                                                                                                                                                                                        if(byTaskFound)
                                                                                                                                                                                            for j=1:length(toplevelChildren)
                                                                                                                                                                                                if(strcmp(toplevelChildren{j},'_SYSTEM_By Task'))
                                                                                                                                                                                                    if isempty(remainingChecks)
                                                                                                                                                                                                        clearIdx=[clearIdx,j];
                                                                                                                                                                                                    else
                                                                                                                                                                                                        checksInFolder=cellfun(@(x)getfield(x,'MAC'),foundObjs{j},'UniformOutput',false);

                                                                                                                                                                                                        [~,foundChecksIdx]=intersect(checksInFolder,remainingChecks);
                                                                                                                                                                                                        foundObjs{j}=foundObjs{j}(foundChecksIdx);

                                                                                                                                                                                                        remainingChecks=setdiff(remainingChecks,checksInFolder);
                                                                                                                                                                                                    end
                                                                                                                                                                                                end
                                                                                                                                                                                            end
                                                                                                                                                                                        end

                                                                                                                                                                                        for j=1:length(toplevelChildren)
                                                                                                                                                                                            if(strcmp(toplevelChildren{j},'_SYSTEM_By Product'))
                                                                                                                                                                                                if isempty(remainingChecks)
                                                                                                                                                                                                    clearIdx=[clearIdx,j];
                                                                                                                                                                                                else
                                                                                                                                                                                                    checksInFolder=cellfun(@(x)getfield(x,'MAC'),foundObjs{j},'UniformOutput',false);
                                                                                                                                                                                                    [~,foundChecksIdx]=intersect(checksInFolder,remainingChecks);
                                                                                                                                                                                                    foundObjs{j}=foundObjs{j}(foundChecksIdx);
                                                                                                                                                                                                    remainingChecks=setdiff(remainingChecks,checksInFolder);
                                                                                                                                                                                                end
                                                                                                                                                                                            end
                                                                                                                                                                                        end

                                                                                                                                                                                        if~isempty(clearIdx)
                                                                                                                                                                                            f=foundObjs;
                                                                                                                                                                                            t=toplevelChildren;
                                                                                                                                                                                            p=parentGroup;
                                                                                                                                                                                            foundObjs={};toplevelChildren={};parentGroup={};
                                                                                                                                                                                            clearIdx=unique(clearIdx);
                                                                                                                                                                                            for kk=1:length(clearIdx)
                                                                                                                                                                                                f{clearIdx(kk)}=[];t{clearIdx(kk)}=[];p{clearIdx(kk)}=[];
                                                                                                                                                                                            end

                                                                                                                                                                                            for i=1:length(f)
                                                                                                                                                                                                if~isempty(f{i})
                                                                                                                                                                                                    foundObjs{end+1}=f{i};
                                                                                                                                                                                                end
                                                                                                                                                                                                if~isempty(p{i})
                                                                                                                                                                                                    parentGroup{end+1}=p{i};
                                                                                                                                                                                                end
                                                                                                                                                                                                if~isempty(t{i})
                                                                                                                                                                                                    toplevelChildren{end+1}=t{i};
                                                                                                                                                                                                end
                                                                                                                                                                                            end
                                                                                                                                                                                        end

                                                                                                                                                                                        function edittime_checklist=edittime_checks(maobj)
                                                                                                                                                                                            edittime_checklist={};
                                                                                                                                                                                            t=maobj.CheckCellArray;
                                                                                                                                                                                            for i=1:length(t)
                                                                                                                                                                                                if(maobj.CheckCellArray{i}.SupportsEditTime)
                                                                                                                                                                                                    edittime_checklist{end+1}=maobj.CheckCellArray{i}.ID;
                                                                                                                                                                                                end
                                                                                                                                                                                            end

                                                                                                                                                                                            function yes=loc_InMixProcedureGroupCase(node)
                                                                                                                                                                                                yes=false;
                                                                                                                                                                                                if isa(node,'ModelAdvisor.Procedure')
                                                                                                                                                                                                    encounterGroup=0;
                                                                                                                                                                                                    encounterProcedure=0;
                                                                                                                                                                                                    i=0;
                                                                                                                                                                                                    while~isempty(node.getParent)
                                                                                                                                                                                                        i=i+1;
                                                                                                                                                                                                        if isa(node.getParent,'ModelAdvisor.Procedure')&&(encounterProcedure==0)
                                                                                                                                                                                                            encounterProcedure=i;
                                                                                                                                                                                                        elseif isa(node.getParent,'ModelAdvisor.Group')&&(encounterGroup==0)
                                                                                                                                                                                                            encounterGroup=i;
                                                                                                                                                                                                        end
                                                                                                                                                                                                        node=node.getParent;
                                                                                                                                                                                                    end
                                                                                                                                                                                                    if(encounterProcedure>encounterGroup)&&(encounterGroup>0)
                                                                                                                                                                                                        yes=true;
                                                                                                                                                                                                    end
                                                                                                                                                                                                end























































