function varargout=menus_selection_links(obj)



    persistent AllSchemas initialized ReqEditorSchema reqEditorIncluded;
    mlock;

    if isempty(obj)


        initialized=false;
        return;
    end

    if isempty(initialized)||~initialized



        selectionLinkTypes={};


        selectionLinkTypes{end+1}=rmi.linktype_mgr('resolveByRegName','linktype_rmi_matlab');


        selectionLinkTypes{end+1}=rmi.linktype_mgr('resolveByRegName','linktype_rmi_data');


        if~isempty(which('stm.view'))&&~isempty(which('stm.internal.util.getCurrentTestCase'))
            selectionLinkTypes{end+1}=rmi.linktype_mgr('resolveByRegName','linktype_rmi_testmgr');
        end

        if rmism.isSafetyManagerLinkingEnabled()
            selectionLinkTypes{end+1}=rmi.linktype_mgr('resolveByRegName','linktype_rmi_safetymanager');
        end

        enabledIdx=rmi.settings_mgr('get','selectIdx');
        if ispc
            enabledAndSetup=enabledIdx&[true,true,rmi.settings_mgr('get','isDoorsSetup')];
            pcTypes={...
            rmi.linktype_mgr('resolveByRegName','linktype_rmi_word'),...
            rmi.linktype_mgr('resolveByRegName','linktype_rmi_excel'),...
            rmi.linktype_mgr('resolveByRegName','linktype_rmi_doors')};

            enabledPcTypes=pcTypes(enabledAndSetup);
            selectionLinkTypes=[selectionLinkTypes,enabledPcTypes];


        end


        if enabledIdx(3)
            oslcLinkType=rmi.linktype_mgr('resolveByRegName','linktype_rmi_oslc');
            if~isempty(oslcLinkType)
                selectionLinkTypes{end+1}=oslcLinkType;
            end
        end


        AllSchemas={};
        for i=1:length(selectionLinkTypes)
            if isa(selectionLinkTypes{1},'ReqMgr.LinkType')
                AllSchemas{end+1}={@CreateSelectionLinkShortcut,SelectionLinkArgs(selectionLinkTypes{i})};%#ok<AGROW>
            end
        end


        regTargets=rmi.settings_mgr('get','regTargets');
        for i=1:length(regTargets)
            if regTargets{i}(1)=='%'
                continue;
            end
            customType=rmi.linktype_mgr('resolveByRegName',regTargets{i});
            if isempty(customType)
                warning(message('Slvnv:rmiml:FailedToResolveLinktype',regTargets{i}));
                continue;
            end

            if any(strcmp(fieldnames(customType),'SelectionLinkLabel'))&&~isempty(customType.SelectionLinkLabel)
                AllSchemas{end+1}={@CreateSelectionLinkShortcut,SelectionLinkArgs(customType)};%#ok<AGROW>
            end
        end
        initialized=true;
        reqEditorIncluded=false;
    end

    if~isempty(AllSchemas)

        needsReqEditorShortcut=slreq.app.MainManager.hasEditor();
        if needsReqEditorShortcut&&~reqEditorIncluded
            if isempty(ReqEditorSchema)
                slreqType=rmi.linktype_mgr('resolveByRegName','linktype_rmi_slreq');
                ReqEditorSchema={@CreateSelectionLinkShortcut,SelectionLinkArgs(slreqType)};
            end
            AllSchemas=[{ReqEditorSchema},AllSchemas];
            reqEditorIncluded=true;
        elseif reqEditorIncluded&&~needsReqEditorShortcut
            AllSchemas(1)=[];
            reqEditorIncluded=false;
        end

        rmi.currentObj(obj);
        if isa(obj,'Simulink.DDEAdapter')
            varargout{1}=replaceDataWithSimulink(AllSchemas);
        else
            varargout{1}=AllSchemas;
        end

    else
        varargout{1}=cell(0);
    end

end

function result=replaceDataWithSimulink(allSchemas)
    result=cell(size(allSchemas));
    for i=1:length(allSchemas)
        if isempty(strfind(allSchemas{i}{2}{2},'DATA'))
            result{i}=allSchemas{i};
        else
            slLinktype=rmi.linktype_mgr('resolveByRegName','linktype_rmi_simulink');
            result{i}={@CreateSelectionLinkShortcut,SelectionLinkArgs(slLinktype)};
        end
    end
end

function schema=CreateSelectionLinkShortcut(callbackInfo)
    schema=DAStudio.ActionSchema;
    schema.label=callbackInfo.userdata{1};
    schema.tag=callbackInfo.userdata{2};
    schema.userdata=callbackInfo.userdata{3};
    schema.callback=@SelectionLinkCallback;
    schema.autoDisableWhen='Busy';
end

function selectionLinkArgs=SelectionLinkArgs(linktype)


    label=linktype.SelectionLinkLabel;
    tag=rmi.settings_mgr('get','selectTag');
    if isempty(tag)
        selectionLinkArgs{1}=label;
    elseif strncmp(label,'Add link to ',length('Add link to '))
        selectionLinkArgs{1}=[label(1:length('Add ')),'"',tag,'"',label(length('Add '):end)];
    else
        selectionLinkArgs{1}=[label,' (',tag,')'];
    end


    selectionLinkArgs{2}=['Simulink:AddLink',upper(strrep(linktype.Registration,'linktype_rmi_',''))];


    selectionLinkArgs{3}=linktype;
end

function SelectionLinkCallback(callbackInfo)
    make2way=rmi.settings_mgr('get','linkSettings','twoWayLink');
    currentObj=rmi.currentObj();
    objH=rmi.canlink(currentObj);
    if isempty(objH)
        return
    end

    if license_checkout_slvnv()
        domainImpl=callbackInfo.userdata;
        isFile=treatAsFile(domainImpl);
        try
            req=feval(domainImpl.SelectionLinkFcn,objH,make2way);
            if~isempty(req)
                if iscell(req)



                    req=req{1};
                end
                try
                    if isFile


                        slreq.uri.ResourcePathHandler.setInteractive(true);
                    end
                    rmi.catReqs(objH,req);
                    rmiut.hiliteAndFade(objH);
                catch Mex
                    errordlg(Mex.message,...
                    getString(message('Slvnv:reqmgt:linktype_rmi_word:RequirementsFailedToAddLink')));
                end
                if isFile

                    slreq.uri.ResourcePathHandler.setInteractive(false);
                end
            end
        catch Mex
            errordlg(...
            getString(message('Slvnv:reqmgt:linktype_rmi_word:SelectionLinkingFailed',Mex.message)),...
            getString(message('Slvnv:reqmgt:linktype_rmi_word:FailedToAddLink')));
        end
    end
end

function tf=treatAsFile(domainImpl)
    tf=domainImpl.isFile||slreq.utils.isNativeDomain(domainImpl.Registration);
end

function success=license_checkout_slvnv()
    invalid=builtin('_license_checkout','Simulink_Requirements','quiet');
    success=~invalid;
    if invalid
        rmi.licenseErrorDlg();
    end
end


