function schema






    rfPackage=findpackage('rfblksdialog');
    parent=findclass(rfPackage,'rfblksdialog');
    this=schema.class(rfPackage,'GeneralPassiveNetwork',parent);


    m=schema.method(this,'getDialogSchema');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','string'};
    s.OutputTypes={'mxArray'};






    if isempty(findtype('DataSourceType'))
        schema.EnumType('DataSourceType',{...
        'RFDATA object',...
        'Data file'});
    end

    if isempty(findtype('InterpMethodType'))
        schema.EnumType('InterpMethodType',{...
        'Linear',...
        'Spline',...
        'Cubic'});
    end

    schema.prop(this,'DataSource','DataSourceType');
    schema.prop(this,'RFDATA','string');
    schema.prop(this,'InterpMethod','InterpMethodType');
    schema.prop(this,'File','string');






    if isempty(findtype('SourceFreqType'))
        schema.EnumType('SourceFreqType',{...
        'Extracted from data source',...
        'User-specified',...
        'Derived from Input Port parameters'});
    end

    if isempty(findtype('SourcePinType'))
        schema.EnumType('SourcePinType',{...
        'Extracted from data source',...
        'User-specified'});
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

    schema.prop(this,'SourceFreq','SourceFreqType');
    schema.prop(this,'Freq','string');
    schema.prop(this,'AllPlotType','AllPlotType');
    schema.prop(this,'YOption','AxesOptionType');
    schema.prop(this,'XOption','AxesOptionType');
    schema.prop(this,'PlotZ0','string');

