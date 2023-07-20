classdef Stepper

    methods(Static)
        function forward(mdl)





            stepper=Simulink.SimulationStepper(mdl);
            stepper.finishStep();
        end

        function rollback(mdl)


            slInternal('sldebug',mdl,'setIsRollingBack',true);




            Simulink.SimulationStepper(mdl).finishStep();








            rollbackStr=[...
'SimulinkDebugger.utils.Stepper.rollbackNSteps('''...
            ,mdl...
            ,''')'...
            ];
            SLM3I.SLCommonDomain.simulationDebugStep(get_param(mdl,'Handle'),rollbackStr);
        end

        function rollbackNSteps(mdl)
            numSteps=get_param(mdl,'NumberOfSteps');
            if~isequal(numSteps,1)
                numStepsPlusCurr=numSteps+1;
                set_param(mdl,'NumberOfSteps',numStepsPlusCurr);
                ocSteps=onCleanup(@()set_param(mdl,'NumberOfSteps',numSteps));
            end
            stepper=Simulink.SimulationStepper(mdl);
            stepper.rollback();

            slInternal('sldebug',mdl,'setIsRollingBack',false);
        end

    end

end