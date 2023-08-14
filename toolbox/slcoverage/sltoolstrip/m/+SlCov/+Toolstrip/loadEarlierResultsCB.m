function loadEarlierResultsCB(callbackInfo,varargin)



    cvre=cvresults(callbackInfo.model.Name,'explore');
    cvre.loadDataFromUI(true);
