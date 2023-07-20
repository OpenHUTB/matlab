classdef polariMBPeaksTable<internal.polariMouseBehavior


    methods
        function obj=polariMBPeaksTable

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
    if s.overFigPanel
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


    if p.ToolTips&&~isempty(p.hToolTip)&&isvalid(p.hToolTip)
        start(p.hToolTip,...
        'Right-click for options');
    end
end
