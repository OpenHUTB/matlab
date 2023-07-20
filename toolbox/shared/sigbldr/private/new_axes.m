function UD=new_axes(UD,index,channels,varargin)







    position=[];

    switch(nargin)
    case 6,
        ylimits=varargin{1};
        xlimits=varargin{2};
        doFast=varargin{3};
        vertProportion=1/(UD.numAxes+1);
    case 5,
        ylimits=varargin{1};
        xlimits=varargin{2};
        doFast=0;
        vertProportion=1/(UD.numAxes+1);
    case 4,
        ylimits=varargin{1};
        xlimits=UD.common.dispTime;
        doFast=0;
        vertProportion=1/(UD.numAxes+1);
    case 3,
        ylimits=[-1,1];
        xlimits=UD.common.dispTime;
        doFast=0;
        vertProportion=1/(UD.numAxes+1);
    otherwise,
        error(message('sigbldr_ui:new_axes:needThreeInputs'));
    end


    if isempty(vertProportion)
        vertProportion=1/(UD.numAxes+1);
    end

    if isempty(xlimits)
        xlimits=UD.common.dispTime;
    end
    if isempty(ylimits)
        ylimits=[-1,1];
    end


    if~isempty(position)
        if(UD.numAxes>0)
            error(message('sigbldr_ui:new_axes:cantGivePosWhenAddingAxes'));
        end
    end


    UD.numAxes=UD.numAxes+1;
    if(UD.numAxes>1)
        xlabelAxes=UD.axes(1).handle;
        ySizeReduction=1-vertProportion;
        if index<=length(UD.axes)

            moveUpAxes=UD.axes(index:end);
            for j=1:length(moveUpAxes)
                axUd=get(moveUpAxes(j).handle,'UserData');
                axUd.index=axUd.index+1;
                set(moveUpAxes(j).handle,'UserData',axUd);
                moveUpchannels=moveUpAxes(j).channels;
                for chIdx=moveUpchannels
                    UD.channels(chIdx).axesInd=axUd.index;
                end
            end
            UD.axes(index)=axes_data_struct(ylimits,vertProportion);
            UD.axes=[UD.axes(1:index),moveUpAxes];
        else
            UD.axes(index)=axes_data_struct(ylimits,vertProportion);
        end
        for i=1:UD.numAxes
            if(i~=index)
                UD.axes(i).vertProportion=ySizeReduction*UD.axes(i).vertProportion;
            end
        end
    else
        UD.axes=axes_data_struct(ylimits,vertProportion);
    end


    axesUD=struct('type','editAxes','index',index);

    if in_iced_state_l(UD),
        color=light_gray_l;
    else
        color=default_axes_bg_color_l;
    end;

    axesH=axes(...
    'Parent',UD.dialog,...
    'Units','points',...
    'XGrid',UD.current.gridSetting,...
    'YGrid',UD.current.gridSetting,...
    'XLim',xlimits,...
    'YLim',ylimits,...
    'UIContextMenu',UD.menus.channelContext.handle,...
    'HandleVisibility','callback',...
    'Box','off',...
    'Visible','off',...
    'Color',color,...
    'UserData',axesUD);

    labelH=text('String',' ',...
    'Parent',axesH,...
    'Position',[0,0,0],...
    'VerticalAlignment','middle',...
    'Interpreter','none',...
    'BackgroundColor',axesH.Color,...
    'Margin',0.5,...
    'HorizontalAlignment','left');

    UD.axes(index).labelH=labelH;

    UD.axes(index).handle=axesH;
    UD.current.axes=axesH;
    update_gca_display(UD.current.axes,UD.hgCtrls.tabselect.axesH)
    xl=get(axesH,'XLabel');

    if(UD.numAxes>1)

        if index==1
            set(axesH,'XTick',get(xlabelAxes,'XTick'));
            set(axesH,'XTickLabel',get(xlabelAxes,'XTickLabel'));
            set(xlabelAxes,'XTickLabel','');
            xlold=get(xlabelAxes,'XLabel');
            set(xlold,'String','');
            ax.XTickLabelMode='auto';
            ax.XTickMode='auto';
            set(xl,'String',getString(message('sigbldr_ui:create:TimeSec')),'FontWeight','Bold');
        else
            ax.XTick=get(xlabelAxes,'XTick');
            ax.XTickLabel='';
            ax.XTickLabelMode='manual';
            ax.XTickMode='auto';
        end
        set(axesH,ax);
    else
        set(xl,'String',getString(message('sigbldr_ui:create:TimeSec')),'FontWeight','Bold');
    end


    for i=1:UD.numAxes
        pos=calc_new_axes_position(UD.current.axesExtent,UD.geomConst,UD.numAxes,i);
        set(UD.axes(i).handle,'Position',pos);
        set(UD.axes(i).handle,'Visible','on');
    end



    for i=1:length(channels)
        chIndex=channels(i);
        UD=new_plot_channel(UD,chIndex,index);
    end

    if~doFast
        drawnow('expose')
        update_all_axes_label(UD.axes);
    end


end

function axStruct=axes_data_struct(ylimits,vertProportion)

    if nargin<2
        vertProportion=1;
    end

    if nargin<1
        ylimits=[-1,1];
    end

    axStruct=struct(...
    'handle',[],...
    'numChannels',[],...
    'channels',[],...
    'yLim',ylimits,...
    'lineLabels',[],...
    'labelPos','TL',...
    'labelH',0,...
    'vertProportion',vertProportion);
end

