classdef(Abstract)PreprocessingActions<handle









    properties(SetAccess=protected,GetAccess=public)
ActionDescription
    end

    methods(Abstract)


        performAction(this,environmentContext)




        revertAction(this)

    end

    methods
        function mslDiagnostic=execute(this,environmentContext)

            mslDiagnostic=MSLDiagnostic.empty;

            try

                this.performAction(environmentContext);




                this.validateAction(environmentContext);

            catch errDiagnostic


                this.revertAction();



                mslDiagnostic=MSLDiagnostic(message('SimulinkFixedPoint:dataTypeOptimization:preprocessingActionFailed',this.ActionDescription,environmentContext.TopModel));
                mslDiagnostic=mslDiagnostic.addCause(MSLDiagnostic(errDiagnostic));


            end

        end

        function validateAction(~,environmentContext)




            set_param(environmentContext.TopModel,'SimulationCommand','update');

        end

        function si=exportSimulationInput(this,environmentContext)%#ok<INUSD>

            si=Simulink.SimulationInput;

        end
    end
end