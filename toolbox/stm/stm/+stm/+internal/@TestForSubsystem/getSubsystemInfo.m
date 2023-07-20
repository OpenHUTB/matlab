function[subModel,topModel]=getSubsystemInfo(subsys,topModelName)







    [splitStrings,matches]=strsplit(subsys,'/');
    if isempty(matches)


        subModel=subsys;
    else
        subModel=splitStrings(1);
    end


    try
        Simulink.harness.internal.validateOwnerHandle(subModel.char,get_param(subsys,'Handle'));
    catch
        error(message('stm:general:NotAValidSubsystemObject'));
    end

    topModel=topModelName;
    if topModelName==""
        topModel=subModel;
    end


    if strcmp(topModelName,subModel)~=1
        [modelRefs,~]=find_mdlrefs(topModel,'AllLevels',true,'MatchFilter',@Simulink.match.activeVariants);
        subModelFound=false;
        for i=1:length(modelRefs)
            if strcmp(modelRefs{i},subModel)==1
                subModelFound=true;
                break;
            end
        end
        if~subModelFound
            error(message('stm:general:SubsystemCanNotBeFoundInTopModel'));
        end
    end

end

