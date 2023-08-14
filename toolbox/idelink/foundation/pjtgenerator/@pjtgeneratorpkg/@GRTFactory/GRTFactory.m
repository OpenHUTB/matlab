function h=GRTFactory(varargin)






    h=pjtgeneratorpkg.GRTFactory;


    set(h,'ProjectMgr',linkfoundation.pjtgenerator.ProjectManager(false));


    h.setAdaptor(h.AdaptorName);

    set(h,'ModelReferenceCompliant','on');
    set(h,'MatFileLogging','off');
    set(h,'ConcurrentExecutionCompliant','on');
    if(h.isValidParam('MATLABClassNameForMDSCustomization'))
        set(h,'MATLABClassNameForMDSCustomization','linkfoundation.pjtgenerator.IdelinkCustomization');
    end
    registerPropList(h,'NoDuplicate','All',[]);
