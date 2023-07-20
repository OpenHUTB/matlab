function schema





    rfPackage=findpackage('simrfV2dialog');
    parent=findclass(rfPackage,'simrfV2dialog');
    this=schema.class(rfPackage,'Junctions',parent);


    m=schema.method(this,'getDialogSchema');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','string'};
    s.OutputTypes={'mxArray'};






    if isempty(findtype('SimRFV2JunctionCirculator'))
        schema.EnumType('SimRFV2JunctionCirculator',{...
        'Circulator clockwise',...
        'Circulator counter clockwise',...
        'Tee H-plane (S11=0)',...
        'Reciprocal phase shifter'});
        schema.EnumType('SimRFV2JunctionDivider',{...
        'T power divider',...
        'Resistive power divider',...
        'Wilkinson power divider',...
        'Tee H-plane (S33=0)',...
        'Tee E-plane'});
        schema.EnumType('SimRFV2JunctionCoupler',{...
        'Directional coupler',...
        'Coupler symmetrical',...
        'Coupler antisymmetrical',...
        'Hybrid quadrature (90 deg)',...
        'Hybrid rat-race',...
        'Magic tee'});
        schema.EnumType('SimRFV2JunctionPorts',{...
        '3','4'});
    end

    schema.prop(this,'NumPorts','SimRFV2JunctionPorts');
    schema.prop(this,'DeviceCirculator','SimRFV2JunctionCirculator');
    schema.prop(this,'DeviceDivider','SimRFV2JunctionDivider');
    schema.prop(this,'DeviceCoupler','SimRFV2JunctionCoupler');
    schema.prop(this,'Phase12','string');
    schema.prop(this,'Phase33','string');
    schema.prop(this,'Alpha','string');
    schema.prop(this,'NumberDividerOutports','string');
    schema.prop(this,'Coupling','string');
    schema.prop(this,'Directivity','string');
    schema.prop(this,'InsertionLoss','string');
    schema.prop(this,'ReturnLoss','string');
    schema.prop(this,'SparamZ0','string');
    schema.prop(this,'InternalGrounding','bool');

