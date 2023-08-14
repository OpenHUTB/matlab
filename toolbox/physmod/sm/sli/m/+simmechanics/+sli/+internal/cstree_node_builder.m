function[treeNode]=cstree_node_builder(fullDirName)












    treeNode=[];

    while(fullDirName(end)=='/')||(fullDirName(end)=='\')
        fullDirName=fullDirName(1:end-1);
    end
    [dirPath,dirName]=fileparts(fullDirName);
    if isempty(dirPath)
        dirPath=pwd;
    end



    if(exist(dirPath,'dir')&&(dirName(1)=='+'))
        treeNode=pm.util.CompoundNode(fullDirName);
        treeNodeFile=fullfile(fullDirName,'configset');

        dirName=dirName(2:end);
        dirName(1)=upper(dirName(1));

        if exist(treeNodeFile,'file')
            setupFunctionH=pm.util.function_handle(treeNodeFile);
            try
                libNode.Info.SourceFile=treeNodeFile;

                treeNodeInfo=feval(setupFunctionH);
                treeNode.Info.Name=treeNodeInfo.Name;
                treeNode.Info.Description=treeNodeInfo.Description;
            catch excp
                pm_error('mech2:local:cptreenodebuilder:InvalidTreeNodeSpecFile',excp.message);
            end

        else


            treeNode.Info.Name=dirName;
            treeNode.Info.Description=dirName;
        end
    end

end

