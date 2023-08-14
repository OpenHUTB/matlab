function schema






    rfPackage=findpackage('rfblksdialog');
    parent=findclass(rfPackage,'rfblksdialog');
    this=schema.class(rfPackage,'InputPort',parent);


    m=schema.method(this,'getDialogSchema');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','string'};
    s.OutputTypes={'mxArray'};





    if isempty(findtype('TreatSimulinkInputSignalAsType'))
        schema.EnumType('TreatSimulinkInputSignalAsType',{...
        'Incident power wave','Source voltage'});
    end

    if isempty(findtype('RFhasDSPType'))
        schema.EnumType('RFhasDSPType',{...
        'Elements as channels (sample based)',...
        'Columns as channels (frame based)'});
    end

    schema.prop(this,'TreatSimulinkInputSignalAs','TreatSimulinkInputSignalAsType');
    schema.prop(this,'MaxLength','string');
    schema.prop(this,'FracBW','string');
    schema.prop(this,'ModelDelay','string');
    schema.prop(this,'Fc','string');
    schema.prop(this,'Ts','string');
    schema.prop(this,'Zs','string');
    schema.prop(this,'RFhasDSP','RFhasDSPType');
    schema.prop(this,'NoiseFlag','bool');
    schema.prop(this,'seed','string');

