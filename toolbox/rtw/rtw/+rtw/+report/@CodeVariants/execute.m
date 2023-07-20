function execute(obj)




    obj.AddSectionToToc=true;
    obj.AddSectionNumber=false;
    obj.AddSectionShrinkButton=true;
    obj.AddDetailedErrorMessage=false;

    objectTable=obj.variantObjectTable(false);
    obj.addSection('sec_variant_control','Variant Control','',objectTable);

    modelBlockTable=obj.variantModelBlockTable('ModelReference','Model Block','Model',false);
    obj.addSection('sec_model_ref','Model Reference Blocks that have Variants','',modelBlockTable);

    subsystemBlockTable=obj.variantModelBlockTable('SubSystem','Subsystem Block','Block',false);
    obj.addSection('sec_subsys','Subsystem Blocks that have Variants','',subsystemBlockTable);
end
