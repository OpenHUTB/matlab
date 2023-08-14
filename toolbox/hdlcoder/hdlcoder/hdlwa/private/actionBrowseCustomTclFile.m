function actionBrowseCustomTclFile(taskobj)



    mdladvObj=taskobj.MAObj;


    hMAExplorer=mdladvObj.MAExplorer;
    if~isempty(hMAExplorer)&&~isempty(hMAExplorer.getDialog)
        currentDialog=hMAExplorer.getDialog;
        currentDialog.apply;
    end


    inputParams=mdladvObj.getInputParameters(taskobj.MAC);
    customTclFile=utilGetInputParameter(inputParams,DAStudio.message('HDLShared:hdldialog:HDLWAInputAdditionalTclFiles'));
    customTclStr=customTclFile.Value;


    if~isempty(customTclStr)&&isempty(regexp(customTclStr,';$','once'))
        customTclStr=sprintf('%s;',customTclStr);
    end


    [filename,filepath,filterindex]=uigetfile(...
    {'*.tcl','All Tcl File (*.tcl)';...
    '*.*','All Files (*.*)'},...
    'Pick a file','MultiSelect','on');


    if filterindex~=0
        if~iscell(filename)
            filename={filename};
        end
        for ii=1:length(filename)
            customTclStr=sprintf('%s%s;',customTclStr,fullfile(filepath,filename{ii}));
        end
        customTclFile.Value=customTclStr;
    end


