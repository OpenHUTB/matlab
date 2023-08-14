function showDialog(dialogType,systemUnderTest)


    try
        [model,ownerHandle]=Simulink.harness.internal.parseForSystemModel(systemUnderTest);
        object=get_param(ownerHandle,'Object');
        switch dialogType
        case 'HarnessCreate'
            Simulink.harness.dialogs.createDialog.create(object);
        case 'HarnessManager'
            Simulink.harness.dialogs.harnessListDialog.create(model,object.getFullName());
        case 'HarnessImport'
            Simulink.harness.dialogs.importDialog.create(object);
        otherwise
            DAStudio.error('Simulink:Harness:InvalidDialogType');
        end
    catch ME
        throwAsCaller(ME);
    end
end
