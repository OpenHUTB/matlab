function fileList=updateLoadedFileList()







    if slreq.data.ReqData.exists()
        reqData=slreq.data.ReqData.getInstance();
        loadedReqSets=reqData.getLoadedReqSets();
        reqFileName=arrayfun(@(rset)rset.name,loadedReqSets,'UniformOutput',false);
        reqFilePath=arrayfun(@(rset)rset.filepath,loadedReqSets,'UniformOutput',false);
        reqSimulating=arrayfun(@(rset)false,loadedReqSets,'UniformOutput',false);
        reqDirtyFlag=arrayfun(@(rset)rset.dirty,loadedReqSets,'UniformOutput',false);


        loadedLinkSets=reqData.getLoadedLinkSets();
        linksFileName=arrayfun(@(lset)lset.name,loadedLinkSets,'UniformOutput',false);
        linksFilePath=arrayfun(@(lset)lset.filepath,loadedLinkSets,'UniformOutput',false);
        linksSimulating=arrayfun(@(lset)false,loadedLinkSets,'UniformOutput',false);
        linksDirtyFlag=arrayfun(@(lset)lset.dirty,loadedLinkSets,'UniformOutput',false);


        fileName=[reqFileName,linksFileName];
        filePath=[reqFilePath,linksFilePath];
        simulating=[reqSimulating,linksSimulating];
        dirtyFlag=[reqDirtyFlag,linksDirtyFlag];

        fileList=horzcat(fileName,filePath,simulating,dirtyFlag);
    else
        fileList={};
    end
end
