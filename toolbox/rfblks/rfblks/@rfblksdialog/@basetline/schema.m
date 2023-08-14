function schema





    rfPackage=findpackage('rfblksdialog');
    parent=findclass(rfPackage,'rfblksdialog');
    this=schema.class(rfPackage,'basetline',parent);





    if isempty(findtype('StubModeType'))
        schema.EnumType('StubModeType',{...
        'Not a stub',...
        'Shunt',...
        'Series'});
    end

    if isempty(findtype('StubTerminationType'))
        schema.EnumType('StubTerminationType',{...
        'Open',...
        'Short'});
    end

    schema.prop(this,'LineLength','string');
    schema.prop(this,'StubMode','StubModeType');
    schema.prop(this,'Termination','StubTerminationType');






    if isempty(findtype('PassivecktFreqType'))
        schema.EnumType('PassivecktFreqType',{...
        'User-specified',...
        'Derived from Input Port parameters'});
    end

    if isempty(findtype('AllPlotType'))
        schema.EnumType('AllPlotType',{...
        'Composite data',...
        'X-Y plane',...
        'Polar plane',...
        'Z Smith chart',...
        'Y Smith chart',...
        'ZY Smith chart'});
    end

    if isempty(findtype('AxesOptionType'))
        schema.EnumType('AxesOptionType',{...
        'Linear',...
        'Log'});
    end

    schema.prop(this,'SourceFreq','PassivecktFreqType');
    schema.prop(this,'Freq','string');
    schema.prop(this,'AllPlotType','AllPlotType');
    schema.prop(this,'YOption','AxesOptionType');
    schema.prop(this,'XOption','AxesOptionType');
    schema.prop(this,'PlotZ0','string');


