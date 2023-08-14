function openCodeImporterUI()
    try
        stm.internal.Spinner.startSpinner(getString(message('stm:toolstrip:TestForCCppCode_SpinnerText')));
        obj=sltest.CodeImporter();
        obj.view();
        stm.internal.Spinner.stopSpinner();
    catch ME
        throw(ME);
    end
end

