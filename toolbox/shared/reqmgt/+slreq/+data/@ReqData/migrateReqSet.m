function migrateReqSet(this,mfReqSet,oldName,asVersion)













    versionsWithoutExternalEditor={'R2018a','R2017b'};
    if ismember(asVersion,versionsWithoutExternalEditor)


        slreq.uri.SourcePath.updateMacroForDescriptionAndRationale(mfReqSet,oldName);



        reqSet=this.wrap(mfReqSet);
        reqSet.refreshImagesMacrosIfNecessary(asVersion)
    end
end
