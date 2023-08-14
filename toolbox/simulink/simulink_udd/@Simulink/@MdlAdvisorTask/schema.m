function schema




    mlock;


    hCreateInPackage=findpackage('Simulink');


    hThisClass=schema.class(hCreateInPackage,'MdlAdvisorTask');


    hThisProp=schema.prop(hThisClass,'Title','ustring');
    hThisProp.FactoryValue='';



    hThisProp=schema.prop(hThisClass,'TitleTips','ustring');
    hThisProp.FactoryValue='';


    hThisProp=schema.prop(hThisClass,'CheckTitleIDs','string vector');
    hThisProp.FactoryValue={};




    hThisProp=schema.prop(hThisClass,'Visible','bool');
    hThisProp.FactoryValue=true;
    hThisProp=schema.prop(hThisClass,'Enable','bool');
    hThisProp.FactoryValue=true;
    hThisProp=schema.prop(hThisClass,'Value','bool');
    hThisProp.FactoryValue=false;




    hThisProp=schema.prop(hThisClass,'TitleID','string');
    hThisProp.FactoryValue='';



    hThisProp=schema.prop(hThisClass,'CallbackFcnPath','string');
    hThisProp.FactoryValue='';

    hThisProp=schema.prop(hThisClass,'Selected','bool');
    hThisProp.FactoryValue=false;

    hThisProp=schema.prop(hThisClass,'TitleIsDuplicate','bool');
    hThisProp.FactoryValue=false;

    hThisProp=schema.prop(hThisClass,'TitleIDIsDuplicate','bool');
    hThisProp.FactoryValue=false;

    hThisProp=schema.prop(hThisClass,'Index','int32');
    hThisProp.FactoryValue=0;

    hThisProp=schema.prop(hThisClass,'CheckIndex','string vector');
    hThisProp.FactoryValue={};



