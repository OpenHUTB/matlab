function[UD,modified]=channel_ui_handler(method,UD,varargin)







    chIdx=UD.current.channel;
    ActiveGroup=UD.sbobj.ActiveGroup;

    if chIdx>0
        axIdx=UD.channels(chIdx).axesInd;
    end

    switch(method)
    case 'label'
        newStr=get(UD.hgCtrls.chDispProp.labelEdit,'String');
        oldStr=UD.sbobj.Groups(ActiveGroup).Signals(chIdx).Name;


        [UD,modified]=signal_rename(UD,newStr,oldStr,chIdx);


    case 'index'
        newIdx=get(UD.hgCtrls.chDispProp.indexPopup,'Value');
        chIdx=UD.current.channel;
        [UD,modified]=changeIndexSignal(UD,newIdx,chIdx);


    case 'leftX'
        Ipts=UD.current.editPoints;
        if((Ipts(1)==1)|(Ipts(1)==length(UD.sbobj.Groups(ActiveGroup).Signals(chIdx).XData)))

            warndlg(getString(message('sigbldr_ui:channel_ui_handler:MinimumDisplay',UD.common.minTime)));

            newStr=num2str(UD.sbobj.Groups(ActiveGroup).Signals(chIdx).XData(Ipts(1)));
            set(UD.hgCtrls.chLeftPoint.xNumDisp,'String',newStr);
            modified=0;
            return;
        end
        str=get(UD.hgCtrls.chLeftPoint.xNumDisp,'String');

        newVal=str2num(str);%#ok<ST2NM>

        if isempty(newVal)||length(newVal)>1||any(~isfinite(newVal))
            errordlg(getString(message('sigbldr_ui:channel_ui_handler:InvalidEntry')));
            modified=0;
            return;
        end
        if~isempty(Ipts==2)&diff(UD.sbobj.Groups(ActiveGroup).Signals(chIdx).XData(Ipts))==0

            P=snap_point(UD,[newVal,0],Ipts,1);
            UD.sbobj.Groups(ActiveGroup).Signals(chIdx).XData(Ipts)=[1,1]*P(1);

        else
            P=snap_point(UD,[newVal,0],Ipts(1),1);
            UD.sbobj.Groups(ActiveGroup).Signals(chIdx).XData(Ipts(1))=P(1);
        end
        set(UD.channels(chIdx).lineH,'XData',UD.sbobj.Groups(ActiveGroup).Signals(chIdx).XData);
        UD=set_dirty_flag(UD);
        UD=update_selection_display_line(UD,...
        UD.sbobj.Groups(ActiveGroup).Signals(chIdx).XData(Ipts),...
        UD.sbobj.Groups(ActiveGroup).Signals(chIdx).YData(Ipts));
        newStr=num2str(P(1),'%.5e');
        set(UD.hgCtrls.chLeftPoint.xNumDisp,'String',newStr);
        modified=1;


    case 'leftY'
        Ipts=UD.current.editPoints;
        str=get(UD.hgCtrls.chLeftPoint.yNumDisp,'String');

        newVal=str2num(str);%#ok<ST2NM>

        if isempty(newVal)||length(newVal)>1||any(~isfinite(newVal))
            errordlg(getString(message('sigbldr_ui:channel_ui_handler:InvalidEntry')));
            modified=0;
            return;
        end

        P=snap_point(UD,[UD.sbobj.Groups(ActiveGroup).Signals(chIdx).XData(Ipts(1)),newVal],...
        Ipts(1),1);
        if~isempty(Ipts==2)&diff(UD.sbobj.Groups(ActiveGroup).Signals(chIdx).YData(Ipts))==0
            UD.sbobj.Groups(ActiveGroup).Signals(chIdx).YData(Ipts)=[1,1]*P(2);
        else
            UD.sbobj.Groups(ActiveGroup).Signals(chIdx).YData(Ipts(1))=P(2);
        end
        set(UD.channels(chIdx).lineH,'YData',UD.sbobj.Groups(ActiveGroup).Signals(chIdx).YData);
        UD=rescale_axes_to_fit_data(UD,axIdx,chIdx);
        UD=set_dirty_flag(UD);
        UD=update_selection_display_line(UD,...
        UD.sbobj.Groups(ActiveGroup).Signals(chIdx).XData(Ipts),...
        UD.sbobj.Groups(ActiveGroup).Signals(chIdx).YData(Ipts));
        newStr=num2str(P(2),'%.5e');
        set(UD.hgCtrls.chLeftPoint.yNumDisp,'String',newStr);
        modified=1;


    case 'rightX'
        Ipts=UD.current.editPoints;
        str=get(UD.hgCtrls.chRightPoint.xNumDisp,'String');

        newVal=str2num(str);%#ok<ST2NM>

        if length(Ipts)<2||isempty(newVal)||length(newVal)>1...
            ||any(~isfinite(newVal))
            errordlg(getString(message('sigbldr_ui:channel_ui_handler:InvalidEntry')));
            modified=0;
            return;
        end

        if Ipts(2)==length(UD.sbobj.Groups(ActiveGroup).Signals(chIdx).XData)

            warndlg(getString(message('sigbldr_ui:channel_ui_handler:MaximumDisplay',UD.common.maxTime)));
            newStr=num2str(UD.sbobj.Groups(ActiveGroup).Signals(chIdx).XData(Ipts(2)));
            set(UD.hgCtrls.chRightPoint.xNumDisp,'String',newStr);
            modified=0;
            return;
        end

        P=snap_point(UD,[newVal,0],Ipts(2),1);
        UD.sbobj.Groups(ActiveGroup).Signals(chIdx).XData(Ipts(2))=P(1);

        set(UD.channels(chIdx).lineH,'XData',UD.sbobj.Groups(ActiveGroup).Signals(chIdx).XData);
        UD=set_dirty_flag(UD);
        UD=update_selection_display_line(UD,...
        UD.sbobj.Groups(ActiveGroup).Signals(chIdx).XData(Ipts),...
        UD.sbobj.Groups(ActiveGroup).Signals(chIdx).YData(Ipts));
        newStr=num2str(P(1),'%.5e');
        set(UD.hgCtrls.chRightPoint.xNumDisp,'String',newStr);
        modified=1;


    case 'rightY'
        Ipts=UD.current.editPoints;
        str=get(UD.hgCtrls.chRightPoint.yNumDisp,'String');

        newVal=str2num(str);%#ok<ST2NM>

        if length(Ipts)<2||isempty(newVal)||length(newVal)>1||any(~isfinite(newVal))
            errordlg(getString(message('sigbldr_ui:channel_ui_handler:InvalidEntry')));
            modified=0;
            return;
        end
        P=snap_point(UD,[UD.sbobj.Groups(ActiveGroup).Signals(chIdx).XData(Ipts(2)),newVal],Ipts(2),1);
        UD.sbobj.Groups(ActiveGroup).Signals(chIdx).YData(Ipts(2))=P(2);


        set(UD.channels(chIdx).lineH,'YData',UD.sbobj.Groups(ActiveGroup).Signals(chIdx).YData);
        UD=rescale_axes_to_fit_data(UD,axIdx,chIdx);
        UD=set_dirty_flag(UD);
        UD=update_selection_display_line(UD,...
        UD.sbobj.Groups(ActiveGroup).Signals(chIdx).XData(Ipts),...
        UD.sbobj.Groups(ActiveGroup).Signals(chIdx).YData(Ipts));
        newStr=num2str(P(2),'%.5e');
        set(UD.hgCtrls.chRightPoint.yNumDisp,'String',newStr);
        modified=1;


    otherwise,
        error(message('sigbldr_ui:channel_ui_handler:unknownMethod'));
    end
