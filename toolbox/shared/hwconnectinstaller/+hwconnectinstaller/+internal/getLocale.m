function lang=getLocale()









    locInfo=feature('locale');
    lang=strtok(locInfo.ctype,'.');
