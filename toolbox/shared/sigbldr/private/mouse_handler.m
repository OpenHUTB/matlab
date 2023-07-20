function[UD,modified]=mouse_handler(method,dialog,UD,varargin)























    modified=1;

    if isempty(UD)
        modified=0;
        return;
    end


    if in_iced_state_l(UD),
        switch UD.current.mode,
        case{9,10,11},

        otherwise,
            switch method,
            case 'ForceMode',

            otherwise,
                modified=0;
                return;
            end;
        end;
    end;




    Pfig=get(dialog,'CurrentPoint');


    if~strcmp(method,'ForceMode')



        if~in_drag_mode(UD.current.mode)&&...
            ((Pfig(2)<UD.current.axesExtent(2))||...
            (Pfig(2)>UD.current.axesExtent*[0;1;0;1]))&&...
            all(UD.current.mode~=[2,9,10,11,3])


            refresh_dynamic_pointer(UD,Pfig);
            modified=0;
            return;
        end

        selctType=get(dialog,'SelectionType');




        currObj=gco(dialog);
        if isempty(currObj)
            currObj=dialog;
        end
        currAx=get(dialog,'CurrentAxes');
    end

    oldMode=UD.current.mode;


    switch(method)

    case 'ButtonDown'

        UD.current.prevbdObj=UD.current.bdObj;
        UD.current.axes=currAx;
        UD.current.bdPoint=Pfig;
        UD.current.bdObj=currObj;
        UD.current.bdMode=oldMode;
        update_gca_display(UD.current.axes,UD.hgCtrls.tabselect.axesH);

        switch(selctType)
        case 'normal'
            event='BD';
        case 'extend'
            event='EBD';
        case 'alt'
            event='ABD';
        case 'open'
            event='OBD';
        end


    case 'ButtonUp'
        switch(selctType)
        case 'normal'
            event='BU';
        case 'extend'
            event='EBU';
        case 'alt'
            event='ABU';
        case 'open'
            event='OBU';
        end


    case 'ButtonMotion'
        switch(selctType)
        case 'normal'
            event='BM';
        case 'extend'
            event='EBM';
        case 'alt'
            event='ABM';
        case 'open'
            event='OBM';
        end


    case 'ForceMode'
        event='FRC';
        nextMode=varargin{1};


    case 'KeyPress'
        event='KP';


    otherwise
        error(message('sigbldr_ui:mouse_handler:unrecognizedMethod'));
    end



    switch(UD.current.mode)


    case 1
        if strcmp(event,'FRC')
            UD.current.mode=nextMode;
        end

        if(strcmp(event,'OBD'))
            UD=fullView(UD.dialog,UD);
        end

        if strcmp(event,'BD')&&~isempty(currObj)
            UD=calc_new_drag_mode(UD,currObj,Pfig,currAx,false);
        end

        if strcmp(event,'BM')||strcmp(event,'EBM')||...
            strcmp(event,'ABM')||strcmp(event,'OBM')
            refresh_dynamic_pointer(UD,Pfig);
        end



        if(strcmp(event,'EBD'))&&~isempty(currObj)
            UD=calc_new_drag_mode(UD,currObj,Pfig,currAx,true);
        end

        if(strcmp(event,'ABD'))
            UD=perform_abd_select(UD,currObj);
        end




    case 2


        if Pfig(1)<15*UD.geomConst.figBuffer
            newXpos=15*UD.geomConst.figBuffer;
        else
            newXpos=Pfig(1);
        end

        if(strcmp(event,'BM'))


            splitterPos=UD.current.splitterPos;
            splitterPos(1)=newXpos;
            set(UD.verify.hg.splitter,'Position',splitterPos);
        end

        if(strcmp(event,'BU'))
            deltaWidth=UD.current.splitterStart-newXpos;
            UD=adjust_verify_width(UD,deltaWidth);
            set(UD.verify.hg.splitter,'Visible','off');
            UD.current.mode=1;
        end


    case 3
        ActiveGroup=UD.sbobj.ActiveGroup;
        if strcmp(event,'FRC')
            UD.current.mode=nextMode;
        end

        chNum=UD.current.channel;

        if strcmp(event,'BM')||strcmp(event,'EBM')||strcmp(event,'ABM')
            refresh_dynamic_pointer(UD,Pfig);
            modified=0;
            return;
        end

        if(strcmp(event,'ABD'))
            UD=perform_abd_select(UD,currObj);
        end

        if(strcmp(event,'EBD'))
            UD=calc_new_drag_mode(UD,currObj,Pfig,currAx,true);
        end

        if(strcmp(event,'BD'))
            if strcmp(get(currObj,'Type'),'line')
                if(currObj==UD.current.prevbdObj)


                    UD.current.lockOutSingleClick=0;
                    I=calc_channel_points(UD.sbobj.Groups(ActiveGroup).Signals(chNum).XData,...
                    UD.sbobj.Groups(ActiveGroup).Signals(chNum).YData,...
                    Pfig,currAx);
                    UD.current.editPoints=I;
                    if(length(I)==2)

                        if(diff(UD.sbobj.Groups(ActiveGroup).Signals(chNum).XData(I))==0)
                            UD.current.mode=6;
                        else
                            UD.current.mode=5;
                        end
                    else
                        UD.current.mode=4;
                    end
                else
                    UD.current.bdMode=1;
                    UD=calc_new_drag_mode(UD,currObj,Pfig,currAx,false);
                end
            else
                UD.current.mode=1;
            end
        end

        if(strcmp(event,'KP'))
            if~isequal(chNum,0)
                Y=UD.sbobj.Groups(ActiveGroup).Signals(chNum).YData;
                X=UD.sbobj.Groups(ActiveGroup).Signals(chNum).XData;
            end
            switch(get(dialog,'CurrentCharacter'))
            case 27
                UD.current.mode=1;

            case 28
                if(UD.channels(chNum).stepX==0)
                    X=X-0.1;
                else
                    X=snap_x_vect(UD.axes,X-UD.channels(chNum).stepX,UD.channels(chNum));
                end
                [X,Y]=update_time_data(X(1),X(end),UD.common.minTime,UD.common.maxTime,X,Y);
                UD=apply_new_channel_data(UD,chNum,X,Y);
                UD=set_dirty_flag(UD);
                UD=rescale_axes_to_fit_data(UD,UD.channels(chNum).axesInd,[]);


            case 29
                if(UD.channels(chNum).stepX==0)
                    X=X+0.1;
                else
                    X=snap_x_vect(UD.axes,X+UD.channels(chNum).stepX,UD.channels(chNum));
                end
                [X,Y]=update_time_data(X(1),X(end),UD.common.minTime,UD.common.maxTime,X,Y);
                UD=apply_new_channel_data(UD,chNum,X,Y);
                UD=set_dirty_flag(UD);
                UD=rescale_axes_to_fit_data(UD,UD.channels(chNum).axesInd,[]);

            case 30


                if(UD.channels(chNum).stepY==0)
                    Y=Y+0.1;
                else
                    Y=snap_y_vect(UD.axes,Y+UD.channels(chNum).stepY,UD.channels(chNum));
                end

                UD=apply_new_channel_data(UD,chNum,[],Y);
                UD=rescale_axes_to_fit_data(UD,UD.channels(chNum).axesInd,[]);

            case 31
                if UD.channels(chNum).stepY==0
                    Y=Y-0.1;
                else
                    Y=snap_y_vect(UD.axes,Y-UD.channels(chNum).stepY,UD.channels(chNum));
                end
                UD=apply_new_channel_data(UD,chNum,[],Y);
                UD=set_dirty_flag(UD);
                UD=rescale_axes_to_fit_data(UD,UD.channels(chNum).axesInd,[]);

            case 127
                if length(UD.channels)==1
                    warndlg(getString(message('sigbldr_ui:channel_handler:DeleteLastSignal')));
                else
                    UD.current.mode=1;
                    UD.adjust.XDisp=[];
                    UD.adjust.YDisp=[];
                    UD=update_undo(UD,'delete','channel',chNum,[]);

                    grpCnt=UD.sbobj.NumGroups;
                    for m=1:grpCnt;

                        UD.sbobj.Groups(m).signalRemove(chNum);
                    end
                    UD=remove_channel(UD,chNum);
                    UD.current.channel=0;
                end
            end
        end



    case 4
        ActiveGroup=UD.sbobj.ActiveGroup;
        if strcmp(event,'FRC')
            UD.current.mode=nextMode;
        end

        Ind=UD.current.editPoints;
        chNum=UD.current.channel;

        if(strcmp(event,'BU'))


            pPrev=UD.current.bdPoint;
            [~,r]=cart2pol(Pfig(1)-pPrev(1),Pfig(2)-pPrev(2));
            if r<UD.geomConst.singleClickThresh
                if(UD.current.bdMode==1||UD.current.lockOutSingleClick)
                    UD.current.mode=3;
                else
                    UD.current.mode=7;
                end
                set(UD.channels(chNum).lineH,'YData',UD.sbobj.Groups(ActiveGroup).Signals(chNum).YData);
            else


                Y=UD.sbobj.Groups(ActiveGroup).Signals(chNum).YData;
                Pax=fig_2_ax_coord(Pfig,currAx);
                PfixStep=snap_point(UD,Pax);
                Y(Ind)=PfixStep(2);
                UD=apply_new_channel_data(UD,chNum,[],Y);

                UD=rescale_axes_to_fit_data(UD,UD.channels(chNum).axesInd);

                UD=set_dirty_flag(UD);
                UD.current.mode=3;
            end
        end

        if(strcmp(event,'BM'))


            Pax=fig_2_ax_coord(Pfig,currAx);
            PfixStep=snap_point(UD,Pax);
            yData=UD.sbobj.Groups(ActiveGroup).Signals(chNum).YData;
            if(yData(Ind)~=PfixStep(2))
                yData(Ind)=PfixStep(2);
                set(UD.channels(chNum).lineH,'YData',yData);
                UD=update_numeric_displays(UD,[],yData(Ind));
            end
            [UD,modified]=update_click_lockout(UD,Pfig);

        end


    case 12
        ActiveGroup=UD.sbobj.ActiveGroup;
        if strcmp(event,'FRC')
            UD.current.mode=nextMode;
        end

        Ind=UD.current.editPoints;
        chNum=UD.current.channel;

        if(strcmp(event,'EBU'))


            pPrev=UD.current.bdPoint;
            [~,r]=cart2pol(Pfig(1)-pPrev(1),Pfig(2)-pPrev(2));
            if r<UD.geomConst.singleClickThresh
                if UD.current.bdMode==1||UD.current.lockOutSingleClick
                    UD.current.mode=3;
                else
                    UD.current.mode=7;
                end
            else


                X=UD.sbobj.Groups(ActiveGroup).Signals(chNum).XData;
                Pax=fig_2_ax_coord(Pfig,currAx);
                PfixStep=snap_point(UD,Pax,Ind);
                X(Ind)=PfixStep(1);

                UD=apply_new_channel_data(UD,chNum,X,[]);


                UD=set_dirty_flag(UD);
                UD.current.mode=3;
            end
        end

        if(strcmp(event,'EBM'))


            Pax=fig_2_ax_coord(Pfig,currAx);
            PfixStep=snap_point(UD,Pax,Ind);
            xData=UD.sbobj.Groups(ActiveGroup).Signals(chNum).XData;
            xData(Ind)=PfixStep(1);
            set(UD.channels(chNum).lineH,'XData',xData);
            UD=update_numeric_displays(UD,xData(Ind),[]);

            [UD,modified]=update_click_lockout(UD,Pfig);
            if~isempty(findall(0,'Type','figure','Tag',['Msgbox_',getString(message('sigbldr_ui:snap_point:SegStartWarnTitle'))]))||...
                ~isempty(findall(0,'Type','figure','Tag',['Msgbox_',getString(message('sigbldr_ui:snap_point:SegEndWarnTitle'))]))
                UD.current.mode=111;
            end
        end


    case 13
        ActiveGroup=UD.sbobj.ActiveGroup;
        if strcmp(event,'FRC')
            UD.current.mode=nextMode;
        end

        Pax=fig_2_ax_coord(Pfig,currAx);
        chNum=UD.current.channel;
        PfixStep=snap_point(UD,Pax);

        if strcmp(event,'EBU')||strcmp(event,'BU')
            pPrev=UD.current.bdPoint;
            [~,r]=cart2pol(Pfig(1)-pPrev(1),Pfig(2)-pPrev(2));
            if r<UD.geomConst.singleClickThresh
                UD=add_new_interpolated_points(UD,chNum,PfixStep(1));
                UD.current.mode=3;
                UD.current.editPoints=[];
                UD.current.tempPoints=[];
            else
                delta=PfixStep-fig_2_ax_coord(UD.current.bdPoint,currAx);
                Y=snap_y_vect(UD.axes,UD.sbobj.Groups(ActiveGroup).Signals(chNum).YData+delta(2),UD.channels(chNum));
                X=snap_x_vect(UD.axes,UD.sbobj.Groups(ActiveGroup).Signals(chNum).XData+delta(1),UD.channels(chNum));
                [X,Y]=update_time_data(X(1),X(end),UD.common.minTime,UD.common.maxTime,X,Y);
                UD=apply_new_channel_data(UD,chNum,X,Y);
                UD=rescale_axes_to_fit_data(UD,UD.channels(chNum).axesInd);
                UD.current.mode=3;
            end
            UD=set_dirty_flag(UD);
        end

        if(strcmp(event,'EBM'))
            delta=PfixStep-fig_2_ax_coord(UD.current.bdPoint,currAx);
            Y=snap_y_vect(UD.axes,UD.sbobj.Groups(ActiveGroup).Signals(chNum).YData+delta(2),UD.channels(chNum));
            X=snap_x_vect(UD.axes,UD.sbobj.Groups(ActiveGroup).Signals(chNum).XData+delta(1),UD.channels(chNum));
            set(UD.channels(chNum).lineH,'YData',Y,'XData',X);
            [UD,lo_mod]=update_click_lockout(UD,Pfig);
            if lo_mod
                modified=1;
            end
        end


    case 5
        ActiveGroup=UD.sbobj.ActiveGroup;
        if strcmp(event,'FRC')
            UD.current.mode=nextMode;
        end

        Ind=UD.current.editPoints;
        chNum=UD.current.channel;
        pPrev=UD.current.bdPoint;
        Pax=fig_2_ax_coord(Pfig,currAx);
        PfixStep=snap_point(UD,Pax);
        Itemp=UD.current.tempPoints;

        if isempty(Itemp)
            oldX=UD.sbobj.Groups(ActiveGroup).Signals(chNum).XData;
            oldY=UD.sbobj.Groups(ActiveGroup).Signals(chNum).YData;
            if(Ind(1)>1)&&(oldX(Ind(1)-1)~=oldX(Ind(1)))
                X=[oldX(1:Ind(1)),oldX(Ind(1):end)];
                Y=[oldY(1:Ind(1)),oldY(Ind(1):end)];
                Itemp=Ind+1;
            else
                X=oldX;
                Y=oldY;
                Itemp=Ind;
            end
            if(Ind(2)<length(oldX))&&(oldX(Ind(2))~=oldX(Ind(2)+1))
                X=[X(1:Itemp(2)),X(Itemp(2):end)];
                Y=[Y(1:Itemp(2)),Y(Itemp(2):end)];
            end
        else
            X=get(UD.channels(chNum).lineH,'XData');
            Y=get(UD.channels(chNum).lineH,'YData');
        end

        if(strcmp(event,'BU'))



            [~,r]=cart2pol(Pfig(1)-pPrev(1),Pfig(2)-pPrev(2));
            if r<UD.geomConst.singleClickThresh
                if(UD.current.bdMode==1)||(UD.current.lockOutSingleClick)||(UD.current.bdMode==8)
                    UD.current.mode=3;
                else
                    UD.current.mode=8;
                end
                UD=apply_new_channel_data(UD,chNum,X,Y);
            else


                delta=PfixStep-fig_2_ax_coord(UD.current.bdPoint,currAx);
                Y(Itemp)=snap_y_vect(UD.axes,UD.sbobj.Groups(ActiveGroup).Signals(chNum).YData(Ind)+delta(2),UD.channels(chNum));
                [X,Y]=remove_unneeded_points(X,Y);
                UD=apply_new_channel_data(UD,chNum,X,Y);

                UD=rescale_axes_to_fit_data(UD,UD.channels(chNum).axesInd);

                UD=set_dirty_flag(UD);
                UD.current.mode=3;
            end
        end

        if(strcmp(event,'BM'))
            delta=PfixStep-fig_2_ax_coord(UD.current.bdPoint,currAx);
            Y(Itemp)=snap_y_vect(UD.axes,UD.sbobj.Groups(ActiveGroup).Signals(chNum).YData(Ind)+delta(2),UD.channels(chNum));
            set(UD.channels(chNum).lineH,'YData',Y,'XData',X);
            UD=update_numeric_displays(UD,[],Y(Itemp));
            [UD,lo_mod]=update_click_lockout(UD,Pfig);
            if lo_mod
                modified=1;
            end
        end


    case 6
        ActiveGroup=UD.sbobj.ActiveGroup;
        if strcmp(event,'FRC')
            UD.current.mode=nextMode;
        end

        Ind=UD.current.editPoints;
        chNum=UD.current.channel;
        pPrev=UD.current.bdPoint;
        Pax=fig_2_ax_coord(Pfig,currAx);
        PfixStep=snap_point(UD,Pax,Ind);

        if(strcmp(event,'BM'))
            X=get(UD.channels(chNum).lineH,'XData');
            X(Ind)=[1,1]*PfixStep(1);
            set(UD.channels(chNum).lineH,'XData',X);
            UD=update_numeric_displays(UD,X(Ind),[]);
            [UD,modified]=update_click_lockout(UD,Pfig);
            ymean=mean(UD.sbobj.Groups(ActiveGroup).Signals(chNum).YData(Ind));

        end

        if(strcmp(event,'BU'))


            [~,r]=cart2pol(Pfig(1)-pPrev(1),Pfig(2)-pPrev(2));
            if r<UD.geomConst.singleClickThresh
                if(UD.current.bdMode==1)||...
                    (UD.current.lockOutSingleClick)||...
                    (UD.current.bdMode==8)
                    UD.current.mode=3;
                else
                    UD.current.mode=8;
                end
            else
                X=get(UD.channels(chNum).lineH,'XData');
                Y=get(UD.channels(chNum).lineH,'YData');
                X(Ind)=[1,1]*PfixStep(1);
                [X,Y]=remove_unneeded_points(X,Y);

                UD=apply_new_channel_data(UD,chNum,X,Y);



                UD=set_dirty_flag(UD);
                UD.current.mode=3;
            end
        end


    case 7
        ActiveGroup=UD.sbobj.ActiveGroup;
        if strcmp(event,'FRC')
            UD.current.mode=nextMode;
        end

        chNum=UD.current.channel;
        Ind=UD.current.editPoints;

        if(strcmp(event,'BD'))
            if(currObj==UD.channels(chNum).lineH)
                UD=calc_new_drag_mode(UD,currObj,Pfig,currAx,false);
            else

                UD=calc_new_drag_mode(UD,currObj,Pfig,currAx,false);
            end
        end

        if(strcmp(event,'ABD'))
            UD=perform_abd_select(UD,currObj);
        end

        if(strcmp(event,'BM'))
            refresh_dynamic_pointer(UD,Pfig);
        end

        if(strcmp(event,'KP'))
            keyChar=get(dialog,'CurrentCharacter');
            switch(keyChar)
            case 27
                UD.current.mode=3;
                UD.current.editPoints=[];

            case{28,29,30,31}

                [xDelta,yDelta]=arrow_key_move(UD,chNum,keyChar);
                X=UD.sbobj.Groups(ActiveGroup).Signals(chNum).XData;
                Y=UD.sbobj.Groups(ActiveGroup).Signals(chNum).YData;
                if(Ind~=1)&&(Ind~=length(X))
                    Pax=[X(Ind)+xDelta,Y(Ind)+yDelta];
                else
                    Pax=[X(Ind),Y(Ind)+yDelta];
                end
                PfixStep=snap_point(UD,Pax,Ind);
                X(Ind)=PfixStep(1);
                Y(Ind)=PfixStep(2);
                UD=apply_new_channel_data(UD,chNum,X,Y);
                UD=update_selection_display_line(UD,X(Ind),Y(Ind));
                UD=rescale_axes_to_fit_data(UD,UD.channels(chNum).axesInd,[]);
                UD=update_numeric_displays(UD,X(Ind),Y(Ind));
                UD=set_dirty_flag(UD);

            case 9
                if(Ind<length(UD.sbobj.Groups(ActiveGroup).Signals(chNum).XData))
                    Ind=Ind+1;
                else
                    Ind=1;
                end
                x=UD.sbobj.Groups(ActiveGroup).Signals(chNum).XData(Ind);
                y=UD.sbobj.Groups(ActiveGroup).Signals(chNum).YData(Ind);
                UD.current.editPoints=Ind;
                set(UD.current.selectLine,'XData',x,'YData',y);
                UD=update_numeric_displays(UD,x,y);
                axes(UD.current.axes);

            case 127

                Y=UD.sbobj.Groups(ActiveGroup).Signals(chNum).YData;
                X=UD.sbobj.Groups(ActiveGroup).Signals(chNum).XData;
                if(Ind==1)||(Ind==length(X))
                    return;
                end
                Y(Ind)=[];
                X(Ind)=[];
                UD=apply_new_channel_data(UD,chNum,X,Y);

                if(Ind>length(X))
                    Ind=Ind-1;
                    UD.current.editPoints=Ind;
                end

                set(UD.current.selectLine,...
                'XData',UD.sbobj.Groups(ActiveGroup).Signals(chNum).XData(Ind),...
                'YData',UD.sbobj.Groups(ActiveGroup).Signals(chNum).YData(Ind));

                UD=set_dirty_flag(UD);
                UD=update_numeric_displays(UD,X(Ind),Y(Ind));

            end
            update_selection_msg(UD);
        end



    case 8
        ActiveGroup=UD.sbobj.ActiveGroup;
        if strcmp(event,'FRC')
            UD.current.mode=nextMode;
        end

        chNum=UD.current.channel;
        Ind=UD.current.editPoints;

        if(strcmp(event,'BM'))
            refresh_dynamic_pointer(UD,Pfig);
        end

        if(strcmp(event,'BD'))
            if(currObj==UD.channels(chNum).lineH)
                UD=calc_new_drag_mode(UD,currObj,Pfig,currAx,false);
            else
                UD=calc_new_drag_mode(UD,currObj,Pfig,currAx,false);
            end
        end

        if(strcmp(event,'ABD'))
            UD=perform_abd_select(UD,currObj);
        end

        if(strcmp(event,'KP'))
            keyChar=get(dialog,'CurrentCharacter');
            switch(keyChar)
            case 27
                UD.current.mode=3;
                UD.current.editPoints=[];

            case{28,29,30,31}

                isVertSegment=diff(UD.sbobj.Groups(ActiveGroup).Signals(chNum).XData(Ind))==0;

                if(isVertSegment||(~(keyChar==28||(keyChar==29))))

                    X=UD.sbobj.Groups(ActiveGroup).Signals(chNum).XData;
                    Y=UD.sbobj.Groups(ActiveGroup).Signals(chNum).YData;

                    [xDelta,yDelta]=arrow_key_move(UD,chNum,keyChar);
                    if Ind~=1&Ind~=length(X)%#ok<*AND2>
                        Pax=[X(Ind)+xDelta,Y(Ind)+yDelta];
                    else
                        Pax=[X(Ind),Y(Ind)+yDelta];
                    end
                    P1fixStep=snap_point(UD,[Pax(1),Pax(3)],Ind);
                    P2fixStep=snap_point(UD,[Pax(2),Pax(4)],Ind);
                    X(Ind)=[P1fixStep(1),P2fixStep(1)];
                    Y(Ind)=[P1fixStep(2),P2fixStep(2)];

                    UD.current.last_modified_channel=chNum;
                    UD=apply_new_channel_data(UD,chNum,X,Y);

                    UD=update_selection_display_line(UD,X(Ind),Y(Ind));
                    UD=rescale_axes_to_fit_data(UD,UD.channels(chNum).axesInd,[]);
                    UD=update_numeric_displays(UD,X(Ind),Y(Ind));
                    UD=set_dirty_flag(UD);
                end
            case 9
                if(Ind(2)<length(UD.sbobj.Groups(ActiveGroup).Signals(chNum).XData))
                    Ind=Ind+1;
                else
                    Ind=[1,2];
                end
                x=UD.sbobj.Groups(ActiveGroup).Signals(chNum).XData(Ind);
                y=UD.sbobj.Groups(ActiveGroup).Signals(chNum).YData(Ind);
                UD.current.editPoints=Ind;
                set(UD.current.selectLine,'XData',x,'YData',y);
                UD=update_numeric_displays(UD,x,y);
                axes(UD.current.axes);%#ok<*MAXES> % Bring focus back to axes
            end
            update_selection_msg(UD);
        end



    case 9
        if strcmp(event,'FRC')
            UD.current.mode=nextMode;
        end

        if(strcmp(event,'KP'))
            keyChar=get(dialog,'CurrentCharacter');
            switch(keyChar)
            case 27
                UD.current.mode=1;
            end
        end

        if(strcmp(event,'BD'))
            UD.current.zoomStart=fig_2_ax_coord(Pfig,currAx);



            UD.current.zoomAxesInd=[];
            axUd=get(currAx,'UserData');

            if isfield(axUd,'index')

                props=struct(...
                'Parent',currAx,...
                'Visible','on',...
                'Color','k');

                X0=UD.current.zoomStart(1);
                Y0=UD.current.zoomStart(2);
                ext=fig_2_ax_ext([8,8],currAx);
                dY=ext(2);

                UD.current.zoomXLine=[line([X0,X0],[Y0,Y0+2*dY],props);...
                line([X0,X0],[Y0+dY,Y0+dY],props);...
                line([X0,X0],[Y0,Y0+2*dY],props)];
                UD.current.zoomAxesInd=axUd.index;
                sigbuilder_tabselector('touch',UD.hgCtrls.tabselect.axesH);
            end
        end

        if(strcmp(event,'BM'))
            if~isempty(UD.current.zoomXLine)
                Pax=fig_2_ax_coord(Pfig,UD.axes(UD.current.zoomAxesInd).handle);
                set(UD.current.zoomXLine(2),'Xdata',[UD.current.zoomStart(1),Pax(1)]);
                set(UD.current.zoomXLine(3),'Xdata',[Pax(1),Pax(1)]);
                sigbuilder_tabselector('touch',UD.hgCtrls.tabselect.axesH);
            end
        end

        if(strcmp(event,'BU'))

            if~isempty(UD.current.zoomAxesInd)
                Pax=fig_2_ax_coord(Pfig,UD.axes(UD.current.zoomAxesInd).handle);
                range=sort([UD.current.zoomStart(1),Pax(1)]);
                delete(UD.current.zoomXLine);
                UD.current.zoomXLine=[];
                UD=set_new_time_range(UD,range);
                UD=cant_undo(UD);
                sigbuilder_tabselector('touch',UD.hgCtrls.tabselect.axesH);
            end
        end



    case 10
        if strcmp(event,'FRC')
            UD.current.mode=nextMode;
        end

        if(strcmp(event,'KP'))
            keyChar=get(dialog,'CurrentCharacter');
            switch(keyChar)
            case 27
                UD.current.mode=1;
            end
        end

        if(strcmp(event,'BD'))
            UD.current.zoomStart=fig_2_ax_coord(Pfig,currAx);



            UD.current.zoomAxesInd=[];
            axUd=get(currAx,'UserData');

            if isfield(axUd,'index')

                props=struct(...
                'Parent',currAx,...
                'Visible','on',...
                'Color','k');

                X0=UD.current.zoomStart(1);
                Y0=UD.current.zoomStart(2);
                ext=fig_2_ax_ext([8,8],currAx);
                dX=ext(1);

                UD.current.zoomYLine=[line([X0-2*dX,X0],[Y0,Y0],props);...
                line([X0-dX,X0-dX],[Y0,Y0],props);...
                line([X0-2*dX,X0],[Y0,Y0],props)];
                UD.current.zoomAxesInd=axUd.index;
                sigbuilder_tabselector('touch',UD.hgCtrls.tabselect.axesH);
            end
        end

        if(strcmp(event,'BM'))
            if~isempty(UD.current.zoomYLine)
                Pax=fig_2_ax_coord(Pfig,UD.axes(UD.current.zoomAxesInd).handle);
                set(UD.current.zoomYLine(2),'Ydata',[UD.current.zoomStart(2),Pax(2)]);
                set(UD.current.zoomYLine(3),'Ydata',[Pax(2),Pax(2)]);
                sigbuilder_tabselector('touch',UD.hgCtrls.tabselect.axesH);
            end
        end

        if(strcmp(event,'BU'))

            if~isempty(UD.current.zoomAxesInd)
                Pax=fig_2_ax_coord(Pfig,UD.axes(UD.current.zoomAxesInd).handle);
                range=sort([UD.current.zoomStart(2),Pax(2)]);
                delete(UD.current.zoomYLine);
                UD.current.zoomYLine=[];
                if diff(range)>0
                    UD.axes(UD.current.zoomAxesInd).yLim=range;
                    set(UD.axes(UD.current.zoomAxesInd).handle,'YLim',range);
                    update_axes_label(UD.axes(UD.current.zoomAxesInd));
                end
                UD=cant_undo(UD);
                sigbuilder_tabselector('touch',UD.hgCtrls.tabselect.axesH);
            end
        end



    case 11
        if strcmp(event,'FRC')
            UD.current.mode=nextMode;
        end

        if(strcmp(event,'KP'))
            keyChar=get(dialog,'CurrentCharacter');
            switch(keyChar)
            case 27
                UD.current.mode=1;
            end
        end

        if(strcmp(event,'BD'))
            UD.current.zoomStart=fig_2_ax_coord(Pfig,currAx);
            axUd=get(currAx,'UserData');

            if isfield(axUd,'index')

                UD.current.zoomAxesInd=axUd.index;


                handleVisibility=get(dialog,'HandleVisibility');
                set(dialog,'HandleVisibility','callback');
                finalRect=rbbox;
                set(dialog,'HandleVisibility',handleVisibility);
                Pax=fig_2_ax_coord(finalRect(1:2),UD.axes(UD.current.zoomAxesInd).handle);
                RBext=fig_2_ax_ext(finalRect(3:4),UD.axes(UD.current.zoomAxesInd).handle);
                trange=[0,RBext(1)]+Pax(1);
                yrange=[0,RBext(2)]+Pax(2);
                UD.axes(UD.current.zoomAxesInd).yLim=yrange;
                if diff(yrange)<=0
                    return;
                end
                set(UD.axes(UD.current.zoomAxesInd).handle,'YLim',yrange);
                UD=set_new_time_range(UD,trange);
                UD=cant_undo(UD);
                sigbuilder_tabselector('touch',UD.hgCtrls.tabselect.axesH);
            end
        end



    case 14
        if strcmp(event,'FRC')
            UD.current.mode=nextMode;
        end



    otherwise,
        error(message('sigbldr_ui:mouse_handler:badModeVariable'))
    end



    if(oldMode~=UD.current.mode)
        if(UD.current.mode~=111)
            update_status_msg(UD);
        end

        switch(oldMode)
        case 1
        case 2
        case 3
        case 4
            UD=disable_adjustment_displays(UD);

        case 111
        case 12
            UD=disable_adjustment_displays(UD);
        case 13

        case 5
            UD=disable_adjustment_displays(UD);
        case 6
            UD=disable_adjustment_displays(UD);
        case 7
            UD=remove_selection_display_line(UD);
            UD=disable_adjustment_displays(UD);

        case 8

            UD=remove_selection_display_line(UD);
            UD=disable_adjustment_displays(UD);

        case 9
            set(UD.toolbar.zoomX,'state','off');
        case 10
            set(UD.toolbar.zoomY,'state','off');
        case 11
            set(UD.toolbar.zoomXY,'state','off');

        otherwise,
            error(message('sigbldr_ui:mouse_handler:badModeVariable'))
        end


        chIdx=UD.current.channel;
        Ipts=UD.current.editPoints;
        switch(UD.current.mode)
        case 1
            set(UD.dialog,'Pointer','arrow');
            UD.current.channel=0;
            UD=update_channel_select(UD);
        case 2
            set(UD.dialog,'Pointer','right');
            UD.current.splitterStart=Pfig(1);
            UD.current.splitterPos=get(UD.verify.hg.splitter,'Position');

        case 3
            UD.current.editPoints=[];
            UD.current.tempPoints=[];
            set(UD.dialog,'Pointer','arrow');
            UD=update_channel_select(UD);

        case 12
            set(UD.dialog,'Pointer','circle');
            UD=activate_adjustment_displays(UD);
        case 13
        case 4
            set(UD.dialog,'Pointer','circle');
            UD=activate_adjustment_displays(UD);
        case 5
            setptr(UD.dialog,'uddrag');
            UD=activate_adjustment_displays(UD);
        case 6
            setptr(UD.dialog,'lrdrag');
            UD=activate_adjustment_displays(UD);
        case 7
            set(UD.dialog,'Pointer','arrow');
            UD=activate_adjustment_displays(UD);
            UD=add_selection_display_line(UD,chIdx,Ipts);
            update_selection_msg(UD);

        case 8
            set(UD.dialog,'Pointer','arrow');
            UD=activate_adjustment_displays(UD);
            UD=add_selection_display_line(UD,chIdx,Ipts);
            update_selection_msg(UD);

        case 9
            set(UD.dialog,'Pointer','custom'...
            ,'PointerShapeCData',UD.pointerdata.zoomt...
            ,'PointerShapeHotSpot',[4,4]...
            );
        case 10
            set(UD.dialog,'Pointer','custom'...
            ,'PointerShapeCData',UD.pointerdata.zoomy...
            ,'PointerShapeHotSpot',[4,4]...
            );
        case 11
            set(UD.dialog,'Pointer','custom'...
            ,'PointerShapeCData',UD.pointerdata.zoomty...
            ,'PointerShapeHotSpot',[4,4]...
            );
        case 111
            set(UD.dialog,'Pointer','arrow');
            UD.current.channel=0;
            UD.current.mode=1;
        otherwise,
            error(message('sigbldr_ui:mouse_handler:badModeVariable'))
        end
    end
end



function UD=activate_adjustment_displays(UD)


    I=UD.current.editPoints;
    chNum=UD.current.channel;

    ActiveGroup=UD.sbobj.ActiveGroup;
    X=UD.sbobj.Groups(ActiveGroup).Signals(chNum).XData(I);
    Y=UD.sbobj.Groups(ActiveGroup).Signals(chNum).YData(I);

    lpStruct=UD.hgCtrls.chLeftPoint;
    adjust.XDisp(1)=lpStruct.xNumDisp;
    adjust.YDisp(1)=lpStruct.yNumDisp;
    set([lpStruct.xLabel,lpStruct.yLabel,lpStruct.title],'Enable','on');
    set(adjust.XDisp(1),'Enable','on','BackgroundColor','w')
    set(adjust.YDisp(1),'Enable','on','BackgroundColor','w')

    if(length(I)==2)
        rpStruct=UD.hgCtrls.chRightPoint;
        set(rpStruct.title,'Enable','on');
        if(diff(X)~=0)
            adjust.XDisp(2)=rpStruct.xNumDisp;
            set(adjust.XDisp(2),'Enable','on','BackgroundColor','w');
            set(rpStruct.xLabel,'Enable','on');
        end
        if(diff(Y)~=0)
            adjust.YDisp(2)=rpStruct.yNumDisp;
            set(adjust.YDisp(2),'Enable','on','BackgroundColor','w');
            set(rpStruct.yLabel,'Enable','on');
        end
    end

    UD.adjust=adjust;
    UD=update_numeric_displays(UD,X,Y);
end

function UD=add_new_interpolated_points(UD,chIdx,newX)


    ActiveGroup=UD.sbobj.ActiveGroup;
    X=UD.sbobj.Groups(ActiveGroup).Signals(chIdx).XData;

    if~any(X==newX)
        Y=UD.sbobj.Groups(ActiveGroup).Signals(chIdx).YData;


        newY=scalar_interp(newX,X,Y);


        [X,I]=sort([X,newX]);
        Y=[Y,newY];
        Y=Y(I);


        UD=apply_new_channel_data(UD,chIdx,X,Y);
    end
end

function UD=add_selection_display_line(UD,chIdx,Ipts)



    lineUd=get(UD.channels(chIdx).lineH,'UserData');
    chColor=UD.channels(chIdx).color;

    if length(Ipts)==1,
        if isequal(chColor,[1,0,0])
            lcolor=[0,0,0];
        else
            lcolor=[1,0,0];
        end
        LineProps={'Marker','o',...
        'Color',lcolor,...
        'MarkerSize',10,...
        'linestyle','none'};
        Tag={'Tag','SignalBuilderSelectedPoint'};
    else
        LineProps={'Marker','none',...
        'Color',[1,0,0],...
        'LineWidth',4,...
        'lineStyle','-'};
        Tag={'Tag','SignalBuilderSelectedLine'};
    end

    UD=remove_selection_display_line(UD);

    ActiveGroup=UD.sbobj.ActiveGroup;
    UD.current.selectLine=line('Parent',UD.current.axes,...
    'XData',UD.sbobj.Groups(ActiveGroup).Signals(chIdx).XData(Ipts),...
    'YData',UD.sbobj.Groups(ActiveGroup).Signals(chIdx).YData(Ipts),...
    'UserData',lineUd,...
    Tag{:},...
    LineProps{:});


    allAxesObjs=get(UD.current.axes,'Children');
    Iselect=(allAxesObjs==UD.current.selectLine);
    set(UD.current.axes,'Children',[allAxesObjs(~Iselect);UD.current.selectLine])
end

function UD=adjust_verify_width(UD,delta)

    if~UD.current.isVerificationVisible
        return;
    end



    if(delta<0&&(UD.current.verifyWidth+delta)<20)
        UD=verifyView(UD);
        set(UD.toolbar.verifyView,'state','off');
        return;
    end

    UD.current.axesExtent=UD.current.axesExtent-[0,0,1,0]*delta;


    for i=1:UD.numAxes
        pos=calc_new_axes_position(UD.current.axesExtent,UD.geomConst,UD.numAxes,i);
        set(UD.axes(i).handle,'Position',pos);
    end

    if strcmp(get(UD.tlegend.scrollbar,'Visible'),'on')
        scrollPos=get(UD.tlegend.scrollbar,'Position');
        scrollPos=scrollPos-[0,0,1,0]*delta;
        set(UD.tlegend.scrollbar,'Position',scrollPos);
    end

    UD.current.verifyWidth=UD.current.verifyWidth+delta;
    verifyPos=find_verify_position(UD.dialog,UD.current.axesExtent,UD.geomConst.figBuffer,UD.current.verifyWidth,UD.current.isVerificationVisible);
    set(UD.verify.hg.componentContainer,'Position',verifyPos)

    splitterPos=calc_splitter_pos(UD.current.axesExtent,UD.geomConst.figBuffer);
    set(UD.verify.hg.splitter,'Position',splitterPos);
end

function[xDelta,yDelta]=arrow_key_move(UD,chIdx,keyChar)


    channelStruct=UD.channels(chIdx);



    axesH=UD.axes(channelStruct.axesInd).handle;
    rawSnap=fig_2_ax_ext([0.75,0.75],axesH);
    defaultStepX=nearest_125(rawSnap(1))*2;
    defaultStepY=nearest_125(rawSnap(2))*2;

    if(channelStruct.stepX>0)
        stepX=channelStruct.stepX;
    else
        stepX=defaultStepX;
    end


    if(channelStruct.stepY>0)
        stepY=channelStruct.stepY;
    else
        stepY=defaultStepY;
    end

    switch(keyChar)
    case 28
        xDelta=-stepX;
        yDelta=0;
    case 29
        xDelta=stepX;
        yDelta=0;
    case 30
        xDelta=0;
        yDelta=stepY;
    case 31
        xDelta=0;
        yDelta=-stepY;
    otherwise,
        xDelta=0;
        yDelta=0;
    end
end

function UD=calc_new_drag_mode(UD,currObj,Pfig,currAx,extend)




    if isempty(currObj)


        return;
    end
    switch(get(currObj,'Type'))
    case 'line'
        ActiveGroup=UD.sbobj.ActiveGroup;
        objUd=get(currObj,'UserData');
        if isempty(objUd)

            return;
        end
        switch(objUd.type)
        case 'Channel'
            chNum=objUd.index;
            UD.current.channel=chNum;
            if~extend
                UD=remove_all_unneeded_points(UD);
            end
            I=calc_channel_points(UD.sbobj.Groups(ActiveGroup).Signals(chNum).XData,...
            UD.sbobj.Groups(ActiveGroup).Signals(chNum).YData,...
            Pfig,currAx);
            UD.current.editPoints=I;
            if(length(I)==2)
                if~extend
                    if(diff(UD.sbobj.Groups(ActiveGroup).Signals(chNum).XData(I))==0)
                        UD.current.mode=6;
                    else
                        UD.current.mode=5;
                    end
                else
                    UD.current.mode=13;
                end
            else
                if~extend
                    UD.current.mode=4;
                else
                    if(I>1)&&(I<length(UD.sbobj.Groups(ActiveGroup).Signals(chNum).XData))
                        UD.current.mode=12;
                    end
                end
            end
            UD.current.lockOutSingleClick=0;
            UD=update_channel_select(UD);
        otherwise
        end
    case 'axes'
        if~extend

            axesBottom=UD.current.axesExtent(2);
            axesTop=axesBottom+UD.current.axesExtent(4);

            if((Pfig(2)<axesBottom)||(Pfig(2)>axesTop))
                UD.current.mode=1;
                return;
            end

            Pax=fig_2_ax_coord(Pfig,currAx);
            if(Pax(1)>UD.common.dispTime(2)&&UD.current.isVerificationVisible)
                UD.current.mode=2;
                UD.current.channel=0;
                UD=update_channel_select(UD);
                splitterPos=calc_splitter_pos(UD.current.axesExtent,UD.geomConst.figBuffer);
                set(UD.verify.hg.splitter,'Visible','on','Position',splitterPos);
            else
                UD.current.mode=1;
                UD.current.channel=0;
                UD=update_channel_select(UD);
            end
        else
            UD.current.mode=1;
            UD.current.channel=0;
        end
    case 'figure'
        if~extend
            if UD.current.isVerificationVisible
                axExtent=UD.current.axesExtent;
                leftPos=axExtent(1)+axExtent(3);

                if(Pfig(1)>leftPos)&&(Pfig(1)<(leftPos+UD.geomConst.figBuffer))
                    if(Pfig(2)>axExtent(2))&&(Pfig(2)<(axExtent(2)+axExtent(4)))
                        UD.current.mode=2;
                        UD.current.channel=0;
                        UD=update_channel_select(UD);
                        splitterPos=calc_splitter_pos(UD.current.axesExtent,UD.geomConst.figBuffer);
                        set(UD.verify.hg.splitter,'Visible','on','Position',splitterPos);
                    end
                end
            end
        end
    case 'uicontrol'
        if~extend


            if(UD.current.isVerificationVisible&&currObj==UD.verify.hg.splitter)
                UD.current.mode=2;
                UD.current.channel=0;
                UD=update_channel_select(UD);
            end
        end
    otherwise,
    end
end

function UD=disable_adjustment_displays(UD)


    objs=[UD.adjust.XDisp,UD.adjust.YDisp];

    if isempty(objs)
        return;
    end
    figBgColor=get(UD.dialog,'Color');
    set(objs,'String','','BackgroundColor',figBgColor,'Enable','off');
    UD.adjust.XDisp=[];
    UD.adjust.YDisp=[];

    rpStruct=UD.hgCtrls.chRightPoint;
    lpStruct=UD.hgCtrls.chLeftPoint;
    objs=[rpStruct.title,rpStruct.xLabel,rpStruct.yLabel...
    ,lpStruct.title,lpStruct.xLabel,lpStruct.yLabel];
    set(objs,'Enable','off');
end

function out=in_drag_mode(mode)




    out=any(mode==4|mode==5|mode==6|mode==12|mode==13);
end

function UD=perform_abd_select(UD,currObj)



    if isempty(currObj)
        return;
    end

    switch(get(currObj,'Type'))
    case 'line'
        lineUd=get(currObj,'UserData');
        if~isempty(lineUd)&&strcmp(lineUd.type,'Channel')
            chNum=lineUd.index;
            UD.current.channel=chNum;
            UD.current.mode=3;
            UD=update_channel_select(UD);
        end

    case 'axes'
        axUD=get(currObj,'UserData');
        if~isempty(axUD)&&isfield(axUD,'type')&&strcmp(axUD.type,'editAxes')
            chNum=UD.axes(axUD.index).channels(1);
            if chNum~=UD.current.channel
                UD.current.channel=chNum;
                UD.current.mode=3;
                UD=update_channel_select(UD);
            end
        else
            UD.current.channel=0;
            UD.current.mode=1;
            UD=update_channel_select(UD);
        end
    end
end

function refresh_dynamic_pointer(UD,Pfig)


    persistent lockout;
    if isempty(lockout)
        lockout=(exist('hittest','builtin')~=5);
    end
    if lockout
        return;
    end

    hitObj=hittest(UD.dialog);

    switch(get(hitObj,'Type'))
    case 'axes'
        if UD.current.isVerificationVisible



            axesBottom=UD.current.axesExtent(2);
            axesTop=axesBottom+UD.current.axesExtent(4);
            axesLeft=UD.current.axesExtent(1);
            axesRight=axesLeft+UD.current.axesExtent(3);



            if Pfig(2)<axesBottom||Pfig(2)>axesTop
                UD.current.mode=1;
                set(UD.dialog,'Pointer','arrow');
                return;
            end







            if Pfig(1)>axesRight
                setptr(UD.dialog,'lrdrag');
                return;
            end
        end
        set(UD.dialog,'Pointer','arrow');


    case 'figure'
        if UD.current.isVerificationVisible



            axesBottom=UD.current.axesExtent(2);
            axesTop=axesBottom+UD.current.axesExtent(4);
            axesLeft=UD.current.axesExtent(1);
            axesRight=axesLeft+UD.current.axesExtent(3);







            if Pfig(1)>axesRight&&...
                Pfig(1)<axesRight+UD.geomConst.figBuffer&&...
                Pfig(2)>axesBottom&&...
                Pfig(2)<axesTop
                setptr(UD.dialog,'lrdrag');
                return;
            end
        end
        set(UD.dialog,'Pointer','arrow');


    case 'line'
        objUd=get(hitObj,'UserData');
        if isempty(objUd)

            return;
        end
        switch(objUd.type)
        case 'Channel'
            chNum=objUd.index;
            if isfield(UD,'channels')&&chNum>0&&chNum<=length(UD.channels)
                currAx=get(hitObj,'Parent');
                ActiveGroup=UD.sbobj.ActiveGroup;
                I=calc_channel_points(UD.sbobj.Groups(ActiveGroup).Signals(chNum).XData,...
                UD.sbobj.Groups(ActiveGroup).Signals(chNum).YData,...
                Pfig,currAx);
                if(length(I)==2)
                    if(diff(UD.sbobj.Groups(ActiveGroup).Signals(chNum).XData(I))==0)

                        setptr(UD.dialog,'lrdrag');
                        update_status_msg(UD,17);
                    else
                        setptr(UD.dialog,'uddrag');
                        update_status_msg(UD,16);
                    end
                else
                    set(UD.dialog,'Pointer','circle');
                    update_status_msg(UD,14);

                end
            end
        otherwise
            set(UD.dialog,'Pointer','arrow');
            update_status_msg(UD);
        end
    otherwise,
        set(UD.dialog,'Pointer','arrow');
        update_status_msg(UD);
    end
end

function[UD,modified]=update_click_lockout(UD,Pfig)



    modified=0;

    if(UD.current.lockOutSingleClick==1)
        return;
    end

    sep=UD.current.bdPoint-Pfig;
    [~,r]=cart2pol(sep(1),sep(2));

    if(r>UD.geomConst.singleClickThresh)
        UD.current.lockOutSingleClick=1;
        modified=1;
    end
end


