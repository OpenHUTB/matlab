
function[params,groups,FC]=get_simmechanics_ConfigurationSet_data(cs)

    compStatus=0;
    params={};

    groups={};


    g_schema=configset.layout.custom.getSimscapeMultibodyText(cs,'web');
    groups{end+1}={'SimscapeMultiBodyTopLevel',{'schema',g_schema}};




