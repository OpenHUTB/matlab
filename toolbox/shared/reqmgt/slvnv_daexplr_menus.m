function[visible,enabled,subMenu]=slvnv_daexplr_menus(method,varargin)



    persistent CbInfo
    persistent schemas
    persistent lastSubMenu

    if~ischar(method)
        mdlexplrudd=method;
        method='create';
    end

    switch(method)
    case 'create'

        if~isempty(lastSubMenu)
            try
                delete(lastSubMenu.getChildren);
                lastSubMenu.delete;
            catch Mex %#ok<NASGU>
            end
        end

        obj=varargin{1};
        subMenu=[];
        if explrHasMultSelect(mdlexplrudd)
            visible=false;
            enabled=false;
            schemas=cell(0);
            CbInfo=[];
        else
            [visible,enabled,schemas,CbInfo]=create(obj);
        end

        if~isempty(schemas)
            subMenu=create_submenu(mdlexplrudd,schemas);
            lastSubMenu=subMenu;
        end

    case 'callback'
        idx=varargin{1};
        invoke_callback(idx,CbInfo,schemas);

    otherwise
        error('Unexpected method');
    end
end

function out=explrHasMultSelect(mdlexplrudd)
    imme=DAStudio.imExplorer(mdlexplrudd);
    selList=imme.getSelectedListNodes();
    out=(length(selList)>1);
end

function[visible,enabled,schemas,CbInfo]=create(obj)
    isSimulinkObject=true;
    if isa(obj,'DAStudio.WSOAdapter')

        [visible,enabled,schemas,CbInfo]=hiddenSchema();
        return;
    elseif isa(obj,'Simulink.DDEAdapter')



        [~,~,ext]=fileparts(obj.getDialogSource.getPropValue('DataSource'));
        if strcmp(ext,'.sldd')

            isSimulinkObject=false;
        else

            [visible,enabled,schemas,CbInfo]=hiddenSchema();
            return;
        end
    end

    if ishandle(obj)
        if~isSimulinkObject

            [visible,enabled,schemas,CbInfo]=visibleRmiSchema(obj);
        elseif obj.rmiIsSupported


            parentMdl=getParentMdlName(obj);
            if~isempty(parentMdl)&&rmisl.isComponentHarness(parentMdl)
                [obj,isEnabled]=getHarnessObjMenuState(parentMdl,obj);
                if~isEnabled
                    [visible,enabled,schemas,CbInfo]=hiddenSchema();
                    return;
                end
            end
            [visible,enabled,schemas,CbInfo]=visibleRmiSchema(obj,parentMdl);
        else
            [visible,enabled,schemas,CbInfo]=hiddenSchema();
        end
    else
        [visible,enabled,schemas,CbInfo]=hiddenSchema();
    end
end

function[visible,enabled,schemas,CbInfo]=visibleRmiSchema(obj,mdlName)
    [rmiInstalled,rmiLicenseAvailable]=rmi.isInstalled();
    if(rmiInstalled&&rmiLicenseAvailable)||~isempty(rmi.getReqs(obj))
        CbInfo=create_callback_info(obj,true);
        try
            if nargin>1
                CbInfo.model=get_param(mdlName,'Object');
            end
            schemaGen=rmisl.menus_rmi_object(CbInfo);
        catch ex
            if strcmp(ex.identifier,'SLDD:sldd:DuplicateSymbol')
                errCbInfo=create_callback_info(obj,{ex.message,ex.cause});
                schemaGen=rmide.explrMenuLabelConflict(errCbInfo);
            else

                warning('slvnv_daexplr_menus: %s',getString(message('Slvnv:rmide:RmiMenuFailure',ex.message)));
                [visible,enabled,schemas,CbInfo]=hiddenSchema();
                return;
            end
        end
        schemas=getSchemas(schemaGen,obj);
        visible=true;
        enabled=true;
    else
        [visible,enabled,schemas,CbInfo]=hiddenSchema();
    end
end

function[remappedObj,isEnabled]=getHarnessObjMenuState(model,obj)
    remappedObj=obj;
    isEnabled=true;

    systemBD=Simulink.harness.internal.getHarnessOwnerBD(model);
    if~Simulink.harness.internal.isReqLinkingSupportedForExtHarness(systemBD)
        isEnabled=false;
        return;
    end

    if~isempty(which('Simulink.harness.internal.sidmap.isHarnessAutoGenBlock'))...
        &&Simulink.harness.internal.sidmap.isHarnessAutoGenBlock(model,obj)
        isEnabled=false;
        return;
    end

    if Simulink.harness.internal.sidmap.isObjectOwnedByCUT(obj)
        try
            remappedObj=rmisl.harnessToModelRemap(obj);
        catch Mex
            if strcmp(Mex.identifier,'Simulink:utility:invalidSID')

                isEnabled=false;
                return;
            else
                rethrow(Mex);
            end
        end
    end
end

function[visible,enabled,schemas,CbInfo]=hiddenSchema()
    CbInfo=[];
    schemas=cell(0);
    visible=false;
    enabled=false;
end

function subMenu=create_submenu(mdlexplrudd,schemas)

    am=DAStudio.ActionManager;
    subMenu=am.createPopupMenu(mdlexplrudd);

    for idx=1:length(schemas)
        if~isequal(schemas{idx},'separator')

            if strcmpi(schemas{idx}.state,'Enabled')
                onOrOff='on';
            else
                onOrOff='off';
            end

            callback=sprintf('slvnv_daexplr_menus(''callback'',%d);',idx);
            action=am.createAction(mdlexplrudd,'Text',schemas{idx}.label,...
            'Callback',callback,...
            'Tag',schemas{idx}.tag,...
            'Enabled',onOrOff);
            subMenu.addMenuItem(action);

            if idx<length(schemas)&&isequal(schemas{idx+1},'separator')
                subMenu.addSeparator;
            end
        end
    end
end

function cbInfo=create_callback_info(selectedUdi,varargin)
    cbInfo=DAStudio.CallbackInfo;
    cbInfo.uiObject=selectedUdi;
    if(~isempty(varargin))
        cbInfo.userdata=varargin{1};
    else
        cbInfo.userdata=true;
    end
end

function schemas=getSchemas(handles,selectedUdi)
    schemas=cell(length(handles),1);
    for i=1:length(handles)

        handle=handles{i};
        if(iscell(handle))
            cbInfo=create_callback_info(selectedUdi,handle{2});
            funhandle=handle{1};
            schemas{i}=funhandle(cbInfo);
        else
            if(isequal(handle,'separator'))
                schemas{i}='separator';
            else
                cbInfo=create_callback_info(selectedUdi);
                schemas{i}=handle(cbInfo);
            end
        end
    end
end

function invoke_callback(idx,cbInfo,schemas)

    if idx>0&&idx<=length(schemas)
        if(~isequal(schemas{idx},'separator'))
            schema=schemas{idx};

            cbInfo.userdata=schema.userdata;
            funhandle=schema.callback;
            funhandle(cbInfo);
        end
    end
end

function parentMdl=getParentMdlName(obj)


    try
        parentMdl=strtok(obj.Path,'/');
    catch ex %#ok<NASGU>
        try
            parentMdl=strtok(obj.Parent,'/');
            if isempty(parentMdl)
                parentMdl=obj.Name;
            end
        catch ex %#ok<NASGU>
            parentMdl='';
        end
    end
end


