









function attachWebContentToEditor(adapterEditor,urlStr)
    oldURL=SLM3I.SLCommonDomain.getUrlFromEditorCEF(adapterEditor);
    hasWebContent=~isempty(oldURL);
    if~hasWebContent
        if~SLM3I.SLCommonDomain.isWebContentLoadedForEditor(adapterEditor)
            SLM3I.SLCommonDomain.loadWebContentForEditorCEF(adapterEditor,urlStr);
        end
    else

        oldURL=replace(oldURL,'%5C','\');

        urlStrStrip=regexprep(urlStr,'snc=\w\w\w\w\w\w','');
        oldURLStrip=regexprep(oldURL,'snc=\w\w\w\w\w\w','');
        if~strcmp(oldURLStrip,urlStrStrip)
            SLM3I.SLCommonDomain.loadWebContentForEditorCEF(adapterEditor,urlStr);
        end
    end
end