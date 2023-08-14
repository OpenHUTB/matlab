function helpview(anchorID)





    docMap=fullfile(docroot,'soc','soc.map');

    try
        helpview(docMap,anchorID);
    catch
        error(message('soc:utils:NoHelpPage',anchorID));
    end
