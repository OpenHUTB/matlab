function helpCB(this,dlg)



    switch dlg.getActiveTab(this.TAB_CONTAINER_TAG)
    case 0
        helpview(fullfile(docroot,'simulink','helptargets.map'),'vis_properties_dialog');

    otherwise
        helpview(fullfile(docroot,'simulink','helptargets.map'),'vis_properties_dialog');
    end
end
