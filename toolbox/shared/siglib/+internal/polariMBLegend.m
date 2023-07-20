classdef polariMBLegend<internal.polariMouseBehavior

    methods
        function obj=polariMBLegend

            obj.InstallFcn=@showToolTipAndPtr;
            obj.MotionEvent=@wbmotion;
            obj.DownEvent=[];
            obj.UpEvent=[];
            obj.ScrollEvent=[];
        end
    end
end





function wbmotion(p,ev)




    s=computeHoverLocation(p,ev);



    firstEntry=p.ChangedState;
    if s.overLegend
        if firstEntry


            p.ChangedState=false;
            showToolTipAndPtr(p);
        end
    else
        if~firstEntry

            autoChangeMouseBehavior(p,s);
        end
    end
end

function showToolTipAndPtr(p)
    setptr(p.hFigure,'hand');
    if p.ToolTips&&~isempty(p.hToolTip)&&isvalid(p.hToolTip)
        start(p.hToolTip,...
        {'Drag to move, DELETE to remove;'});



    end
end
