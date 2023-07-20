










classdef UIPanel<hgsetget

    methods(Static,Access=public)
        function y=moveComponent(h,x,y,pad)

            hPos=get(h,'Position');
            set(h,'Position',[x,y-pad-hPos(4),hPos(3),hPos(4)]);

            y=y-hPos(4);
            y=y-pad;
        end

        function shiftComponentDown(h,y)
            pos=get(h,'Position');
            pos(2)=pos(2)-y;
            set(h,'Position',pos);
        end

        function out=getFieldPadding()
            out=16;
            if ismac
                out=30;
            end
        end

        function yPad=getYPosPadding()
            yPad=34;
            if ismac
                yPad=50;
            end
        end

        function xPad=getXPosPadding()
            xPad=9;
            if ismac
                xPad=25;
            end
        end

        function xPad=getWidthPadding()
            xPad=15;
            if ismac
                xPad=20;
            end
        end

        function xPad=getPlotComboBoxPadding()
            xPad=4;
            if ismac
                xPad=12;
            end
        end
    end
end