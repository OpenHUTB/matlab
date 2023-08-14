function[status,str]=postApply(this)




    status=true;str='';
    editor=this.getExclusionEditor();
    if~isempty(this.fileName)&&strcmp(this.fileName,'<untitled.xml>')
        [~,~,ext]=fileparts(this.fileName);
        if~strcmpi(ext,'.xml')
            errordlg(DAStudio.message('ModelAdvisor:engine:FileShouldBeXML'));
            status=false;
            return;
        end
        set_param(editor.getModelName,'MAModelExclusionFile',this.fileName);
        editor.show;
        editor.fileName=this.fileName;
        editor.fDialogHandle.restoreFromSchema;
    end