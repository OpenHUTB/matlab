function checkSolverConfiguration(obj)




    simscapeModel=obj.SimscapeModel;

    try


        solverBlks=utilGetSolverConfiguration(simscapeModel);

        if isempty(solverBlks)

            me=MException('checkSolverConfiguration:NoSSCNetworks',...
            message('hdlcoder:hdlssc:ssccodegenworkflow_SwitchedLinearWorkflow:NoSSCNetworks',simscapeModel).getString);
            throwAsCaller(me);
        elseif~iscell(solverBlks)
            solverBlks={solverBlks};
        end

        sampleTimes=ones(1,numel(solverBlks));
        fixedIters=double.empty;

        for i=1:numel(solverBlks)
            solverBlk=solverBlks{i};


            if~strcmpi(get_param(solverBlk,'UseLocalSolver'),'on')
                me=MException('checkSolverConfiguration:UseLocalSolverOff',...
                message('hdlcoder:hdlssc:ssccodegenworkflow_SwitchedLinearWorkflow:UseLocalSolverOff',...
                ssccodegenutils.getBlockHyperlink(solverBlk)).getString);
                throwAsCaller(me);
            end


            if(get_param(solverBlk,'ComputeImpulses')=="on")
                me=MException('checkSolverConfiguration:ImpulseComputationOn',...
                message('hdlcoder:hdlssc:ssccodegenworkflow_SwitchedLinearWorkflow:ComputeImpulses').getString);
                throwAsCaller(me);
            end


            switch get_param(solverBlk,'LocalSolverChoice')
            case 'NE_BACKWARD_EULER_ADVANCER'
                obj.SolverTypes(i)=0;
            case 'NE_PARTITIONING_ADVANCER'
                obj.SolverTypes(i)=1;
            otherwise
                me=MException('checkSolverConfiguration:IncorrectLocalSolverChoice',...
                message('hdlcoder:hdlssc:ssccodegenworkflow_SwitchedLinearWorkflow:IncorrectLocalSolverChoice',...
                ssccodegenutils.getBlockHyperlink(solverBlk)).getString);
                throwAsCaller(me);
            end


            if strcmpi(get_param(solverBlk,'DoFixedCost'),'on')
                temp=slResolve(get_param(solverBlk,'MaxNonlinIter'),solverBlk);
                fixedIters=[fixedIters,temp];%#ok<AGROW>
            end


            sampleTime=slResolve(get_param(solverBlk,'LocalSolverSampleTime'),solverBlk);
            sampleTimes(i)=sampleTime;

        end

        if numel(unique(obj.SolverTypes))~=1
            me=MException('checkSolverConfiguration:DifferentLocalSolvers',...
            message('hdlcoder:hdlssc:ssccodegenworkflow_SwitchedLinearWorkflow:DifferentLocalSolvers').getString);
            throwAsCaller(me);

        end

        if numel(fixedIters)~=numel(solverBlks)&&~isempty(fixedIters)
            me=MException('checkSolverConfiguration:InconsistentFixedItersOption',...
            message('hdlcoder:hdlssc:ssccodegenworkflow_SwitchedLinearWorkflow:InconsistentFixedItersOption').getString);
            throwAsCaller(me);
        end



        if~isempty(fixedIters)
            if~isscalar(unique(fixedIters))
                me=MException('checkSolverConfiguration:DifferentFixedIters',...
                message('hdlcoder:hdlssc:ssccodegenworkflow_SwitchedLinearWorkflow:DifferentFixedIters').getString);
                throwAsCaller(me);
            else

                obj.UseFixedCost=true;
                obj.NumFixedCostIters=fixedIters(1);
            end
        else
            obj.UseFixedCost=false;
            obj.NumFixedCostIters=0;
        end

        obj.SolverConfiguration=solverBlks;

    catch me
        throwAsCaller(me);
    end
end



