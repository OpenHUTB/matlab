function exportToFile(~,obj)



    if isempty(obj.ConfigObjVarName)
        slvariants.internal.manager.ui.util.createErrorDialog(...
        obj.ConfigObjVarName,'Simulink:VariantManagerUI:MessageConfigdatacantexportwithemptynameError');
        return;
    end





    defaultFileName=[obj.ConfigObjVarName,'_vcdo'];

    varConfigDataName=obj.ConfigObjVarName;
    configObject=obj.SourceObj;
    fileName=exportDialog(defaultFileName,obj.BDName);
    if isempty(fileName)
        return;
    end
    [~,~,ext]=fileparts(fileName);
    if strcmp(ext,'.m')
        slvariants.internal.manager.ui.config.exportToMFile(configObject,varConfigDataName,fileName);
    else
        slvariants.internal.manager.ui.config.exportToMatFile(configObject,varConfigDataName,fileName);
    end

    exportSuccessMsg=MException(message('Simulink:VariantManagerUI:MessageInfoSaveVarConfigObjToFile',fileName,varConfigDataName));
    sldiagviewer.reportInfo(exportSuccessMsg);
end

function fileName=exportDialog(startName,modelName)





    validate=true;
    modal=true;
    fileName='';

    [dirName,objName]=fileparts(startName);
    if isempty(dirName)
        dirName=pwd;
    end
    ext='.m';
    defaultFileName=fullfile(dirName,[objName,ext]);
    filter={...
    '*.m',DAStudio.message('MATLAB:uistring:uiopen:MATLABFiles');...
    '*.mat',DAStudio.message('MATLAB:uistring:uiopen:MATfiles');...
    };

    titlePrefix=[modelName,': '];
    title=[titlePrefix,DAStudio.message('Simulink:VariantManagerUI:VariantManagerExportFilechooserTitle')];



    while true
        [f,d]=uiputfile(filter,title,defaultFileName);
        if ischar(f)
            fileName=fullfile(d,f);
            [~,objName,ext]=fileparts(fileName);
            if(validate)
                if isempty(ext)
                    ext='.m';
                    fileName=[fileName,ext];%#ok<AGROW> (not really growing)
                end
                if~isvarname(objName)
                    id='Simulink:VariantManagerUI:VariantManagerExportInvalidMatlabFilename';
                    msg=DAStudio.message(id);
                    if modal
                        uiwait(errordlg(msg,title,'modal'));
                        continue;
                    else
                        DAStudio.error(id,objName);%#ok<UNRCH>
                    end
                end
            end

            break;
        else
            fileName='';

            break;
        end
    end
end


