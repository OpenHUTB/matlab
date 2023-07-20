function legendEntry=getCurveType(aCurve,compactDisplay)



    if~isa(aCurve,'simscapeCurve')
        pm_error('physmod:ee:library:MaskParameterOverride',getString(message('physmod:ee:library:comments:utils:mask:getCurveType:error_InputMustBeASimscapeCurveType')));
    end
    if~exist('compactDisplay','var')
        compactDisplay=false;
    end
    switch aCurve.outputType
    case simscapeCurveType.current
        legendEntry=['I',sprintf('_{%d}-',aCurve.outputTerminal)];
    case simscapeCurveType.voltage
        legendEntry=['V',sprintf('_{%d}-',aCurve.outputTerminal)];
    case simscapeCurveType.capacitance
        legendEntry=['C',sprintf('_{%d%d}-',...
        aCurve.outputTerminal(1),...
        aCurve.outputTerminal(2))];
    otherwise
        pm_error('physmod:ee:library:NotFound',getString(message('physmod:ee:library:comments:utils:mask:getCurveType:error_OutputType')));
    end
    for kk=1:length(aCurve.terminalValues)
        if length(aCurve.terminalValues{kk})>1
            break;
        end
    end
    switch aCurve.terminalTypes(kk)
    case simscapeStimulusType.current
        legendEntry=[legendEntry,'I'];
    case simscapeStimulusType.voltage
        legendEntry=[legendEntry,'V'];
    otherwise
        pm_error('physmod:ee:library:NotFound',getString(message('physmod:ee:library:comments:utils:mask:getCurveType:error_TerminalType')));
    end
    if compactDisplay
        legendEntry=[legendEntry,'_{',num2str(kk),'}'];
    else
        legendEntry=[legendEntry,'_{',num2str(kk),'} ('...
        ,num2str(min(aCurve.terminalValues{kk})),'-'...
        ,num2str(max(aCurve.terminalValues{kk})),')'];
    end
    if length(find(aCurve.terminalTypes~=simscapeStimulusType.reference))>1
        legendEntry=[legendEntry,' @'];
        for kk=1:length(aCurve.terminalValues)
            if length(aCurve.terminalValues{kk})==1...
                &&aCurve.terminalTypes(kk)~=simscapeStimulusType.reference
                switch aCurve.terminalTypes(kk)
                case simscapeStimulusType.current
                    legendEntry=[legendEntry,' I_{',num2str(kk),'}=',num2str(aCurve.terminalValues{kk})];%#ok<AGROW>
                case simscapeStimulusType.voltage
                    legendEntry=[legendEntry,' V_{',num2str(kk),'}=',num2str(aCurve.terminalValues{kk})];%#ok<AGROW>
                otherwise
                    pm_error('physmod:ee:library:NotFound',getString(message('physmod:ee:library:comments:utils:mask:getCurveType:error_TerminalType')));
                end
            end
        end
    end
    if compactDisplay
        if isa(aCurve,'simscapeSimulatedCurve')
            legendEntry=[legendEntry,' ',getString(message('physmod:ee:library:comments:utils:mask:getCurveType:legend_Sim'))];
        elseif isa(aCurve,'simscapeTargetCurve')
            legendEntry=[legendEntry,' ',getString(message('physmod:ee:library:comments:utils:mask:getCurveType:legend_Targ'))];
        else
            legendEntry=[legendEntry,' (?)'];
        end
    else
        if isa(aCurve,'simscapeSimulatedCurve')
            legendEntry=[legendEntry,' --> ',getString(message('physmod:ee:library:comments:utils:mask:getCurveType:legend_Simulated'))];
        elseif isa(aCurve,'simscapeTargetCurve')
            legendEntry=[legendEntry,' --> ',getString(message('physmod:ee:library:comments:utils:mask:getCurveType:legend_Target'))];
        else
            legendEntry=[legendEntry,' --> ',getString(message('physmod:ee:library:comments:utils:mask:getCurveType:legend_UnrecognizedCurveType'))];
        end
    end
end