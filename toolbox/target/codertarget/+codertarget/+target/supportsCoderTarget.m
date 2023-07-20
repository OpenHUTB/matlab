function supported=supportsCoderTarget(arg,updatingSTF)





    if nargin<2
        updatingSTF=false;
    end


    configSet=coder.make.internal.getConfigObject(arg);


    supportedStfs={'ert.tlc';
    'autosar.tlc'};

    supported=false;


    stf=get_param(configSet,'SystemTargetFile');


    if~ismember(stf,supportedStfs)
        return;
    end




    if(updatingSTF)





        newTgtSettings=codertarget.utils.getOrSetSTFInfo();
        if~isempty(newTgtSettings)&&isfield(newTgtSettings,'TemplateMakefile')
            supported=~isequal(newTgtSettings.TemplateMakefile,'RTW.MSVCBuild');
        else
            supported=true;
        end
    else
        supported=~isequal(lower(get_param(configSet,'TemplateMakefile')),'rtw.msvcbuild');
    end
end

