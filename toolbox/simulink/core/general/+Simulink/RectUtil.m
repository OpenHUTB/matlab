
classdef RectUtil
    methods(Static)

        function ltrb=toLTRB(rect)
            ltrb=[rect(1),rect(2),rect(1)+rect(3),rect(2)+rect(4)];
        end


        function rb=bottomRight(rect)
            rb=[rect(1)+rect(3),rect(2)+rect(4)];
        end


        function rect=fromCornerPoints(p,q)
            rect=[min([p(1),q(1)]),min([p(2),q(2)]),...
            abs(p(1)-q(1)),abs(p(2)-q(2))];
        end


        function rect=fromPointAndSize(p,size)
            rect=[p(1),p(2),size(1),size(2)];
        end


        function res=diff(r1,r2)
            res=Simulink.RectUtil.toLTRB(r1)-Simulink.RectUtil.toLTRB(r2);
        end


        function res=offset(rect,offset)
            res=[rect(1)+offset(1),rect(2)+offset(2),rect(3),rect(4)];
        end


        function res=center(rect)
            res=[rect(1)+rect(3)*0.5,rect(2)+rect(4)*0.5];
        end


        function res=centerAt(rect,newCenter)
            res=Simulink.RectUtil.offset(rect,newCenter-Simulink.RectUtil.center(rect));
        end


        function res=expand(rect,margins)
            res=[rect(1)-margins(1),rect(2)-margins(2),...
            rect(3)+margins(1)+margins(3),...
            rect(4)+margins(2)+margins(4)];
        end


        function res=union(rect1,rect2)
            l=min([rect1(1),rect2(1)]);
            t=min([rect1(2),rect2(2)]);
            r=max([rect1(1)+rect1(3),rect2(1)+rect2(3)]);
            b=max([rect1(2)+rect1(4),rect2(2)+rect2(4)]);
            res=[l,t,r-l,b-t];
        end


        function res=unionPoint(rect,p)
            l=min([rect(1),p(1)]);
            t=min([rect(2),p(2)]);
            r=max([rect(1)+rect(3),p(1)]);
            b=max([rect(2)+rect(4),p(2)]);
            res=[l,t,r-l,b-t];
        end


        function offset=minMoveForMaxOverlap(rectToMove,fixedRect)
            diff=Simulink.RectUtil.diff(rectToMove,fixedRect);
            xOffset=0;
            yOffset=0;

            if sign(diff(1))==sign(diff(3))
                xOffset=-sign(diff(1))*min(abs(diff(1)),abs(diff(3)));
            end
            if sign(diff(2))==sign(diff(4))
                yOffset=-sign(diff(2))*min(abs(diff(2)),abs(diff(4)));
            end
            offset=[xOffset,yOffset];
        end
    end
end