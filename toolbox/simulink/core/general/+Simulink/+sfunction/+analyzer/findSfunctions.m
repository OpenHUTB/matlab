









function[sfunctions,sfuncBlockMap,filteredBlocks,sfuncBlockModelMap]=findSfunctions(Input)
    Input=convertStringsToChars(Input);
    isFile=false;
    if exist(Input,'file')
        [~,model,~]=fileparts(Input);
        isFile=true;
        target=model;
    else
        cc=strsplit(Input,'/');
        model=cc{1};
        target=Input;
    end

    try
        isLoaded=bdIsLoaded(model);
    catch ss
        me=MException('Simulink:SFunctions:ComplianceCheckInvalidInput',DAStudio.message('Simulink:SFunctions:ComplianceCheckInvalidInput'));
        me=addCause(me,ss);
        throw(me);
    end
    finishup=onCleanup(@()exitCleanupFun(model,isLoaded));
    if~isLoaded
        try
            if isFile
                load_system(Input)
            else
                load_system(model);
            end
        catch me
            error(me.message);
        end
    end

    sfuncBlockMap=containers.Map();
    sfuncBlockModelMap=containers.Map();


    try


        sfuncBlocks=find_system(target,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'LookUnderMasks','all','FollowLinks','on','BlockType','S-Function');
    catch ss
        me=MException('Simulink:SFunctions:ComplianceCheckInvalidInput',DAStudio.message('Simulink:SFunctions:ComplianceCheckInvalidInput'));
        me=addCause(me,ss);
        throw(me);
    end


    libdata=libinfo(model,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices);
    sfunctions={};
    filteredBlocks={};
    if~isempty(sfuncBlocks)
        for i=1:numel(sfuncBlocks)
            parentblk=get_param(sfuncBlocks{i},'Parent');
            if~slprivate('is_stateflow_based_block',parentblk)
                sfcnName=get_param(sfuncBlocks{i},'FunctionName');
                sfcnPath=which(sfcnName);
                filterPath=fullfile(matlabroot,'toolbox');
                if~contains(sfcnPath,filterPath)||contains(sfcnPath,fullfile(matlabroot,'toolbox','simulink','simdemos','simfeatures'))
                    sfunctions=[sfunctions,{sfcnName}];


                    re='';
                    repath='';
                    if~isempty(libdata)
                        for t=1:numel(libdata)
                            if contains(sfuncBlocks{i},libdata(t).Block)&&isequal(libdata(t).LinkStatus,'resolved')
                                re=t;
                                repath=sfuncBlocks{i}(length(libdata(t).Block)+1:end);
                                break;
                            end
                        end
                    end
                    if~isempty(re)
                        if isempty(repath)
                            sfunBlocks{i}=libdata(re).ReferenceBlock;
                        else
                            sfuncBlocks{i}=[libdata(re).ReferenceBlock,repath];
                        end
                        sfuncBlockModelMap(sfuncBlocks{i})=libdata(re).Library;
                    else
                        sfuncBlockModelMap(sfuncBlocks{i})=model;
                    end
                    sfuncBlockMap(sfcnName)=sfuncBlocks{i};
                else
                    filteredBlocks=[filteredBlocks,{sfuncBlocks{i}}];
                end
            else
                filteredBlocks=[filteredBlocks,{sfuncBlocks{i}}];
            end
        end
        sfunctions=unique(sfunctions);

    end
end
function exitCleanupFun(model,isLoaded)
    if~isLoaded
        close_system(model,0);
    end
end
