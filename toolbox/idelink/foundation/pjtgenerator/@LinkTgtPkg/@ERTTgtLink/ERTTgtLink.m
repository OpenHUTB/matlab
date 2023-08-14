function h=ERTTgtLink(varargin)




    if nargin>0
        h=[];
        error(message('ERRORHANDLER:utils:IncorrectConstructorSignature'));
    end

    h=LinkTgtPkg.ERTTgtLink;

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
