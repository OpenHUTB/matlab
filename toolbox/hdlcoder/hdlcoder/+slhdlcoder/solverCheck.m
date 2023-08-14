function checks=solverCheck(this,rates,Severity,CachedSingleTaskRateTransMsg,generatingTB)


    checks=struct('path',{},...
    'type',{},...
    'message',{},...
    'level',{},...
    'MessageID',{});

    if this.isDutModelRef
        mdlName=get_param(get_param(this.DUTMdlRefHandle,'ActiveVariantBlock'),'ModelName');
    else
        mdlName=this.ModelName;
    end


    rates=rates(rates~=Inf);


    if~(all(rates==-1)||all(rates==0))




        rates(rates==-1)=min(rates(rates>=0));
        if any(rates(1)~=rates)
            solver=get_param(mdlName,'Solver');
            solverType=get_param(mdlName,'SolverType');
            multitaskingMode=get_param(mdlName,'EnableMultiTasking');
            if~(strcmp(solver,'FixedStepDiscrete')&&...
                strcmp(solverType,'Fixed-step')&&...
                strcmp(multitaskingMode,'off'))
                msg=message('HDLShared:hdlshared:MultirateSolver');
                check.path=this.getStartNodeName;
                check.type='model';
                check.message=msg.getString;
                check.level=Severity;
                check.MessageID=msg.Identifier;
                checks=check;
            end








            if(isempty(CachedSingleTaskRateTransMsg))
                singleTaskRateTransition=get_param(mdlName,'SingleTaskRateTransMsg');
            else
                singleTaskRateTransition=CachedSingleTaskRateTransMsg;
            end
            multiTaskRateTransition=get_param(mdlName,'MultiTaskRateTransMsg');
            if~strcmp(multiTaskRateTransition,'error')||...
                ~(strcmp(singleTaskRateTransition,'error')||generatingTB)
                msg=message('HDLShared:hdlshared:MultirateMultiTasking');
                check.path=this.getStartNodeName;
                check.type='model';
                check.message=msg.getString;
                check.level='Error';
                check.MessageID=msg.Identifier;
                checks(end+1)=check;
            end


            if strcmpi(get_param(mdlName,'AutoInsertRateTranBlk'),'on')
                msg=message('HDLShared:hdlshared:AutoRateTransfer');
                check.path=this.getStartNodeName;
                check.type='model';
                check.message=msg.getString;
                check.level=Severity;
                check.MessageID=msg.Identifier;
                checks(end+1)=check;
            end
        end
    end



end

