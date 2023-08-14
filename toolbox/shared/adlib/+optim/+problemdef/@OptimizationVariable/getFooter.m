function footer=getFooter(obj)






    if isempty(obj)
        footer='';
    else


        if obj.IsSubsref
            [startTag,endTag]=optim.internal.problemdef.createHotlinks(...
            'helpPopup','problem_reference','normal',true);
            referenceFooter=getString(message('shared_adlib:OptimizationVariable:ReferenceFooterStr',...
            startTag,endTag,obj.Name));
            referenceFooter=sprintf('  %s\n\n',referenceFooter);
        else
            referenceFooter='';
        end


        [startTagVar,endTagVar]=optim.internal.problemdef.createHotlinks(...
        'helpPopup','optim.problemdef.OptimizationVariable/show');
        [startTagBounds,endTagBounds]=optim.internal.problemdef.createHotlinks(...
        'helpPopup','optim.problemdef.OptimizationVariable/showbounds');
        seeVariableAndBoundsFooter=getString(message('shared_adlib:OptimizationVariable:FooterText',...
        startTagVar,endTagVar,startTagBounds,endTagBounds));


        footer=sprintf('%s  %s',...
        referenceFooter,seeVariableAndBoundsFooter);

    end
