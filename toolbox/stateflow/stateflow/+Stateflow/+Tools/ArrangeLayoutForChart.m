
% ARRANGELAYOUTFORCHART Arrange graphical objects for a chart.
%
%   ARRANGELAYOUTFORCHART(CHARTHANDLE) arranges all graphical objects in the chart.
%   VALID OBJECT TYPES: Chart.

function ArrangeLayoutForChart(chartH)

%   Copyright 2016-2019 The MathWorks, Inc.
    isSFObj = isa(chartH, 'Stateflow.DDObject');
    if nargin ~= 1 || ~isscalar(chartH) || ~isSFObj
        errorMsg = message('Stateflow:studio:InvalidInputArgForArrangeLayout').getString();
        error('Stateflow:studio:InvalidInputArgForArrangeLayout', errorMsg);
    end

    if isa(chartH, 'Stateflow.StateTransitionTableChart')
        errorMsg = message('Stateflow:studio:STTNotSupportedForArrangeLayout').getString();
        error('Stateflow:studio:STTNotSupportedForArrangeLayout',errorMsg);
    end

    if ~isa(chartH, 'Stateflow.Chart')
        errorMsg = message('Stateflow:studio:InvalidObjectHandleForArrangeLayout').getString();
        error('Stateflow:studio:InvalidObjectHandleForArrangeLayout', errorMsg);
    end

    if chartH.Locked
        return;
    end
    invokedFromUI = false;
    invokeArrangeLayoutForChart(invokedFromUI, chartH);
    chartH.view();  % When arrange layout is done, return to the chart level editor.
end

function invokeArrangeLayoutForChart(invokedFromUI, objH)
    objH.view();
    editorH = StateflowDI.SFDomain.getLastActiveEditor;
    subview = sf('IdToHandle', double(editorH.getDiagram.backendId));
	invokeArrangeLayoutForCurrentSubviewer(invokedFromUI);
	objHs = subview.find('-isa', 'Stateflow.State', 'Subviewer', subview, 'IsSubchart', 1, '-or', ...
                         '-isa', 'Stateflow.AtomicSubchart', 'Subviewer', subview, '-or', ...
                         '-isa', 'Stateflow.Box', 'Subviewer', subview, 'IsSubchart', 1, '-or', ...
                         '-isa', 'Stateflow.AtomicBox', 'Subviewer', subview, '-or', ...
                         '-isa', 'Stateflow.Function', 'Subviewer', subview, 'IsSubchart', 1);

    if ~isempty( objHs )
        for obj = objHs(:)'
            invokeArrangeLayoutForChart( invokedFromUI, obj );
        end
    end
end

function invokeArrangeLayoutForCurrentSubviewer( invokedFromUI )
    try
        Stateflow.Tools.Beautifier.invoke(invokedFromUI);
    catch reason
        try
            throw(reason); % Want the exception to originate from this file
        catch filteredReason
            ME = MException('Stateflow:ArrangeLayout:ArrangeLayoutFailed', message('Stateflow:studio:ArrangeLayoutFailed').getString());
            ME = ME.addCause(filteredReason);
            throw(ME);
        end
    end
end
