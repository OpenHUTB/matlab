function[artifact,name]=getSourceName(source)

    [~,name,ext]=fileparts(source.artifactUri);
    artifact=[name,ext];

    switch source.domain
    case 'linktype_rmi_simulink'
        [~,modelName,~]=fileparts(source.artifactUri);
        sid=[modelName,source.id];
        name=get_param(sid,'name');
    case 'linktype_rmi_testmgr'
        name=stm.internal.getTestCaseNameFromUUIDAndTestFile(source.id,...
        source.artifactUri);
    otherwise
        name=source.id;
    end
end

