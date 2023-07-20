function UD=group_activate(UD,newActiveGroupIdx,suppressStore,allowUndo,relativeActiveGroupIdx)




    if nargin<4
        allowUndo=false;
    end

    if nargin<3
        suppressStore=false;
    end

    oldActiveGroupIdx=UD.current.dataSetIdx;
    if oldActiveGroupIdx==-1
        oldActiveGroupIdx=[];
        oldVisChannels=[];
        oldCnt=0;
    else
        oldVisChannels=UD.dataSet(oldActiveGroupIdx).activeDispIdx;
        oldCnt=length(oldVisChannels);
    end

    newVisChannels=UD.dataSet(newActiveGroupIdx).activeDispIdx;
    newCnt=length(newVisChannels);

    DO_FAST=1;

    if newActiveGroupIdx==oldActiveGroupIdx
        return;
    end

    if is_req_dialog_open(UD.common)
        sigbuilder_tabselector('activate',UD.hgCtrls.tabselect.axesH,oldActiveGroupIdx,1);
        need_to_close_rmi;
        return;
    end


    switch(UD.current.mode)
    case{1,3}

    otherwise
        UD=mouse_handler('ForceMode',UD.dialog,UD,1);
    end

    if strcmp(get(UD.tlegend.scrollbar,'Visible'),'on')
        set(UD.tlegend.scrollbar,'Enable','off','Visible','off');
        UD.current.axesExtent=UD.current.axesExtent+[0,-1,0,1]*UD.geomConst.scrollHeight;
    end

    if~allowUndo
        UD=cant_undo(UD);
    end


    if~suppressStore
        UD=group_store(UD);
    end


    set(UD.dialog,'Pointer','watch');


    if isequal(oldVisChannels,newVisChannels)
        applyDataOnly=ones(1,oldCnt);
        lastApply=oldCnt;
    else
        newCnt=length(newVisChannels);


        if oldCnt>newCnt
            if newCnt>0
                applyDataOnly=oldVisChannels(1:newCnt)==newVisChannels;
            end
            lastApply=newCnt;
            for i=(newCnt+1):oldCnt
                UD=remove_axes(UD,newCnt+1,DO_FAST);
            end


            if newCnt>0
                [UD.channels(newVisChannels).lineH]=deal(UD.channels(oldVisChannels(1:newCnt)).lineH);
                [UD.channels(newVisChannels).axesInd]=deal(UD.channels(oldVisChannels(1:newCnt)).axesInd);
            end

        elseif newCnt>oldCnt
            if oldCnt>0
                applyDataOnly=oldVisChannels==newVisChannels(1:oldCnt);
            else
                applyDataOnly=[];
            end
            lastApply=oldCnt;
            cantShow=0;
            for i=(oldCnt+1):newCnt
                if is_space_for_new_axes(UD.current.axesExtent,UD.geomConst,UD.numAxes)
                    UD=new_axes(UD,i,[],[-1,1],UD.common.dispTime,DO_FAST);
                else
                    cantShow=cantShow+1;
                end
            end
            if cantShow>0;
                newVisChannels(oldCnt-(1:cantShow))=[];
                UD.dataSet(newActiveGroupIdx).activeDispIdx=newVisChannels;
                newCnt=newCnt-cantShow;
            end


            if oldCnt>0
                [UD.channels(newVisChannels(1:oldCnt)).lineH]=deal(UD.channels(oldVisChannels).lineH);
                [UD.channels(newVisChannels(1:oldCnt)).axesInd]=deal(UD.channels(oldVisChannels).axesInd);
            end

        else
            applyDataOnly=oldVisChannels==newVisChannels;
            lastApply=newCnt;


            [UD.channels(newVisChannels).lineH]=deal(UD.channels(oldVisChannels).lineH);
            [UD.channels(newVisChannels).axesInd]=deal(UD.channels(oldVisChannels).axesInd);
        end


        newInvisible=setdiff(1:length(UD.channels),newVisChannels);
        if~isempty(newInvisible)
            [UD.channels(newInvisible).lineH]=deal([]);
            [UD.channels(newInvisible).axesInd]=deal(0);
        end


        if lastApply>0
            chCell=num2cell(newVisChannels(1:lastApply));
            [UD.axes(1:lastApply).channels]=deal(chCell{:});
        end
    end


    UD.current.mode=1;
    if isempty(UD.dataSet(newActiveGroupIdx).activeDispIdx)
        UD.current.channel=0;
        UD.current.axes=0;
    else
        UD.current.channel=UD.dataSet(newActiveGroupIdx).activeDispIdx(end);
        UD.current.axes=UD.axes(1).handle;
    end

    UD.current.editPoints=[];
    UD.current.tempPoints=[];
    UD.current.bdPoint=[0,0];
    UD.current.bdObj=[];
    UD.current.prevbdObj=[];
    UD.current.selectLine=[];
    UD.current.zoomStart=[];
    UD.current.zoomAxesInd=[];
    UD.current.zoomXLine=[];
    UD.current.zoomYLine=[];
    UD.current.lockOutSingleClick=0;
    UD.common.dispMode=1;
    UD.common.minTime=UD.dataSet(newActiveGroupIdx).timeRange(1);
    UD.common.maxTime=UD.dataSet(newActiveGroupIdx).timeRange(2);

    if~(isfield(UD.dataSet(newActiveGroupIdx),'displayRange'))
        UD.common.dispTime=UD.dataSet(newActiveGroupIdx).timeRange;
    else
        if~(isempty(UD.dataSet(newActiveGroupIdx).displayRange))
            UD.common.dispTime=UD.dataSet(newActiveGroupIdx).displayRange;
        else
            UD.common.dispTime=UD.dataSet(newActiveGroupIdx).timeRange;
            UD.dataSet(newActiveGroupIdx).displayRange=UD.common.dispTime;
        end
    end

    UD.current.dataSetIdx=relativeActiveGroupIdx;


    if isfield(UD,'axes')
        if length(UD.axes)>1
            if isfield(UD.dataSet,'displayRange')&&...
                ~isempty(UD.dataSet(newActiveGroupIdx).displayRange)&&...
                (UD.dataSet(newActiveGroupIdx).timeRange(1)~=UD.dataSet(newActiveGroupIdx).displayRange(1)||...
                UD.dataSet(newActiveGroupIdx).timeRange(2)~=UD.dataSet(newActiveGroupIdx).displayRange(2))
                UD=set_new_time_range(UD,UD.dataSet(newActiveGroupIdx).displayRange,0);
            else
                set([UD.axes.handle],{'XLim'},{UD.dataSet(newActiveGroupIdx).timeRange});
            end
        elseif~isempty(UD.axes)
            if isfield(UD.dataSet,'displayRange')&&...
                (UD.dataSet(newActiveGroupIdx).timeRange(1)~=UD.dataSet(newActiveGroupIdx).displayRange(1)||...
                UD.dataSet(newActiveGroupIdx).timeRange(2)~=UD.dataSet(newActiveGroupIdx).displayRange(2))
                UD=set_new_time_range(UD,UD.dataSet(newActiveGroupIdx).displayRange,0);
            else
                set(UD.axes.handle,'XLim',UD.dataSet(newActiveGroupIdx).timeRange);
            end
        end
    end



    lineUD.index=0;
    lineUD.type='Channel';


    for i=1:lastApply
        chIdx=newVisChannels(i);
        lineUD.index=chIdx;
        if(applyDataOnly(i))
            set(UD.channels(chIdx).lineH...
            ,'UserData',lineUD...
            ,'XData',UD.sbobj.Groups(relativeActiveGroupIdx).Signals(chIdx).XData...
            ,'YData',UD.sbobj.Groups(relativeActiveGroupIdx).Signals(chIdx).YData);
        else
            set(UD.channels(chIdx).lineH...
            ,'UserData',lineUD...
            ,'Color',UD.channels(chIdx).color...
            ,'LineWidth',UD.channels(chIdx).lineWidth...
            ,'LineStyle',UD.channels(chIdx).lineStyle...
            ,'XData',UD.sbobj.Groups(relativeActiveGroupIdx).Signals(chIdx).XData...
            ,'YData',UD.sbobj.Groups(relativeActiveGroupIdx).Signals(chIdx).YData);


            set(UD.axes(i).labelH,'String',UD.channels(chIdx).label,...
            'Color',UD.channels(chIdx).color);
        end
    end


    for i=(lastApply+1):newCnt
        chIdx=newVisChannels(i);
        UD=new_plot_channel(UD,chIdx,i,DO_FAST);
    end


    numChan=length(UD.channels);
    notShown=false(1,numChan);
    for i=1:numChan
        notShown(i)=isempty(UD.channels(i).lineH);
    end
    chanStr=get(UD.hgCtrls.chanListbox,'String');


    shownPlot=[char(9745),' '];

    hiddenPlot=[char(9744),' '];


    chanStr(notShown,1:2)=char(ones(sum(notShown),1)*hiddenPlot);

    chanStr(~notShown,1:2)=char(ones(sum(~notShown),1)*shownPlot);

    set(UD.hgCtrls.chanListbox,'String',chanStr);

    UD=update_channel_select(UD);
    UD=update_show_menu(UD);
    UD=set_dirty_flag(UD);
    UD=dataSet_sync_menu_state(UD);

    for i=1:newCnt
        UD=rescale_axes_to_fit_data(UD,i,1,DO_FAST);
    end


    UD=resize(UD);

    set(UD.dialog,'Pointer','arrow');


    if isfield(UD,'simulink')&&~isempty(UD.simulink)
        vnv_notify('sbBlkGroupChange',UD.simulink.subsysH,newActiveGroupIdx);

        if vnv_enabled&&isfield(UD,'verify')&&isfield(UD.verify,'jVerifyPanel')
            vnv_panel_mgr('sbGroupChange',UD.simulink.subsysH,UD.verify.jVerifyPanel);

        end
    end
