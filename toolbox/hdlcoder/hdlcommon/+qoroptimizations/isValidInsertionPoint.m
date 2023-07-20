function[valid,msg]=isValidInsertionPoint(curS)



    reasons={};
    valid=true;





    if(isempty(curS.signal))

        reasons{end+1}=message('hdlcoder:optimization:CutNotTraceable').getString;
        valid=false;
    else
        if(~hasGuidedRetimingDBMatchingDelay(curS.signal))
            if(isInLoop(curS.signal))
                if(~(isInCRP(curS.signal)&&getClockRatePipelineAllowance(curS.signal)>0))

                    reasons{end+1}=message('hdlcoder:optimization:CutInLoop').getString;
                    valid=false;
                end
            end
            if(isAllReceiverDelays(curS.signal))

                reasons{end+1}=message('hdlcoder:optimization:CutFollowedByDelays').getString;
                valid=false;
            end
            if(isAllDriverDelays(curS.signal))

                reasons{end+1}=message('hdlcoder:optimization:CutDrivenByDelays').getString;
                valid=false;
            end
            if(length(curS.signal.Owner.instances)>1)

                reasons{end+1}=message('hdlcoder:optimization:CutInMultiInst').getString;
                valid=false;
            end
        end
    end

    if(valid)
        msg='';
    else
        assert(~isempty(reasons));
        msg=reasons{1};
        for i=2:length(reasons)
            msg=sprintf('%s\n%s',msg,reasons{i});
        end
    end
end

function inLoop=isInLoop(s)
    assert(~isempty(s));
    inLoop=s.isInLoopInDelayBalancedRegion();
end

function allDelays=isAllReceiverDelays(s)
    allDelays=false;
    if(~isempty(s))
        recOfS=s.getConcreteReceivingComps();
        allDelays=true;
        for ii=1:length(recOfS)
            comp=recOfS(ii);
            if(~isDelayDerivedComp(comp)&&(~comp.isBlackBox()||~comp.elaborationHelper()))
                allDelays=false;
                break;
            end
        end
    end
end

function allDelays=isAllDriverDelays(s)
    allDelays=false;
    if(~isempty(s))
        drvOfS=s.getConcreteDrivingComps();
        allDelays=true;
        for ii=1:length(drvOfS)
            comp=drvOfS(ii);
            if(~isDelayDerivedComp(comp)&&(~comp.isBlackBox()||~comp.elaborationHelper()))
                allDelays=false;
                break;
            end
        end
    end
end

function delay=isDelayDerivedComp(comp)




    if(isequal(class(comp),'hdlcoder.network'))
        delay=false;
    else
        delay=comp.isDelay()||comp.isTappedDelay();
    end
end

