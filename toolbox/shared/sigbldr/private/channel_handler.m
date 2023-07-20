function[UD,modified]=channel_handler(method,dialog,UD,varargin)







    chIdx=UD.current.channel;

    if chIdx==0
        if UD.current.axes==0
            modified=0;
            return;
        else
            axUd=get(UD.current.axes,'UserData');
            if isempty(axUd)||~isfield(axUd,'index')
                modified=0;
                return;
            else
                chIdx=UD.axes(axUd.index).channels(1);
            end
        end
    end


    switch(method)

    case{'sigrename','rename'}
        currLabel=UD.channels(chIdx).label;
        newLabel=sigbuilder_modal_edit_dialog('SetLabelStringDlg',...
        getString(message('sigbldr_ui:channel_handler:SetLabelString')),{getString(message('sigbldr_ui:channel_handler:ChannelNumber',chIdx))},{currLabel});

        [UD,modified]=signal_rename(UD,newLabel,currLabel,chIdx);


    case 'changeAxes'
        desAxes=UD.numAxes+1-varargin{1};
        if(desAxes==UD.channels(chIdx).axesInd)
            return;
        end
        UD=hide_channel(UD,chIdx);
        UD=new_plot_channel(UD,chIdx,desAxes);
        modified=1;


    case 'setColor'
        lineH=UD.channels(chIdx).lineH;
        axIdx=UD.channels(chIdx).axesInd;
        C=uisetcolor(lineH,getString(message('sigbldr_ui:channel_handler:SetChannelColor',chIdx,UD.channels(chIdx).label)));
        if length(C)>1
            UD=update_undo(UD,'edit','channel',chIdx,UD.channels(chIdx));
            set(lineH,'Color',C);
            UD.channels(chIdx).color=C;
            if axIdx>0
                set(UD.axes(axIdx).labelH,'Color',C);
            end
            UD=set_dirty_flag(UD);
            modified=1;
        else
            modified=0;
        end
        UD=update_legend_line(UD,'on',chIdx);


    case 'setWidth'
        wdth=UD.channels(chIdx).lineWidth;
        title=getString(message('sigbldr_ui:channel_handler:SetChannelWidth',chIdx,...
        UD.channels(chIdx).label));
        wdthStr=sigbuilder_modal_edit_dialog('SetChannelLineWidthDlg',...
        title,getString(message('sigbldr_ui:channel_handler:WidthColon')),num2str(wdth));
        if~ischar(wdthStr)
            modified=0;
            return;
        end
        wdth=eval_to_real_scalar(wdthStr,'width');
        if isempty(wdth)
            modified=0;
            return;
        end


        if wdth<=0
            errordlg(getString(message('sigbldr_ui:channel_handler:WidthNonZero')));
            modified=0;
            return;
        end
        UD=update_undo(UD,'edit','channel',chIdx,UD.channels(chIdx));

        UD.channels(chIdx).lineWidth=wdth;
        set(UD.channels(chIdx).lineH,'LineWidth',wdth);
        UD=update_legend_line(UD,'on',chIdx);

        UD=set_dirty_flag(UD);
        modified=1;


    case 'setLineStyle'
        modified=1;
        switch(varargin{1})
        case 'solid'
            UD=update_undo(UD,'edit','channel',chIdx,UD.channels(chIdx));
            set(UD.channels(chIdx).lineH,'LineStyle','-');
            UD.channels(chIdx).lineStyle='-';

        case 'dashed'
            UD=update_undo(UD,'edit','channel',chIdx,UD.channels(chIdx));
            set(UD.channels(chIdx).lineH,'LineStyle','--');
            UD.channels(chIdx).lineStyle='--';

        case 'dotted'
            UD=update_undo(UD,'edit','channel',chIdx,UD.channels(chIdx));
            set(UD.channels(chIdx).lineH,'LineStyle',':');
            UD.channels(chIdx).lineStyle=':';

        case 'dash-dott'
            UD=update_undo(UD,'edit','channel',chIdx,UD.channels(chIdx));
            set(UD.channels(chIdx).lineH,'LineStyle','-.');
            UD.channels(chIdx).lineStyle='-.';

        otherwise
            modified=0;
        end
        if(modified==1)
            UD=set_dirty_flag(UD);
        end

        UD=update_legend_line(UD,'on',chIdx);



    case 'yminmax'
        ActiveGroup=UD.sbobj.ActiveGroup;
        y=UD.sbobj.Groups(ActiveGroup).Signals(chIdx).YData;
        labels={getString(message('sigbldr_ui:channel_handler:MinYValue')),...
        getString(message('sigbldr_ui:channel_handler:MaxYValue'))};
        startVals={num2str(UD.channels(chIdx).yMin),num2str(UD.channels(chIdx).yMax)};
        title=getString(message('sigbldr_ui:channel_handler:SetChannelLimits',chIdx,...
        UD.channels(chIdx).label));
        vals=sigbuilder_modal_edit_dialog('SetChannelYLimitsDlg',title,...
        labels,startVals);
        if~iscell(vals)
            modified=0;
            return;
        end


        minY=eval_to_real_scalar(vals{1},'minimum',0);
        maxY=eval_to_real_scalar(vals{2},'maximum',0);
        if isempty(minY)||isempty(maxY)
            modified=0;
            return;
        end
        if maxY<=minY
            errordlg(getString(message('sigbldr_ui:channel_handler:MinimumValue')));
            modified=0;
            return;
        end

        UD=update_undo(UD,'edit','channel',chIdx,UD.channels(chIdx));
        onesY=ones(1,length(y));
        y(y>maxY)=maxY*onesY(y>maxY);
        y(y<minY)=minY*onesY(y<minY);
        UD=apply_new_channel_data(UD,chIdx,[],y);
        UD.channels(chIdx).yMin=minY;
        UD.channels(chIdx).yMax=maxY;
        modified=1;


    case 'cut'

        if(length(UD.channels)==1)
            warndlg(getString(message('sigbldr_ui:channel_handler:CutLastSignal')));
            modified=0;
            return;
        end

        choice=questdlg(getString(message('sigbldr_ui:channel_handler:CutSignalFromGroup',UD.channels(chIdx).label)),...
        getString(message('sigbldr_ui:channel_handler:CutConfirmation')),...
        getString(message('sigbldr_ui:channel_handler:OK')),getString(message('sigbldr_ui:channel_handler:Cancel')),...
        getString(message('sigbldr_ui:channel_handler:Cancel')));

        if~isempty(choice)
            switch choice
            case getString(message('sigbldr_ui:channel_handler:OK'))
                if length(UD.channels)>1
                    UD=copySignal(UD,chIdx);
                end

                [UD,modified]=deleteSignal(UD,chIdx,dialog);
            case getString(message('sigbldr_ui:channel_handler:Cancel'))
                modified=0;

            end
        else
            modified=0;
        end

    case 'copy'
        UD=copySignal(UD,chIdx);
        modified=1;


    case 'complement'
        ActiveGroup=UD.sbobj.ActiveGroup;
        y=UD.sbobj.Groups(ActiveGroup).Signals(chIdx).YData;
        [~,off]=get_amplitude_offset(y);
        ynew=-1*y+(2*off);
        UD=apply_new_channel_data(UD,chIdx,[],ynew);
        modified=1;


    case 'paste'
        UD=update_undo(UD,'edit','channel',chIdx,UD.channels(chIdx));
        lineH=UD.channels(chIdx).lineH;
        chStruct=UD.clipboard.content;
        axIdx=UD.channels(chIdx).axesInd;
        UD.channels(chIdx).stepX=chStruct.stepX;
        UD.channels(chIdx).stepY=chStruct.stepY;
        UD.channels(chIdx)=check_and_apply_line_properties(UD.channels(chIdx),UD.numChannels,chStruct.color,chStruct.lineStyle,chStruct.lineWidth);
        set(lineH,'XData',chStruct.xData,...
        'YData',chStruct.yData,...
        'Color',chStruct.color,...
        'LineWidth',chStruct.lineWidth,...
        'LineStyle',chStruct.lineStyle);

        ActiveGroup=UD.sbobj.ActiveGroup;
        UD.sbobj.Groups(ActiveGroup).Signals(chIdx).XData=chStruct.xData;
        UD.sbobj.Groups(ActiveGroup).Signals(chIdx).YData=chStruct.yData;

        if axIdx>0
            UD=rescale_axes_to_fit_data(UD,axIdx,1);
            UD=update_channel_select(UD);
            set(UD.axes(axIdx).labelH,'Color',chStruct.color);
        end

        modified=1;


    case 'delete'
        if(length(UD.channels)==1)
            warndlg(getString(message('sigbldr_ui:channel_handler:DeleteLastSignal')));
            modified=0;
            return;
        end

        choice=questdlg(getString(message('sigbldr_ui:channel_handler:DeleteSignalFromGroup',UD.channels(chIdx).label)),...
        getString(message('sigbldr_ui:channel_handler:DeleteConfirmation')),...
        getString(message('sigbldr_ui:channel_handler:OK')),getString(message('sigbldr_ui:channel_handler:Cancel')),...
        getString(message('sigbldr_ui:channel_handler:Cancel')));

        if~isempty(choice)
            switch choice
            case getString(message('sigbldr_ui:channel_handler:OK'))
                [UD,modified]=deleteSignal(UD,chIdx,dialog);
            case getString(message('sigbldr_ui:channel_handler:Cancel'))
                modified=0;

            end
        else
            modified=0;
        end

    case 'sighide'
        dsIdx=UD.current.dataSetIdx;
        axesIdx=UD.channels(chIdx).axesInd;

        [UD,modified]=signal_hide(UD,chIdx,dsIdx,axesIdx);

    case{'setStepX','setStepY'}
        if chIdx==0
            axesUD=get(UD.current.axes,'UserData');
            if isempty(axesUD)
                modified=0;
                return;
            end
            axesInd=axesUD.index;
            chIdx=UD.axes(axesInd).channels(1);
        end
        UD=update_undo(UD,'edit','channel',chIdx,UD.channels(chIdx));
        switch(method)
        case 'setStepX'
            UD.channels(chIdx).stepX=varargin{1};
        case 'setStepY'
            UD.channels(chIdx).stepY=varargin{1};
        end
        UD=update_channel_select(UD);
        UD=set_dirty_flag(UD);
        modified=1;
    otherwise,
        error(message('sigbldr_ui:channel_handler:unknownMethod'));
    end
end



function[amplitude,offset]=get_amplitude_offset(y)
    yMax=max(y);
    yMin=min(y);
    amplitude=(yMax-yMin)/2;
    offset=(yMax+yMin)/2;
end

