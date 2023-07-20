function[slcovcc,configSet,configSetRefVarName]=cv_configcomp_get(modelH)


    narginchk(1,1);

    modelObj=get_param(modelH,'Object');
    origConfigSet=modelObj.getActiveConfigSet();
    configSet=configset.util.getSource(origConfigSet);

    configSetRefVarName='';

    if isa(configSet,'SlCovCC.ConfigComp')
        slcovcc=configSet;
    else
        if~isa(configSet,'Simulink.ConfigSet')
            error(message('Slvnv:simcoverage:cv_configcomp_get:InvalidConfSet'));
        end
        if isa(origConfigSet,'Simulink.ConfigSetRef')
            if~strcmp(origConfigSet.SourceResolved,'on')
                error(message('Slvnv:simcoverage:cv_configcomp_get:InvalidConfSetRef',origConfigSet.Name,origConfigSet.WSVarName));
            end
            configSetRefVarName=origConfigSet.WSVarName;
        end
        components=configSet.Components;
        names=get(components,'Name');
        slcovcc=components(strcmp(names,'Simulink Coverage'));
    end
end
