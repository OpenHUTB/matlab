function resultJSON=loadModelName(modelName)

    modelName=bdroot(modelName);

    open(modelName);






    modelObj=get_param(modelName,'Object');
    treeItems=getTree(modelObj,1);
    result=struct('success',true,'message',jsonencode(struct('title','','content','')),'warning',false,'filepath','','value',jsonencode(treeItems));
    resultJSON=jsonencode(result);
end


function treeItems=getTree(modelObj,showLibraries)
    if(modelObj==slroot)
        children=modelObj.getHierarchicalChildren;
        treeItems={'Simulink Root',{}};
        for u=1:length(children)
            if isa(children(u),'Simulink.BlockDiagram')&&...
                (showLibraries||~strcmpi(children(u).BlockDiagramType,'library'))
                substruct=convertSystemHierarchyToTreeFindSys(children(u).Name);
                treeItems{2}{end+1}=substruct{1};

                if(length(substruct)>1)
                    treeItems{2}{end+1}=substruct{2};
                end
            end
        end
    else
        treeItems=convertSystemHierarchyToTreeFindSys(modelObj.Name);
    end
end

function treeItems=convertSystemHierarchyToTreeFindSys(rootSystemName)
    childSubsystem=find_system(rootSystemName,'SearchDepth',1,...
    'LookUnderMasks','all','FollowLinks','on','BlockType','SubSystem');
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
    data.id=item;
    data.label=replaceCarriageReturnWithSpace(get_param(item,'Name'));
    data.fullname=replaceCarriageReturnWithSpace(getfullname(item));
    data.parent=get_param(item,'Parent');
    if isempty(data.parent)
        data.parent=NaN;
    end
end

function output=replaceCarriageReturnWithSpace(input)
    output=strrep(input,newline,' ');
end
