function[genCpp,ext,isGpu]=getSimTargetLangCpp(model,parentTarget)



    isSfunTarget=false;
    if nargin>1&&~isempty(parentTarget)
        targetName=sf('get',parentTarget{1},'target.name');
        isSfunTarget=strcmp(targetName,'sfun');
    end

    if(isSfunTarget||isRaccelOrMdfRefSimTarget(model))

        if ispc&&sfpref('UseLCC64')
            genCpp=false;
        else
            genCpp=strcmp(get_param(model,'SimTargetLang'),'C++');
        end
        [ext,isGpu]=getExtension(model,genCpp,true);

    else
        genCpp=rtwprivate('rtw_is_cpp_build',model);
        [ext,isGpu]=getExtension(model,genCpp,false);
    end

end

function isSimTarget=isRaccelOrMdfRefSimTarget(model)

    stf=get_param(model,'SystemTargetFile');
    israccel=isequal(stf,'raccel.tlc');
    isaccel=isequal(stf,'accel.tlc');

    issim=strcmpi(get_param(model,'TargetStyle'),'SimulationTarget');

    mdlRefTarget=get_param(model,'ModelReferenceTargetType');
    isMdlRefTarget=strcmpi(mdlRefTarget,'sim');



    isSimTarget=israccel||isMdlRefTarget||(issim&&~isaccel);
end


function[ext,isGpu]=getExtension(model,genCpp,isSim)
    isGpu=isGpuCodegen(model,isSim);
    ext='.c';
    if genCpp
        ext='.cpp';
    end
end

function isGpu=isGpuCodegen(model,isSim)
    if isSim
        isGpu=strcmp(get_param(model,'GPUAcceleration'),'on');
    else
        isGpu=strcmp(get_param(model,'GenerateGPUCode'),'CUDA');
    end
end
