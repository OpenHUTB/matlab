
function schema=ObserverMenu(fncname,cbinfo)

    fcn=str2func(fncname);
    schema=fcn(cbinfo);
end







function schema=ObserverMenuImpl(cbinfo)
    schema=sl_container_schema;
    schema.label=DAStudio.message('Simulink:studio:ObserverMenu');
    schema.tag='Simulink:ObserverMenu';
    schema.generateFcn=@generateObserverMenuChildren;


    isMWLib=false;
    if Simulink.harness.internal.isMathWorksLibrary(get_param(cbinfo.model.name,'Handle'))
        isMWLib=true;
    end


    if~slfeature('SimHarnessObserver')||...
        ~Simulink.harness.internal.isInstalled()||...
        ~Simulink.harness.internal.licenseTest()||isMWLib

        schema.state='Hidden';
        return
    end

    [~,selectionType]=getObserverSelectionAndValidate(cbinfo);
    if~strcmp(selectionType,'other')
        schema.state='Enabled';
    else
        schema.state='Disabled';
    end
    schema.autoDisableWhen='Busy';
end





function children=generateObserverMenuChildren(cbinfo)
    im=DAStudio.InterfaceManagerHelper(cbinfo.studio,'Simulink');

    children={...
    im.getAction('Simulink:GotoObserverBlock')...
    ,im.getAction('Simulink:AddObserver')...
    ,im.getAction('Simulink:AddObserverPort')...
    ,im.getAction('Simulink:ObserveSignal')...
    ,im.getAction('Simulink:GotoObserverPort')...
    ,im.getAction('Simulink:SendToObserver')...
    ,im.getAction('Simulink:ManageObserver')...
    ,im.getAction('Simulink:GoToObservedEntity')...
    };
end

function schema=GotoObserverBlock(cbinfo)
    schema=sl_action_schema;
    schema.tag='Simulink:GotoObserverBlock';

    schema.label=DAStudio.message('Simulink:studio:GotoObserverBlock');
    schema.state='Hidden';

    [~,selectionType]=getObserverSelectionAndValidate(cbinfo);

    if~slfeature('SimHarnessObserver')||(~strcmp(selectionType,'empty')&&cbinfo.isContextMenu)
        return;
    end

    schema.callback=@GotoObserverBlockCB;
    obsRefBlk=get_param(bdroot(gcs),'ObserverContext');
    if~isempty(obsRefBlk)
        schema.state='Enabled';
    else
        schema.state='Disabled';
    end
    schema.autoDisableWhen='Never';
end


function schema=AddObserver(cbinfo)
    schema=sl_action_schema;
    schema.tag='Simulink:AddObserver';

    schema.label=DAStudio.message('Simulink:studio:AddObserverHere');
    schema.state='Hidden';
    [~,selectionType]=getObserverSelectionAndValidate(cbinfo);

    if~slfeature('SimHarnessObserver')||(~strcmp(selectionType,'empty')&&cbinfo.isContextMenu)
        return;
    end

    schema.label=DAStudio.message('Simulink:studio:AddObserverHere');
    schema.callback=@CreateObserverCB;

    res=ShouldObserverCreateBeEnabled(cbinfo);
    if res&&isa(get_param(gcs,'Object'),'Simulink.BlockDiagram')
        schema.state='Enabled';
    else
        schema.state='Disabled';
    end
    schema.autoDisableWhen='Never';
end


function schema=ObserveSignal(cbinfo)
    schema=sl_container_schema;
    schema.tag='Simulink:ObserveSignal';

    schema.label=DAStudio.message('Simulink:studio:ObserveSignal');
    schema.generateFcn=@listAvailableObservers;
    schema.state='Hidden';
    [~,selectionType]=getObserverSelectionAndValidate(cbinfo);

    if~slfeature('SimHarnessObserver')||~strcmp(selectionType,'signals')
        return;
    end

    res=ShouldObserverCreateBeEnabled(cbinfo);
    if res
        schema.state='Enabled';
    else
        schema.state='Disabled';
    end

    schema.autoDisableWhen='Never';
end


function schema=GotoObserverPort(cbinfo)
    import sltest.internal.menus.getObserverPortBlocks;
    schema=sl_container_schema;
    schema.tag='Simulink:GotoObserverPort';

    schema.label=DAStudio.message('Simulink:studio:GotoObserverPort');
    schema.generateFcn=@listAvailableObserverPorts;
    schema.state='Hidden';

    obsPrtBlks=getObserverPortBlocks(cbinfo.getSelection,cbinfo.model.Name);
    if~isempty(obsPrtBlks)
        schema.state='Enabled';
        schema.userdata=obsPrtBlks;
    else
        schema.state='Disabled';
    end
    schema.autoDisableWhen='Never';
end



function schema=SendToObserver(cbinfo)
    import sltest.internal.menus.getEnableSendToObserver;
    schema=sl_container_schema;
    schema.tag='Simulink:SendToObserver';

    schema.label=DAStudio.message('Simulink:studio:SendToObserver');
    schema.generateFcn=@listAvailableObservers;
    schema.state='Hidden';
    [selection,selectionType]=getObserverSelectionAndValidate(cbinfo);

    if~slfeature('SimHarnessObserver')||~strcmp(selectionType,'block')...
        ||(~isprop(selection,'portHandles')&&~isprop(selection,'PortHandles'))
        return;
    end

    schema.state='Disabled';
    if getEnableSendToObserver(cbinfo.getSelection,cbinfo.model.Name)
        if ShouldObserverCreateBeEnabled(cbinfo)
            schema.state='Enabled';
        end
    end
    schema.autoDisableWhen='Never';
end


function children=listAvailableObservers(cbinfo)
    im=DAStudio.InterfaceManagerHelper(cbinfo.studio,'Simulink');
    selection=cbinfo.getSelection;
    bpList=Simulink.sltblkmap.internal.getParentBlockPath(selection);
    children={...
    im.getAction('Simulink:NewObserver')...
    ,'separator'...
    };
    counter=1;
    for i=1:numel(bpList)
        obsH=Simulink.observer.internal.getAvailableObserversForArea(bdroot(bpList(i)));
        obsCell=cell(1,numel(obsH));
        obsNames=string(getfullname(obsH)).replace(newline,' ').sort.';
        for j=1:numel(obsH)
            obsCell{j}={@ExistingObserver;{counter,obsNames{j}}};
            counter=counter+1;
        end
        children=[children,obsCell];
    end
    if numel(children)==2
        children=children(1);
    end
end



function children=listAvailableObserverPorts(cbinfo)
    ObsPrtBlks=cbinfo.userdata;

    if~isempty(ObsPrtBlks)
        children=cell(1,size(ObsPrtBlks,1));
        for j=1:size(ObsPrtBlks,1)
            obsRefH=ObsPrtBlks{j,1};
            [mdlName,blkSID,blkH]=getBlockFromMapElemStr(ObsPrtBlks{j,2});
            if blkH~=-1
                obsPrtName=strrep(getfullname(blkH),newline,' ');
                newItem={@ExistingObserverPorts;{j,true,obsRefH,obsPrtName}};
                children{j}=newItem;
            else
                newItem={@ExistingObserverPorts;{j,false,obsRefH,mdlName,blkSID}};
                children{j}=newItem;
            end
        end
    else




        children={'separator'};
    end

end



function schema=ExistingObserverPorts(cbinfo)

    blkIdx=cbinfo.userdata{1};
    isLoaded=cbinfo.userdata{2};
    obsRefH=cbinfo.userdata{3};

    schema=sl_action_schema;
    schema.tag=['Simulink:GotoObserverPort_',num2str(blkIdx)];
    schema.state='Enabled';
    schema.autoDisableWhen='Never';
    if isLoaded
        blkPath=cbinfo.userdata{4};
        schema.label=DAStudio.message('Simulink:Observer:ObserverPortInLoadedMdl',blkPath,strrep(getfullname(obsRefH),newline,' '));
        schema.callback=@GotoObserverPortCB;
        schema.userdata={obsRefH,blkPath};
    else
        mdlName=cbinfo.userdata{4};
        blkSID=cbinfo.userdata{5};
        schema.label=DAStudio.message('Simulink:Observer:ObserverPortInUnloadedMdl',blkSID,strrep(getfullname(obsRefH),newline,' '));
        schema.callback=@LoadModelAndGotoObserverPortCB;
        schema.userdata={obsRefH,mdlName,blkSID};
    end
end


function schema=NewObserver(~)
    schema=sl_action_schema;
    schema.tag='Simulink:NewObserver';

    schema.state='Enabled';
    schema.label=DAStudio.message('Simulink:studio:NewObserver');
    schema.callback=@NewObserverCB;

    schema.autoDisableWhen='Never';
end



function schema=ExistingObserver(cbinfo)
    blkIdx=cbinfo.userdata{1};
    blkPath=cbinfo.userdata{2};
    obsMdlName=get_param(blkPath,'ObserverModelName');
    schema=sl_action_schema;
    schema.tag=['Simulink:ExistingObserver_',num2str(blkIdx)];

    if strcmp(obsMdlName,'<Enter Model Name>')
        schema.state='Hidden';
    else
        schema.state='Enabled';
    end
    schema.label=[blkPath,' (',obsMdlName,')'];
    schema.callback=@ExistingObserverCB;
    schema.userdata=blkPath;
    schema.autoDisableWhen='Never';
end


function schema=ManageObserver(cbinfo)
    schema=sl_action_schema;
    schema.tag='Simulink:ManageObserver';

    schema.state='Hidden';
    schema.label=DAStudio.message('Simulink:studio:ManageObserver');
    schema.callback=@ManageObserverCB;
    [selection,selectionType]=getObserverSelectionAndValidate(cbinfo);

    if~slfeature('SimHarnessObserver')
        return;
    end

    isInObserver=~isempty(get_param(bdroot(gcs),'ObserverContext'));

    if isInObserver
        if cbinfo.isContextMenu&&(~strcmp(selectionType,'empty')&&~strcmp(selectionType,'observerport')&&~strcmp(selectionType,'observer'))
            return;
        end
        if strcmp(selectionType,'observer')||strcmp(selectionType,'observerport')
            hdl=selection.Handle;
        else
            hdl=get_param(get_param(bdroot(gcs),'ObserverContext'),'Handle');
        end
    else
        if~strcmp(selectionType,'observer')
            return;
        end
        hdl=selection.Handle;
    end

    schema.state='Enabled';
    schema.userdata=hdl;
    schema.autoDisableWhen='Never';
end


function schema=AddObserverPort(cbinfo)
    schema=sl_action_schema;
    schema.tag='Simulink:AddObserverPort';

    schema.state='Hidden';
    schema.label=DAStudio.message('Simulink:studio:AddObserverPort');
    schema.callback=@AddObserverPortCB;
    [~,selectionType]=getObserverSelectionAndValidate(cbinfo);

    if~slfeature('SimHarnessObserver')
        return;
    end

    if~strcmp(selectionType,'empty')&&cbinfo.isContextMenu
        return;
    end

    schema.state='Enabled';
    schema.autoDisableWhen='Never';
end


function schema=GoToObservedEntity(cbinfo)
    schema=sl_action_schema;
    schema.tag='Simulink:GoToObservedEntity';

    schema.state='Hidden';
    schema.label='';
    schema.callback=@GoToObservedSignalCB;
    [selection,selectionType]=getObserverSelectionAndValidate(cbinfo);

    if~slfeature('SimHarnessObserver')||~strcmp(selectionType,'observerport')
        return;
    end

    [schema.state,schema.label]=...
    sltest.internal.menus.getEntityStateAndLabel(selection.Handle);
    schema.autoDisableWhen='Never';
end










function res=ShouldObserverCreateBeEnabled(cbinfo)
    res=true;

    simStatus=get_param(cbinfo.model.Handle,'SimulationStatus');
    locked=get_param(bdroot(gcs),'Lock');

    if~strcmpi(simStatus,'stopped')||strcmp(locked,'on')

        res=false;
    end
end








function[selection,selectionType]=getObserverSelectionAndValidate(cbinfo)
    selection=cbinfo.getSelection();
    selectionType='other';

    if isempty(selection)
        selectionType='empty';
    elseif numel(selection)==1
        if isa(selection,'Simulink.ObserverReference')
            selectionType='observer';
        elseif isa(selection,'Simulink.ObserverPort')
            selectionType='observerport';
        elseif isa(selection,'Simulink.Segment')
            if strcmp(selection.LineType,'signal')&&selection.SrcPortHandle~=-1&&strcmp(get_param(selection.SrcPortHandle,'PortType'),'outport')
                selectionType='signals';
            end
        else
            selectionType='block';
        end
    else
        if sltest.internal.menus.getEnableObserveSignals(selection,cbinfo.model.Name)
            selectionType='signals';
        end
    end
end

function[mdlName,blkSID,blkH]=getBlockFromMapElemStr(mapElemStr)

    colonPos=strfind(mapElemStr,':');
    barPos=strfind(mapElemStr,'|');

    blkSID=mapElemStr(barPos(1)+1:end);
    mdlName=mapElemStr(barPos(1)+1:colonPos(1)-1);
    if bdIsLoaded(mdlName)
        if Simulink.sltblkmap.internal.blockWithSIDExists(blkSID)
            blkH=Simulink.ID.getHandle(blkSID);
        else
            blkH=-1;
        end
    else
        blkH=-1;
    end

end








function GotoObserverBlockCB(~)
    try
        obsRefBlk=get_param(bdroot(gcs),'ObserverContext');
        designMdl=bdroot(obsRefBlk);
        SLStudio.HighlightSignal.removeHighlighting(get_param(designMdl,'Handle'));
        SLStudio.EmphasisStyleSheet.applyStyler(get_param(designMdl,'Handle'),get_param(obsRefBlk,'Handle'));
        if~strcmp(get_param(designMdl,'open'),'on')
            open_system(designMdl,'Window');
        else
            open_system(designMdl);
        end
    catch
    end
end

function CreateObserverCB(cbinfo)
    if cbinfo.isContextMenu
        [obsHandle,~]=Simulink.observer.internal.createObserverMdlAndAddSpecificPorts(gcs,[],false);
        if ishandle(obsHandle)
            pos=cbinfo.studio.App.getActiveEditor.mapFromGlobal(cbinfo.contextMenuPosition());
            set_param(obsHandle,'Position',[pos(1)-42,pos(2)-26,pos(1)+43,pos(2)+26])
        end
    else
        Simulink.observer.internal.createObserverMdlAndAddSpecificPorts(gcs,[],false);
    end
end

function NewObserverCB(cbinfo)

    selection=cbinfo.getSelection;
    if all(arrayfun(@(x)isa(x,'Simulink.Segment'),selection))

        srcPrtHdls=unique(arrayfun(@(x)x.SrcPortHandle,selection));
        srcPrtHdls=srcPrtHdls(arrayfun(@(x)(x~=-1&&strcmp(get_param(x,'PortType'),'outport')),srcPrtHdls));
        Simulink.observer.internal.createObserverMdlAndAddSpecificPorts(gcs,srcPrtHdls,true);
    elseif isa(selection,'Simulink.Block')

        Simulink.observer.internal.sendBlockToObserver(selection.getFullName,'',true);
    end
end

function ExistingObserverCB(cbinfo)

    selection=cbinfo.getSelection;
    blkPath=cbinfo.userdata;
    obsMdl=get_param(blkPath,'ObserverModelName');
    if exist(obsMdl,'File')==0
        DAStudio.error('Simulink:Observer:ObsMdlNotFound',obsMdl,blkPath);
    elseif~bdIsLoaded(obsMdl)
        Simulink.observer.internal.openObserverMdlFromObsRefBlk(get_param(blkPath,'Handle'));
    end
    if all(arrayfun(@(x)isa(x,'Simulink.Segment'),selection))

        srcPrtHdls=unique(arrayfun(@(x)x.SrcPortHandle,selection));
        srcPrtHdls=srcPrtHdls(arrayfun(@(x)(x~=-1&&strcmp(get_param(x,'PortType'),'outport')),srcPrtHdls));
        bpList=Simulink.sltblkmap.internal.getParentBlockPath(srcPrtHdls);
        blkList=[];
        for j=1:numel(bpList)-1
            if bdroot(bpList(j))==get_param(bdroot(blkPath),'Handle')
                blkList=bpList(j:end-1);
                break;
            end
        end
        Simulink.observer.internal.addObserverPortsForSignalsInObserver({blkList,srcPrtHdls},obsMdl,true);
    elseif isa(selection,'Simulink.Block')

        Simulink.observer.internal.sendBlockToObserver(selection.getFullName,obsMdl,true);
    end
end

function GotoObserverPortCB(cbinfo)

    obsRefH=cbinfo.userdata{1};
    blkPath=cbinfo.userdata{2};
    blkH=get_param(blkPath,'Handle');
    mdlH=bdroot(blkH);
    ctxBlk=get_param(mdlH,'CoSimContext');

    if isempty(ctxBlk)||get_param(ctxBlk,'Handle')~=obsRefH
        try
            Simulink.sltblkmap.internal.convertStandaloneMdlToContexted(mdlH,obsRefH);
        catch ME
            Simulink.observer.internal.error(ME,true,'Simulink:Observer:ObserverStage',getfullname(mdlH));
            return;
        end
    end
    sys=get_param(blkPath,'Parent');
    if~strcmp(get_param(sys,'Open'),'on')
        open_system(sys,'force','Window');
    else
        open_system(sys);
    end

    portHandles=get_param(blkH,'PortHandles');
    linH=get_param(portHandles.Outport,'Line');
    if linH~=-1
        hdls=[blkH,linH];
    else
        hdls=blkH;
    end
    SLStudio.HighlightSignal.removeHighlighting(mdlH);
    SLStudio.EmphasisStyleSheet.applyStyler(mdlH,hdls);

end

function LoadModelAndGotoObserverPortCB(cbinfo)

    obsRefH=cbinfo.userdata{1};
    mdlName=cbinfo.userdata{2};
    blkSID=cbinfo.userdata{3};
    obsMdlName=get_param(obsRefH,'ObserverModelName');
    if~exist(obsMdlName,'file')
        Simulink.observer.internal.error({'Simulink:Observer:ObsMdlNotFound',obsMdlName,getfullname(obsRefH)},true,'Simulink:Observer:ObserverStage',mdlName);
        return;
    end
    try
        open_system(obsRefH);
    catch ME
        Simulink.observer.internal.error(ME,true,'Simulink:Observer:ObserverStage',mdlName);
        return;
    end

    try
        blkH=Simulink.ID.getHandle(blkSID);
    catch
        Simulink.observer.internal.error({'Simulink:Observer:ObserverPortNoLongerValid',blkSID},true,'Simulink:Observer:ObserverStage',mdlName);
        return;
    end
    if blkH==-1
        Simulink.observer.internal.error({'Simulink:Observer:ObserverPortNoLongerValid',blkSID},true,'Simulink:Observer:ObserverStage',mdlName);
        return;
    end

    sys=get_param(blkH,'Parent');
    if~strcmp(get_param(sys,'Open'),'on')
        open_system(sys,'force','Window');
    else
        open_system(sys);
    end

    portHandles=get_param(blkH,'PortHandles');
    linH=get_param(portHandles.Outport,'Line');
    if linH~=-1
        hdls=[blkH,linH];
    else
        hdls=blkH;
    end
    mdlH=bdroot(blkH);
    SLStudio.HighlightSignal.removeHighlighting(mdlH);
    SLStudio.EmphasisStyleSheet.applyStyler(mdlH,hdls);

end

function ManageObserverCB(cbinfo)


    hdl=cbinfo.userdata;
    Simulink.observer.dialog.ObsPortDialog.getInstance(hdl);
end

function AddObserverPortCB(cbinfo)
    if cbinfo.isContextMenu
        pos=cbinfo.studio.App.getActiveEditor.mapFromGlobal(cbinfo.contextMenuPosition());
        Simulink.observer.internal.addObserverPortsForSignalsInObserver(-1,gcs,false,'Position',[pos(1)-22,pos(2)-13,pos(1)+23,pos(2)+13]);
    else
        Simulink.observer.internal.addObserverPortsForSignalsInObserver(-1,gcs,false);
    end
end

function GoToObservedSignalCB(cbinfo)
    obsPrt=cbinfo.getSelection;
    obsPrtH=obsPrt.Handle;
    entType=Simulink.sltblkmap.internal.getMappedElementType(obsPrtH);
    switch entType
    case 'Outport'
        blkH=Simulink.observer.internal.getObservedBlockForceLoad(obsPrtH);
        if blkH==-1
            DAStudio.error('Simulink:Observer:InvalidObserverPort',strrep(getfullname(obsPrtH),newline,' '));
        end
        prtIdx=Simulink.observer.internal.getObservedPortIndex(obsPrtH)+1;
        portHandles=get_param(blkH,'PortHandles');
        linH=get_param(portHandles.Outport(prtIdx),'Line');
        if linH~=-1
            hdls=[blkH,linH];
        else
            hdls=blkH;
        end
        SLStudio.HighlightSignal.removeHighlighting(cbinfo.model.Handle);
        SLStudio.HighlightSignal.removeHighlighting(bdroot(blkH));
        SLStudio.EmphasisStyleSheet.applyStyler(bdroot(blkH),hdls);
        sys=get_param(blkH,'Parent');
        if~strcmp(get_param(sys,'Open'),'on')
            open_system(sys,'force','Window');
        else
            open_system(sys);
        end
    case 'SFState'
        sfObj=Simulink.observer.internal.getObservedSFObj(obsPrtH);
        if~sfObj.Valid
            DAStudio.error('Simulink:Observer:InvalidObserverPort',strrep(getfullname(obsPrtH),newline,' '));
        end
        SLStudio.HighlightSignal.removeHighlighting(cbinfo.model.Handle);
        Simulink.observer.internal.highlightObservedSFState(str2double(sfObj.ID));
    case 'SFData'

        sfObj=Simulink.observer.internal.getObservedSFObj(obsPrtH);
        if~sfObj.Valid
            DAStudio.error('Simulink:Observer:InvalidObserverPort',strrep(getfullname(obsPrtH),newline,' '));
        end
        SLStudio.HighlightSignal.removeHighlighting(cbinfo.model.Handle);
        SLStudio.EmphasisStyleSheet.applyStyler(bdroot(sfObj.ChartBlk),sfObj.ChartBlk);
        sys=get_param(sfObj.ChartBlk,'Parent');
        if~strcmp(get_param(sys,'Open'),'on')
            open_system(sys,'force','Window');
        else
            open_system(sys);
        end
    otherwise

    end
end







function HighlightObserverPortBlockToSource(cbinfo)
    sel=cbinfo.getSelection();
    modelName=get_param(cbinfo.model.Handle,'Name');
    obsBlockSID=get_param(sel.Handle,'ObservedBlock');
    obsBlockHandle=Simulink.ID.getHandle([modelName,':',obsBlockSID]);
    obsSigName=get_param(sel.Handle,'ObservedEntityName');

    pH=get_param(obsBlockHandle,'PortHandles');
    if(length(pH.Outport)==1)
        pHList={pH.Outport};
    else
        pHList=pH.Outport;
    end

    for n=1:length(pHList)
        lineHandle=get_param(pHList{n},'Line');
        lineName=get_param(lineHandle,'Name');

        if(strcmp(lineName,obsSigName))
            open_system(get_param(obsBlockHandle,'Parent'),'tab');
            SLStudio.HighlightSignal.HighlightSignalToSource(lineHandle,cbinfo.model.Handle);
            return;
        end
    end
end
