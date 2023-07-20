function FigKeyEvent(p,ev)




    if~p.Interactive
        return
    end

    isKeyPressed=strcmpi(ev.EventName,'WindowKeyPress');
    key=ev.Key;





    p.pShiftKeyPressed=isKeyPressed&&...
    (strcmpi(key,'shift')||...
    strcmpi(key,'control'));




    s=computeHoverLocation(p,[]);


    if isKeyPressed&&s.any

        switch key
        case{'delete','backspace'}
            delKeyPressed(p);




        end
    end
