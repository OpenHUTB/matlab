function out=isPublicFcn(blk,fcnName)




    defFcnInfo='';
    if~isnumeric(blk)
        blk=get_param(blk,'handle');
    end
    fcns=Simulink.FunctionGraphCatalog(blk);
    for i=1:length(fcns)
        fcn=fcns(i);
        if strcmp(fcn.name,fcnName)
            defFcnInfo=fcn;
            break;
        end
    end
    if~isempty(defFcnInfo)
        if~strcmp(get_param(defFcnInfo.handle,'BlockType'),'ModelReference')
            mdlName=get_param(bdroot(defFcnInfo.handle),'name');
            if strcmp(get_param(defFcnInfo.handle,'parent'),mdlName)



                trigPort=find_system(defFcnInfo.handle,...
                'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
                'FollowLinks','on','LookUnderMasks','all',...
                'BlockType','TriggerPort');
                if strcmp(get_param(trigPort,'FunctionVisibility'),'global')

                    out=false;
                elseif strcmp(get_param(trigPort,'FunctionVisibility'),'scoped')

                    out=true;
                else
                    out=false;
                end
            else

                out=false;
            end
        else

            out=false;
        end
    else

        out=false;
    end
end
