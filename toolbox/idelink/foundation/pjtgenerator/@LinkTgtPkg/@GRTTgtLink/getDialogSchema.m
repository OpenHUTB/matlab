function dlgstruct=getDialogSchema(hSrc,schemaName)




    tag='Tag_ConfigSet_Target_';







    [myowntab1]=getTgtDialogSchema(hSrc,schemaName);


    [GRTtab]=getGRTDialogSchema(hSrc,schemaName);

    tabs.Name='tabs';
    tabs.type='tab';
    tabs.Tabs={GRTtab,myowntab1};

    if strcmp(schemaName,'tab')
        dlgstruct.nTabs=2;
        dlgstruct.Tabs=tabs.Tabs;
    else
        dlgstruct.DialogTitle='GRT Target';
        dlgstruct.Items={tabs};
    end



    function isEnabled=getEnabledFlag(hSrc,objProp)

        isEnabled=~hSrc.isReadonlyProperty(objProp);

        switch(hSrc.buildAction)
        case 'Archive_library',
            OptionsToBeDisabled={'exportIDEObj','ideObjName',...
            'ProfileGenCode','systemStackSize','linkerOptionsStr','getLinkerOptions',...
            'overrunNotificationMethod','overrunNotificationFcn'};
            if any(strcmp(objProp,OptionsToBeDisabled))
                isEnabled=false;
            else
                isEnabled=true;
            end
        end

        isEnabled=isEnabled&~hSrc.isReadonlyProperty(objProp);
