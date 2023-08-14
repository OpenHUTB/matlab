function[origMLFB,singleMLFB,varSubsys,newCreation]=makeVariantSubsystemForMLFB(origMLFB)



    import coder.internal.mlfbDoubleToSingle.utils.SLHelper;



    assert(SLHelper.isMLFB(origMLFB));

    parent=get_param(origMLFB,'Parent');
    parentIsBlockDiagram=strcmp(get_param(parent,'Type'),'block_diagram');
    parentIsVariant=~parentIsBlockDiagram&&strcmp(get_param(parent,'Variant'),'on');

    if parentIsVariant
        varSubsys=parent;
        newCreation=false;
    else
        varSubsys=Simulink.VariantManager.convertToVariant(origMLFB);
        set_param(varSubsys,'LabelModeActiveChoice','');
        newCreation=true;


        variants=get_param(varSubsys,'Variants');


        assert(numel(variants)==1);


        origMLFB=variants.BlockName;
    end

    singleMLFB=createSingleMLFB(origMLFB);
    configureMLFBVarSubsys(origMLFB,singleMLFB,newCreation);
end

function singleMLFB=createSingleMLFB(origMLFB)
    pos=get_param(origMLFB,'Position');

    singleMLFB=[origMLFB,'_single'];
    posNew=[pos(1),pos(4)+50,pos(3),2*pos(4)-pos(2)+50];
    addedBlock=add_block(origMLFB,singleMLFB,'Position',posNew);
    sfId=sfprivate('block2chart',addedBlock);
    chart=idToHandle(slroot,sfId);
    chart.Script='%% WILL BE GENERATED VIA SINGLE PRECISION CONVERSION';
end

function configureMLFBVarSubsys(origMLFB,singleMLFB,newCreation)
    if newCreation
        singleVariantControl='(default)';
    else
        singleVariantControl=get_param(origMLFB,'VariantControl');
    end

    set_param(origMLFB,'VariantControl','false()');
    set_param(singleMLFB,'VariantControl',singleVariantControl);
end



