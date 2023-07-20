function h=GRTTgtLinkCCS(varargin)





    h=CCSLinkTgtPkg.GRTTgtLinkCCS;

    h.ideObjName='CCS_Obj';
    h.oldideObjName='CCS_Obj';

    set(h,'ModelReferenceCompliant','on');
    set(h,'MatFileLogging','off');

    registerPropList(h,'NoDuplicate','All',[]);
