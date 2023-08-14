function[descGrp,unknownBlockFound]=buildBlockDescription(source)




    unknownBlockFound=checkUnsupportedBlock(source.getBlock);

    descTxt.Name=DAStudio.message('Simulink:blkprm_prompts:SubsysParameterDialogDescr');
    descTxt.Type='text';
    descTxt.WordWrap=true;

    descGrp.Type='group';
    descGrp.Items={descTxt};
    descGrp.RowSpan=[1,1];
    descGrp.ColSpan=[1,1];
end

function unknownBlockFound=checkUnsupportedBlock(block)
    unknownBlockFound=true;

    if~strcmp(get_param(block.Handle,'BlockType'),'SubSystem')

        return;
    end






    if(strcmp(block.Mask,'on')&&...
        strcmp(block.MaskType,'Enumerated Constant'))
        return;
    end


    if strcmp(block.Variant,'on')
        return;
    end


    if~isempty(block.TemplateBlock)
        return;
    end


    if((strcmp(get_param(block.Handle,'SystemType'),'EventFunction')||...
        strcmp(get_param(block.Handle,'SystemType'),'MessageFunction')))


        eventListener=find_system(block.Handle,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'LookUnderMasks','all','BlockType','EventListener');
        if~isempty(eventListener)
            return;
        end
    end


    if(strcmp(get_param(block.Handle,'SystemType'),'RunOrder'))


        runOrderConfigurator=find_system(block.Handle,...
        'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
        'LookUnderMasks','all','BlockType','RunOrderSpecifier');
        if~isempty(runOrderConfigurator)
            return;
        end
    end

    unknownBlockFound=false;
end

