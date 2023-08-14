function[selectedFilter,isCancelled]=promptFilterSelection(this)




    selectedFilter=[];
    isCancelled=true;

    filterObjects={this.filters.filterObj};
    filterNames=cellfun(@(fobj)fobj.filterName,filterObjects,'UniformOutput',false);

    filterEntries=[...
    filterNames,...
    DAStudio.message('Slvnv:simcoverage:cvresultsexplorer:PromptFilterSelectionCreateText')];

    [option,ok]=listdlg(...
    'Name',DAStudio.message('Slvnv:simcoverage:cvresultsexplorer:PromptFilterSelectionDlgTitle'),...
    'PromptString',DAStudio.message('Slvnv:simcoverage:cvresultsexplorer:PromptFilterSelectionDlgText'),...
    'SelectionMode','single',...
    'ListSize',[300,100],...
    'InitialValue',length(filterEntries)-1,...
    'ListString',filterEntries);

    if ok
        isCancelled=false;
        if(option<=length(filterObjects))
            selectedFilter=filterObjects{option};
        end
    end

