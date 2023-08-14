function ret=isSupportedWidget(h,objProp)





    objProp=convertStringsToChars(objProp);

    ret=h.ProjectMgr.isSupportedWidget(objProp,h.AdaptorName);