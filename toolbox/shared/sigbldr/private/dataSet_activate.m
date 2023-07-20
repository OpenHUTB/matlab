function UD=dataSet_activate(UD,newDatasetIdx,suppressStore,allowUndo)




    if nargin<4
        allowUndo=false;
    end

    if nargin<3
        suppressStore=false;
    end


    oldDatasetIdx=UD.current.dataSetIdx;

    if oldDatasetIdx==-1
        oldDatasetIdx=[];
        oldVisChannels=[];
        oldCnt=0;


        UD.current.channel=1;
    else

        oldVisChannels=UD.dataSet(oldDatasetIdx).activeDispIdx;
        oldCnt=length(oldVisChannels);
    end

    newVisChannels=UD.dataSet(newDatasetIdx).activeDispIdx;
    newCnt=length(newVisChannels);

    DO_FAST=1;

    if newDatasetIdx==oldDatasetIdx

        return;
    end

    if is_req_dialog_open(UD.common)

        sigbuilder_tabselector('activate',UD.hgCtrls.tabselect.axesH,oldDatasetIdx,1);
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
        UD=dataSet_store(UD);
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
            if cantShow>0

                newVisChannels(newCnt+1-(1:cantShow))=[];
                UD.dataSet(newDatasetIdx).activeDispIdx=newVisChannels;
                newCnt=newCnt-cantShow;
            end


            if oldCnt>0
                [UD.channels(newVisChannels(1:oldCnt)).lineH]=deal(UD.channels(oldVisChannels).lineH);
                [UD.channels(newVisChannels(1:oldCnt)).axesInd]=deal(UD.channels(oldVisChannels).axesInd);
            end

        else

            lastApply=newCnt;
            if(~isempty(oldVisChannels)&&~isempty(newVisChannels))
                applyDataOnly=oldVisChannels==newVisChannels;
                lastApply=newCnt;


                [UD.channels(newVisChannels).lineH]=deal(UD.channels(oldVisChannels).lineH);
                [UD.channels(newVisChannels).axesInd]=deal(UD.channels(oldVisChannels).axesInd);
            end
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
    UD.common.minTime=UD.dataSet(newDatasetIdx).timeRange(1);
    UD.common.maxTime=UD.dataSet(newDatasetIdx).timeRange(2);

    if~(isfield(UD.dataSet(newDatasetIdx),'displayRange'))
        UD.common.dispTime=UD.dataSet(newDatasetIdx).timeRange;
    else
        if~(isempty(UD.dataSet(newDatasetIdx).displayRange))
            UD.common.dispTime=UD.dataSet(newDatasetIdx).displayRange;
        else
            UD.common.dispTime=UD.dataSet(newDatasetIdx).timeRange;
            UD.dataSet(newDatasetIdx).displayRange=UD.common.dispTime;
        end
    end

    UD.current.dataSetIdx=newDatasetIdx;
    UD.sbobj.ActiveGroup=newDatasetIdx;


    if isfield(UD,'axes')
        if length(UD.axes)>1
            if isfield(UD.dataSet,'displayRange')&&~isempty(UD.dataSet(newDatasetIdx).displayRange)&&...
                (UD.dataSet(newDatasetIdx).timeRange(1)~=UD.dataSet(newDatasetIdx).displayRange(1)||...
                UD.dataSet(newDatasetIdx).timeRange(2)~=UD.dataSet(newDatasetIdx).displayRange(2))
                UD=set_new_time_range(UD,UD.dataSet(newDatasetIdx).displayRange,0);
            else
                set([UD.axes.handle],{'XLim'},{UD.dataSet(newDatasetIdx).timeRange});
            end
        elseif~isempty(UD.axes)
            if isfield(UD.dataSet,'displayRange')&&(UD.dataSet(newDatasetIdx).timeRange(1)~=UD.dataSet(newDatasetIdx).displayRange(1)||...
                UD.dataSet(newDatasetIdx).timeRange(2)~=UD.dataSet(newDatasetIdx).displayRange(2))
                UD=set_new_time_range(UD,UD.dataSet(newDatasetIdx).displayRange,0);
            else
                set(UD.axes.handle,'XLim',UD.dataSet(newDatasetIdx).timeRange);
            end
        end
    end



    lineUD.index=0;
    lineUD.type='Channel';

    ActiveGroup=UD.sbobj.ActiveGroup;
    for i=1:lastApply
        chIdx=newVisChannels(i);
        lineUD.index=chIdx;

        if(applyDataOnly(i))
            set(UD.channels(chIdx).lineH,'UserData',lineUD,...
            'XData',UD.sbobj.Groups(ActiveGroup).Signals(chIdx).XData...
            ,'YData',UD.sbobj.Groups(ActiveGroup).Signals(chIdx).YData...
            ,'Marker','none');
        else
            set(UD.channels(chIdx).lineH...
            ,'UserData',lineUD...
            ,'Color',UD.channels(chIdx).color...
            ,'LineWidth',UD.channels(chIdx).lineWidth...
            ,'LineStyle',UD.channels(chIdx).lineStyle...
            ,'XData',UD.sbobj.Groups(ActiveGroup).Signals(chIdx).XData...
            ,'YData',UD.sbobj.Groups(ActiveGroup).Signals(chIdx).YData...
            ,'Marker','none');


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


    if~isempty(chanStr(notShown))
        chanStr(notShown,1:2)=char(ones(sum(notShown),1)*hiddenPlot);
    end

    if~isempty(chanStr(~notShown))
        chanStr(~notShown,1:2)=char(ones(sum(~notShown),1)*shownPlot);
    end

    set(UD.hgCtrls.chanListbox,'String',chanStr);

    if UD.current.channel~=0&&...
        ~isempty(UD.dataSet(newDatasetIdx).activeDispIdx)&&...
        min(abs(UD.dataSet(newDatasetIdx).activeDispIdx-UD.current.channel))==0

        UD=trimDataPoints(UD);


        UD=update_channel_select(UD);
        UD=update_show_menu(UD);

        UD.current.axes=get(UD.channels(UD.current.channel).lineH,'Parent');
        update_gca_display(UD.current.axes,UD.hgCtrls.tabselect.axesH);
        UD.current.mode=3;
    else









        tempChannel=UD.current.channel;


        if~isempty(UD.dataSet(newDatasetIdx).activeDispIdx)
            UD.current.channel=UD.dataSet(newDatasetIdx).activeDispIdx(end);
        else
            UD.current.channel=0;
        end

        UD=trimDataPoints(UD);
        UD=update_channel_select(UD);
        UD=update_show_menu(UD);
        UD.current.channel=tempChannel;

        if~isempty(UD.dataSet(newDatasetIdx).activeDispIdx)


            currentAxes=UD.axes(end).handle;
            update_gca_display(currentAxes,UD.hgCtrls.tabselect.axesH);
        end
    end

    UD=set_dirty_flag(UD);
    UD=dataSet_sync_menu_state(UD);

    for i=1:newCnt
        UD=rescale_axes_to_fit_data(UD,i,1,DO_FAST);
    end


    UD=resize(UD);

    set(UD.dialog,'Pointer','arrow');


    if isfield(UD,'simulink')&&~isempty(UD.simulink)
        vnv_notify('sbBlkGroupChange',UD.simulink.subsysH,newDatasetIdx);

        set(UD.dialog,'UserData',UD);
        refreshGroupAnnotation(UD.simulink.subsysH);
        if vnv_rmi_installed&&isfield(UD,'verify')&&isfield(UD.verify,'jVerifyPanel')
            vnv_panel_mgr('sbGroupChange',UD.simulink.subsysH,UD.verify.jVerifyPanel);

        end
    end
