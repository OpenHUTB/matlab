



function excluded_sysclone=checkmachineParentedData(result,mdls,excluded_sysclone,allFlag)
    hasStateflowCandidates=false;
    for i=1:length(result)
        for j=1:length(result{i})
            fname=result{i}{j};
            if isKey(excluded_sysclone,fname)
                continue;
            end
            if~strcmp(get_param(fname,'Type'),'block_diagram')&&strcmp(get_param(fname,'BlockType'),'SubSystem')&&strcmp(get_param(fname,'SFBlockType'),'Chart')
                hasStateflowCandidates=true;
                break;
            end
        end
        if hasStateflowCandidates
            break;
        end
    end



    if~hasStateflowCandidates
        return;
    end

    flag=hasMachineParentedData(mdls);

    if~flag
        return;
    end

    disp(['model ',mdls{1},' includes machine parented data, will skip all stateflow clones replacement']);

    for i=1:length(result)
        for j=1:length(result{i})
            fname=result{i}{j};
            if~strcmp(get_param(fname,'Type'),'block_diagram')&&strcmp(get_param(fname,'SFBlockType'),'Chart')
                disp([fname,' is excluded.']);
                if allFlag
                    excluded_sysclone(fname)='Model and stateflow clones contain machine parented data.';
                else
                    excluded_sysclone(result{i}{1})='Model and stateflow clones contain machine parented data.';
                    break;
                end
            end
        end
    end
end

function flag=hasMachineParentedData(mdls)
    flag=false;
    for i=1:length(mdls)
        mdlname=mdls{i};
        rt=sfroot;
        machineH=rt.find('-isa','Stateflow.Machine','Name',mdlname);
        if isempty(machineH)
            continue;
        end
        machineParentedData=machineH.find('-isa','Stateflow.Data','-depth',1);
        if~isempty(machineParentedData)
            flag=true;
            return;
        end
    end
end