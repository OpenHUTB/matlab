function schema





    package=findpackage('dspdialog');
    parent=findclass(package,'DSPDDG');

    this=schema.class(package,'MatrixViewer',parent);


    m=schema.method(this,'getDialogSchema');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','string'};
    s.OutputTypes={'mxArray'};


    if isempty(findtype('DSPMATRIXVIEWERAxisOrigin'))
        schema.EnumType('DSPMATRIXVIEWERAxisOrigin',{'Upper left corner','Lower left corner'});
    end

    if isempty(findtype('DSPMATRIXVIEWERAxisTickMode'))
        schema.EnumType('DSPMATRIXVIEWERAxisTickMode',{'Auto','User-defined'});
    end



    schema.prop(this,'CMapStr','ustring');
    schema.prop(this,'YMin','ustring');
    schema.prop(this,'YMax','ustring');
    schema.prop(this,'AxisColorbar','bool');

    schema.prop(this,'AxisOrigin','DSPMATRIXVIEWERAxisOrigin');
    schema.prop(this,'XLabel','ustring');
    schema.prop(this,'YLabel','ustring');
    schema.prop(this,'ZLabel','ustring');
    schema.prop(this,'FigPos','ustring');
    schema.prop(this,'AxisZoom','bool');
    schema.prop(this,'AxisTickMode','DSPMATRIXVIEWERAxisTickMode');
    schema.prop(this,'XTickRange','ustring');
    schema.prop(this,'YTickRange','ustring');
