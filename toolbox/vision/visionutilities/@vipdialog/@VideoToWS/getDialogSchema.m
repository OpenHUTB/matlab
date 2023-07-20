function dlgStruct=getDialogSchema(this,dummy)











    VariableName=dspGetLeafWidgetBase('edit',getString(message('vision:masks:VariableName')),...
    'VariableName',this,'VariableName');
    VariableName.Entries=set(this,'VariableName')';


    NumInputs=dspGetLeafWidgetBase('edit',getString(message('vision:masks:NumberOfInputs')),...
    'NumInputs',this,'NumInputs');
    NumInputs.Entries=set(this,'NumInputs')';
    NumInputs.DialogRefresh=1;

    DataLimit=dspGetLeafWidgetBase('edit',getString(message('vision:masks:LimitDataPointsToLast')),...
    'DataLimit',this,'DataLimit');
    DataLimit.Entries=set(this,'DataLimit')';

    DecimationFactor=dspGetLeafWidgetBase('edit',getString(message('vision:masks:Decimation')),...
    'DecimationFactor',this,'DecimationFactor');
    DecimationFactor.Entries=set(this,'DecimationFactor')';

    InPortLabels=dspGetLeafWidgetBase('edit',getString(message('vision:masks:InputPortLabels')),...
    'InPortLabels',this,'InPortLabels');
    InPortLabels.Entries=set(this,'InPortLabels')';

    if(str2num(this.NumInputs)==1)
        InPortLabels.Visible=0;
    else
        InPortLabels.Visible=1;
    end

    LogFi=dspGetLeafWidgetBase('checkbox',getString(message('vision:masks:LogFixedpointDataAsAFiObject')),...
    'LogFi',this,'LogFi');



    parameterPane=dspGetContainerWidgetBase('group',getString(message('vision:masks:Parameters')),'parameterPane');
    parameterPane.Items=dspTrimItemList({VariableName,NumInputs,DataLimit,DecimationFactor,...
    LogFi,InPortLabels});
    parameterPane.RowSpan=[2,2];
    parameterPane.ColSpan=[1,1];

    dlgStruct=this.getBaseSchemaStruct(parameterPane);





