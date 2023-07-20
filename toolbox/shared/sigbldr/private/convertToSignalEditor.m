function convertToSignalEditor(blockH)






    tag='ConvertToSignalEditorDlg';
    startVals={'dataset.mat'};
    titleStr=getString(message('sigbldr_ui:convert2SE:DialogTitle'));
    prompts={getString(message('sigbldr_ui:convert2SE:DialogPrompt'))};

    fileName=sigbuilder_modal_edit_dialog(tag,titleStr,prompts,startVals);

    if(fileName==0)

        return;
    end


    checkMatFileName(fileName);


    if exist(fileName,'file')


        hErrorDlg=errordlg(getString(message('sigbldr_ui:convert2SE:ErrorDialogMessage',fileName,fileName)),...
        getString(message('sigbldr_ui:convert2SE:ErrorDialogTitle')),'modal');
        waitfor(hErrorDlg);
        convertToSignalEditor(blockH);
    else

        signalBuilderToSignalEditor(blockH,'FileName',fileName);
    end
end
