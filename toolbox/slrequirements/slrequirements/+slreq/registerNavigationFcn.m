



















function registerNavigationFcn(sourceName,callbackName)

    ncbMgr=slreq.internal.NavigationFcnRegistry.getInstance();

    srcNameChar=strtrim(convertStringsToChars(sourceName));
    callbackNameChar=strtrim(convertStringsToChars(callbackName));

    ncbMgr.set(srcNameChar,callbackNameChar);

end
