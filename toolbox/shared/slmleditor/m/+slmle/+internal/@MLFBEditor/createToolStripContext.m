function createToolStripContext(obj)




    studio=obj.ed.getStudio;

    typechain={};
    if Stateflow.App.IsStateflowApp(obj.chartId)
        typechain{end+1}='sfxContext';
        typechain{end+1}='mlfbInSFXContext';
    else
        typechain{end+1}='mlfbInSLContext';
    end
    typechain{end+1}='slmleContext';

    context=slmle.internal.toolstrip.context.SlmleDocumentContext(...
    'slmleDocContext',typechain,studio,'slmleSimulationTab');

    ed=obj.ed;
    ed.setDocumentContext(context);
    obj.context=context;
    context.updateTypeChain;


    try
        waitfor(context,'TypeChain',typechain);
        waitfor(obj,'ready',true);
        ts=studio.getToolStrip;


        if all(ismember(typechain,ts.TypeChain))
            ts.ActiveTab=context.DefaultTabName;
        end
    catch ME
    end