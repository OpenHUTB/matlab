function addonStruct=performanceAdvisorGroupDialogSchema(this)



    addonStruct=this.createContainerDialog(1);

    addonStruct.Items{1}.Tabs{1}.Items{1}.Items{2}.Items{1}.MatlabMethod='runTaskAdvisorWrapper';

end