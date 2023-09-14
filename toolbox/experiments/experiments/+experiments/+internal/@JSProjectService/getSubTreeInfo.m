function fileInfo=getSubTreeInfo(this,prj,filePath)
    fileInfo=[];

    parentPath=fileparts(filePath);
    assert(isKey(this.mFilePathToId,parentPath))
    parentId=this.mFilePathToId(parentPath);

    visitDirectoriesRecursive(filePath,parentId);

    function visitDirectoriesRecursive(filePath,parentId)
        [valid,id]=addToFileInfo(filePath,parentId);
        if isfolder(filePath)&&valid
            d=dir(filePath);
            for idx=1:length(d)
                currd=d(idx);

                isMetaDir=strcmp(currd.name,'.')||...
                strcmp(currd.name,'..');

                if~isMetaDir
                    visitDirectoriesRecursive(fullfile(currd.folder,currd.name),id)
                end
            end
        end
    end

    function[valid,id]=addToFileInfo(fullPath,parentId)
        valid=true;
        [~,label,ext]=fileparts(fullPath);

        type=prj.getType(fullPath);
        if isempty(type)
            valid=false;
            id='';
            return;
        end
        [isExp,expType]=this.isValidExperimentFile(fullPath);
        if isExp


            type='Experiment';
        end

        isDirectory=isfolder(fullPath);
        id=this.getIdForFile(fullPath);

        info=struct(...
        'id',id,...
        'parent',parentId,...
        'label',label,...
        'ext',ext,...
        'isDirectory',isDirectory,...
        'inProjectPath',prj.isInProjectPath(fullPath),...
        'path',fullPath,...
        'type',type,...
        'expType',expType);

        if isempty(fileInfo)
            fileInfo=info;
        else
            fileInfo(end+1)=info;
        end
    end
end
