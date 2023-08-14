function changeMouseBehavior(p,mouseBehavior,signalChangedState)











    if~strcmpi(mouseBehavior,p.LastMouseBehavior)




        p.LastMouseBehavior=mouseBehavior;

        if nargin<3||signalChangedState
            p.ChangedState=true;
        end
        installMouseBehavior(p,mouseBehavior);
    end
