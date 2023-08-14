function searchDirectories=getSearchDirectoriesFromPath()

    searchDirectories=regexp(matlabpath,pathsep,'split');
    filterIndices=startsWith(searchDirectories,matlabroot,'IgnoreCase',ispc);
    searchDirectories(filterIndices)=[];