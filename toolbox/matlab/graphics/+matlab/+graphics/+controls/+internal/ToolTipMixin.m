classdef ToolTipMixin<handle


    properties
        Tooltip='';
    end

    properties(Access=protected,Transient,NonCopyable)
        hToolTip=[];
    end

    methods(Hidden,Access={?tToolTipMixin,?AxesToolbarFriend})
        function handleToolTip=gethToolTip(obj)
            handleToolTip=obj.hToolTip;
        end
    end

    methods(Hidden)


        function showToolTip(obj)
            if~isempty(obj)
                pos=obj.Position;
                x=pos(1)+11;
                y=pos(2)-7;
                if isempty(obj.hToolTip)
                    obj.createToolTip();
                end

                obj.hToolTip.String=obj.Tooltip;
                obj.hToolTip.Position=[x,y,0];
                obj.hToolTip.Visible='on';
            end
        end

        function hideToolTip(obj)
            if~isempty(obj.hToolTip)
                obj.hToolTip.Visible='off';
            end
        end



        function createToolTip(obj)
            obj.hToolTip=matlab.graphics.primitive.Text('Visible','off');
            obj.hToolTip.String=obj.Tooltip;
            obj.hToolTip.VerticalAlignment='top';
            obj.hToolTip.HorizontalAlignment='right';
            obj.hToolTip.Internal=true;
            obj.hToolTip.HitTest='off';
            obj.hToolTip.HandleVisibility='off';
            obj.hToolTip.Clipping='off';
            obj.hToolTip.BackgroundColor=[255,255,225]./255;
            obj.hToolTip.Margin=2;
            obj.hToolTip.EdgeColor='black';
            obj.hToolTip.Color='black';
            obj.hToolTip.PickableParts='none';
            obj.hToolTip.FontSmoothing='on';
            obj.hToolTip.FontName=get(groot,'FactoryAxesFontName');
            obj.hToolTip.FontSize=0.85*get(groot,'FactoryAxesFontSize');
            obj.hToolTip.Layer='front';

            obj.addNode(obj.hToolTip);
        end
    end
end

