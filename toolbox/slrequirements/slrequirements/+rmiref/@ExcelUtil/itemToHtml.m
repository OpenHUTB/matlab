function[html,cachedFile]=itemToHtml(doc,itemId)




    targetFilePath=rmiref.ExcelUtil.getCacheFilePath(doc,itemId);
    if rmiref.ExcelUtil.isUpToDate(targetFilePath,doc)
        cachedFile=targetFilePath;
    else
        hDoc=rmiref.ExcelUtil.activateDocument(doc);

        if strncmp(itemId,'Simulink_requirement_item_',length('Simulink_requirement_item_'))
            itemId=['@',itemId];
        end

        hRange=rmiref.ExcelUtil.selectCell([],hDoc,itemId);

        if isempty(hRange)
            cachedFile='';
        else
            cachedFile=rmiref.ExcelUtil.rangeToHtml(hRange,targetFilePath,itemId);
        end
    end

    if~isempty(cachedFile)&&exist(cachedFile,'file')==2
        html=rmi.Informer.htmlFileToString(cachedFile);
    else


        html=['<br/>','<font color="red">',getString(message('Slvnv:rmiref:ExcelUtil:UnableToLocate',itemId(2:end),doc))...
        ,'</font>','<br/>'];
    end

end



