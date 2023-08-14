function hObj=PmNePSConvertPanel(varargin)









    hObj=NetworkEngine.PmNePSConvertPanel;
    hObj.CreateInstanceFcn=PMDialogs.PmCreateInstance;

    narginchk(2,2);
    pm_assert(ishandle(varargin{1}));
    hObj.BlockHandle=varargin{1};

    hSlBlk=pmsl_getdoublehandle(hObj.BlockHandle);


    unitChoices=simscape.schema.internal.common_units();

    if strcmp(get_param(hSlBlk,'SubClassName'),'ps_input')
        boxPanel=PMDialogs.PmGroupPanel(hSlBlk,pm_message('physmod:ne_sli:nesl_utility:common:ParametersContainer'),'Box');
        tabPanel=PMDialogs.PmGroupPanel(hSlBlk,'Params','TabContainer');
        basicPanel=PMDialogs.PmGroupPanel(hSlBlk,pm_message('physmod:ne_sli:nesl_utility:sl2ps:UnitsContainer'),'TabPage');

        blockType=varargin{2};
        unitPrompt=[pm_message(['physmod:ne_sli:nesl_utility:',blockType,':unit']),':'];
        affineConversionPrompt=pm_message('physmod:ne_sli:nesl_utility:common:affine');



        unit=PMDialogs.PmEditDropDown(hSlBlk,...
        unitPrompt,'Unit',...
        unitChoices,1,'1','','',@(x)lPreApply(x,false));

        basicPanel=laddItem(basicPanel,unit);


        affineConversion=PMDialogs.PmCheckBox(hSlBlk,affineConversionPrompt,'AffineConversion',1);
        basicPanel=laddItem(basicPanel,affineConversion);


        providePanel=PMDialogs.PmGroupPanel(hSlBlk,pm_message('physmod:ne_sli:nesl_utility:sl2ps:InputHandlingContainer'),'TabPage');

        derivativeSourcePnl=PMDialogs.PmDropDown(hSlBlk,...
        pm_message('physmod:ne_sli:nesl_utility:sl2ps:FilteringAndDerivativesPrompt'),...
        'FilteringAndDerivatives',...
        {
        pm_message('physmod:ne_sli:nesl_utility:sl2ps:FilteringAndDerivativesProvide')
        pm_message('physmod:ne_sli:nesl_utility:sl2ps:FilteringAndDerivativesFilter')
        pm_message('physmod:ne_sli:nesl_utility:sl2ps:FilteringAndDerivativesZero')
        }',...
        1,'',[],{'provide','filter','zero'});
        providePanel=laddItem(providePanel,derivativeSourcePnl);

        userProvidedDerivLevelPnl=PMDialogs.PmDropDown(hSlBlk,...
        pm_message('physmod:ne_sli:nesl_utility:sl2ps:ProvidedSignalsPrompt'),...
        'UdotUserProvided',...
        {
        pm_message('physmod:ne_sli:nesl_utility:sl2ps:NoInputDerivativesProvidedOption')
        pm_message('physmod:ne_sli:nesl_utility:sl2ps:OneInputDerivativeProvidedOption')
        pm_message('physmod:ne_sli:nesl_utility:sl2ps:TwoInputDerivativesProvidedOption')
        }',...
        1,'',[],{'0','1','2'});

        providePanel=laddItem(providePanel,userProvidedDerivLevelPnl);

        simscapeFilterLevelPnl=PMDialogs.PmDropDown(hSlBlk,...
        pm_message('physmod:ne_sli:nesl_utility:sl2ps:SimscapeFilterOrder'),...
        'SimscapeFilterOrder',...
        {pm_message('physmod:ne_sli:nesl_utility:sl2ps:FirstOrderFiltering'),...
        pm_message('physmod:ne_sli:nesl_utility:sl2ps:SecondOrderFiltering')},...
        1,'',[],{'1','2'});
        providePanel=laddItem(providePanel,simscapeFilterLevelPnl);


        filterParamLabel=pm_message('physmod:ne_sli:nesl_utility:sl2ps:FilterTimeConstantPrompt');
        filterParamName='InputFilterTimeConstant';
        filterTimeConstantPnl=PMDialogs.PmEditBox(hSlBlk,filterParamLabel,filterParamName,1);
        providePanel=laddItem(providePanel,filterTimeConstantPnl);

        tabPanel=laddItem(tabPanel,basicPanel);
        tabPanel=laddItem(tabPanel,providePanel);
        boxPanel=laddItem(boxPanel,tabPanel);
        hObj.Items=boxPanel;
    else
        paramPanel=PMDialogs.PmGroupPanel(hSlBlk,pm_message('physmod:ne_sli:nesl_utility:common:ParametersContainer'),'Box');

        blockType=varargin{2};
        unitPrompt=[pm_message(['physmod:ne_sli:nesl_utility:',blockType,':unit']),':'];
        affineConversionPrompt=pm_message('physmod:ne_sli:nesl_utility:common:affine');


        vectorFormatLabel=pm_message('physmod:ne_sli:nesl_utility:ps2sl:VectorFormatPrompt');
        vectorFormatName='VectorFormat';
        vectorFormat=PMDialogs.PmDropDown(hSlBlk,...
        vectorFormatLabel,vectorFormatName,...
        {
        pm_message('physmod:ne_sli:nesl_utility:ps2sl:VectorFormatInherit')
        pm_message('physmod:ne_sli:nesl_utility:ps2sl:VectorFormat1DArray')
        }',...
        1,'',[],{'inherit','1-D array'});
        paramPanel=laddItem(paramPanel,vectorFormat);


        outputUnitChoices=[pm_inherit_id();unitChoices];
        unit=PMDialogs.PmEditDropDown(hSlBlk,...
        unitPrompt,'Unit',...
        outputUnitChoices,1,pm_inherit_id(),'','',@(x)lPreApply(x,true));
        paramPanel=laddItem(paramPanel,unit);


        affineConversion=PMDialogs.PmCheckBox(hSlBlk,affineConversionPrompt,'AffineConversion',1);
        paramPanel=laddItem(paramPanel,affineConversion);

        hObj.Items=paramPanel;
    end
end


function aPanel=laddItem(aPanel,aItem)

    if(isempty(aPanel.Items))
        aPanel.Items=aItem;
    else
        aPanel.Items(end+1)=aItem;
    end
end

function[status,messageString]=lPreApply(unitExpression,allowInherit)

    status=true;
    messageString='';
    if~pm_isunit(unitExpression)&&~(allowInherit&&strcmp(pm_inherit_id(),unitExpression))
        status=false;
        unitExpression=strrep(unitExpression,'<','&lt;');
        unitExpression=strrep(unitExpression,'>','&gt;');
        messageString=pm_message('physmod:common:data:mli:value:InvalidUnit',unitExpression);
    end

end
