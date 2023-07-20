

function[pslinkcc,configSet,configSetRefVarName]=getConfigComp(modelH)

    narginchk(1,1);

    [configSet,origConfigSet]=getMdlConfigSet(modelH);
    configSetRefVarName='';

    if isa(configSet,'pslink.ConfigComp')
        pslinkcc=configSet;
    else
        if~isa(configSet,'Simulink.ConfigSet')
            error('pslink:badConfigSet',message('polyspace:gui:pslink:badConfigSet').getString());
        end
        if isa(origConfigSet,'Simulink.ConfigSetRef')
            if~strcmpi(origConfigSet.SourceResolved,'on')
                error(message('polyspace:gui:pslink:badConfigSetRef',...
                origConfigSet.Name,origConfigSet.WSVarName))
            end
            configSetRefVarName=origConfigSet.WSVarName;
        end
        pslinkcc=configSet.getComponent(message('polyspace:gui:pslink:configCompPolyspaceTab').getString());
        if isempty(pslinkcc)

            pslinkcc=configSet.getComponent('Polyspace Model Link');
        end
    end


