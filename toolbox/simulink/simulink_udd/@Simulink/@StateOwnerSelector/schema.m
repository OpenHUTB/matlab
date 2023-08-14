function schema





    hDeriveFromPackage1=findpackage('DAStudio');
    hDeriveFromClass1=findclass(hDeriveFromPackage1,'Object');
    hCreateInPackage=findpackage('Simulink');


    hThisClass=schema.class(hCreateInPackage,'StateOwnerSelector',hDeriveFromClass1);








    hThisProp=schema.prop(hThisClass,'ModelObj','MATLAB array');
    hThisProp.FactoryValue={};


    hThisProp=schema.prop(hThisClass,'StateAccessorBlock','MATLAB array');
    hThisProp.FactoryValue={};


    hThisProp=schema.prop(hThisClass,'StateAccessorBlockDlg','MATLAB array');
    hThisProp.FactoryValue={};




    hThisProp=schema.prop(hThisClass,'SelectedStateOwner','string');
    hThisProp.FactoryValue='';


    hThisProp=schema.prop(hThisClass,'TreeModel','MATLAB array');
    hThisProp.FactoryValue={};


    hThisProp=schema.prop(hThisClass,'TreeExpandItems','MATLAB array');
    hThisProp.FactoryValue={};


    hThisProp=schema.prop(hThisClass,'TreeSelectedItem','MATLAB array');
    hThisProp.FactoryValue={};


    hThisProp=schema.prop(hThisClass,'SelectedOwnerBlock','MATLAB array');
    hThisProp.FactoryValue={};


    hThisProp=schema.prop(hThisClass,'SelectedOwnerState','MATLAB array');
    hThisProp.FactoryValue={};


    hThisProp=schema.prop(hThisClass,'ModelHasStateOwnerBlock','MATLAB array');
    hThisProp.FactoryValue={};



    hThisProp=schema.prop(hThisClass,'HighlightedBlock','string');
    hThisProp.FactoryValue='';







    m=schema.method(hThisClass,'getDialogSchema');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','string'};
    s.OutputTypes={'mxArray'};


    m=schema.method(hThisClass,'isValidStateOwnerBlock');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','mxArray'};
    s.OutputTypes={'bool'};


    m=schema.method(hThisClass,'treeCB');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','mxArray'};
    s.OutputTypes={};


    m=schema.method(hThisClass,'selectButtonCB');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','handle'};
    s.OutputTypes={};


    m=schema.method(hThisClass,'highlightButtonCB');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle'};
    s.OutputTypes={};


    m=schema.method(hThisClass,'cancelButtonCB');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','handle'};
    s.OutputTypes={};


    m=schema.method(hThisClass,'closeDlg');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','handle'};
    s.OutputTypes={};

end

