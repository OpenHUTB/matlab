function[projectDirPath,...
    projectDirArray,...
    projectDirRelPath,...
    projectDirReverseRelPath]=get_cgxe_proj(modelName,srcOrInfo)

    rootDir=get_cgxe_proj_root();

    projectDirArray={rootDir,'slprj','_cgxe',modelName,srcOrInfo};
    projectDirPath=fullfile(projectDirArray{:});
    projectDirRelPath=fullfile(projectDirArray{2:end});

    projectDirReverseRelPath='';
    for i=1:length(projectDirArray)-1
        projectDirReverseRelPath=[projectDirReverseRelPath,'..',filesep];%#ok<AGROW>
    end
