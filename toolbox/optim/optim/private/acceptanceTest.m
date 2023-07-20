function[stepAccept,nextTrialStepType,trRadius,stepTooSmall]=acceptanceTest(meritDecrease,modelDecrease,...
    xCurrent,trialStep,f_ip,fTrial_ip,...
    trRadius,options,sizes)














    if meritDecrease>=1e-8*modelDecrease&&~trialStep.autoReject&&modelDecrease>=0
        nextTrialStepType=trialStep.type;
        stepAccept=true;
        stepTooSmall=false;
    else

        stepAccept=false;




        if strcmpi(trialStep.type,'pc')
            nextTrialStepType='direct';

        elseif meritDecrease<0&&fTrial_ip<=f_ip...
            &&(strcmpi(trialStep.type,'cg')||strcmpi(trialStep.type,'direct'))...
            &&~trialStep.autoReject

            if strcmpi(trialStep.type,'cg')
                nextTrialStepType='cgsoc';
            else
                nextTrialStepType='directsoc';
            end
        elseif trialStep.useDirect&&trialStep.bkCount<3

            nextTrialStepType='directbk';
        else



            if strcmpi(trialStep.type,'cg')||strcmpi(trialStep.type,'cgsoc')
                trRadius=0.5*min(trRadius,norm(trialStep.normal+trialStep.tangential));
            end
            if strcmpi(trialStep.type,'cgfeas')
                trRadius=0.5*min(trRadius,norm(trialStep.stepFeas));
                nextTrialStepType='cgfeas';
            else
                nextTrialStepType='cg';
            end
        end

        if all(abs(trialStep.primal(1:sizes.nVar))<options.TolX*max(1,abs(xCurrent)))
            stepTooSmall=true;
        else
            stepTooSmall=false;
        end
    end
