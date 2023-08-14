function result=actionUpdateBlocks(taskobj)



    mdladvObj=taskobj.MAObj;
    model=getfullname(mdladvObj.System);

    updateInfo=ModelUpdater.update(model,'OperatingMode','AnalyzeReplaceBlocks');
    blkList1=updateInfo.blockList;

    ModelUpdater.update(model,'prompt',0,'OperatingMode','updateReplaceBlocks');

    updateInfo=ModelUpdater.update(model,'OperatingMode','AnalyzeReplaceBlocks');
    blkList2=updateInfo.blockList;

    updatedBlks=setdiff(blkList1,blkList2);

    list1=createList(updatedBlks);
    list2=createList(blkList2);

    changedMsg=DAStudio.message('ModelAdvisor:engine:slupdateChangedBlks');
    unchangedMsg=DAStudio.message('ModelAdvisor:engine:slupdateUnchangedBlks');

    if(isempty(updatedBlks))
        changedMsg='';
    end
    if(isempty(blkList2))
        unchangedMsg='';
    end

    result=[changedMsg,list1.emitHTML,unchangedMsg,list2.emitHTML];

    mdladvObj.setActionResultStatus(true);
    mdladvObj.setActionEnable(false);

end

function list=createList(blkList)
    list=ModelAdvisor.List;
    for k=1:length(blkList)
        fullname=blkList{k};
        hyperlink=['matlab: modeladvisorprivate(''hiliteSystem'',''',blkList{k},''')'];
        Block=ModelAdvisor.Text(fullname);
        Block.setHyperlink(hyperlink);
        list.addItem(Block);
    end
end

