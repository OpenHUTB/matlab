function result=getModelHierarchy(this)
    if~bdIsLoaded(this.rootmodel)
        error('Advisor:ui:advisor_model_not_loaded',DAStudio.message('Advisor:ui:advisor_model_not_loaded',this.rootmodel));
    end


    modelObj=get_param(this.rootmodel,'Object');

    if(modelObj==slroot)
        children=modelObj.getHierarchicalChildren;
        treeItems={'Simulink Root',{}};
        for u=1:length(children)
            if isa(children(u),'Simulink.BlockDiagram')&&~strcmpi(children(u).BlockDiagramType,'library')
                substruct=convertSystemHierarchyToTreeFindSys(children(u).Name);
                treeItems{2}{end+1}=substruct{1};

                if(length(substruct)>1)
                    treeItems{2}{end+1}=substruct{2};
                end
            end
        end
    else
        treeItems=convertSystemHierarchyToTreeFindSys(this.rootmodel);
    end


    result=treeItems;
end

function treeItems=convertSystemHierarchyToTreeFindSys(rootSystemName)


    childSubsystem=find_system(rootSystemName,'SearchDepth',1,...
    'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
    'LookUnderMasks','all','FollowLinks','on',...
    'BlockType','SubSystem');


    if~strcmp(bdroot(rootSystemName),rootSystemName)
        childSubsystem=childSubsystem(2:end);
    end
    treeItems=getTreeItemStruct(rootSystemName);
    if~isempty(childSubsystem)
        for i=1:length(childSubsystem)
            treeItems=[treeItems,convertSystemHierarchyToTreeFindSys(childSubsystem{i})];%#ok<AGROW>
        end
    end
end

function data=getTreeItemStruct(item)
    data.id=Simulink.ID.getSID(item);
    data.label=strrep(get_param(item,'Name'),newline,' ');
    parent=get_param(item,'Parent');
    if~isempty(parent)
        data.parent=Simulink.ID.getSID(parent);
    else
        data.parent=[];
    end
    if isempty(data.parent)
        data.parent=NaN;
    end
end
