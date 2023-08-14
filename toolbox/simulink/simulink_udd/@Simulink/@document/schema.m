function schema






    hDeriveFromPackage=findpackage('DAStudio');
    hDeriveFromClass=findclass(hDeriveFromPackage,'Object');
    hCreateInPackage=findpackage('Simulink');

    hThisClass=schema.class(hCreateInPackage,'document',hDeriveFromClass);


    hThisProp=schema.prop(hThisClass,'documentName','ustring');
    hThisProp.FactoryValue='';

    hThisProp=schema.prop(hThisClass,'displayDocument','ustring');
    hThisProp.FactoryValue='';

    hThisProp=schema.prop(hThisClass,'displayLabel','string');
    hThisProp.FactoryValue='';

    hThisProp=schema.prop(hThisClass,'Modified','string');
    hThisProp.FactoryValue='';
    hThisProp.AccessFlags.PublicSet='off';

    hThisProp=schema.prop(hThisClass,'Size','double');
    hThisProp.FactoryValue=0;
    hThisProp.AccessFlags.PublicSet='off';

    hThisProp=schema.prop(hThisClass,'generateBacklink','bool');
    hThisProp.FactoryValue=false;

    hThisProp=schema.prop(hThisClass,'SearchString','string');
    hThisProp.FactoryValue='';

    hThisProp=schema.prop(hThisClass,'ExplicitShow','bool');
    hThisProp.FactoryValue=false;

    hThisProp=schema.prop(hThisClass,'Title','string');
    hThisProp.FactoryValue='';

    hThisProp=schema.prop(hThisClass,'HelpMethod','string');
    hThisProp.FactoryValue='';

    hThisProp=schema.prop(hThisClass,'Model','string');
    hThisProp.FactoryValue='';

    hThisProp=schema.prop(hThisClass,'ModelFileNameAtBuild','string');
    hThisProp.FactoryValue='';

    hThisProp=schema.prop(hThisClass,'BuildDir','ustring');
    hThisProp.FactoryValue='';

    hThisProp=schema.prop(hThisClass,'CheckoutLicenseDuringLoad','bool');
    hThisProp.FactoryValue=false;

    hThisProp=schema.prop(hThisClass,'CleanupAfterShow','bool');
    hThisProp.FactoryValue=false;

    hThisProp=schema.prop(hThisClass,'IsCodeReportDocumentStyle','bool');
    hThisProp.FactoryValue=false;

    hThisProp=schema.prop(hThisClass,'IsTestHarness','bool');
    hThisProp.FactoryValue=false;

    hThisProp=schema.prop(hThisClass,'HarnessName','string');
    hThisProp.FactoryValue='';

    hThisProp=schema.prop(hThisClass,'HarnessOwner','string');
    hThisProp.FactoryValue='';

    hThisProp=schema.prop(hThisClass,'OwnerFileName','ustring');
    hThisProp.FactoryValue='';


    m=schema.method(hThisClass,'getDisplayLabel');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle'};
    s.OutputTypes={'ustring'};

    m=schema.method(hThisClass,'getDisplayIcon');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle'};
    s.OutputTypes={'string'};

    m=schema.method(hThisClass,'closeCallback');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle'};
    s.OutputTypes={};

    m=schema.method(hThisClass,'getDialogSchema');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','string'};
    s.OutputTypes={'mxArray'};

    m=schema.method(hThisClass,'exploreAction');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle'};
    s.OutputTypes={};

    m=schema.method(hThisClass,'getPreferredProperties');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle'};
    s.OutputTypes={'string vector'};

    m=schema.method(hThisClass,'parseFileURL','static');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'ustring'};
    s.OutputTypes={'ustring','string','string'};

    m=schema.method(hThisClass,'fileURL','static');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'ustring','string'};
    s.OutputTypes={'ustring'};
