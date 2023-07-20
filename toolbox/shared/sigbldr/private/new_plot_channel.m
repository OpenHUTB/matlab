function[UD,lineH]=new_plot_channel(UD,chIndex,axesInd,doFast)




    if nargin<4
        doFast=0;
    end

    axesH=UD.axes(axesInd).handle;
    lineUD.index=chIndex;
    lineUD.type='Channel';

    ActiveGroup=UD.sbobj.ActiveGroup;

    lineH=line(...
    'Parent',axesH,...
    'Color',UD.channels(chIndex).color,...
    'HandleVisibility','callback',...
    'LineWidth',UD.channels(chIndex).lineWidth,...
    'LineStyle',UD.channels(chIndex).lineStyle,...
    'Xdata',UD.sbobj.Groups(ActiveGroup).Signals(chIndex).XData,...
    'Ydata',UD.sbobj.Groups(ActiveGroup).Signals(chIndex).YData,...
    'UIContextMenu',UD.menus.channelContext.handle,...
    'UserData',lineUD);


    bottom_of_hg_stack(lineH);

    UD.channels(chIndex).lineH=lineH;
    UD.channels(chIndex).axesInd=axesInd;
    UD.channels(chIndex).color=get(lineH,'Color');
    UD.axes(axesInd).channels(end+1)=chIndex;


    set(UD.axes(axesInd).labelH,'String',UD.channels(chIndex).label,'Color',UD.channels(chIndex).color);

    if~doFast

        UD=rescale_axes_to_fit_data(UD,axesInd,1);

        update_axes_label(UD.axes(axesInd));


        chanStr=get(UD.hgCtrls.chanListbox,'String');


        shownPlot=[char(9745),' '];

        chanStr(chIndex,1:2)=shownPlot;
        set(UD.hgCtrls.chanListbox,'String',chanStr);


        activeDispIdx=UD.dataSet(UD.current.dataSetIdx).activeDispIdx;
        UD.dataSet(UD.current.dataSetIdx).activeDispIdx=sort([activeDispIdx,chIndex],'descend');
    end
end


function bottom_of_hg_stack(hgObj)

    parent=get(hgObj,'Parent');
    allChildren=get(parent,'Children');
    isObj=(allChildren==hgObj);
    set(parent,'Children',[allChildren(~isObj);hgObj]);
end

