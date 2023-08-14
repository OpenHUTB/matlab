function updatedTree=updateDisplayIcons(tree)

    updatedtree=tree;
    for i=1:length(updatedtree)
        if updatedtree{i}.MACIndex<0
            updatedtree{i}.iconUri='../../../../toolbox/simulink/simulink/modeladvisor/resources/resolveSymbols.svg';
            updatedtree=updateFolderIcons(tree{i},updatedtree);
        elseif updatedtree{i}.MACIndex==0
            updatedtree{i}.iconUri='../../../../toolbox/simulink/simulink/modeladvisor/resources/folder_16.png';
        end

    end
    updatedtree{1}.iconUri='../../../../toolbox/simulink/simulink/modeladvisor/resources/mace.png';

    updatedTree=updatedtree;

end

function updatedTree=updateFolderIcons(check,tree)

    if~isnan(check.parent)
        folderIndex=cellfun(@(x)strcmp(x.id,check.parent),tree,'UniformOutput',1);
        tree{folderIndex}.iconUri='../../../../toolbox/simulink/simulink/modeladvisor/resources/folder_failed_16.png';
        tree{folderIndex}.MACIndex=-3;
        parentFolder=tree{folderIndex};
        updatedTree=updateFolderIcons(parentFolder,tree);
    else
        updatedTree=tree;
    end

end