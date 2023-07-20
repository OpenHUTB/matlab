function setupSharedInterfaces(bh,top,ref,mode)




    refIsAComposition=strcmpi(get_param(ref,'SimulinkSubDomain'),'Architecture')||...
    strcmpi(get_param(ref,'SimulinkSubDomain'),'SoftwareArchitecture');
    topDDName=get_param(top,'DataDictionary');

    if(~isempty(topDDName))


        if refIsAComposition
            refModel=systemcomposer.arch.Model(ref);

            if get_param(ref,'BlockDiagramType')~="subsystem"
                linkDictionary(refModel,topDDName);
            end
        else

            if get_param(ref,'BlockDiagramType')~="subsystem"
                set_param(ref,'DataDictionary',topDDName);
            end
        end

    elseif(systemcomposer.internal.modelHasLocallyScopedInterfaces(get_param(top,'Handle')))
        if(strcmp(mode,'saveAsModel'))
            baseObj=message('SystemArchitecture:API:UnableToSaveComponentAsModelBecauseOfLocalInterfaces',get_param(bh,'Name'),ref,top);
            baseException=MSLException([],baseObj);
        else
            assert(strcmp(mode,'createSLBehavior'));
            baseObj=message('SystemArchitecture:API:UnableToCreateSLBehaviorForComponentBecauseOfLocalInterfaces',ref,get_param(bh,'Name'),top);
            baseException=MSLException([],baseObj);
        end
        throw(baseException);
    end

end


