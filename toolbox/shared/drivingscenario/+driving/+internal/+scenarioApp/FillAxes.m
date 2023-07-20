classdef FillAxes<matlabshared.application.FillAxes
    methods(Hidden)
        function updateLimits(this,ax)
            if nargin<2
                ax=getAxes(this);
            end

            p=get(ax,'Parent');
            origAUnits=get(ax,'Units');
            origPUnits=get(p,'Units');
            c1=onCleanup(@()set(ax,'Units',origAUnits));
            c2=onCleanup(@()set(p,'Units',origPUnits));
            set(ax,'Units','Pixels');
            pos=get(p,'Position');
            insets=get(ax,'LooseInset');



            if insets(4)<25
                insets(4)=25;
            end

            pos(3)=abs(pos(3)-insets(1)-insets(3));
            pos(4)=abs(pos(4)-insets(2)-insets(4));

            center=this.Center;
            unitsPerPixel=getUnitsPerPixel(this,ax);
            range=[-1,1]*unitsPerPixel/2;

            view=ax.View;
            if isequal(view,[0,90])
                set(ax,...
                'XLim',center(1)+range*pos(3),...
                'YLim',center(2)+range*pos(4));
            elseif isequal(view,[0,0])
                set(ax,...
                'XLim',center(1)+range*pos(3),...
                'ZLim',center(3)+range*pos(4));
            elseif isequal(view,[90,0])
                set(ax,...
                'YLim',center(2)+range*pos(3),...
                'ZLim',center(3)+range*pos(4));
            elseif isequal(view,[-90,90])
                set(ax,...
                'XLim',center(1)+range*pos(4),...
                'YLim',center(2)+range*pos(3));
            end
        end
    end
end
