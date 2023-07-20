function schema





    hDeriveFromPackage=findpackage('Simulink');
    hDeriveFromClass=findclass(hDeriveFromPackage,'SLDialogSource');
    hPackage=findpackage('TaskManagerDlg');
    this=schema.class(hPackage,'TaskManagerMask',hDeriveFromClass);




    schema.prop(this,'Block','mxArray');
    schema.prop(this,'BlockHandle','double');
    schema.prop(this,'selectedTask','string');
    schema.prop(this,'taskList','string vector');

    schema.prop(this,'enableTaskSimulation','bool');
    schema.prop(this,'useScheduleEditor','bool');

    schema.prop(this,'taskDurationData','MATLAB array');
    schema.prop(this,'selectedTableRow','double');
    schema.prop(this,'selectedTableCol','double');

    schema.prop(this,'streamToSDI','bool');
    schema.prop(this,'writeToFile','bool');
    schema.prop(this,'overwriteFile','bool');

    schema.prop(this,'taskName','string');
    schema.prop(this,'taskType','string');
    schema.prop(this,'taskPeriod','string');
    schema.prop(this,'taskEvent','string');
    schema.prop(this,'taskEventSource','string');
    schema.prop(this,'taskEventSourceType','string');
    schema.prop(this,'taskEventSourceAssignmentType','string');
    schema.prop(this,'taskPriority','string');
    schema.prop(this,'coreNum','string');
    schema.prop(this,'dropOverranTasks','bool');

    schema.prop(this,'playbackRecorded','bool');
    schema.prop(this,'taskDurationSource','string');
    schema.prop(this,'taskDuration','double');
    schema.prop(this,'taskDurationDeviation','double');
    schema.prop(this,'diagnosticsFile','string');

    schema.prop(this,'logExecutionData','bool');
    schema.prop(this,'logDroppedTasks','bool');

    schema.prop(this,'allTaskData','string');
    schema.prop(this,'Root','mxArray');

    schema.prop(this,'taskEditData','string');

    schema.prop(this,'customizationInfo','MATLAB array');

    m=schema.method(this,'getDialogSchema');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','string'};
    s.OutputTypes={'mxArray'};

    m=schema.method(this,'onTaskSelectionChange');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','handle','mxArray','mxArray'};
    s.OutputTypes={};

    m=schema.method(this,'onTaskNameChange');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','handle','mxArray','mxArray'};
    s.OutputTypes={};

    m=schema.method(this,'onTaskTypeChange');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','handle','mxArray','mxArray'};
    s.OutputTypes={};

    m=schema.method(this,'onTaskDurationSourceChange');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','handle','mxArray','mxArray'};
    s.OutputTypes={};

    m=schema.method(this,'onTaskParameterChange');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','handle','mxArray','mxArray'};
    s.OutputTypes={};

    m=schema.method(this,'onDiagnosticsFileChange');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','handle','mxArray','mxArray'};
    s.OutputTypes={};

    m=schema.method(this,'taskManagerPreApplyCallback');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','handle'};
    s.OutputTypes={'bool','string'};

    m=schema.method(this,'updateWidgetValues');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','handle','mxArray'};
    s.OutputTypes={};
end


