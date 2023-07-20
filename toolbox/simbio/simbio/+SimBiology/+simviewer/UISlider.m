










classdef UISlider<SimBiology.simviewer.UIPanel

    properties(Access=public)
        Max=-1;
        MaxField=-1;
        Min=-1;
        MinField=-1;
        Name=-1;
        NameLabel=-1;
        UnitsLabel=-1;
        RangeButton=-1;
        ShowRange=false;
        Slider=-1;
        Units='';
        Value=-1;
        ValueField=-1;
    end

    methods
        function obj=UISlider(model)
            obj.Min=model.Min;
            obj.Max=model.Max;
            obj.Name=model.Name;
            obj.Units=model.Units;
            obj.Value=model.Value;
        end

        function initComponents(obj,hFigure,index)
            obj.NameLabel=uicontrol(hFigure,'Style','text',...
            'String',obj.Name,...
            'HorizontalAlignment','left',...
            'HandleVisibility','off',...
            'Tag',['ExploreModelTab_ParamValue_NameLabel_',num2str(index)]);

            obj.Slider=uicontrol(hFigure,'Style','slider',...
            'Min',obj.Min,...
            'Max',obj.Max,...
            'Value',obj.Value,...
            'HandleVisibility','off',...
            'Tag',['ExploreModelTab_ParamValue_Slider_',num2str(index)]);

            obj.ValueField=uicontrol(hFigure,'Style','edit',...
            'String',obj.Value,...
            'HandleVisibility','off',...
            'Tag',['ExploreModelTab_ParamValue_ValueField_',num2str(index)]);

            obj.RangeButton=uicontrol(hFigure,'Style','pushbutton',...
            'String','...',...
            'HandleVisibility','off',...
            'Tag',['ExploreModelTab_ParamValue_RangeButton_',num2str(index)]);

            obj.MinField=uicontrol(hFigure,'Style','edit',...
            'String',num2str(obj.Min),...
            'Visible','off',...
            'HandleVisibility','off',...
            'Tag',['ExploreModelTab_ParamValue_MinField_',num2str(index)]);

            obj.MaxField=uicontrol(hFigure,'Style','edit',...
            'String',num2str(obj.Max),...
            'Visible','off',...
            'HandleVisibility','off',...
            'Tag',['ExploreModelTab_ParamValue_MaxField_',num2str(index)]);

            obj.UnitsLabel=uicontrol(hFigure,'Style','text',...
            'String',obj.Units,...
            'Visible','off',...
            'FontSize',7,...
            'HorizontalAlignment','left',...
            'HandleVisibility','off',...
            'Tag',['ExploreModelTab_ParamValue_UnitsLabel_',num2str(index)]);

            if~isempty(obj.Units)
                obj.UnitsLabel.Visible='on';
            end
        end

        function showComponents(obj,visible)
            obj.NameLabel.Visible=visible;
            obj.UnitsLabel.Visible=visible;
            obj.RangeButton.Visible=visible;
            obj.Slider.Visible=visible;
            obj.ValueField.Visible=visible;

            if strcmp(visible,'off')
                obj.MaxField.Visible=visible;
                obj.MinField.Visible=visible;
            end
        end

        function y=positionComponents(obj,handles,x,y,okToPad)
            figPosition=handles.Figure.Position;
            tabPosition=handles.TabPanelGroup.Position;
            width=max(40,figPosition(3)*tabPosition(3)-SimBiology.simviewer.UIPanel.getXPosPadding());
            showUnits=strcmp(obj.UnitsLabel.Visible,'on');

            pad=0;
            if okToPad&&~showUnits
                pad=6;
            end

            y=SimBiology.simviewer.UIPanel.moveComponent(obj.NameLabel,x,y,pad);
            SimBiology.simviewer.UIPanel.shiftComponentDown(obj.NameLabel,4);

            if strcmp(obj.UnitsLabel.Visible,'on')
                y=SimBiology.simviewer.UIPanel.moveComponent(obj.UnitsLabel,x,y,pad);
                y=y+10;
            end


            labelWidth=obj.NameLabel.Position(3);
            buttonWidth=obj.RangeButton.Position(3);
            fieldWidth=60;
            sliderWidth=max(60,width-labelWidth-buttonWidth-fieldWidth-20);


            x=x+obj.NameLabel.Position(3)+4;

            set(obj.Slider,'Position',[x,y,sliderWidth,obj.Slider.Position(4)]);
            x=x+sliderWidth+4;

            set(obj.ValueField,'Position',[x,y,fieldWidth,obj.ValueField.Position(4)]);
            x=x+fieldWidth+4;

            pos=obj.RangeButton.Position;
            set(obj.RangeButton,'Position',[x,y,pos(3),pos(4)]);

            if obj.ShowRange
                y=y-obj.Slider.Position(4)-4;
                pos=obj.MinField.Position;
                set(obj.MinField,'Position',[obj.Slider.Position(1),y,pos(3),pos(4)],'Visible','on');
                set(obj.MaxField,'Position',[obj.Slider.Position(1)+obj.Slider.Position(3)-pos(3),y,pos(3),pos(4)],'Visible','on');
            else
                set(obj.MinField,'Visible','off');
                set(obj.MaxField,'Visible','off');
            end
        end
    end
end