function schema()




    hCreateInPackage=findpackage('Simulink');


    hDeriveFromPackage=findpackage('DAStudio');
    hDeriveFromClass=findclass(hDeriveFromPackage,'Object');


    hThisClass=schema.class(hCreateInPackage,'CSCUI',hDeriveFromClass);





    if isempty(findtype('CSCUI_Enum_CommentChoice'))
        schema.EnumType('CSCUI_Enum_CommentChoice',{
        'None';
        'ByTLC';
        'Specify';});
    end





    hThisProp=schema.prop(hThisClass,'IsAdvanceMode','bool');
    hThisProp.AccessFlags.Init='on';
    hThisProp.FactoryValue=false;

    hThisProp=schema.prop(hThisClass,'IsDirty','bool');
    hThisProp.AccessFlags.Init='on';
    hThisProp.FactoryValue=false;

    hThisProp=schema.prop(hThisClass,'PackageNames','string vector');
    hThisProp.FactoryValue={};

    hThisProp=schema.prop(hThisClass,'CurrPackage','string');
    hThisProp.FactoryValue='';

    hThisProp=schema.prop(hThisClass,'AllDefns','mxArray');
    hThisProp.FactoryValue={[],[]};


    hThisProp=schema.prop(hThisClass,'Index','mxArray');
    hThisProp.FactoryValue=[0,0];



    hThisProp=schema.prop(hThisClass,'MainActiveTab','int');
    hThisProp.FactoryValue=0;

    hThisProp=schema.prop(hThisClass,'CSCActiveSubTab','int');
    hThisProp.FactoryValue=0;

    hThisProp=schema.prop(hThisClass,'RegFilePath','string');
    hThisProp.AccessFlags.PublicSet='off';
    hThisProp.SetFunction=@setFcn_CSCRegFile;
    hThisProp.FactoryValue='';

    hThisProp=schema.prop(hThisClass,'RegFileInfo','mxArray');
    hThisProp.AccessFlags.PublicSet='off';
    hThisProp.FactoryValue={'','',''};

    hThisProp=schema.prop(hThisClass,'InvalidList','mxArray');
    hThisProp.FactoryValue={{},{}};

    hThisProp=schema.prop(hThisClass,'PreviewDefnBak','mxArray');
    hThisProp.FactoryValue={[],[]};





    hThisProp=schema.prop(hThisClass,'TESTING_DONT_ASK_DONT_SAVE','int');
    hThisProp.FactoryValue=0;





    m=schema.method(hThisClass,'getDialogSchema');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','string'};
    s.OutputTypes={'mxArray'};

    m=schema.method(hThisClass,'getSchema_packageSelGrp');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle'};
    s.OutputTypes={'mxArray'};

    m=schema.method(hThisClass,'getSchema_mainTabs');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle'};
    s.OutputTypes={'mxArray'};

    m=schema.method(hThisClass,'assignOrSetEmpty');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','string'};
    s.OutputTypes={'string'};

    m=schema.method(hThisClass,'getSchema_saveGrp');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle'};
    s.OutputTypes={'mxArray'};

    m=schema.method(hThisClass,'getSchema_validGrp');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle'};
    s.OutputTypes={'mxArray'};

    m=schema.method(hThisClass,'getSchema_previewGrp');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle'};
    s.OutputTypes={'mxArray'};

    m=schema.method(hThisClass,'selectPackage');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','mxArray'};
    s.OutputTypes={};

    m=schema.method(hThisClass,'getCurrDefn');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle'};
    s.OutputTypes={'mxArray'};

    m=schema.method(hThisClass,'getCurrCSCDefn');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle'};
    s.OutputTypes={'mxArray'};

    m=schema.method(hThisClass,'getCurrMSDefn');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle'};
    s.OutputTypes={'mxArray'};

    m=schema.method(hThisClass,'setIndex');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','mxArray'};
    s.OutputTypes={};

    m=schema.method(hThisClass,'nameDefn');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','mxArray'};
    s.OutputTypes={};

    m=schema.method(hThisClass,'newDefn');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','string'};
    s.OutputTypes={};

    m=schema.method(hThisClass,'copyDefn');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle'};
    s.OutputTypes={};

    m=schema.method(hThisClass,'upDefn');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle'};
    s.OutputTypes={};

    m=schema.method(hThisClass,'downDefn');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle'};
    s.OutputTypes={};

    m=schema.method(hThisClass,'removeDefn');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle'};
    s.OutputTypes={};

    m=schema.method(hThisClass,'loadCurrPackage');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','string'};
    s.OutputTypes={};

    m=schema.method(hThisClass,'saveCurrPackage');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle'};
    s.OutputTypes={'bool'};

    m=schema.method(hThisClass,'promptSave');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','string'};
    s.OutputTypes={'bool'};

    m=schema.method(hThisClass,'validDefn');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle'};
    s.OutputTypes={};

    m=schema.method(hThisClass,'validateAll');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle'};
    s.OutputTypes={};

    m=schema.method(hThisClass,'instanceComboFcn');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','mxArray','mxArray','mxArray','mxArray'};
    s.OutputTypes={};

    m=schema.method(hThisClass,'show');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle'};
    s.OutputTypes={};

    m=schema.method(hThisClass,'setPropAndDirty');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','mxArray','mxArray','mxArray','mxArray'};
    s.OutputTypes={};


    m=schema.method(hThisClass,'setCSCTypeAttributesPropAndDirty');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','mxArray','mxArray','mxArray','mxArray'};
    s.OutputTypes={};

    m=schema.method(hThisClass,'prepareUIStringForCode','Static');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'ustring'};
    s.OutputTypes={'ustring'};

    m=schema.method(hThisClass,'prepareCodeStringForUI','Static');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'ustring'};
    s.OutputTypes={'ustring'};

    m=schema.method(hThisClass,'disableWidgets','Static');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'mxArray'};
    s.OutputTypes={'mxArray'};

    m=schema.method(hThisClass,'isCSCRegFileReadOnly');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle'};
    s.OutputTypes={'bool'};




    function value=setFcn_CSCRegFile(obj,value)
        [filepath,filename,fileext]=fileparts(value);
        assert(strcmp(filename,'csc_registration'));
        obj.RegFileInfo={filepath,filename,fileext};


