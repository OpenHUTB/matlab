function[figH,errMsg]=printUD(UD,config,method,varargin)







    figH=[];
    errMsg='';

    if isfield(config,'showTitle')&&~isempty(config.showTitle)
        showTitle=config.showTitle;
    else
        showTitle=true;
    end

    if isempty(config)
        figH=print_to_figure(UD,true);
    else
        errMsg=print_config_check(UD,config);
        if~isempty(errMsg)
            return;
        end


        startvisibility=get(UD.dialog,'Visible');
        modelDirtyFlag=get_param(UD.simulink.modelH,'dirty');
        dirtyFlag=UD.common.dirtyFlag;
        dataSetCache=UD.dataSet;
        configCache=print_config_capture(UD);

        set(UD.dialog,'Visible','off');
        UD=print_config_apply(UD,config,1.0);
        set(UD.dialog,'UserData',UD);
        figH=print_to_figure(UD,showTitle);


        UD=print_config_apply(UD,configCache,-1.0);
        UD.common.dirtyFlag=dirtyFlag;
        UD.dataSet=dataSetCache;
        set(UD.dialog,'UserData',UD);
        set_param(UD.simulink.modelH,'dirty',modelDirtyFlag);
        set(UD.dialog,'Visible',startvisibility);
    end

    switch(method)
    case 'figure'
        return;

    case 'cmd'
        print(figH,varargin{1}{:});
        delete(figH);
        return;

    case 'dlg'
        printdlg(figH);
        delete(figH);
        return;

    otherwise
        error(message('sigbldr_ui:printCmd:unknownMethod'));
    end
end



function UD=print_config_apply(UD,config,scale)


    axExtent=UD.current.axesExtent;
    if isfield(config,'extent')&&~isempty(config.extent)
        desiredPointExt=pixels2points(UD.dialog,config.extent);
    else
        desiredPointExt=axExtent(3:4);
    end

    if~isequal(axExtent(3:4),desiredPointExt)






        delta=desiredPointExt-axExtent(3:4)-scale*(UD.geomConst.figBuffer);
        uiPos=get(UD.dialog,'Position');
        uiPos(3:4)=uiPos(3:4)+delta;
        if(uiPos(3)<UD.minExtent(1))||(uiPos(4)<UD.minExtent(2))
            error(message('sigbldr_ui:signalbuilder:printExtentTooSmall'));
        end
        set(UD.dialog,'UserData',UD);
        set(UD.dialog,'Position',uiPos);
        drawnow;
        UD=get(UD.dialog,'UserData');
    end


    if~isfield(config,'groupIndex')||isempty(config.groupIndex)||config.groupIndex==UD.current.dataSetIdx
        if isfield(config,'visibleSignals')&&~isempty(config.visibleSignals)
            config.visibleSignals=sort(unique(config.visibleSignals));
            currentSignals=sort(UD.dataSet(UD.current.dataSetIdx).activeDispIdx);

            if~isequal(config.visibleSignals,currentSignals)
                addSignals=setdiff(config.visibleSignals,currentSignals);
                removeSignals=setdiff(currentSignals,config.visibleSignals);


                for chanIdx=removeSignals(:)'
                    axesIdx=UD.channels(chanIdx).axesInd;
                    UD=hide_channel(UD,chanIdx);
                    UD=remove_axes(UD,axesIdx);
                end


                dispChannelIdx=intersect(config.visibleSignals,currentSignals);
                dispChannelIdx=sort(dispChannelIdx,'descend');

                for chanIdx=addSignals(:)'
                    if is_space_for_new_axes(UD.current.axesExtent,UD.geomConst,UD.numAxes)
                        newAxesIdx=sum(dispChannelIdx>chanIdx)+1;
                        UD=new_axes(UD,newAxesIdx,[]);
                        UD=new_plot_channel(UD,chanIdx,newAxesIdx);
                        dispChannelIdx=sort([dispChannelIdx,chanIdx],'descend');
                    end
                end
                UD.dataSet(UD.current.dataSetIdx).activeDispIdx=fliplr(config.visibleSignals);
                UD=update_show_menu(UD);
            end
        end
    else
        if isfield(config,'visibleSignals')&&~isempty(config.visibleSignals)
            config.visibleSignals=sort(unique(config.visibleSignals));
            UD.dataSet(config.groupIndex).activeDispIdx=fliplr(config.visibleSignals);
        end
        UD=dataSet_activate(UD,config.groupIndex,1,0);
    end


    if isfield(config,'timeRange')&&~isempty(config.timeRange)
        UD=set_new_time_range(UD,config.timeRange);
    end


    if isfield(config,'yLimits')&&~isempty(config.yLimits)
        idx=1;
        for chIdx=length(UD.channels):-1:1
            if length(config.yLimits)>1
                idx=chIdx;
            end
            axIdx=UD.channels(chIdx).axesInd;
        end
        for chIdx=1:length(UD.channels)
            if length(config.yLimits)>1
                idx=chIdx;
            end
            axIdx=UD.channels(chIdx).axesInd;
            if axIdx>0&&diff(config.yLimits{idx})>0
                UD.axes(axIdx).yLim=config.yLimits{idx};
                set(UD.axes(axIdx).handle,'YLim',config.yLimits{idx});
                update_axes_label(UD.axes(axIdx));
            end
        end
    end
end

function config=print_config_capture(UD)

    config.groupIndex=UD.current.dataSetIdx;
    config.timeRange=[UD.common.minTime,UD.common.maxTime];
    config.visibleSignals=sort(UD.dataSet(UD.current.dataSetIdx).activeDispIdx);


    config.yLimits=cell(1,length(UD.channels));
    for chIdx=1:length(UD.channels)
        axIdx=UD.channels(chIdx).axesInd;
        if axIdx>0
            config.yLimits{chIdx}=get(UD.axes(axIdx).handle,'Ylim');
        end
    end

    config.extent=points2pixels(UD,UD.current.axesExtent(3:4));
    config.showTitle=true;
end

function errMsg=print_config_check(UD,config)








    errMsg='';


    if isfield(config,'groupIndex')&&~isempty(config.groupIndex)
        groupIndex=config.groupIndex;
        if~isnumeric(groupIndex)||length(groupIndex)>1||...
            groupIndex<1||groupIndex>length(UD.dataSet)
            errMsg=getString(message('sigbldr_ui:printCmd:ConfigGroupIndex',length(UD.dataSet)));
        end
    else
        groupIndex=UD.current.dataSetIdx;
    end

    if~isempty(errMsg),return;end


    totalRange=UD.dataSet(groupIndex).timeRange;
    if isfield(config,'timeRange')&&~isempty(config.timeRange)
        timeRange=config.timeRange;
        if~isnumeric(timeRange)||length(timeRange)~=2||...
            timeRange(1)>=timeRange(2)
            errMsg=getString(message('sigbldr_ui:printCmd:ConfigTRangeIncreasing'));
        elseif timeRange(1)>=totalRange(2)||timeRange(2)<=totalRange(1)
            errMsg=getString(message('sigbldr_ui:printCmd:ConfigTRange'));
        end
    end

    if~isempty(errMsg),return;end


    if isfield(config,'visibleSignals')&&~isempty(config.visibleSignals)
        visibleSignals=config.visibleSignals;
        if~isnumeric(visibleSignals)||any(visibleSignals<1)||any(visibleSignals>length(UD.channels))
            errMsg=getString(message('sigbldr_ui:printCmd:ConfigVisibleSignal',length(UD.channels)));
        end
    else
        visibleSignals=sort(UD.dataSet(UD.current.dataSetIdx).activeDispIdx);%#ok
    end

    if~isempty(errMsg),return;end


    if isfield(config,'yLimits')&&~isempty(config.yLimits)
        yLimits=config.yLimits;
        if~iscell(yLimits)||(length(yLimits)~=1&&length(yLimits)~=length(UD.channels))
            errMsg=getString(message('sigbldr_ui:printCmd:ConfigYLimitCell',length(UD.channels)));
        else
            for idx=1:length(yLimits)
                if~isnumeric(yLimits{idx})||length(yLimits{idx})~=2||diff(yLimits{idx})<=0
                    errMsg=getString(message('sigbldr_ui:printCmd:ConfigYLimit',idx));
                end
            end
        end
    end

    if~isempty(errMsg),return;end


    if isfield(config,'extent')&&~isempty(config.extent)
        extent=config.extent;
        if~isnumeric(extent)||length(extent)~=2
            errMsg=getString(message('sigbldr_ui:printCmd:ConfigExtent'));
        end
    else
        points2pixels(UD,UD.current.axesExtent(3:4));
    end

    if~isempty(errMsg),return;end


    if isfield(config,'showTitle')&&~isempty(config.showTitle)&&~islogical(config.showTitle)
        errMsg=getString(message('sigbldr_ui:printCmd:ConfigShowTitle'));
    end

    if~isempty(errMsg),return;end
end

function figH=print_to_figure(UD,showTitle)

    figH=figure(...
    'NumberTitle','off',...
    'MenuBar','figure',...
    'PaperPositionMode','manual',...
    'Units','points',...
    'HandleVisibility','callback',...
    'Interruptible','off',...
    'IntegerHandle','off',...
    'Toolbar','figure',...
    'Visible','off');

    dialogH=UD.dialog;
    axesH=[UD.axes.handle];
    axExtent=UD.current.axesExtent;
    blockH=UD.simulink.subsysH;


    util_copyprop(dialogH,figH,'Units');
    util_copyprop(dialogH,figH,'Color');


    allLines=[UD.channels.lineH];
    set(allLines,'Marker','none');



    figPos=get(figH,'Position');
    if showTitle
        nspace=4+length(axesH)-1;
    else
        nspace=2+length(axesH)-1;
    end
    figPos(3:4)=axExtent(3:4)+[2,nspace]*UD.geomConst.figBuffer;


    margin=10;
    screenUnits=get(0,'Units');
    set(0,'Units','Points');
    screenPos=get(0,'ScreenSize');
    set(0,'Units',screenUnits);

    if[1,0,1,0]*figPos(:)>(screenPos(3)-margin)
        figPos(1)=screenPos(3)-figPos(3)-margin;
    end
    if[0,1,0,1]*figPos(:)>(screenPos(4)-margin)
        figPos(2)=screenPos(4)-figPos(4)-margin;
    end

    set(figH,'Position',figPos,'Toolbar','none');


    newAxesH=copyobj(axesH,figH);


    util_moveobj(newAxesH,-axExtent(1)+UD.geomConst.figBuffer,-axExtent(2)+1.5*UD.geomConst.figBuffer);


    for axIdx=2:length(axesH)
        util_moveobj(newAxesH(axIdx),0,(axIdx-1)*UD.geomConst.figBuffer);
    end


    set(newAxesH,'FontWeight','normal');
    xlabels=get(newAxesH,'Xlabel');
    if~iscell(xlabels),xlabels={xlabels};end
    set([xlabels{:}],'FontWeight','normal');

    if showTitle
        groupLabel=UD.dataSet(UD.current.dataSetIdx).name;
        modelName=get_param(bdroot(blockH),'Name');
        blockLabel=[modelName,formatted_block_name(blockH,length(modelName))];
        titleStr=[blockLabel,' : ',groupLabel];
        title(newAxesH(end),titleStr,'Interpreter','none');
    end
end


function labelstr=formatted_block_name(blockH,mdlNameLength)

    maxStrLength=45;
    maxParentLength=14;

    blkPath=getfullname(blockH);
    dispPath=blkPath((mdlNameLength+1):end);
    dispPath=strrep(dispPath,char(10),' ');



    if length(dispPath)<=maxStrLength

        labelstr=dispPath;
    else
        parentH=get_param(get_param(blockH,'Parent'),'Handle');
        if(parentH==bdroot(blockH))

            labelstr=[dispPath(1:(maxStrLength-3)),'...'];
        else
            grandParentH=get_param(get_param(parentH,'Parent'),'Handle');
            parentName=get_param(parentH,'Name');

            if(grandParentH==bdroot(blockH))
                if(length(parentName)>maxParentLength)

                    labelstr=['/',parentName(1:(maxParentLength-3)),'.../',get_param(blockH,'Name')];
                else

                    labelstr=dispPath;
                end
            else
                if(length(parentName)>maxParentLength)

                    labelstr=['/../',parentName(1:(maxParentLength-3)),'.../',get_param(blockH,'Name')];
                else

                    labelstr=['/../',parentName,'/',get_param(blockH,'Name')];
                end
            end

            if(length(labelstr)>maxStrLength)
                labelstr=[labelstr(1:(maxStrLength-3)),'...'];
            end
        end
    end
end

function util_copyprop(sourceH,destH,prop)

    value=get(sourceH,prop);
    set(destH,prop,value);
end

function util_moveobj(hgObjs,deltaX,deltaY)

    if length(hgObjs)>1
        positionCell=get(hgObjs,'Position');
        positionMatrix=cat(1,positionCell{:});
        positionMatrix(:,1)=positionMatrix(:,1)+deltaX;
        positionMatrix(:,2)=positionMatrix(:,2)+deltaY;
        newPositionCell=num2cell(positionMatrix,2);
        set(hgObjs,{'Position'},newPositionCell);
    else
        oldPos=get(hgObjs,'Position');
        set(hgObjs,'Position',oldPos+[deltaX,deltaY,0,0]);
    end
end

