function schema




    mlock;


    hDeriveFromPackage1=findpackage('DAStudio');
    hDeriveFromClass1=findclass(hDeriveFromPackage1,'Object');
    hCreateInPackage=findpackage('Simulink');


    hThisClass=schema.class(hCreateInPackage,'TaskAdvisor',hDeriveFromClass1);







    hThisProp=schema.prop(hThisClass,'ID','string');
    hThisProp.FactoryValue='';


    hThisProp=schema.prop(hThisClass,'DisplayName','string');
    hThisProp.FactoryValue='';


    hThisProp=schema.prop(hThisClass,'Help','string');
    hThisProp.FactoryValue='';


    hThisProp=schema.prop(hThisClass,'HelpMethod','string');
    hThisProp.FactoryValue='';


    hThisProp=schema.prop(hThisClass,'HelpArgs','MATLAB array');
    hThisProp.FactoryValue={};


    hThisProp=schema.prop(hThisClass,'CSHParameters','MATLAB array');
    hThisProp.FactoryValue={};


    hThisProp=schema.prop(hThisClass,'Selected','bool');
    hThisProp.FactoryValue=true;


    hThisProp=schema.prop(hThisClass,'SelectedGUI','bool');
    hThisProp.FactoryValue=true;
    hThisProp.GetFunction=@getSelectedGUI;
    hThisProp.SetFunction=@setSelectedGUI;


    hThisProp=schema.prop(hThisClass,'Severity','string');
    hThisProp.FactoryValue='Advisory';


    hThisProp=schema.prop(hThisClass,'Type','string');
    hThisProp.FactoryValue='';


    hThisProp=schema.prop(hThisClass,'State','string');
    hThisProp.FactoryValue='None';


    hThisProp=schema.prop(hThisClass,'WaiveFailure','bool');
    hThisProp.FactoryValue=false;
    hThisProp.GetFunction=@getWaiveFailure;
    hThisProp.SetFunction=@setWaiveFailure;


    hThisProp=schema.prop(hThisClass,'ShowWaiveFailure','bool');
    hThisProp.FactoryValue=false;


    hThisProp=schema.prop(hThisClass,'ShowCheckbox','bool');
    hThisProp.FactoryValue=true;



    hThisProp=schema.prop(hThisClass,'InternalState','string');
    hThisProp.FactoryValue='';


    hThisProp=schema.prop(hThisClass,'MAC','string');
    hThisProp.FactoryValue='';



    hThisProp=schema.prop(hThisClass,'MAT','string');
    hThisProp.FactoryValue='';


    hThisProp=schema.prop(hThisClass,'MACVersion','MATLAB array');
    hThisProp.FactoryValue={};


    hThisProp=schema.prop(hThisClass,'Children','MATLAB array');
    hThisProp.FactoryValue={};


    hThisProp=schema.prop(hThisClass,'ChildrenObj','MATLAB array');
    hThisProp.FactoryValue={};


    hThisProp=schema.prop(hThisClass,'ParentObj','handle');


    hThisProp=schema.prop(hThisClass,'Version','string');
    hThisProp.FactoryValue='';


    hThisProp=schema.prop(hThisClass,'Dependency','MATLAB array');
    hThisProp.FactoryValue={};


    hThisProp=schema.prop(hThisClass,'LicenseName','MATLAB array');
    hThisProp.FactoryValue={};


    hThisProp=schema.prop(hThisClass,'Visible','bool');
    hThisProp.FactoryValue=true;


    hThisProp=schema.prop(hThisClass,'Enable','bool');
    hThisProp.FactoryValue=true;




    hThisProp=schema.prop(hThisClass,'Value','MATLAB array');
    hThisProp.FactoryValue='';


    hThisProp=schema.prop(hThisClass,'ByTaskMode','bool');
    hThisProp.FactoryValue=false;


    hThisProp=schema.prop(hThisClass,'OverwriteHTML','bool');
    hThisProp.FactoryValue=true;


    hThisProp=schema.prop(hThisClass,'LaunchReport','bool');
    hThisProp.FactoryValue=false;







    hThisProp=schema.prop(hThisClass,'CheckBoxMode','string');
    hThisProp.FactoryValue='All';






    hThisProp=schema.prop(hThisClass,'Index','int32');
    hThisProp.FactoryValue=0;


    hThisProp=schema.prop(hThisClass,'AllChildrenIndex','MATLAB array');
    hThisProp.FactoryValue={};


    hThisProp=schema.prop(hThisClass,'DependencyObj','MATLAB array');
    hThisProp.FactoryValue={};


    hThisProp=schema.prop(hThisClass,'ReverseDependencyObj','MATLAB array');
    hThisProp.FactoryValue={};


    hThisProp=schema.prop(hThisClass,'CallbackFcnPath','string');
    hThisProp.FactoryValue='';



    hThisProp=schema.prop(hThisClass,'CustomDialogSchema','MATLAB callback');
    hThisProp.FactoryValue=[];


    hThisProp=schema.prop(hThisClass,'MACIndex','int32');
    hThisProp.FactoryValue=0;


    hThisProp=schema.prop(hThisClass,'MATIndex','int32');
    hThisProp.FactoryValue=0;


    hThisProp=schema.prop(hThisClass,'ChildrenMACIndex','MATLAB array');
    hThisProp.FactoryValue={};






    hThisProp=schema.prop(hThisClass,'MAObj','MATLAB array');
    hThisProp.FactoryValue={};




    m=schema.method(hThisClass,'getDialogSchema');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','string'};
    s.OutputTypes={'mxArray'};

    m=schema.method(hThisClass,'getDisplayIcon');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle'};
    s.OutputTypes={'string'};








    m=schema.method(hThisClass,'getCheckableProperty');
    m.signature.varargin='off';
    m.signature.inputTypes={'handle'};
    m.signature.OutputTypes={'string'};

    m=schema.method(hThisClass,'isReadonlyProperty');
    m.signature.varargin='off';
    m.signature.inputTypes={'handle','string'};
    m.signature.OutputTypes={'bool'};

    m=schema.method(hThisClass,'getContextMenu');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','handle vector'};
    s.OutputTypes={'handle'};

    m=schema.method(hThisClass,'getDisplayLabel');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle'};
    s.OutputTypes={'string'};

    m=schema.method(hThisClass,'isHierarchical');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle'};
    s.OutputTypes={'bool'};

    m=schema.method(hThisClass,'isHierarchyReadonly');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle'};
    s.OutputTypes={'bool'};







    m=schema.method(hThisClass,'runTaskAdvisor');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle'};
    s.OutputTypes={};

    m=schema.method(hThisClass,'runAction');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle'};
    s.OutputTypes={};

    m=schema.method(hThisClass,'viewReport');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle'};
    s.OutputTypes={};

    m=schema.method(hThisClass,'isUnderDeactiveWorkflow');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle'};
    s.OutputTypes={'bool'};

    m=schema.method(hThisClass,'getChildren');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle'};
    s.OutputTypes={'handle vector'};

    m=schema.method(hThisClass,'getHierarchicalChildren');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle'};
    s.OutputTypes={'handle vector'};

    m=schema.method(hThisClass,'handleCheckEvent');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','string','handle'};
    s.OutputTypes={};



    m=schema.method(hThisClass,'select','static');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={};
    s.OutputTypes={'mxArray'};



    m=schema.method(hThisClass,'deselect','static');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={};
    s.OutputTypes={'mxArray'};



    m=schema.method(hThisClass,'run','static');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={};
    s.OutputTypes={};



    m=schema.method(hThisClass,'opencsh','static');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={};
    s.OutputTypes={};



    m=schema.method(hThisClass,'toggleSourcetab','static');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={};
    s.OutputTypes={};



    m=schema.method(hThisClass,'closeExplorer','static');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={};
    s.OutputTypes={};
