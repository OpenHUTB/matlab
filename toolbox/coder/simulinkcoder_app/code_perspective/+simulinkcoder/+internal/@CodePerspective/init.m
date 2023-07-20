function init(obj)




    if~obj.initialized


        obj.tasks={
        simulinkcoder.internal.codeperspectivetask.Task_ModelData;
        simulinkcoder.internal.codeperspectivetask.Task_CodeMapping;
        simulinkcoder.internal.codeperspectivetask.Task_CodeReport;
        simulinkcoder.internal.codeperspectivetask.Task_PropertyInspector;
        simulinkcoder.internal.codeperspectivetask.Task_EditTimeChecking;
        simulinkcoder.internal.codeperspectivetask.Task_StorageClassOnSignals;
        };


        obj.code=simulinkcoder.internal.Report.getInstance;





        Simulink.dd.private.AddDDMgrMATLABCallBackEventHandler('simulinkcoder.internal.util.dataDictionaryEventHandler');

        obj.initialized=true;

    end


