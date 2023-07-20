function[delta,formulaType]=cntrlFinDiffInsideBnds(xC,lb,ub,delta,dim,DiffMinChange)






































    formulaType=0;


    if lb~=ub&&xC>=lb&&xC<=ub
        if xC-delta<lb
            if ub<xC+delta

                distNear=min([xC-lb,ub-xC]);
                [distFar,far_idx]=max([xC-lb,ub-xC]);
                if distNear>=distFar/2


                    delta=distNear;
                    formulaType=0;
                else



                    delta=distFar/2;


                    formulaType=(-1)^far_idx;
                end
            else
                if xC+2*delta<=ub

                    formulaType=1;
                else


                    if xC-lb>=(ub-xC)/2


                        delta=xC-lb;
                        formulaType=0;
                    else


                        delta=(ub-xC)/2;
                        formulaType=1;
                    end
                end
            end
        elseif ub<xC+delta
            if lb<=xC-2*delta

                formulaType=-1;
            else


                if ub-xC>=(xC-lb)/2


                    delta=ub-xC;
                    formulaType=0;
                else


                    delta=(xC-lb)/2;
                    formulaType=-1;
                end
            end
        end


        if delta<DiffMinChange
            mexcptn=MException('optimlib:cntrlFinDiffInsideBnds:DistanceTooSmall',...
            getString(message('optimlib:cntrlFinDiffInsideBnds:DistanceTooSmall',dim,sprintf('%0.5g',3*DiffMinChange))));
            throwAsCaller(mexcptn);
        end
    end


