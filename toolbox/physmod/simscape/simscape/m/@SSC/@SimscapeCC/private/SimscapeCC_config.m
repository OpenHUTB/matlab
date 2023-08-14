function configData=SimscapeCC_config















    persistent fConfigData

    if isempty(fConfigData)

        msgStem='physmod:simscape:simscape:SSC:SimscapeCC:';





        msgPrfx=[msgStem,'subcomponent:'];


        theList(1)=struct('ProductName',SSC.SimscapeCC.getComponentName,...
        'TabName_msgid',[msgPrfx,'general:tabname'],...
        'TreeName_msgid',[msgPrfx,'general:treename'],...
        'CustomComponent','SSC.SimscapeCC',...
        'ExistsFcn','ssc_private',...
        'LicenseName','Simscape');

        theList(2)=struct('ProductName','SimscapeMultibody',...
        'TabName_msgid',[msgPrfx,'SimscapeMultibody:tabname'],...
        'TreeName_msgid',[msgPrfx,'SimscapeMultibody:treename'],...
        'CustomComponent','simmechanics.ConfigurationSet',...
        'ExistsFcn','sm_lib',...
        'LicenseName','SimMechanics');


        fConfigData.SubComponents=theList;

        fConfigData.SlMenu.Name_msgid=[msgStem,'menu:name'];

        fConfigData.internal.getDialogSchemaError=[msgStem,'internal:getDialogSchema'];

    end

    configData=fConfigData;



