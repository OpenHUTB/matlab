function[exitFlag,reasonToStop]=SS_CheckStopCriteria(options,state)




















    persistent lastOutput outputLines


    reasonToStop='';
    exitFlag=[];


    switch options.Display
    case{'off','none'}
        verbosity=0;
    case 'final'
        verbosity=1;
    case 'iter'
        verbosity=2;
    case 'diagnose'
        verbosity=3;
    end


    if strcmp(state.CurrentState,'init')&&verbosity>0
        lastOutput=0;
        if verbosity>1
            outputLines=0;

            fprintf('\nEvaluation       Best         Duplicates      Diversity\n');
            fprintf('  number         f(x)          removed          calls\n\n');
        end
        return;
    end

    if verbosity>1


        if state.Evaluations-lastOutput>100
            if outputLines==30

                fprintf('\nEvaluation       Best         Duplicates      Diversity\n');
                fprintf('  number         f(x)          removed          calls\n\n');
                outputLines=0;
            end
            fprintf(' %6.0f     %12g        %6.0f         %5.0f\n',state.Evaluations,state.BestFval(end),state.DuplicatesRemoved,state.DiversityCalls);
            outputLines=outputLines+1;
            lastOutput=state.Evaluations;
        end
    end


    if(state.Evaluations>=options.MaxEvaluations)
        reasonToStop=sprintf('Optimization terminated: maximum number of evaluations reached.');
        exitFlag=0;
    elseif strcmpi(options.UsePointDatabase,'on')&&...
        (state.PointDbaseSize>=options.MaxPointDatabaseSize)
        reasonToStop=sprintf('Optimization terminated: maximum point database size reached.');
        exitFlag=0;
    elseif((cputime-state.StartTime)>options.TimeLimit)
        reasonToStop=sprintf('Optimization terminated: time limit exceeded.');
        exitFlag=1;
    elseif((cputime-state.LastImprovementTime)>options.StallTimeLimit)
        reasonToStop=sprintf('Optimization terminated: stall time limit exceeded.');
        exitFlag=2;
    elseif(~isempty(state.StopFlag))
        reasonToStop=sprintf('Optimization terminated: state.StopFlag = %s',state.StopFlag);
        exitFlag=-1;
    elseif~isempty(state.BestFval)
        if(state.BestFval(end)<options.ObjectiveLimit)
            reasonToStop=sprintf('Optimization terminated: minimum objective function limit reached.');
            exitFlag=3;
        end
    end


    if~isempty(exitFlag)&&verbosity>0&&state.Evaluations>lastOutput
        if(verbosity>1&&outputLines==30)||verbosity<2

            fprintf('\nEvaluation       Best         Duplicates      Diversity\n');
            fprintf('  number         f(x)          removed          calls\n\n');
            outputLines=0;
        end
        fprintf(' %6.0f     %12g        %6.0f         %5.0f\n',state.Evaluations,state.BestFval(end),state.DuplicatesRemoved,state.DiversityCalls);
        fprintf('%s\n',reasonToStop);
        return;
    end


    if verbosity>1&&~isempty(exitFlag)
        fprintf('\n%s\nexitFlag = %d',reasonToStop,exitFlag)
    end