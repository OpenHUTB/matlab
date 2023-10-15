classdef DeployedSimulationInputHelper < Simulink.Simulation.internal.SimulationInputHelper
    %#function numerictype
    methods ( Static )
        function validateVariable( simVar, simInput )
            arguments
                simVar( 1, 1 )Simulink.Simulation.Variable
                simInput( 1, 1 )Simulink.SimulationInput
            end

            varWorkspaceIsGlobalOrTopModelWorkspace =  ...
                strcmpi( simVar.Workspace, 'global-workspace' ) ||  ...
                strcmpi( simVar.Workspace, simInput.ModelName );

            if ~varWorkspaceIsGlobalOrTopModelWorkspace
                error( message( 'simulinkcompiler:simulation_input:InvalidWorkspaceForVariable', simInput.ModelName ) );
            end
        end


        function newValue = modifyVariableValue( varName, varValue, varExpr, exprValue )%#ok

            evalc( varName + "= varValue" );
            evalc( varExpr + "= exprValue" );
            evalc( "newValue = " + varName );
        end

        function [ varValue, varWasResolved ] = getVariableValue( modelName, varName, varargin )
            [ varValue, varWasResolved ] = find_nonsimulationinput_variable_with_workspace_resolution(  ...
                varName,  ...
                modelName ...
                );
        end
    end
end

