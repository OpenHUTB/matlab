function UD=change_channel_index(UD,newIdx,oldIdx)






    dsIdx=UD.current.dataSetIdx;
    activeDispIdx=UD.dataSet(dsIdx).activeDispIdx;
    chanCnt=length(UD.channels);

    if newIdx>oldIdx
        changeAxesIdx=find(activeDispIdx>=oldIdx&activeDispIdx<=newIdx);
        old2newIdx=[1:(oldIdx-1),(oldIdx+1):newIdx,oldIdx,(newIdx+1):chanCnt];
        old2newAxIdx=[1:(changeAxesIdx(1)-1)...
        ,changeAxesIdx(end)...
        ,changeAxesIdx(1:(end-1))...
        ,(changeAxesIdx(end)+1):length(UD.axes)];
    else
        changeAxesIdx=find(activeDispIdx>=newIdx&activeDispIdx<=oldIdx);
        old2newIdx=[1:(newIdx-1),oldIdx,newIdx:(oldIdx-1),(oldIdx+1):chanCnt];
        old2newAxIdx=[1:(changeAxesIdx(1)-1)...
        ,changeAxesIdx(2:end)...
        ,changeAxesIdx(1)...
        ,(changeAxesIdx(end)+1):length(UD.axes)];
    end


    if length(changeAxesIdx)>1
        axesObjs=cat(1,UD.axes.handle);

        axPos=get(axesObjs(changeAxesIdx),'Position');
        newOrderAxes=axesObjs(old2newAxIdx(changeAxesIdx));
        set(newOrderAxes,{'Position'},axPos);

        UD.axes=UD.axes(old2newAxIdx);
    end


    UD.channels=UD.channels(old2newIdx);


    grpCnt=UD.sbobj.NumGroups;
    for k=1:grpCnt;

        UD.sbobj.Groups(k).signalReorder(old2newIdx);
    end

    listBoxStr=get(UD.hgCtrls.chanListbox,'String');
    set(UD.hgCtrls.chanListbox,'String',listBoxStr(old2newIdx,:));

    [~,new2oldIdx]=sort(old2newIdx);
    for i=1:length(UD.dataSet)
        UD.dataSet(i).activeDispIdx=sort(new2oldIdx(UD.dataSet(i).activeDispIdx),'descend');
    end


    newActiveDispIdx=UD.dataSet(dsIdx).activeDispIdx;


    for i=1:length(newActiveDispIdx)
        chIdx=newActiveDispIdx(i);
        if~isempty(UD.channels(chIdx).lineH)
            lineUd=get(UD.channels(chIdx).lineH,'UserData');
            lineUd.index=chIdx;
            set(UD.channels(chIdx).lineH,'UserData',lineUd);
            UD.channels(chIdx).axesInd=i;
        end
    end



    for axIdx=changeAxesIdx(:)'
        axUd=get(UD.axes(axIdx).handle,'UserData');
        axUd.index=axIdx;
        set(UD.axes(axIdx).handle,'UserData',axUd);
        UD.axes(axIdx).channels=UD.dataSet(dsIdx).activeDispIdx(axIdx);
    end




    if(changeAxesIdx(1)==1)
        xlabelAxes=UD.axes(old2newAxIdx==1).handle;
        axesH=UD.axes(1).handle;
        xl=get(axesH,'XLabel');
        set(axesH,'XTick',get(xlabelAxes,'XTick'));
        set(axesH,'XTickLabel',get(xlabelAxes,'XTickLabel'));
        set(xlabelAxes,'XTickLabel','');
        xlold=get(xlabelAxes,'XLabel');
        set(xlold,'String','');
        ax.XTickLabelMode='auto';
        ax.XTickMode='auto';
        set(xl,'String',getString(message('sigbldr_ui:create:TimeSec')),'FontWeight','Bold');
        set(axesH,ax);
    end



    UD.current.channel=newIdx;
    UD=mouse_handler('ForceMode',UD.dialog,UD,3);
    UD=update_channel_select(UD);

    if~isempty(UD.simulink)
        UD.simulink=sigbuilder_block('move_port',UD.simulink,newIdx,oldIdx);
    end

    update_all_axes_label(UD.axes);
    sigbuilder_tabselector('touch',UD.hgCtrls.tabselect.axesH);
