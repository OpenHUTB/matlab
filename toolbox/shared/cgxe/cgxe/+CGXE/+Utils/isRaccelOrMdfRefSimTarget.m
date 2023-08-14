function isRaccelOrMdlRef=isRaccelOrMdfRefSimTarget(model)


    stf=get_param(model,'SystemTargetFile');
    isRaccel=isequal(stf,'raccel.tlc');

    mdlRefTarget=get_param(model,'ModelReferenceTargetType');
    isMdlRefTarget=strcmpi(mdlRefTarget,'sim');


    isRaccelOrMdlRef=isRaccel||isMdlRefTarget;
