function[newModel,newTopModel,excludeBlocks]=saveSystemAndMdlRefs(mdlName,topModel,testModelExtn,extend,excludeBlocks)




    if nargin<2
        topModel=mdlName;
    end
    if nargin<3
        testModelExtn='';
    end
    if nargin<4
        extend='append';
    end
    if nargin<5
        excludeBlocks={};
    end








    newModel='';
    newTopModel='';
    mainMdlObj=get_param(topModel,'Object');
    mainMdlObj.refreshModelBlocks();

    modelsAlreadySaved={};



    [mdlrefList,mdlrefBlks]=find_mdlrefs(topModel,'MatchFilter',@Simulink.match.internal.filterOutCodeInactiveVariantSubsystemChoices);
    for i=1:length(mdlrefList)
        load_system(mdlrefList{i});

        if strcmpi(extend,'append')
            newMdl=[mdlrefList{i},testModelExtn];
        elseif strcmpi(extend,'remove')
            index=strfind(mdlrefList{i},testModelExtn);
            if~isempty(index)&&strcmp(mdlrefList{i}(index(end):end),testModelExtn)
                newMdl=mdlrefList{i}(1:index(end)-1);
                if isempty(newMdl)
                    error(['Any model cannot have the name ',testModelExtn]);
                end
            else
                newMdl=mdlrefList{i};
            end
        else
            newMdl=mdlrefList{i};
        end

        if strcmp(mdlrefList{i},mdlName)
            newModel=newMdl;
        end
        if strcmp(mdlrefList{i},topModel)
            newTopModel=newMdl;
        end



        load_system(mdlrefList{i});


        aBlocks=find_system(mdlrefList{i},'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'LookUnderMasks','all','Type','Block');
        for j=1:length(excludeBlocks)
            for k=1:length(aBlocks)
                if strcmp(aBlocks{k},excludeBlocks{j})
                    [~,blockName]=Simulink.SimplifyModel.getSubsystemName(aBlocks{k});
                    excludeBlocks{j}=[newMdl,'/',blockName];
                    break;
                end
            end
        end

        x=which(mdlrefList{i});
        [~,~,ext]=fileparts(x);
        if~strcmp(newMdl,mdlrefList{i})
            close_system(newMdl,0);
        end
        save_system(mdlrefList{i},[newMdl,ext]);
        modelsAlreadySaved{end+1}=mdlrefList{i};%#ok<AGROW>


        for j=1:length(mdlrefBlks)
            parentModel=Simulink.SimplifyModel.getSubsystemName(mdlrefBlks{j});
            if~ismember(parentModel,modelsAlreadySaved)
                load_system(parentModel);
                if strcmp(get_param(mdlrefBlks{j},'ModelName'),mdlrefList{i})
                    set_param(mdlrefBlks{j},'ModelName',newMdl);
                    refMdlObj=get_param(parentModel,'Object');
                    refMdlObj.refreshModelBlocks();
                end
            end
        end
    end








