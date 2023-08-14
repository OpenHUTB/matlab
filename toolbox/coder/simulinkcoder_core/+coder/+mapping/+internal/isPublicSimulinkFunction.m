function[isPublic,isMulti,definedInReferenceMdl,details]=isPublicSimulinkFunction(blk)


















    isPublic=false;
    isMulti=false;
    details={};
    definedInReferenceMdl=false;

    if ischar(blk)||isstring(blk)
        blk=get_param(blk,'handle');
    end
    if loc_isSlFcn(blk)

        fcns=Simulink.FunctionGraphCatalog(blk);
        prototype=get_param(blk,'FunctionPrototype');
        defFcnInfo='';

        for i=1:length(fcns)
            fcn=fcns(i);
            if(ischar(fcn.prototypes)||isstring(fcn.prototypes))...
                &&strcmp(fcn.prototypes,prototype)
                defFcnInfo=fcn;
                break;
            end

            if strcmp(get_param(fcn.handle,'BlockType'),'ModelReference')
                if isequal(get_param(fcn.handle,'ProtectedModel'),'on')
                    mdlFileName=get_param(fcn.handle,'ModelFile');
                    [~,mdlName,~]=fileparts(mdlFileName);
                else
                    mdlName=get_param(fcn.handle,'ModelName');
                end
                mdlBlockName=get_param(fcn.handle,'Name');
                modPrototype=strrep(fcn.prototypes,mdlBlockName,mdlName);
                if(strcmp(modPrototype,prototype))
                    defFcnInfo=fcn;
                    break;
                end
            end
        end
        if~isempty(defFcnInfo)
            [isPublic,isMulti,definedInReferenceMdl,details]=loc_isPublic(defFcnInfo);
        else

            isPublic=false;
            isMulti=false;
        end
    end
end

function isSLFcn=loc_isSlFcn(blk)
    isSLFcn=strcmp(get_param(blk,'BlockType'),'FunctionCaller')||...
    (strcmp(get_param(blk,'BlockType'),'SubSystem')&&...
    strcmp(get_param(blk,'SystemType'),'SimulinkFunction'));
end

function[isPublic,isMulti,definedInReferenceMdl,details]=loc_isPublic(fcn)
    details={};
    if~strcmp(get_param(fcn.handle,'BlockType'),'ModelReference')

        definedInReferenceMdl=false;
        mdlName=get_param(bdroot(fcn.handle),'name');
        if strcmp(get_param(fcn.handle,'parent'),mdlName)



            trigPort=find_system(fcn.handle,...
            'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
            'BlockType','TriggerPort');
            if strcmp(get_param(trigPort,'FunctionVisibility'),'global')

                isPublic=false;
                isMulti=false;
            elseif strcmp(get_param(trigPort,'FunctionVisibility'),'scoped')

                mdlRefMultiInstance=strcmp(get_param(mdlName,'ModelReferenceNumInstancesAllowed'),'Multi');
                mdlRefZeroInstance=strcmp(get_param(mdlName,'ModelReferenceNumInstancesAllowed'),'Zero');
                topBuildMultiInstance=strcmp(get_param(mdlName,'CodeInterfacePackaging'),'Reusable function');
                details={};
                if topBuildMultiInstance
                    details{end+1}='TopBuild';
                end
                if mdlRefMultiInstance
                    details{end+1}='MdlRefBuild';
                end
                if mdlRefZeroInstance
                    details{end+1}='ZeroMdlRef';
                end
                isPublic=true;
                if mdlRefMultiInstance||topBuildMultiInstance
                    isMulti=true;
                else
                    isMulti=false;
                end
            else
                isPublic=false;
                isMulti=false;
            end
        else

            isPublic=false;
            isMulti=false;
        end
    else

        definedInReferenceMdl=true;
        if~isempty(strfind(fcn.prototypes,'.'))

            if isequal(get_param(fcn.handle,'ProtectedModel'),'on')
                refMdlFileName=get_param(fcn.handle,'ModelFile');
                [~,refMdl,~]=fileparts(refMdlFileName);
                cs=Simulink.ProtectedModel.getConfigSet(refMdl);
            else
                refMdl=get_param(fcn.handle,'ModelName');
                sr=slroot;
                if~sr.isValidSlObject(refMdl)
                    load_system(refMdl);
                    oc_load=onCleanup(@()close_system(refMdl));
                end
                cs=getActiveConfigSet(refMdl);
            end
            mdlRefMultiInstance=strcmp(get_param(cs,'ModelReferenceNumInstancesAllowed'),'Multi');
            topBuildMultiInstance=strcmp(get_param(cs,'CodeInterfacePackaging'),'Reusable function');
            details={};
            if topBuildMultiInstance
                details{end+1}='TopBuild';
            end
            if mdlRefMultiInstance
                details{end+1}='MdlRefBuild';
            end
            isPublic=true;
            isMulti=mdlRefMultiInstance;
        else

            isPublic=false;
            isMulti=false;
        end
    end
end


