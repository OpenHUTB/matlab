function invokeLatestMouseMotionHandler(p,ev)









    b=p.pMouseBehavior;
    if isempty(b)
        return
    end
    fcn=b.MotionEvent;
    if isempty(fcn)
        return
    end
    if nargin<2
        ev=p.pLatestMotionEv;
        if isempty(ev)

            h=p.hAxes;
            ev.EventName='WindowMouseMotion';
            ev.Source=h;
            ev.HitObject=h;
            ev.Point=h.CurrentPoint;
        end
    end

    fcn(p,ev);
