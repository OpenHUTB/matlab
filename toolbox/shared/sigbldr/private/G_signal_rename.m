function[UD,newName]=G_signal_rename(UD,sigIdx,newName)






    if UD.current.channel==sigIdx
        set(UD.hgCtrls.chDispProp.labelEdit,'String',newName);
    end

    if~strcmp(newName,UD.channels(sigIdx).label)&~isempty(UD.simulink)
        sigbuilder_block('rename_outport',UD.simulink,sigIdx,newName);
    end


    UD.channels(sigIdx).label=newName;
    UD.sbobj.Groups(UD.current.dataSetIdx).Signals(sigIdx).Name=newName;


    shownPlot=[char(9745),' '];


    padding=length(shownPlot);

    if length(newName)>29-length(shownPlot)

        ellipseStr='...';


        ellipseIDX=padding+length(ellipseStr);


        newStr=[char(32*ones(1,padding)),newName(1:29-ellipseIDX),ellipseStr];
        newStr=[newStr,blanks(29-length(newStr))];
    else
        newStr=[char(32*ones(1,padding)),newName,char(32*ones(1,29-length(newName)-padding))];
    end


    chanStr=get(UD.hgCtrls.chanListbox,'String');
    newStr(1:2)=chanStr(sigIdx,1:2);

    chanStr(sigIdx,:)=newStr;
    set(UD.hgCtrls.chanListbox,'String',chanStr);


    axesIdx=UD.channels(sigIdx).axesInd;
    if~isempty(axesIdx)&&axesIdx>0
        labelH=UD.axes(axesIdx).labelH;
        set(labelH,'String',newName);
        update_axes_label(UD.axes(axesIdx));
    end
    sigbuilder_tabselector('touch',UD.hgCtrls.tabselect.axesH);
    update_selection_msg(UD);
    UD=set_dirty_flag(UD);
