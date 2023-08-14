function h=ERTFactory(varargin)






    h=pjtgeneratorpkg.ERTFactory;


    set(h,'ProjectMgr',linkfoundation.pjtgenerator.ProjectManager);


    h.setAdaptor(h.AdaptorName);

    set(h,'IsERTTarget','on');
    set(h,'ModelReferenceCompliant','on');
    set(h,'GRTInterface','off');
    set(h,'CombineOutputUpdateFcns','on');
    set(h,'ERTCustomFileBanners','on');
    set(h,'GenerateSampleERTMain','off');
    set(h,'MatFileLogging','off');
    set(h,'SupportNonInlinedSFcns','off');
    set(h,'SupportContinuousTime','off');
    set(h,'ConcurrentExecutionCompliant','on');
    if(h.isValidParam('MATLABClassNameForMDSCustomization'))
        set(h,'MATLABClassNameForMDSCustomization','linkfoundation.pjtgenerator.IdelinkCustomization');
    end
    registerPropList(h,'NoDuplicate','All',[]);
