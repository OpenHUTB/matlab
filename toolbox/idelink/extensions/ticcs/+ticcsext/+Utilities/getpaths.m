function[ccsdir,stubpath,proxypath]=getpaths(cc)




    ccsdir=cc.invokeIdeModule('GetAppDirectory');
    stubpath=cc.invokeIdeModule('GetStubPath');
    proxypath=cc.invokeIdeModule('GetProxyPath');

