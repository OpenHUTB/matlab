



function insertStateflowObjectCB(userdata,cbinfo)

    editor=cbinfo.studio.App.getActiveEditor;
    switch userdata
    case 'state'
        StateflowDI.ToolCreation.enterCreateStateMode(editor);
    case 'junction'
        StateflowDI.ToolCreation.enterCreateJunctionMode(editor);
    case 'defaultTransition'
        StateflowDI.ToolCreation.enterCreateDefaultTransitionMode(editor);
    case 'graphicalFunction'
        StateflowDI.ToolCreation.enterCreateGraphicalFunctionMode(editor);
    case 'simulinkState'
        StateflowDI.ToolCreation.enterCreateSimulinkStateMode(editor);
    case 'simulinkFunction'
        StateflowDI.ToolCreation.enterCreateSimulinkFunctionMode(editor);
    case 'matlabFunction'
        StateflowDI.ToolCreation.enterCreateMatlabFunctionMode(editor);
    case 'truthTable'
        StateflowDI.ToolCreation.enterCreateTruthTableMode(editor);
    case 'box'
        StateflowDI.ToolCreation.enterCreateBoxMode(editor);
    case 'historyJunction'
        StateflowDI.ToolCreation.enterCreateHistoryJunctionMode(editor);
    case 'subchart'
        SFStudio.Utils.createSubchart(editor);
    case 'atomicSubchart'
        SFStudio.Utils.createSubchart(editor,StateflowDI.StateType.AtomicSubchart);
    case 'entryport'
        StateflowDI.ToolCreation.enterCreateEntryPortMode(editor);
    case 'exitport'
        StateflowDI.ToolCreation.enterCreateExitPortMode(editor);
    otherwise
        disp(['Invalid object:',userdata]);
    end
end
