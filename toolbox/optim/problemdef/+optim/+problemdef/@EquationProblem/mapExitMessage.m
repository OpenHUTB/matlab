function output=mapExitMessage(~,fval,exitflag,output,varargin)







    if~any(strcmp(output.solver,{'lsqnonlin','lsqlin'}))
        return
    end


    resnorm=fval(:)'*fval(:);




    tolFunValue=optim.problemdef.EquationProblem.getFunctionToleranceForSolve(...
    output.solver,varargin{:});
    sqrtTolFunValue=sqrt(tolFunValue);



    if isfield(output,'msgData')
        msgData=output.msgData;
        output=rmfield(output,'msgData');
    else
        msgData=[];
    end


    switch output.solver
    case 'lsqnonlin'
        output=mapLsqnonlinExitflagAndMessage(exitflag,output,...
        resnorm,sqrtTolFunValue,msgData);
    case 'lsqlin'
        output=mapLsqlinExitflagAndMessage(exitflag,output,...
        resnorm,sqrtTolFunValue,msgData);
    end

    function output=mapLsqnonlinExitflagAndMessage(exitflag,output,...
        resnorm,sqrtTolFunValue,msgData)



        makeExitMsg=true;
        doFormatMessage=true;
        switch output.algorithm
        case 'trust-region-reflective'
            algorithmflag=1;
        case 'levenberg-marquardt'
            algorithmflag=3;
        otherwise
            doFormatMessage=false;
        end

        if doFormatMessage
            [~,output.message]=formatFsolveMessage(resnorm,...
            sqrtTolFunValue,exitflag,msgData,algorithmflag,makeExitMsg,...
            output.solver);
        end

        function output=mapLsqlinExitflagAndMessage(exitflag,output,...
            resnorm,sqrtTolFunValue,msgData)

            if any(strcmp(output.algorithm,{'unconstrained','mldivide'}))||(exitflag<=0||exitflag>3)

                return
            end


            algorithm=replace(output.algorithm,'trust-region-reflective','TRR');
            algorithm=replace(algorithm,'interior-point','IP');



            msgId="optim_problemdef:EquationProblem:mapExitflagAndMessage:Lsqlin";
            if resnorm>sqrtTolFunValue
                msgId=msgId+algorithm+exitflag+"NoRoot";
            else
                msgId=msgId+algorithm+exitflag+"Root";
            end



            if strcmp(output.algorithm,'trust-region-reflective')
                msgData=cell(1,4);

                msgData{3}=true;

                msgData{4}=false;
            end


            msgData{1}=msgId;


            output.message=createExitMsg(msgData{:});
