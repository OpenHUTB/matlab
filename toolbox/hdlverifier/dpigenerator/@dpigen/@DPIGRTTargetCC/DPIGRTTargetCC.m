function h=DPIGRTTargetCC(varargin)




    if nargin>0
        h=[];%#ok<NASGU>

        error(message('HDLLink:DPITargetCC:BadCtor'));
    end

    h=dpigen.DPIGRTTargetCC;




    set(h,'IsERTTarget','off');
    set(h,'ModelReferenceCompliant','on');
    set(h,'ParMdlRefBuildCompliant','on');
    set(h,'CompOptLevelCompliant','off');
    set(h,'GRTInterface','off');
    set(h,'GenerateSampleERTMain','off');
    set(h,'MatFileLogging','off');
    set(h,'SupportNonInlinedSFcns','off');
    set(h,'SupportContinuousTime','on');

    set(h,'ModelStepFunctionPrototypeControlCompliant','on');

    set(h,'GeneratePreprocessorConditionals','Use local settings');







    registerPropList(h,'NoDuplicate','All',[]);

    h.postSetListener=handle.listener(h,h.propsThatCanDirtyModel,...
    'PropertyPostSet',@propValueChangeCallback);
    h.postSetListener.CallbackTarget=h;




end
