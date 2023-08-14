classdef BreakpointType




    enumeration
Signal
Block
Model
onChartEntry
onStateEntry
onStateDuring
onStateExit
onFunctionDuringCall
whenTransitionTested
whenTransitionValid
EMChart
EMFunction
    end

    methods
        function guiName=getString(enumType)
            switch enumType
            case SimulinkDebugger.breakpoints.BreakpointType.onChartEntry
                guiName=message('Stateflow:misc:GuiChartEntry').getString();
            case SimulinkDebugger.breakpoints.BreakpointType.onStateEntry
                guiName=message('Stateflow:misc:GuiStateEntry').getString();
            case SimulinkDebugger.breakpoints.BreakpointType.onStateDuring
                guiName=message('Stateflow:misc:GuiStateDuring').getString();
            case SimulinkDebugger.breakpoints.BreakpointType.onStateExit
                guiName=message('Stateflow:misc:GuiStateExit').getString();
            case SimulinkDebugger.breakpoints.BreakpointType.whenTransitionTested
                guiName=message('Stateflow:misc:GuiTransitionTested').getString();
            case SimulinkDebugger.breakpoints.BreakpointType.whenTransitionValid
                guiName=message('Stateflow:misc:GuiTransitionValid').getString();
            case SimulinkDebugger.breakpoints.BreakpointType.onFunctionDuringCall
                guiName=message('Stateflow:misc:GuiDuringFunctionCall').getString();
            case SimulinkDebugger.breakpoints.BreakpointType.EMFunction
                guiName='MATLAB Function';
            case SimulinkDebugger.breakpoints.BreakpointType.EMChart
                guiName='MATLAB Function Block';
            otherwise
                guiName=char(enumType);
            end
        end
    end
end
