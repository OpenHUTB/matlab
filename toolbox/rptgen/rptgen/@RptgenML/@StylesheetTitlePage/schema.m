function schema






    pkg=findpackage('RptgenML');
    h=schema.class(pkg,'StylesheetTitlePage',pkg.findclass('StylesheetElementID'));

    rptgen.prop(h,'Format','MATLAB array');

    p=rptgen.prop(h,'LOGridCols','int32',1,getString(message('rptgen:RptgenML_StylesheetTitlePage:loGridNColsLabel')));
    p.GetFunction={@getLayoutGridProp,'NumberOfColumns'};
    p.SetFunction={@setLayoutGridProp,'NumberOfColumns'};

    p=rptgen.prop(h,'LOGridRows','int32',16,getString(message('rptgen:RptgenML_StylesheetTitlePage:loGridNRowsLabel')));
    p.GetFunction={@getLayoutGridProp,'NumberOfRows'};
    p.SetFunction={@setLayoutGridProp,'NumberOfRows'};

    rptgen.prop(h,'LOGridWidthType',...
    {
    'page',getString(message('rptgen:RptgenML_StylesheetTitlePage:loGridSizeTypePage'))
    'specify',getString(message('rptgen:RptgenML_StylesheetTitlePage:loGridSizeTypeSpecify'))
    },'page',getString(message('rptgen:RptgenML_StylesheetTitlePage:loGridWidthTypeLabel')));

    p=rptgen.prop(h,'LOGridWidth','string');
    p.SetFunction=@setLayoutGridWidth;

    p=rptgen.prop(h,'LOGridWidthUnit',RptgenML.enumTypographicUnits,...
    'in',getString(message('rptgen:RptgenML_StylesheetTitlePage:loGridUnitsLabel')));
    p.SetFunction={@setLayoutGridProp,'WidthUnit'};

    rptgen.prop(h,'LOGridHeightType',...
    {
    'page',getString(message('rptgen:RptgenML_StylesheetTitlePage:loGridSizeTypePage'))
    'specify',getString(message('rptgen:RptgenML_StylesheetTitlePage:loGridSizeTypeSpecify'))
    },'page',getString(message('rptgen:RptgenML_StylesheetTitlePage:loGridHeightTypeLabel')));

    p=rptgen.prop(h,'LOGridHeight','string');
    p.SetFunction=@setLayoutGridHeight;

    p=rptgen.prop(h,'LOGridHeightUnit',RptgenML.enumTypographicUnits,...
    'in',getString(message('rptgen:RptgenML_StylesheetTitlePage:loGridUnitsLabel')));
    p.SetFunction={@setLayoutGridProp,'HeightUnit'};

    p=rptgen.prop(h,'ShowGrid','bool',false,getString(message('rptgen:RptgenML_StylesheetTitlePage:loGridShowGridLabel')));
    p.SetFunction={@setLayoutGridProp,'Show'};

    e=RptgenML.enumTitlePageContents;

    p=rptgen.prop(h,'CurrIncludeElementIdx','int32',0);
    p.Visible='off';

    p=rptgen.prop(h,'CurrExcludeElementIdx','int32',0);
    p.Visible='off';

    rptgen.prop(h,'IncludedElementDisplayNames','string vector',e.DisplayNames);
    rptgen.prop(h,'IncludedElementNames','string vector',e.Strings);
    rptgen.prop(h,'IncludedElementIndices','MATLAB array',e.values);

    rptgen.prop(h,'ExcludedElementDisplayNames','string vector');
    rptgen.prop(h,'ExcludedElementNames','string vector');
    rptgen.prop(h,'ExcludedElementIndices','MATLAB array');

    p=rptgen.prop(h,'CurrElemRow','int32');
    p.SetFunction={@setCurrElemProp,'RowNum'};

    p=rptgen.prop(h,'CurrElemRowSpan','int32',1);
    p.SetFunction={@setCurrElemProp,'RowSpan'};

    p=rptgen.prop(h,'CurrElemCol','int32',1);
    p.SetFunction={@setCurrElemProp,'ColNum'};

    p=rptgen.prop(h,'CurrElemColSpan','int32',1);
    p.SetFunction={@setCurrElemProp,'ColSpan'};


    p=rptgen.prop(h,'CurrElemFontSize','string','',...
    getString(message('rptgen:RptgenML_StylesheetTitlePage:ItemFormatFontSizeLabel')));
    p.SetFunction={@setCurrElemProp,'FontSize'};

    p=rptgen.prop(h,'CurrElemIsBold','bool',true,...
    getString(message('rptgen:RptgenML_StylesheetTitlePage:ItemFormatBoldLabel')));
    p.SetFunction={@setCurrElemProp,'IsBold'};

    p=rptgen.prop(h,'CurrElemIsItalic','bool',false,...
    getString(message('rptgen:RptgenML_StylesheetTitlePage:ItemFormatItalicLabel')));
    p.SetFunction={@setCurrElemProp,'IsItalic'};

    p=rptgen.prop(h,'CurrElemColor','string','black');
    p.SetFunction={@setCurrElemProp,'Color'};

    p=rptgen.prop(h,'CurrElemHAlign','string','center');
    p.SetFunction={@setCurrElemProp,'HAlign'};

    p=rptgen.prop(h,'CurrElemXPath','string','');
    p.SetFunction={@setCurrElemProp,'XPath'};

    p=rptgen.prop(h,'CurrElemXForm','string','');
    p.SetFunction={@setCurrElemProp,'XForm'};


    m=schema.method(h,'getDialogSchema');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','string'};
    s.OutputTypes={'mxArray'};

    m=schema.method(h,'acceptDrop');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','handle vector'};
    s.OutputTypes={'bool'};

    m=schema.method(h,'postApply');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle'};
    s.OutputTypes={'bool','string'};

