classdef AxesHelpText<handle
    properties(Transient)
        String='';
    end

    properties(Hidden,Transient,SetAccess=private)
Axes
Text
    end

    properties(Hidden,Constant)
        TextColor=[.5,.5,.5];
        FontSize=14;
    end

    methods
        function this=AxesHelpText(hAxes)
            this.Axes=hAxes;
            this.Text=matlab.graphics.primitive.Text.empty;
        end

        function set.String(this,newVal)
            this.String=newVal;
            if isempty(newVal)
                delete(this.Text(ishghandle(this.Text)));
                this.Text=matlab.graphics.primitive.Text.empty;
            elseif isempty(this.Text)
                this.Text=text(this.Axes,...
                'FontSize',this.FontSize,...
                'HitTest','off',...
                'Color',this.TextColor,...
                'HorizontalAlignment','center');
                setappdata(this.Text,'listener',event.proplistener(this.Axes,{this.Axes.findprop('XLim'),this.Axes.findprop('YLim')},'PostSet',@this.update));
                update(this);
            else
                update(this);
            end
        end

        function update(this,~,~)
            if~isempty(this.String)&&~isempty(this.Text)
                this.Text.String=matlabshared.application.wrapText(this.String,this.Text,this.Axes);
                this.Text.Position=[mean(this.Axes.XLim),mean(this.Axes.YLim),this.Axes.ZLim(2)];
            end
        end
    end

end