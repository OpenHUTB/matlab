function[visible,enabled,subMenu]=configSetDaexplrMenus(arg,varargin)




    persistent cbInfo
    persistent dialogSchemas
    persistent lastSubMenu

    if~isempty(varargin)&&length(varargin)>1
        visible=1;
        enabled=1;
        subMenu=1;
        method=varargin{2};
    else
        if ischar(arg)
            method=arg;
        else
            mdlexplrudd=arg;
            method='create';
        end
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
        if explrHasMultSelection(mdlexplrudd)
            visible=false;
            enabled=false;
            dialogSchemas=cell(0);
            cbInfo=[];
        else
            [visible,enabled,dialogSchemas,cbInfo]=create_menugroup(obj);
        end

        if~isempty(dialogSchemas)
            subMenu=create_submenu(mdlexplrudd,dialogSchemas);
            lastSubMenu=subMenu;
        end

    case 'callback'
        idx=varargin{1};
        invoke_callback(idx,cbInfo,dialogSchemas);

    case 'MEConfigSetRef'
        dialogD=Simulink.ConfigSetME;
        dialogD.node=slprivate('getSelectedModelFromDAExplorer');
        DAStudio.Dialog(dialogD,'addCSRefOnly','DLG_STANDALONE');

    otherwise
        error('Unexpected method');
    end


    function out=explrHasMultSelection(mdlexplrudd)
        out=length(getListSelection(mdlexplrudd))>1;

        function[visible,enabled,dialogSchemas,cbInfo]=create_menugroup(obj)
            if isa(obj,'DAStudio.WSOAdapter')
                obj=-1;
            end

            if ishandle(obj)&&isa(obj,'Simulink.BlockDiagram')&&~obj.isLibrary
                cbInfo=create_callback_info(obj,true);
                schemaGen=configset.internal.dastudio.generateSchema(cbInfo);
                dialogSchemas=getSchemas(schemaGen,obj);
                visible=true;
                enabled=true;
            else
                cbInfo=[];
                dialogSchemas=cell(0);
                visible=false;
                enabled=false;
            end


            function subMenu=create_submenu(mdlexplrudd,dialogSchemas)
                am=DAStudio.ActionManager;
                subMenu=am.createPopupMenu(mdlexplrudd);

                for idx=1:length(dialogSchemas)
                    if(~isequal(dialogSchemas{idx},'separator'))

                        callback=sprintf('configset.internal.dastudio.configSetDaexplrMenus(''callback'',%d);',idx);
                        action=am.createAction(mdlexplrudd,...
                        'Text',dialogSchemas{idx}.label,...
                        'Callback',callback,...
                        'Tag',dialogSchemas{idx}.tag);

                        action.enabled=dialogSchemas{idx}.userdata.enabled;
                        action.visible=dialogSchemas{idx}.userdata.visible;

                        subMenu.addMenuItem(action);

                        if(idx<length(dialogSchemas)&&isequal(dialogSchemas{idx+1},'separator'))
                            subMenu.addSeparator;
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


                    function dialogSchemas=getSchemas(handles,selectedUdi)
                        dialogSchemas=cell(length(handles),1);
                        for i=1:length(handles)

                            handle=handles{i};
                            if(iscell(handle))
                                cbInfo=create_callback_info(selectedUdi,handle{2});
                                funhandle=handle{1};
                                dialogSchemas{i}=funhandle(cbInfo);
                            else
                                if(isequal(handle,'separator'))
                                    dialogSchemas{i}='separator';
                                else
                                    cbInfo=create_callback_info(selectedUdi);
                                    dialogSchemas{i}=handle(cbInfo);
                                end
                            end
                        end


                        function invoke_callback(idx,cbInfo,dialogSchemas)

                            if idx>0&&idx<=length(dialogSchemas)
                                if(~isequal(dialogSchemas{idx},'separator'))
                                    schema=dialogSchemas{idx};

                                    cbInfo.userdata=schema.userdata;
                                    funhandle=schema.callback;
                                    funhandle(cbInfo);
                                end
                            end
