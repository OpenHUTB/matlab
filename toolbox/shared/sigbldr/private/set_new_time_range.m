function UD=set_new_time_range(UD,range,fromScrollbar)








    if nargin==2||isempty(fromScrollbar)
        fromScrollbar=0;
    end


    if diff(range)<=0
        return;
    end


    if range(1)<UD.common.minTime

        if range(2)<=UD.common.minTime
            errordlg(getString(message('sigbldr_ui:set_new_time_range:DisplayLimits')));
            return;
        end
        warndlg(getString(message('sigbldr_ui:set_new_time_range:MinimumDisplayLimits',...
        num2str(UD.common.minTime))));
        range(1)=UD.common.minTime;
    end
    if range(2)>UD.common.maxTime

        if range(1)>=UD.common.maxTime
            errordlg(getString(message('sigbldr_ui:set_new_time_range:DisplayLimits')));
            return;
        end
        warndlg(getString(message('sigbldr_ui:set_new_time_range:MaximumDisplayLimits',...
        num2str(UD.common.maxTime))));
        range(2)=UD.common.maxTime;
    end



    for i=1:UD.numAxes
        set(UD.axes(i).handle,'XLim',range);
    end

    UD.common.dispTime=range;


    if~fromScrollbar
        scrollBarVisible=strcmp(get(UD.tlegend.scrollbar,'Visible'),'on');

        if(range(1)==UD.common.minTime&range(2)==UD.common.maxTime)
            if scrollBarVisible
                set(UD.tlegend.scrollbar,'Enable','off','Visible','off');
                UD.current.axesExtent=UD.current.axesExtent+[0,-1,0,1]*UD.geomConst.scrollHeight;
                for i=1:UD.numAxes
                    pos=calc_new_axes_position(UD.current.axesExtent,UD.geomConst,UD.numAxes,i);
                    set(UD.axes(i).handle,'Position',pos);
                end
            end
        else

            visTime=diff(range);
            pageStep=visTime/(UD.common.maxTime-UD.common.minTime-visTime);
            if or(pageStep>1,pageStep<0)
                pageStep=1;
            end
            oldScrollPos=get(UD.tlegend.scrollbar,'Position');
            scrollPos=[oldScrollPos(1:2)...
            ,UD.current.axesExtent(3)-UD.geomConst.axesOffset(1)...
            ,oldScrollPos(4)];
            scrollBarMax=UD.common.maxTime-visTime;
            scrollBarValue=range(1);

            if scrollBarMax<scrollBarValue
                scrollBarValue=scrollBarMax;
            end
            set(UD.tlegend.scrollbar,...
            'Min',UD.common.minTime,...
            'Max',scrollBarMax,...
            'SliderStep',[0.1,0.9]*pageStep,...
            'Value',scrollBarValue,...
            'BackgroundColor','w',...
            'Position',scrollPos,...
            'Visible','on',...
            'Enable','on');

            if~scrollBarVisible
                UD.current.axesExtent=UD.current.axesExtent+[0,1,0,-1]*UD.geomConst.scrollHeight;
                for i=1:UD.numAxes
                    pos=calc_new_axes_position(UD.current.axesExtent,UD.geomConst,UD.numAxes,i);
                    set(UD.axes(i).handle,'Position',pos);
                end
            end
        end
    end

    update_all_axes_label(UD.axes);
