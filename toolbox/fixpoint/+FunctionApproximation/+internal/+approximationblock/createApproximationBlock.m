function approximationBlockInfo=createApproximationBlock(blockPath,nApproximates)






    blockPath=convertStringsToChars(blockPath);

    [isValid,diagnostic]=FunctionApproximation.internal.Utils.isBlockPathValid(blockPath);
    if~isValid
        throwAsCaller(diagnostic);
    end

    if nargin<2
        nApproximates=1;
    end

    try
        mustBePositive(nApproximates);
        mustBeInteger(nApproximates);
    catch err
        exceptionObject=MException(message('SimulinkFixedPoint:functionApproximation:rfabInvalidNumberOfApproximates'));
        exceptionObject=exceptionObject.addCause(err);
        throwAsCaller(exceptionObject);
    end

    isCreatedByFunctionApproximation=FunctionApproximation.internal.approximationblock.isCreatedByFunctionApproximation(blockPath);
    if~isCreatedByFunctionApproximation
        schema=FunctionApproximation.internal.approximationblock.BlockSchema();


        FunctionApproximation.internal.approximationblock.wrapBlockWithSubsytem(blockPath);
        blockHandle=get_param(blockPath,'Handle');
        blockPosition=get_param(blockPath,'Position');
        vssHandle=Simulink.VariantManager.convertToVariant(blockHandle);
        set_param(vssHandle,'Position',blockPosition);


        variantChoices=get_param(vssHandle,'Variants');
        set_param(vssHandle,'VariantControl','');
        set_param(vssHandle,'LabelModeActiveChoice','');
        variantSystemTag=FunctionApproximation.internal.approximationblock.getHexTag(vssHandle);
        originalBlock=variantChoices(1).BlockName;
        variantTagOriginal=schema.getTagForOriginal();
        set_param(originalBlock,'VariantControl','eval(''true'');');
        set_param(originalBlock,'Tag',variantTagOriginal);



        previousBlock=originalBlock;
        for i=1:nApproximates
            pos=get_param(previousBlock,'Position');
            newBlock=schema.getNameForApproximate(blockPath,i);
            posNew=schema.getNextPosition(pos);
            addedBlock=add_block(originalBlock,newBlock,'Position',posNew);
            variantTag=schema.getTagForApproximate(i);
            set_param(addedBlock,'VariantControl','eval(''false'');');
            set_param(addedBlock,'Tag',variantTag);
            previousBlock=addedBlock;
        end
        set_param(originalBlock,'Name',schema.OriginalBlockName);



        maskObject=Simulink.Mask.create(vssHandle);
        originalMask=Simulink.Mask.get(schema.getOriginalSource(blockPath));
        if~isempty(originalMask)
            maskObject.copy(originalMask);
            for ii=1:numel(maskObject.Parameters)
                maskObject.Parameters(ii).Visible='off';
            end
        end

        maskObject.Initialization=schema.getCallbackForMaskInitialization();



        variantTag=maskObject.addParameter('Type','textarea','Name',schema.VariantTagParameterName);
        variantTag.Value=variantSystemTag;
        variantTag.Hidden='on';
        variantTag.Visible='off';
        variantTag.ReadOnly='on';


        variantTag=maskObject.addParameter('Type','textarea','Name',schema.CreatedByParameterName);
        variantTag.Value=schema.CreatedByParameterValue;
        variantTag.Hidden='on';
        variantTag.Visible='off';


        nApproximatesParameter=maskObject.addParameter('Type','textarea','Name',schema.NumApproximatesParameterName);
        nApproximatesParameter.Value=int2str(nApproximates);
        nApproximatesParameter.Hidden='on';
        nApproximatesParameter.Visible='off';
        nApproximatesParameter.ReadOnly='on';



        createdOnParameter=maskObject.addParameter('Type','textarea','Name',schema.CreatedOnParameterName);
        createdOnParameter.Value=datestr(now,'yyyymmddTHHMMSSFFF');
        createdOnParameter.Hidden='on';
        createdOnParameter.Visible='off';
        createdOnParameter.ReadOnly='on';


        matlabVersionParameter=maskObject.addParameter('Type','textarea','Name',schema.MATLABVersionOnParameterName);
        matlabVersionParameter.Value=jsonencode(ver('MATLAB'));
        matlabVersionParameter.Hidden='on';
        matlabVersionParameter.Visible='off';
        matlabVersionParameter.ReadOnly='on';


        detailsCollapsible=maskObject.addDialogControl('collapsiblepanel',schema.DetailsParameter);
        detailsCollapsible.Prompt=message('SimulinkFixedPoint:functionApproximation:rfabDetailsPrompt').getString();
        detailsCollapsible.Tooltip=message('SimulinkFixedPoint:functionApproximation:rfabDetailsTooltip').getString();
        detailsCollapsible.Row='new';
        detailsCollapsible.addDialogControl('text',schema.DetailsTextParameter);



        popup=maskObject.addParameter('Type','popup','Name',schema.FunctionVersionParameterName);
        popup.TypeOptions={schema.getTagForOriginal()};
        for i=1:nApproximates
            popup.TypeOptions{end+1}=schema.getTagForApproximate(i);
        end
        popup.Value=schema.getTagForApproximate(1);
        popup.Prompt=schema.SelectFunctionVersionPrompt;


        dialogControlShowOriginal=maskObject.addDialogControl('pushbutton',schema.ShowOriginalButtonParameterName);
        dialogControlShowOriginal.Callback=schema.getCallbackForShowOriginal(variantSystemTag,variantTagOriginal);
        dialogControlShowOriginal.Prompt=schema.ShowOriginalPrompt;
        dialogControlShowOriginal.Tooltip=schema.ShowOriginalTooltip;
        dialogControlShowOriginal.Row='new';


        dialogControlShowCurrent=maskObject.addDialogControl('pushbutton',schema.ShowCurrentButtonParameterName);
        dialogControlShowCurrent.Callback=schema.getCallbackForShowCurrent(variantSystemTag);
        dialogControlShowCurrent.Prompt=schema.ShowCurrentPrompt;
        dialogControlShowCurrent.Tooltip=schema.ShowCurrentTooltip;
        dialogControlShowCurrent.Row='current';


        dialogControlRevertToOriginal=maskObject.addDialogControl('hyperlink',schema.RevertToOriginal);
        dialogControlRevertToOriginal.Callback=schema.getCallbackForRevertLink(variantSystemTag);
        dialogControlRevertToOriginal.Prompt=schema.RevertToOriginalPrompt;
        dialogControlRevertToOriginal.Tooltip=schema.RevertToOriginalTooltip;
        dialogControlRevertToOriginal.Row='new';


        set_param(vssHandle,'MaskHideContents','on');




        maskObject.Type=message('SimulinkFixedPoint:functionApproximation:rfabBlockType').getString();
        maskObject.Description=message('SimulinkFixedPoint:functionApproximation:rfabBlockDescription').getString();
        maskObject.Help=schema.getHelpFunction();

        blockObject=get_param(blockPath,'Object');
        blockObject.OpenFcn=schema.getCallbackForOpenFunction(variantSystemTag);
    end


    approximationBlockInfo=FunctionApproximation.internal.approximationblock.getApproximationBlockInfoUsingBlock(blockPath);
end


