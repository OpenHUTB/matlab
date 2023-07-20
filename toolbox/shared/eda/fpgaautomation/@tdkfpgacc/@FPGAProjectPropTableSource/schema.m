function schema




    mlock;

    hPackage=findpackage('tdkfpgacc');
    this=schema.class(hPackage,'FPGAProjectPropTableSource');





    m=schema.method(this,'SetSourceData');
    m.Signature.varargin='off';
    m.Signature.InputTypes={'handle','mxArray','int'};

    m=schema.method(this,'CreateTableOperationsWidget');
    m.Signature.varargin='off';
    m.Signature.InputTypes={'handle','mxArray'};
    m.Signature.OutputTypes={'mxArray'};

    m=schema.method(this,'CreateTableWidget');
    m.Signature.varargin='off';
    m.Signature.InputTypes={'handle'};
    m.Signature.OutputTypes={'mxArray'};


    m=schema.method(this,'GetTableOperationsEnables');
    m.Signature.varargin='off';
    m.Signature.InputTypes={'handle'};
    m.Signature.OutputTypes={'mxArray'};






    m=schema.method(this,'GetColInfo');
    m.Signature.varargin='off';
    m.Signature.InputTypes={'handle'};

    m.Signature.OutputTypes={'mxArray','mxArray','int'};

    m=schema.method(this,'GetMaxPathLength');
    m.Signature.varargin='off';
    m.Signature.InputTypes={'handle'};
    m.Signature.OutputTypes={'int'};

    m=schema.method(this,'CreateTableData');
    m.Signature.varargin='off';
    m.Signature.InputTypes={'handle'};
    m.Signature.OutputTypes={'mxArray'};

    m=schema.method(this,'CreateTableCell');
    m.Signature.varargin='off';
    m.Signature.InputTypes={'handle','string','string'};
    m.Signature.OutputTypes={'mxArray'};



    m=schema.method(this,'AddRow');
    m.Signature.varargin='off';
    m.Signature.InputTypes={'handle','handle'};

    m=schema.method(this,'DeleteRow');
    m.Signature.varargin='off';
    m.Signature.InputTypes={'handle','handle'};

    m=schema.method(this,'MoveRowUp');
    m.Signature.varargin='off';
    m.Signature.InputTypes={'handle','handle'};

    m=schema.method(this,'MoveRowDown');
    m.Signature.varargin='off';
    m.Signature.InputTypes={'handle','handle'};




    m=schema.method(this,'OnTableValueChangeCB');
    m.Signature.varargin='off';

    m.Signature.InputTypes={'handle','handle','int','int','mxArray'};



    m=schema.method(this,'RefreshRow');
    m.Signature.varargin='off';

    m.Signature.InputTypes={'handle','handle','int'};

    m=schema.method(this,'RefreshTable');
    m.Signature.varargin='off';

    m.Signature.InputTypes={'handle','handle'};

    m=schema.method(this,'OnTableFocusChangeCB');
    m.Signature.varargin='off';

    m.Signature.InputTypes={'handle','handle','int','int'};







    m=schema.method(this,'GetSourceData');
    m.Signature.varargin='off';
    m.Signature.InputTypes={'handle'};
    m.Signature.OutputTypes={'mxArray'};







    schema.prop(this,'TableName','string');
    schema.prop(this,'TableOpsTag','string');
    schema.prop(this,'AddRowTag','string');
    schema.prop(this,'DeleteRowTag','string');
    schema.prop(this,'MoveRowUpTag','string');
    schema.prop(this,'MoveRowDownTag','string');

    schema.prop(this,'UddUtil','handle');

    schema.prop(this,'NumRows','int');
    schema.prop(this,'NumCols','int');
    schema.prop(this,'CurrRow','int');
    schema.prop(this,'MaxPathLength','int');
    schema.prop(this,'RowSources','handle vector');



    schema.prop(this,'colPos','mxArray');
    schema.prop(this,'colName','mxArray');
