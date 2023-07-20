function[delta,modifiedStep]=fwdFinDiffInsideBnds(xC,lb,ub,delta,dim,DiffMinChange)



















    modifiedStep=false;



    if lb~=ub&&xC>=lb&&xC<=ub
        if xC+delta>ub||xC+delta<lb
            delta=-delta;
            modifiedStep=true;
            if xC+delta>ub||xC+delta<lb
                [newDelta,indsign]=max([xC-lb,ub-xC]);
                if newDelta>=DiffMinChange
                    delta=((-1)^indsign)*newDelta;
                    warning(message('optimlib:fwdFinDiffInsideBnds:StepReduced',dim,sprintf('%0.5g',2*abs(delta))))
                else
                    mexcptn=MException('optimlib:fwdFinDiffInsideBnds:DistanceTooSmall',...
                    getString(message('optimlib:fwdFinDiffInsideBnds:DistanceTooSmall',dim,sprintf('%0.5g',2*DiffMinChange))));
                    throwAsCaller(mexcptn);
                end
            end
        end
    end

