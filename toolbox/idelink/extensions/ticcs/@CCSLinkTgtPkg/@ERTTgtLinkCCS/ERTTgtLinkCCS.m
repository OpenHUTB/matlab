function h=ERTTgtLinkCCS(varargin)




    h=CCSLinkTgtPkg.ERTTgtLinkCCS;

    h.ideObjName='CCS_Obj';
    h.oldideObjName='CCS_Obj';

    set(h,'IsERTTarget','on');
    set(h,'ModelReferenceCompliant','on');
    set(h,'GRTInterface','off');
    set(h,'CombineOutputUpdateFcns','on');
    set(h,'ERTCustomFileBanners','on');
    set(h,'GenerateSampleERTMain','off');
    set(h,'MatFileLogging','off');
    set(h,'SupportNonInlinedSFcns','off');
    set(h,'SupportContinuousTime','off');

    registerPropList(h,'NoDuplicate','All',[]);
