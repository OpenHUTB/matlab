function h=ERTTargetCC(varargin)






    if nargin>0
        h=[];%#ok<NASGU> 
        DAStudio.error('Simulink:utility:ConstructorInputMismatch','Simulink.ERTTargetCC');
    end

    h=Simulink.ERTTargetCC;

    h.IsERTTarget='on';
    h.ModelReferenceCompliant='on';
    h.ParMdlRefBuildCompliant='on';
    h.CompOptLevelCompliant='on';
    h.ConcurrentExecutionCompliant='on';
    h.CombineOutputUpdateFcns='on';
    h.GRTInterface='off';
    h.ERTCustomFileBanners='on';
    h.GenerateSampleERTMain='on';
    h.MatFileLogging='off';
    h.SupportNonInlinedSFcns='off';
    h.SupportContinuousTime='off';
    h.ERTFirstTimeCompliant='on';
    h.ModelStepFunctionPrototypeControlCompliant='on';
    h.CPPClassGenCompliant='on';
    h.MultiwordTypeDef='System Defined';
    h.MultiwordLength='256';


    h.MemSecFuncSharedUtilSetByExecute='on';
    h.MATLABClassNameForMDSCustomization='Simulink.SoftwareTarget.ERTCustomization';

    registerPropList(h,'NoDuplicate','All',[]);

