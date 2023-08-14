function schema





    package=findpackage('dspdialog');
    parent=findclass(package,'DSPDDG');
    this=schema.class(package,'Kalman',parent);


    m=schema.method(this,'getDialogSchema');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','string'};
    s.OutputTypes={'mxArray'};

    if isempty(findtype('DSPKalmanSourceEnable'))
        schema.EnumType('DSPKalmanSourceEnable',...
        {'Always',...
        'Specify via input port <Enable>'});
    end

    if isempty(findtype('DSPKalmanSourceMeasure'))
        schema.EnumType('DSPKalmanSourceMeasure',...
        {'Specify via dialog',...
        'Input port <H>'});
    end


    schema.prop(this,'num_targets','string');
    schema.prop(this,'sourceEnable','DSPKalmanSourceEnable');
    schema.prop(this,'isReset','bool');
    schema.prop(this,'sourceMeasure','DSPKalmanSourceMeasure');


    schema.prop(this,'X','ustring');
    schema.prop(this,'P','ustring');
    schema.prop(this,'A','ustring');
    schema.prop(this,'H','ustring');
    schema.prop(this,'Q','ustring');
    schema.prop(this,'R','ustring');


    schema.prop(this,'isOutputPrdState','bool');
    schema.prop(this,'isOutputPrdMeasure','bool');
    schema.prop(this,'isOutputPrdError','bool');
    schema.prop(this,'isOutputEstState','bool');
    schema.prop(this,'isOutputEstMeasure','bool');
    schema.prop(this,'isOutputEstError','bool');


