function[origMLFB,fixptMLFB,varSubSys,newCreation]=makeVariantSubsystemForMLFB(mlfb)
    newCreation=false;

    if~isMLFB(mlfb)

        varSubSys=mlfb;
        [origMLFB,fixptMLFB]=fetchMLFBVariants(varSubSys);
        if~isempty(origMLFB)&&~isempty(fixptMLFB)
            [origMLFB,fixptMLFB]=configureMLFBVarSubsys(varSubSys);
        end
    else
        varSubSys=get_param(mlfb,'Parent');
        reuseVarSubsys=1;
        [origMLFB,fixptMLFB]=fetchMLFBVariants(varSubSys,reuseVarSubsys);

        if isempty(origMLFB)&&isempty(fixptMLFB)
            varSubSys=Simulink.VariantManager.convertToVariant(get_param(mlfb,'Handle'));


            set_param(varSubSys,'LabelModeActiveChoice','');

            createFixPtMLFB(varSubSys);
            [origMLFB,fixptMLFB]=configureMLFBVarSubsys(varSubSys);
            newCreation=true;
        elseif~isempty(origMLFB)&&isempty(fixptMLFB)

            createFixPtMLFB(varSubSys);
            [origMLFB,fixptMLFB]=configureMLFBVarSubsys(varSubSys);
        end
    end

end

function createFixPtMLFB(varSubSys)
    variantChoices=get_param(varSubSys,'Variants');
    if(length(variantChoices)==1)
        origMLFBName=variantChoices(1).BlockName;
        pos=get_param(origMLFBName,'Position');

        newMLFBName=[origMLFBName,'_FixPt'];
        posNew=[pos(1),pos(4)+50,pos(3),2*pos(4)-pos(2)+50];
        addedBlock=add_block(origMLFBName,newMLFBName,'Position',posNew);
        sfId=sfprivate('block2chart',addedBlock);
        chart=idToHandle(slroot,sfId);
        chart.Script='%% WILL BE GENERATED VIA FIXED POINT CONVERSION';
    end
end

function[origMLFB,fixptMLFB]=configureMLFBVarSubsys(subSys)
    variantChoices=get_param(subSys,'Variants');

    assert(length(variantChoices)==2);

    origMLFB=variantChoices(1).BlockName;
    set_param(origMLFB,'VariantControl','false()');

    fixptMLFB=variantChoices(2).BlockName;
    set_param(fixptMLFB,'VariantControl','(default)');
end


