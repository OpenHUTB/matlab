function h=TLMTargetCC(varargin)




    if nargin>0
        h=[];%#ok<NASGU>

        error(message('TLMGenerator:TLMTargetCC:BadCtor'));
    end

    h=tlmg.TLMTargetCC;

    set(h,'CPPClassGenCompliant','off')



    set(h,'IsERTTarget','on');
    set(h,'ModelReferenceCompliant','on');
    set(h,'ParMdlRefBuildCompliant','on');
    set(h,'CompOptLevelCompliant','off');
    set(h,'GRTInterface','off');
    set(h,'CombineOutputUpdateFcns','on');
    set(h,'ERTCustomFileBanners','on');
    set(h,'GenerateSampleERTMain','off');
    set(h,'MatFileLogging','off');
    set(h,'SupportNonInlinedSFcns','off');
    set(h,'SupportContinuousTime','off');
    set(h,'ERTFirstTimeCompliant','on');
    set(h,'ModelStepFunctionPrototypeControlCompliant','on');
    set(h,'MultiInstanceErrorCode','Error');

    registerPropList(h,'NoDuplicate','All',[]);

    h.postSetListener=handle.listener(h,h.propsThatCanDirtyModel,...
    'PropertyPostSet',@propValueChangeCallback);
    h.postSetListener.CallbackTarget=h;




    h.dlgCb.method='dialogExtensionCallback';
    h.dlgCb.methodArgs={'%dialog','%value','%tag'};
    h.dlgCb.argTypes={'handle','mxArray','string'};


