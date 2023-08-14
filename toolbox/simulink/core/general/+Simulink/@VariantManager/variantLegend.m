function variantLegend(modelName,action,varargin)































    variantConditionLegendObj=Simulink.EnhancedVariantConditionLegend.getInstance;





    minNumberOfArguments=2;
    maxNumberOfArguments=3;
    narginchk(minNumberOfArguments,maxNumberOfArguments);
    if~(isa(modelName,'char')||isa(modelName,'string'))||~isvarname(modelName)
        DAStudio.error('Simulink:Variants:InvalidModelNameForVariantLegend');
    end

    if~bdIsLoaded(modelName)
        DAStudio.error('Simulink:Variants:ModelNotLoadedForVariantLegend',modelName);
    end



    if isa(modelName,'string')
        modelName=char(modelName);
    end

    switch action
    case 'open'






        numInputArgCheck(varargin);

        set_param(modelName,'VariantCondition','on');
        set_param(modelName,'SortedOrder','off');
        set_param(modelName,'BlockVariantConditionDataTip','on');
        if(strcmp(get_param(modelName,'VariantAnnotationsAreReady'),'off'))
            modelHandle=get_param(modelName,'handle');
            SLM3I.SLDomain.updateDiagram(modelHandle);
        end

        variantConditionLegendObj.showLegend(modelName);
    case 'print'
        numInputArgCheck(varargin);

        hDlg=DAStudio.ToolRoot.getOpenDialogs;
        dlg=hDlg.find('dialogTag',modelName);
        if isempty(dlg)
            DAStudio.error('Simulink:Variants:LegendNotOpen','print');
        end

        variantConditionLegendObj.printLegend(modelName);
    case 'showCodeConditions'


        if numel(varargin)~=1
            DAStudio.error('Simulink:Variants:InvalidNumberOfInputs');
        end

        hDlg=DAStudio.ToolRoot.getOpenDialogs;
        dlg=hDlg.find('dialogTag',modelName);
        if isempty(dlg)
            DAStudio.error('Simulink:Variants:LegendNotOpen','showCodeConditions');
        end
        switch varargin{1}
        case 'on'
            action=1;
        case 'off'
            action=0;
        otherwise
            DAStudio.error('Simulink:Variants:InvalidValuePairForVariantLegend');
        end
        variantConditionLegendObj.controlCodeGenColumn(action,modelName);
    case 'close'


        numInputArgCheck(varargin);
        variantConditionLegendObj.removeModel(modelName);
    otherwise
        DAStudio.error('Simulink:Variants:InvalidActionForVariantLegend');
    end


    function numInputArgCheck(inputs)
        if~isempty(inputs)
            DAStudio.error('Simulink:Variants:InvalidNumberOfInputs');
        end
    end

end
