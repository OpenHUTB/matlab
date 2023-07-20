function characteristicVisualizer(blockHandle)



    if ishandle(blockHandle)
        name=get_param(blockHandle,'Name');
        parent=get_param(blockHandle,'Parent');
        blockName=[parent,'/',name];
    else
        blockName=blockHandle;
    end
    componentPath=get_param(blockName,'ComponentPath');

    paramsPerRow=3;
    testModelName='characteristicViewer';


    parameterNameValueList=ee.internal.mask.getParameterNameValueList(blockName);


    defaultSweepValues=[0,1,2,3,4,5,6,7,8,9,10];
    defaultSweepRange=[0,20];
    defaultStepValues=[0,10];
    defaultOutputValues=[0,1e-6,2e-6,3e-6,4e-6,5e-6,6e-6,7e-6,8e-6,9e-6,1e-5;...
    0,1,2,3,3.1,3.2,3.3,3.3,3.3,3.3,3.3];

    switch componentPath
    case{'ee.semiconductors.sp_nmos'}
        open_system(testModelName);
        replace_block(testModelName,'Name','DUT','ee_lib/Semiconductors & Converters/N-Channel MOSFET','noprompt');
        nesl_setvariant=nesl_private('nesl_setvariant');
        nesl_setvariant([testModelName,'/DUT'],componentPath);
        terminals={'D','G','S'};
        referenceTerminal='S';
        sweepOptions={'V_DS','V_GS','I_D'};
        stepOptions={'V_GS','V_DS','I_D'};
        outputOptions={'I_D','V_GS','V_DS','C_GG','C_GD','C_DG','C_DD'};
    case{'ee.semiconductors.sp_pmos'}
        open_system(testModelName);
        replace_block(testModelName,'Name','DUT','ee_lib/Semiconductors & Converters/P-Channel MOSFET','noprompt');
        nesl_setvariant=nesl_private('nesl_setvariant');
        nesl_setvariant([testModelName,'/DUT'],componentPath);
        terminals={'D','G','S'};
        referenceTerminal='S';
        sweepOptions={'V_DS','V_GS','I_D'};
        stepOptions={'V_GS','V_DS','I_D'};
        outputOptions={'I_D','V_GS','V_DS','C_GG','C_GD','C_DG','C_DD'};
        defaultSweepValues=-defaultSweepValues;
        defaultSweepRange=-defaultSweepRange;
        defaultStepValues=-defaultStepValues;
        defaultOutputValues=-defaultOutputValues;
    otherwise
        pm_error('physmod:ee:library:NotFound',getString(message('physmod:ee:library:comments:utils:mask:characteristicVisualizer:error_HarnessForThisComponentType')));
    end


    mask=Simulink.Mask.get([testModelName,'/Characteristics']);
    for ii=1:length(mask.Parameters)
        switch mask.Parameters(ii).Name
        case{'sweepType'}
            mask.Parameters(ii).TypeOptions=sweepOptions;
        case{'stepType'}
            mask.Parameters(ii).TypeOptions=stepOptions;
        case{'outputType'}
            mask.Parameters(ii).TypeOptions=outputOptions;
        case{'sweepValues'}
            mask.Parameters(ii).Value=ee.internal.mask.mat2str(defaultSweepValues);
        case{'sweepRange'}
            mask.Parameters(ii).Value=ee.internal.mask.mat2str(defaultSweepRange);
        case{'stepValues'}
            mask.Parameters(ii).Value=ee.internal.mask.mat2str(defaultStepValues);
        case{'outputValues'}
            mask.Parameters(ii).Value=ee.internal.mask.mat2str(defaultOutputValues);
        end
    end


    mws=get_param(testModelName,'modelworkspace');
    ee.internal.mask.populateDataStructureInModel(testModelName,parameterNameValueList);
    ds=ee.internal.mask.getSimscapeBlockDatasetFromModel(testModelName);
    ds.addTabulatedData(simscapeTabulatedData('terminals','term',terminals));
    ds.addTabulatedData(simscapeTabulatedData('referenceTerminal','ref',referenceTerminal));
    ds.addTabulatedData(simscapeTabulatedData('componentPath','model',componentPath));


    tunerName=[testModelName,'/Tuner'];
    mask=Simulink.Mask.get(tunerName);
    if isempty(mask)
        mask=Simulink.Mask.create(tunerName);
    else
        mask.delete;
        mask=Simulink.Mask.create(tunerName);
    end
    mask.removeAllParameters;
    set_param(tunerName,'MaskDisplay',['disp(''',getString(message('physmod:ee:library:comments:utils:characteristicViewer:ChooseParameters')),''')']);
    tabNames=cell.empty;
    for ii=1:length(parameterNameValueList)
        if~ismember(parameterNameValueList{ii}{3},tabNames)
            tabNames{end+1}=parameterNameValueList{ii}{3};%#ok<AGROW>
        end
    end
    tabContainer=mask.addDialogControl('tabcontainer','tabgroup');
    for ii=1:length(tabNames)
        tabContainer.addDialogControl('Type','tab','Name',[tabNames{ii},'_tab'],...
        'Prompt',upper(tabNames{ii}));
    end
    for ii=1:length(parameterNameValueList)
        val=str2num(parameterNameValueList{ii}{2});%#ok<ST2NM>
        if isempty(val)
            bdclose(testModelName);
            pm_error('physmod:ee:library:MaskParameterOverride',getString(message('physmod:ee:library:comments:utils:mask:characteristicVisualizer:error_VariableAndNonnumericParameterValuesAreNotSupportedForThe')));
        end
        if val==0
            minValue=0;
            maxValue=1;
        else
            if val>0
                minValue=0;
                maxValue=val*2;
            else
                maxValue=0;
                minValue=val*2;
            end
        end
        if strcmp(parameterNameValueList{ii}{4},'1')
            mask.addDialogControl('Type','group','Name',[parameterNameValueList{ii}{1},'_control'],...
            'Prompt',[parameterNameValueList{ii}{1},' (-)'],...
            'Container',[parameterNameValueList{ii}{3},'_tab']);
        else
            mask.addDialogControl('Type','group','Name',[parameterNameValueList{ii}{1},'_control'],...
            'Prompt',[parameterNameValueList{ii}{1},' (',parameterNameValueList{ii}{4},')'],...
            'Container',[parameterNameValueList{ii}{3},'_tab']);
        end
        mask.addParameter('Type','slider',...
        'Name',parameterNameValueList{ii}{1},'Value',parameterNameValueList{ii}{2},...
        'Range',[minValue,maxValue],'Container',[parameterNameValueList{ii}{1},'_control'],...
        'Callback',['ee.internal.mask.chooseParameters_sliderUpdate(gcs,''',parameterNameValueList{ii}{1},''');']);
        mask.addParameter('Type','edit','Prompt',getString(message('physmod:ee:library:comments:utils:mask:characteristicVisualizer:prompt_min')),...
        'Name',[parameterNameValueList{ii}{1},'_min'],'Value',num2str(minValue),...
        'Container',[parameterNameValueList{ii}{1},'_control'],...
        'Callback',['ee.internal.mask.chooseParameters_sliderRangeUpdate(gcs,''',parameterNameValueList{ii}{1},''');']);
        mask.addParameter('Type','edit','Prompt',getString(message('physmod:ee:library:comments:utils:mask:characteristicVisualizer:prompt_max')),...
        'Name',[parameterNameValueList{ii}{1},'_max'],'Value',num2str(maxValue),...
        'Container',[parameterNameValueList{ii}{1},'_control'],...
        'Callback',['ee.internal.mask.chooseParameters_sliderRangeUpdate(gcs,''',parameterNameValueList{ii}{1},''');']);
    end
    for ii=1:length(tabContainer.DialogControls)
        controls=tabContainer.DialogControls(ii).DialogControls;
        skipValues=1:paramsPerRow:length(controls);
        for jj=1:length(controls)
            if ismember(jj,skipValues)
                controls(jj).Row='new';
            else
                controls(jj).Row='current';
            end
        end
    end



    assignin(mws,'harnessCalledBy',blockName);
    evalin(get_param(gcs,'modelworkspace'),'modelName = gcs;');
    evalin(get_param(gcs,'modelworkspace'),'blockName = ''DUT'';');
    evalin(get_param(gcs,'modelworkspace'),'paramSetChangeListener=event.listener(parameterHelper.parameters,''isChanged'',@(x,y)ee.internal.mask.chooseParameters_updateValues(modelName));');

end
