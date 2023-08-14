function[success,message]=applyChangeToDD(cs)





    success=true;
    message='';
    if isa(cs,'Simulink.ConfigSetRef')
        ddPath=cs.DDName;
    else
        ddPath=cs.getDialogController.DataDictionary;
    end
    if~isempty(ddPath)
        try
            dd=Simulink.data.dictionary.open(ddPath);
            if dd.isOpen
                configSec=dd.getSection('Configurations');
                if configSec.exist(cs.Name,'','','BaseWorkspaceAccess',false)
                    entryCS=configSec.getEntry(cs.Name);

                    entryCS(1).setValue(cs);
                elseif~configSec.exist(cs.Name)
                    configSec.addEntry(cs.Name,cs);
                end
            end


            configset.internal.util.callParentDialog(cs.getDialogController,'enableApplyButton',true);
        catch e
            success=false;
            message=e.message;
        end
    end
