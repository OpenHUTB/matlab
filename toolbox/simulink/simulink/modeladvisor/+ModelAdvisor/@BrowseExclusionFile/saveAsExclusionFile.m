function saveAsExclusionFile(this)




    exclusionEditor=this.getExclusionEditor;

    if strcmp(exclusionEditor.getFileNameToDisplay,'<untitled.xml>')
        defaultChoice=[exclusionEditor.fModelName,'_exclusions.xml'];
    else
        defaultChoice=exclusionEditor.fileName;
    end
    [FileName,PathName]=uiputfile(defaultChoice,...
    DAStudio.message('ModelAdvisor:engine:SaveExclusionFile'));
    dlg=exclusionEditor.fDialogHandle;
    if isequal(FileName,0)&&isequal(PathName,0)
        dlg.setWidgetWithError('ModelExclusionsModelExclusionFilename');
        return;
    end
    FileName=[PathName,FileName];
    if~checkXMLExt(dlg,FileName)
        return;
    end
    exclusionEditor.fileName=FileName;
    exclusionEditor.save(exclusionEditor.fileName,true);
    exclusionEditor.fDialogHandle.refresh;
    exclusionEditor.fDialogHandle.restoreFromSchema;
    exclusionEditor.fDialogHandle.enableApplyButton(false);
    this.delete;
end

function isXML=checkXMLExt(dlg,FileName)
    isXML=true;
    [~,~,ext]=fileparts(FileName);
    if~strcmpi(ext,'.xml')
        isXML=false;
        dp=DAStudio.DialogProvider;
        dp.errordlg(DAStudio.message('ModelAdvisor:engine:FileShouldBeXML'),'Error',true);
        dlg.setWidgetWithError('ModelExclusionsModelExclusionFilename');
    end
end
