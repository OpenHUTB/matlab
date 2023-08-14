function schema




    mlock;


    hCreateInPackage=findpackage('Simulink');


    hThisClass=schema.class(hCreateInPackage,'MdlAdvisorCheck');


    hThisProp=schema.prop(hThisClass,'ModelName','string');
    hThisProp.FactoryValue='';


    hThisProp=schema.prop(hThisClass,'Title','ustring');
    hThisProp.FactoryValue='';



    hThisProp=schema.prop(hThisClass,'TitleTips','ustring');
    hThisProp.FactoryValue='';


    hThisProp=schema.prop(hThisClass,'CSHParameters','MATLAB array');
    hThisProp.FactoryValue={};



    hThisProp=schema.prop(hThisClass,'TitleInRAWFormat','bool');
    hThisProp.FactoryValue=false;


    hThisProp=schema.prop(hThisClass,'RAWTitle','ustring');
    hThisProp.FactoryValue='';


    hThisProp=schema.prop(hThisClass,'ActionCallbackHandle','MATLAB callback');
    hThisProp.FactoryValue=[];


    hThisProp=schema.prop(hThisClass,'ActionEnable','bool');
    hThisProp.FactoryValue=false;


    hThisProp=schema.prop(hThisClass,'ActionSuccess','bool');
    hThisProp.FactoryValue=true;



    hThisProp=schema.prop(hThisClass,'ActionButtonName','ustring');
    hThisProp.FactoryValue='';


    hThisProp=schema.prop(hThisClass,'ActionDescription','ustring');
    hThisProp.FactoryValue='';


    hThisProp=schema.prop(hThisClass,'ActionResultInHTML','ustring');
    hThisProp.FactoryValue='';


    hThisProp=schema.prop(hThisClass,'CallbackHandle','MATLAB callback');
    hThisProp.FactoryValue=[];




    hThisProp=schema.prop(hThisClass,'CallbackContext','string');
    hThisProp.FactoryValue='None';





    hThisProp=schema.prop(hThisClass,'CallbackStyle','string');
    hThisProp.FactoryValue='StyleOne';



    hThisProp=schema.prop(hThisClass,'CallbackReturnInRAWFormat','bool');
    hThisProp.FactoryValue=false;




    hThisProp=schema.prop(hThisClass,'Visible','bool');
    hThisProp.FactoryValue=true;
    hThisProp=schema.prop(hThisClass,'Enable','bool');
    hThisProp.FactoryValue=true;
    hThisProp=schema.prop(hThisClass,'Value','bool');
    hThisProp.FactoryValue=true;



    hThisProp=schema.prop(hThisClass,'VisibleInProductList','bool');
    hThisProp.FactoryValue=true;



    hThisProp=schema.prop(hThisClass,'Group','ustring');
    hThisProp.FactoryValue='';





    hThisProp=schema.prop(hThisClass,'GroupID','string');
    hThisProp.FactoryValue='';
    hThisProp=schema.prop(hThisClass,'TitleID','string');
    hThisProp.FactoryValue='';


    hThisProp=schema.prop(hThisClass,'Result','MATLAB array');
    hThisProp.FactoryValue={};


    hThisProp=schema.prop(hThisClass,'FoundObjects','MATLAB array');
    hThisProp.FactoryValue={};


    hThisProp=schema.prop(hThisClass,'ResultInHTML','ustring');
    hThisProp.FactoryValue='';


    hThisProp=schema.prop(hThisClass,'Success','bool');
    hThisProp.FactoryValue=false;


    hThisProp=schema.prop(hThisClass,'ErrorSeverity','int32');
    hThisProp.FactoryValue=0;


    hThisProp=schema.prop(hThisClass,'RunComplete','bool');
    hThisProp.FactoryValue=true;


    hThisProp=schema.prop(hThisClass,'InputParameters','MATLAB array');
    hThisProp.FactoryValue={};


    hThisProp=schema.prop(hThisClass,'InputParametersLayoutGrid','MATLAB array');
    hThisProp.FactoryValue=[];


    hThisProp=schema.prop(hThisClass,'InputParamsDlgCallback','MATLAB callback');
    hThisProp.FactoryValue=[];




    hThisProp=schema.prop(hThisClass,'ListViewVisible','bool');
    hThisProp.FactoryValue=false;


    hThisProp=schema.prop(hThisClass,'ListViewParameters','MATLAB array');
    hThisProp.FactoryValue={};



    hThisProp=schema.prop(hThisClass,'SelectedListViewParamIndex','int32');
    hThisProp.FactoryValue=1;



    hThisProp=schema.prop(hThisClass,'ListViewActionCallback','MATLAB callback');
    hThisProp.FactoryValue=[];


    hThisProp=schema.prop(hThisClass,'ListViewCloseCallback','MATLAB callback');
    hThisProp.FactoryValue=[];


    hThisProp=schema.prop(hThisClass,'PushToModelExplorer','bool');
    hThisProp.FactoryValue=false;

    hThisProp=schema.prop(hThisClass,'PushToModelExplorerProperties','string vector');
    hThisProp.FactoryValue={};


    hThisProp=schema.prop(hThisClass,'ResultData','MATLAB array');
    hThisProp.FactoryValue={};


    hThisProp=schema.prop(hThisClass,'LicenseName','string vector');
    hThisProp.FactoryValue={};


    hThisProp=schema.prop(hThisClass,'HasANDLicenseComposition','bool');
    hThisProp.FactoryValue=true;


    hThisProp=schema.prop(hThisClass,'SupportExclusion','bool');
    hThisProp.FactoryValue=false;


    hThisProp=schema.prop(hThisClass,'SupportLibrary','bool');
    hThisProp.FactoryValue=false;



    hThisProp=schema.prop(hThisClass,'CallbackFcnPath','string');
    hThisProp.FactoryValue='';

    hThisProp=schema.prop(hThisClass,'Selected','bool');
    hThisProp.FactoryValue=false;

    hThisProp=schema.prop(hThisClass,'SelectedByTask','bool');
    hThisProp.FactoryValue=false;

    hThisProp=schema.prop(hThisClass,'TitleIsDuplicate','bool');
    hThisProp.FactoryValue=false;

    hThisProp=schema.prop(hThisClass,'TitleIDIsDuplicate','bool');
    hThisProp.FactoryValue=false;

    hThisProp=schema.prop(hThisClass,'Index','int32');
    hThisProp.FactoryValue=0;



