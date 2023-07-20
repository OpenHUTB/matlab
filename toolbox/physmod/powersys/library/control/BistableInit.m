function[WantBlockChoice,Ts,sps]=BistableInit(block,SPSpriority,ic,Ts)






    if SPSpriority==1
        sps.str1='[R]';
        sps.str2='S';
    else
        sps.str1='R';
        sps.str2='[S]';
    end

    [WantBlockChoice,Ts,~,Init]=DetermineBlockChoice(block,Ts,0,1);



    if Init
        if~all(ic==0|ic==1)
            error(message('physmod:powersys:common:InvalidParameterState','Initial condition (state of Q)',block,'0','1'));
        end
    end
