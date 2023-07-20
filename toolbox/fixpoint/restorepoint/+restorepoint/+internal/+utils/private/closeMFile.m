function closeMFile(mFullFile,restoreData,editorsMap)




    rd=restoreData.getDataForFile(mFullFile);
    if editorsMap.isKey(mFullFile)
        rd.openFile=true;
        curEditor=editorsMap(mFullFile);
        curEditor.closeNoPrompt();
    else
        rd.openFile=false;
    end
    restoreData.setDataForFile(mFullFile,rd);
end
