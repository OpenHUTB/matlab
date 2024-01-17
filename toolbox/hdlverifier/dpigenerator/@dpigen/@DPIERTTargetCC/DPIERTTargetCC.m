function h=DPIERTTargetCC(varargin)

    if nargin>0
        h=[];%#ok<NASGU>

        error(message('HDLLink:DPITargetCC:BadCtor'));
    end

    h=dpigen.DPIERTTargetCC;

    set(h,'IsERTTarget','on');
    set(h,'ModelReferenceCompliant','on');
    set(h,'ParMdlRefBuildCompliant','on');
    set(h,'CompOptLevelCompliant','off');
    set(h,'GRTInterface','off');
    set(h,'GenerateSampleERTMain','off');
    set(h,'MatFileLogging','off');

    set(h,'SupportContinuousTime','on');

    set(h,'ModelStepFunctionPrototypeControlCompliant','on');

    set(h,'GeneratePreprocessorConditionals','Use local settings');


    set(h,'ERTCustomFileBanners','on');
    set(h,'MultiInstanceErrorCode','Error');
    set(h,'ERTCustomFileTemplate','dpigenerator_entry.tlc');
    set(h,'IncludeERTFirstTime','off');

    registerPropList(h,'NoDuplicate','All',[]);

    h.postSetListener=handle.listener(h,h.propsThatCanDirtyModel,...
    'PropertyPostSet',@propValueChangeCallback);
    h.postSetListener.CallbackTarget=h;

end
