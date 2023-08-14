function h=GRTTgtLinkCCS(varargin)





    h=LinkTgtPkg.GRTTgtLink;
    set(h,'ModelReferenceCompliant','on');
    set(h,'MatFileLogging','off');

    registerPropList(h,'NoDuplicate','All',[]);
