function UD=restore_from_saveStruct(UD,saveStruct)








    UD=quick_delete_all_channels_axes(UD);


    if~isfield(saveStruct,'sbobj')
        sbobj=SigSuite(saveStruct);
    else
        if iscell(saveStruct.sbobj.Groups)
            sbobj=convertFrom2008a(saveStruct);
        else

            sbobj=update_sbobj_fields(saveStruct);
        end
    end

    if isempty(sbobj.ActiveGroup)
        if isfield(saveStruct,'dataSetIdx')
            sbobj.ActiveGroup=saveStruct.dataSetIdx;
        elseif isfield(saveStruct,'current')
            sbobj.ActiveGroup=saveStruct.current.dataSetIdx;
        else
            sbobj.ActiveGroup=1;
        end

    end
    saveStruct.sbobj=sbobj;
    UD.sbobj=sbobj;


    UD.current.dataSetIdx=saveStruct.dataSetIdx;


    for i=1:length(saveStruct.channels)
        ch=saveStruct.channels(i);

        UD=signal_new(UD,ch.stepX,ch.stepY,ch.label,ch.color,...
        ch.lineStyle,ch.lineWidth);
    end


    UD.common=saveStruct.common;
    UD.common.dirtyFlag=0;
    UD.dataSet=saveStruct.dataSet;
    UD.current.gridSetting=saveStruct.gridSetting;


    switch(UD.current.gridSetting)
    case 'on'
        set(UD.toolbar.snapGrid,'state','on');
    case 'off'
        set(UD.toolbar.snapGrid,'state','off');
    end


    sigbuilder_tabselector('addentry',UD.hgCtrls.tabselect.axesH,...
    {UD.dataSet.name});


    dsIdx=UD.current.dataSetIdx;
    UD.current.dataSetIdx=-1;
    UD=dataSet_activate(UD,dsIdx,1);
    sigbuilder_tabselector('activate',UD.hgCtrls.tabselect.axesH,...
    UD.current.dataSetIdx,1);
end


function UD=quick_delete_all_channels_axes(UD)


    UD.channels=[];
    UD.numChannels=0;

    if~isfield(UD,'axes')
        return;
    end


    for axStruct=UD.axes
        delete(axStruct.handle);
    end
    set(UD.hgCtrls.chanListbox,'Value',1,'String',' ');


    UD.axes=[];
    UD.numAxes=0;
end

