function rmischemas=menus_rmi_object(callbackInfo)

    [installed,licensed]=rmi.isInstalled();

    isSys=callbackInfo.userdata;
    if(isSys)
        objh=cbUiObject(callbackInfo);
    else
        objh=cbSelection(callbackInfo);
    end
    if(~isSys&&isempty(objh))
        objh=cbUiObject(callbackInfo);
        isSys=true;
    end

    isData=rmide.isDataEntry(objh(1));

    isSysComp=sysarch.isSysArchObject(objh);

    if length(objh)==1&&~isData&&~isSysComp...
        &&rmisl.isComponentHarness(callbackInfo.model.Name)

        if Simulink.harness.internal.sidmap.isObjectOwnedByCUT(objh)
            objh=rmisl.harnessToModelRemap(objh);
        end
    end
    isInSubsystemReference=rmisl.inSubsystemReference(objh);
    refSid='';
    if isa(objh,'Simulink.SubSystem')
        try
            refSid=get_param(objh.Handle,'ReferencedSubsystem');
        catch ex %#ok<NASGU>

        end
    end
    isSusystemReferenceInstanceBlock=~isempty(refSid);

    if isInSubsystemReference||isSusystemReferenceInstanceBlock
        [rmischemas,hasItsOwnLinks]=create_requirement_links_forSSRef(objh);
    else
        [rmischemas,hasItsOwnLinks]=create_requirement_links(objh);
    end

    isStateflow=isStateflowObject(objh);

    isInLibrary=false;

    if isInSubsystemReference||isSusystemReferenceInstanceBlock
        ssRefObj=rmisl.getRefSidFromObjSSRefInstance(objh,'',true);

        ssRefName=strtok(ssRefObj,':');
        linksFromSSRef_schema={@LinksFromSSRef,{ssRefName,ssRefObj}};
        rmischemas=[rmischemas,{linksFromSSRef_schema},'separator'];
    elseif~isData&&~isSysComp&&(~isStateflow||(isa(objh,'Stateflow.AtomicSubchart')&&objh.isLink))

        libObj=[];
        if isStateflow
            libObj=objh.Subchart.Path;
        elseif rmisl.inLibrary(objh)
            isInLibrary=true;

            libObj=objh.ReferenceBlock;

            rmischemas=cell(0);
        elseif isa(objh,'Simulink.SubSystem')

            if strcmp(objh.LinkStatus,'resolved')
                libObj=objh.ReferenceBlock;
            elseif strcmp(objh.LinkStatus,'inactive')
                libObj=objh.AncestorBlock;
            end
        elseif isa(objh,'Simulink.Block')&&~strcmp(objh.LinkStatus,'none')

            if strcmp(objh.LinkStatus,'resolved')
                libObj=objh.ReferenceBlock;
            elseif strcmp(objh.LinkStatus,'inactive')
                libObj=objh.AncestorBlock;
            end
        end
        if~isempty(libObj)
            libName=strtok(libObj,'/');
            linksFromLib_schema={@LinksFromLib,{libName,libObj}};
            rmischemas=[rmischemas,{linksFromLib_schema},'separator'];
        end
    end

    if~isData&&~isSysComp
        modelH=callbackInfo.model.Handle;

        if installed&&licensed&&rmisl.menus_UpdateDataBeforeUse(modelH)
            if isempty(rmischemas)
                rmischemas={@rmisl.menus_UpdateDataBeforeUse};
            else
                rmischemas=[rmischemas,'separator',{@rmisl.menus_UpdateDataBeforeUse}];
            end
            return;
        elseif rmiut.isBuiltinNoRmi(modelH)
            rmischemas={@rmisl.menus_BuildInLib};
            return;
        end
    end

    if isStateflow&&...
        any(strcmp(class(callbackInfo.uiObject),...
        {'Stateflow.Chart','Stateflow.EMChart',...
        'Stateflow.TruthTableChart','Stateflow.StateTransitionTableChart',...
        'Stateflow.ReactiveTestingTableChart'}))...
        &&sf('get',objh.Id,'.isa')==sf('get','default','chart.isa')
        chartBlock=sf('Private','chart2block',callbackInfo.uiObject.Id);

        if isempty(rmischemas)||rmidata.isExternal(modelH)
            objh=get_param(chartBlock,'Object');
            [rmischemas,hasItsOwnLinks]=create_requirement_links(objh);
        elseif licensed
            move_schema={@MoveChartReqs,{objh.Id,chartBlock}};
            rmischemas=[rmischemas,{move_schema}];
            return
        end
    end

    if isStateflow&&any(strcmp(class(objh),{'Stateflow.SLFunction','Stateflow.SimulinkBasedState'}))
        subSys=objh.getDialogProxy();
        if isempty(rmischemas)||rmidata.isExternal(modelH)
            objh=subSys;
            [rmischemas,hasItsOwnLinks]=create_requirement_links(objh);
        elseif licensed
            move_schema={@MoveSLFunctionReqs,{objh.Id,subSys.Handle}};
            rmischemas=[rmischemas,{move_schema}];
            return
        end
    end

    if licensed&&installed&&(~isInLibrary&&~isInSubsystemReference)&&~rmisl.is_signal_builder_block(objh)
        sLinkMenus=rmi.menus_selection_links(objh);
        if~rmiut.isMeOpen()||...
            isa(callbackInfo,'DAStudio.CallbackInfo')
            sLinkMenus=skipDataLink(sLinkMenus);
        end
        if rmifa.isFaultLinkingEnabled()&&isData&&rmiut.isFaultTableOpen(objh)
            sLinkMenus=[sLinkMenus,{@LinkToFaultTable}];
        end
        if~isempty(sLinkMenus)
            rmischemas=[rmischemas,sLinkMenus,'separator'];
        end
        if~isData&&~rmisl.isLibObject(objh)
            rmischemas=[rmischemas,intraLinkMenus(objh),'separator'];
        end
    end

    if isSys
        if hasItsOwnLinks&&licensed&&installed&&~isInLibrary&&~isInSubsystemReference
            rmischemas=[rmischemas,{@EditAddSys,@DeleteAllSys},'separator'];
        else
            rmischemas=[rmischemas,{@EditAddSys},'separator'];
        end
    else
        if hasItsOwnLinks&&licensed&&installed&&~isInLibrary&&~isInSubsystemReference
            rmischemas=[rmischemas,{@EditAddBlk,@DeleteAllBlk},'separator'];
        else
            rmischemas=[rmischemas,{@EditAddBlk},'separator'];
        end
    end

    if licensed&&installed
        if isSys
            rmischemas=[rmischemas,{{@CopyUrlToClipboardSys,{objh,isData}}},'separator'];
        else
            rmischemas=[rmischemas,{{@CopyUrlToClipboardBlk,{objh,isData}}},'separator'];
        end

        if isData&&rmide.dictHasChanges(objh)
            rmischemas=[rmischemas,{@SaveDataDictionary},'separator'];
        end

        if reqmgt('rmiFeature','Experimental')
            if rmi.settings_mgr('get','coverageSettings','enabled')
                filters_schema={@rmisl.covFilterCtxMenu,{objh,isInLibrary}};
                rmischemas=[rmischemas,{filters_schema},'separator'];
            end
        end
    end

end


function result=isStateflowObject(objh)
    result=strncmp(class(objh),'Stateflow.',length('Stateflow.'));
end


function selectionMenus=skipDataLink(selectionMenus)
    takeIdx=true(size(selectionMenus));
    for i=1:length(takeIdx)
        if~isempty(strfind(selectionMenus{i}{2}{2},'DATA'))
            takeIdx(i)=false;
            break;
        end
    end
    selectionMenus=selectionMenus(takeIdx);
end


function[link_schemas,hasLinks]=create_requirement_links(objh,tagPrefix)
    if nargin<2
        tagPrefix='';
    end
    [descriptions,enabled]=rmi.getLinkLabels(objh);
    [~,objH]=rmi.resolveobj(objh);
    link_schemas=getLinkSchemaFromDescription(objH,descriptions,enabled,tagPrefix);
    hasLinks=~isempty(link_schemas);
end


function link_schemas=getLinkSchemaFromDescription(handle,descriptions,enabled,tagPrefix)
    if nargin<4
        tagPrefix='';
    end
    if isempty(descriptions)
        cnt=0;
    else
        descriptions=create_requirement_labels(descriptions);
        if iscell(descriptions)
            cnt=length(descriptions);
        else
            cnt=1;
        end
    end
    if cnt>0
        link_schemas=cell(1,cnt);
        for i=1:cnt
            if rmifa.isFaultInfoObj(handle)
                handle={handle};
            end
            link_schemas{i}={@CreateDynamicReqMenu,[descriptions(i),handle,i,enabled(i),{tagPrefix}]};
        end
        link_schemas{end+1}='separator';
    else
        link_schemas=cell(0);
    end
end


function[link_schemas,hasLinks]=create_requirement_links_forSSRef(objh)

    allReqs=rmidata.getReqs(objh);
    descriptions=cell(length(allReqs),1);

    enabled=true(length(allReqs),1);

    for index=1:length(allReqs)
        cReq=allReqs(index);
        adapter=slreq.adapters.AdapterManager.getInstance.getAdapterByDomain(cReq.reqsys);
        descriptions{index}=adapter.getSummary(cReq.doc,cReq.id);
    end

    if isa(objh,'Stateflow.Object')
        handle=objh.Id;
    else
        handle=objh.Handle;
    end
    link_schemas=getLinkSchemaFromDescription(handle,descriptions,enabled);
    hasLinks=~isempty(link_schemas);
end


function labels=create_requirement_labels(descriptions)
    reqCnt=length(descriptions);

    if reqCnt==0
        labels={};
        return;
    end

    numbers=cellstr(num2str((1:reqCnt)'))';
    labels=strcat(numbers,'. "',descriptions,'"');
    for i=1:length(labels)
        oneLabel=labels{i};
        if length(oneLabel)>100
            labels{i}=[oneLabel(1:100),'..."'];
        end
    end
end


function objh=cbSelection(callbackInfo)
    objh=callbackInfo.getSelection;

    if isempty(objh)
        objh=find(cbUiObject(callbackInfo),'-isa','Simulink.Line','-and','Selected','on');%#ok<*GTARG>
    end
end


function objh=cbSelectionToRmiObj(callbackInfo)
    objh=callbackInfo.getSelection;
    if rmisl.isComponentHarness(callbackInfo.model.Name)
        if Simulink.harness.internal.sidmap.isObjectOwnedByCUT(objh)
            objh=rmisl.harnessToModelRemap(objh);
        end
    end
    if~isempty(callbackInfo.userdata)&&rmifa.isFaultInfoObj(callbackInfo.userdata{1})
        objh=callbackInfo.userdata{1};
        return;
    end
    if isempty(objh)
        objh=find(cbUiObject(callbackInfo),'-isa','Simulink.Line','-and','Selected','on');%#ok<*GTARG>
    elseif any(strcmp(class(objh),{'Stateflow.SLFunction','Stateflow.SimulinkBasedState'}))
        objh=objh.getDialogProxy();
    end
end


function objh=cbUiObject(callbackInfo)
    objh=callbackInfo.uiObject;

    if isa(objh,'DAStudio.WSOAdapter')
        objh=objh.getVariable;
    elseif isa(objh,'DAStudio.ModelReferenceShortcut')

        objh=objh.getForwardedObject();
    end
    if isa(objh,'DAStudio.DAObjectProxy')
        objh=objh.getMCOSObjectReference;
    end
end


function objh=cbUiObjectToRmiObj(callbackInfo)
    objh=callbackInfo.uiObject;
    objClass=class(objh);
    switch objClass
    case{...
        'Stateflow.Chart',...
        'Stateflow.EMChart',...
        'Stateflow.TruthTableChart',...
        'Stateflow.StateTransitionTableChart',...
        'Stateflow.ReactiveTestingTableChart'}
        if sf('get',objh.Id,'.isa')==sf('get','default','chart.isa')
            objh=sf('Private','chart2block',objh.Id);
        end
    case 'DAStudio.ModelReferenceShortcut'
        objh=objh.getForwardedObject();
    end
end


function schema=CopyUrlToClipboardSys(callbackInfo)
    schema=DAStudio.ActionSchema;
    schema.label=getString(message('Slvnv:rmisl:menus_rmi_object:CopyURL'));
    schema.tag='Simulink:CopyUrlToClipboard';
    schema.callback=@CopyUrlToClipboardSys_callback;
    schema.autoDisableWhen='Busy';

    if~callbackInfo.userdata{2}&&guidYok(callbackInfo)

        schema.state='Disabled';
    end
end


function yesno=guidYok(callbackInfo)
    if isempty(callbackInfo.model)
        yesno=false;
        return;
    elseif rmidata.isExternal(callbackInfo.model.Name)
        yesno=false;
    else
        obj=callbackInfo.userdata{1};
        if~isempty(obj.RequirementInfo)
            yesno=false;
        else
            yesno=strcmp(get_param(callbackInfo.model.Name,'lock'),'on');
        end
    end
end


function CopyUrlToClipboardSys_callback(callbackInfo)
    if builtin('_license_checkout','Simulink_Requirements','quiet')
        rmi.licenseErrorDlg();
    else
        obj=cbUiObjectToRmiObj(callbackInfo);
        url=rmi.getURL(obj);
        clipboard('copy',url);
    end
end


function schema=CopyUrlToClipboardBlk(callbackInfo)
    schema=DAStudio.ActionSchema;
    schema.label=getString(message('Slvnv:rmisl:menus_rmi_object:CopyURL'));
    schema.tag='Simulink:CopyUrlToClipboard';
    schema.callback=@CopyUrlToClipboardBlk_callback;
    schema.autoDisableWhen='Busy';
    if~callbackInfo.userdata{2}&&guidYok(callbackInfo)
        schema.state='Disabled';
    end
end


function CopyUrlToClipboardBlk_callback(callbackInfo)
    if builtin('_license_checkout','Simulink_Requirements','quiet')
        rmi.licenseErrorDlg();
    else
        obj=cbSelectionToRmiObj(callbackInfo);
        url=rmi.getURL(obj);
        clipboard('copy',url);
    end
end


function schema=LinkToFaultTable(callbackInfo)%#ok<*INUSD>
    schema=DAStudio.ActionSchema;
    schema.label=getString(message('Slvnv:reqmgt:linktype_rmi_simulink:LinkToSelectedFaultObj'));
    schema.tag='Simulink:AddLinkFaultTable';
    schema.callback=@LinkToFaultTable_callback;
    schema.autoDisableWhen='Busy';
end


function LinkToFaultTable_callback(callbackInfo)
    obj=rmi.currentObj();

    objH=rmi.canlink(obj);
    req=rmifa.selectionLink('',false);
    rmi.catReqs(objH,req);
end


function schema=EditAddBlk(callbackInfo)%#ok<*INUSD>
    schema=DAStudio.ActionSchema;
    schema.label=getString(message('Slvnv:rmisl:menus_rmi_object:EditAddLinks'));
    schema.tag='Simulink:EditAddBlkLinks';
    schema.callback=@EditAddBlk_callback;
    schema.autoDisableWhen='Busy';
end


function EditAddBlk_callback(callbackInfo)
    obj=cbSelectionToRmiObj(callbackInfo);
    rmi('edit',obj);
end


function schema=EditAddSys(callbackInfo)
    schema=DAStudio.ActionSchema;
    schema.label=getString(message('Slvnv:rmisl:menus_rmi_object:EditAddLinks'));
    schema.tag='Simulink:EditAddSysLinks';
    schema.callback=@EditAddSys_callback;
    schema.autoDisableWhen='Busy';
end


function EditAddSys_callback(callbackInfo)
    obj=cbUiObjectToRmiObj(callbackInfo);
    rmi('edit',obj);
end


function schema=CreateDynamicReqMenu(callbackInfo)
    schema=DAStudio.ActionSchema;
    schema.label=callbackInfo.userdata{1};
    schema.tag=['Simulink:DynamicReqMenu',callbackInfo.userdata{5},num2str(callbackInfo.userdata{3})];
    schema.userdata=callbackInfo.userdata(2:3);
    if~callbackInfo.userdata{4}
        schema.state='Disabled';
    end
    schema.callback=@CreateDynamicReqMenu_callback;
    schema.autoDisableWhen='Busy';
end


function CreateDynamicReqMenu_callback(callbackInfo)
    rmi('view',callbackInfo.userdata{:});
end


function schema=DeleteAllBlk(callbackInfo)
    schema=DAStudio.ActionSchema;
    schema.label=getString(message('Slvnv:rmisl:menus_rmi_object:DeleteAllLinks'));
    schema.tag='Simulink:DeleteBlkLinks';
    schema.callback=@DeleteAllBlk_callback;
    schema.autoDisableWhen='Busy';
end


function DeleteAllBlk_callback(callbackInfo)
    if builtin('_license_checkout','Simulink_Requirements','quiet')
        rmi.licenseErrorDlg();
    else
        obj=cbSelectionToRmiObj(callbackInfo);
        try
            rmi('clearAll',obj);
        catch Mex
            errordlg(Mex.message,getString(message('Slvnv:rmisl:menus_rmi_deprecated:FailedToDeleteLinks')));
        end
    end
end


function schema=DeleteAllSys(callbackInfo)
    schema=DAStudio.ActionSchema;
    schema.label=getString(message('Slvnv:rmisl:menus_rmi_object:DeleteAllLinks'));
    schema.tag='Simulink:DeleteAllSysLinks';
    schema.callback=@DeleteAllSys_callback;
    schema.autoDisableWhen='Busy';
end


function DeleteAllSys_callback(callbackInfo)
    if builtin('_license_checkout','Simulink_Requirements','quiet')
        rmi.licenseErrorDlg();
    else
        obj=cbUiObjectToRmiObj(callbackInfo);
        try
            rmi('clearAll',obj);
        catch Mex
            errordlg(Mex.message,getString(message('Slvnv:rmisl:menus_rmi_deprecated:FailedToDeleteLinks')));
        end
    end
end


function chart_schema=MoveChartReqs(callbackInfo)
    chart_schema=DAStudio.ActionSchema;
    chart_schema.label=getString(message('Slvnv:rmisl:menus_rmi_deprecated:DeprecatedLinksDetected'));
    chart_schema.tag='Simulink:DeprecatedReqs';
    chart_schema.userdata=callbackInfo.userdata;
    chart_schema.callback=@MoveChartReqs_callback;
    chart_schema.autoDisableWhen='Busy';
end


function MoveChartReqs_callback(callbackInfo)
    objs=callbackInfo.userdata;
    switch lower(get_param(objs{2},'SFBlockType'))
    case lower('MATLAB Function')
        line1=getString(message('Slvnv:rmisl:menus_rmi_deprecated:MFunctionLinksNotAttachedToBlock'));
        line2=getString(message('Slvnv:rmisl:menus_rmi_deprecated:MFunctionLinksNotSupported'));
        line3=getString(message('Slvnv:rmisl:menus_rmi_deprecated:MoveLinksToMFunctionBlockInSimulink'));
    case lower('Truth Table')
        line1=getString(message('Slvnv:rmisl:menus_rmi_deprecated:TTableLinksNotAttachedToBlock'));
        line2=getString(message('Slvnv:rmisl:menus_rmi_deprecated:TTableLinksNotSupported'));
        line3=getString(message('Slvnv:rmisl:menus_rmi_deprecated:MoveLinksToTTableBlockInSimulink'));
    otherwise
        line1=getString(message('Slvnv:rmisl:menus_rmi_deprecated:ChartLinksNotAttachedToBlock'));
        line2=getString(message('Slvnv:rmisl:menus_rmi_deprecated:TopChartLinksNotSupported'));
        line3=getString(message('Slvnv:rmisl:menus_rmi_deprecated:MoveLinksToChartBlockInSimulink'));
    end
    title=getString(message('Slvnv:rmisl:menus_rmi_deprecated:RequirementsDeprecatedLinks'));
    yes=getString(message('Slvnv:rmisl:menus_rmi_deprecated:xlate_Yes'));
    no=getString(message('Slvnv:rmisl:menus_rmi_deprecated:xlate_No'));
    reply=questdlg({[line1,' ',line2],' ',line3},title,...
    yes,no,yes);
    if~isempty(reply)&&strcmp(reply,yes)
        rmi('move',objs{:});
    end
end


function slfunc_schema=MoveSLFunctionReqs(callbackInfo)
    slfunc_schema=DAStudio.ActionSchema;
    slfunc_schema.label=getString(message('Slvnv:rmisl:menus_rmi_deprecated:DeprecatedLinksDetected'));
    slfunc_schema.tag='Simulink:DeprecatedReqs';
    slfunc_schema.userdata=callbackInfo.userdata;
    slfunc_schema.callback=@MoveSLFunctionReqs_callback;
end

function MoveSLFunctionReqs_callback(callbackInfo)
    objs=callbackInfo.userdata;
    reply=questdlg({[getString(message('Slvnv:rmisl:menus_rmi_deprecated:LinksOnSLFunctionNotAttachedToSubsys'))...
    ,' '...
    ,getString(message('Slvnv:rmisl:menus_rmi_deprecated:SLFunctionLinksShouldAttachSubsystem'))],...
    ' ',...
    getString(message('Slvnv:rmisl:menus_rmi_deprecated:MoveLinksToSubsystem'))},...
    getString(message('Slvnv:rmisl:menus_rmi_deprecated:RequirementsDeprecatedLinks')),...
    getString(message('Slvnv:rmisl:menus_rmi_deprecated:xlate_Yes')),getString(message('Slvnv:rmisl:menus_rmi_deprecated:xlate_No')),getString(message('Slvnv:rmisl:menus_rmi_deprecated:xlate_Yes')));
    if~isempty(reply)&&strcmp(reply,getString(message('Slvnv:rmisl:menus_rmi_deprecated:xlate_Yes')))
        rmi('move',objs{:});
    end
end


function schema=SaveDataDictionary(callbackInfo)
    schema=DAStudio.ActionSchema;
    schema.label=getString(message('Slvnv:rmide:SaveTraceabilityForDD'));
    schema.tag='Simulink:SaveTraceabilityForDD';
    schema.callback=@SaveDataDictionary_callback;
    schema.autoDisableWhen='Busy';
end
function SaveDataDictionary_callback(callbackInfo)
    obj=callbackInfo.uiObject;
    dictName=rmide.resolveEntry(obj);
    rmide.save(dictName);
end


function schema=LinksFromSSRef(callbackInfo)


    libObj=callbackInfo.userdata{2};

    schema=DAStudio.ContainerSchema;
    schema.tag='Simulink:SSRefBlockRequirements';
    schema.label=getString(message('Slvnv:rmisl:menus_rmi_object:SSRefBlockRequirements'));
    ssRefName=callbackInfo.userdata{1};

    if isvarname(ssRefName)&&dig.isProductInstalled('Simulink')&&bdIsLoaded(ssRefName)

        if rmi.objHasReqs(libObj,[])
            schema.userdata=libObj;
            schema.generateFcn=@create_library_requirement_links;
        else
            schema.label=getString(message('Slvnv:rmisl:menus_rmi_object:NoSSRefBlockRequirements'));
            schema.state='Hidden';
            schema.childrenFcns={DAStudio.Actions('HiddenSchema')};
        end
    else

        schema.state='Disabled';
        schema.childrenFcns={DAStudio.Actions('HiddenSchema')};
    end

    schema.autoDisableWhen='Busy';
end


function schema=LinksFromLib(callbackInfo)
    schema=DAStudio.ContainerSchema;
    schema.tag='Simulink:LibraryBlockRequirements';
    schema.label=getString(message('Slvnv:rmisl:menus_rmi_object:LibraryBlockRequirements'));

    try
        libName=callbackInfo.userdata{1};
        get_param(libName,'Handle');

        libObj=callbackInfo.userdata{2};
        if rmi.objHasReqs(libObj,[])
            schema.userdata=libObj;
            schema.generateFcn=@create_library_requirement_links;
        else
            schema.label=getString(message('Slvnv:rmisl:menus_rmi_object:NoLibraryBlockRequirements'));
            schema.state='Hidden';
            schema.childrenFcns={DAStudio.Actions('HiddenSchema')};
        end
    catch ex %#ok<NASGU>

        schema.state='Disabled';
        schema.childrenFcns={DAStudio.Actions('HiddenSchema')};
    end
    schema.autoDisableWhen='Busy';
end


function link_schemas=create_library_requirement_links(callbackInfo)
    link_schemas=create_requirement_links(callbackInfo.userdata,'Lib');
end


function intraLinkSchemas=intraLinkMenus(obj)
    intraLinkSchemas=rmisl.intraLinkMenus(obj);
end


