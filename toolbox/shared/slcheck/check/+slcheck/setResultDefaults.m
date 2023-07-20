function MAObj=setResultDefaults(SubCheckObj,MAObj)
    prefix=[SubCheckObj.MessageCatalogPrefix,SubCheckObj.ID];
    MAObj.Title=DAStudio.message([prefix,'_subtitle']);
    MAObj.Status=DAStudio.message([prefix,'_warn']);
    MAObj.RecAction=DAStudio.message([prefix,'_rec_action']);
end