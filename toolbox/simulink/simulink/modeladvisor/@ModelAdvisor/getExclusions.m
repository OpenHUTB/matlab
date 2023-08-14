function exclusionObjs=getExclusions(ID,mdladvobj)




    system=mdladvobj.system;
    exclusionObjs=[];
    exclusions=[];
    if ishandle(system)
        system=getfullname(system);
    end
    system=regexprep(system,sprintf('\n'),' ');
    exclusions=ModelAdvisor.ExclusionManager('get',system);
    if~isempty(mdladvobj.exclusionCellArray)
        exclusions=[exclusions,mdladvobj.exclusionCellArray];
    end
    for i=1:length(exclusions)
        exCheckIDs=exclusions(i).CheckIDs;
        for j=1:length(exCheckIDs)
            if strcmp(exCheckIDs{j},ID)||~isempty(regexp(ID,exCheckIDs{j}))
                exclusionObjs=[exclusionObjs,exclusions(i)];
                break;
            end
        end
    end

