function autoblksloadparameter(Block)







    MaskObject=get_param(Block,'MaskObject');
    Obj=MaskObject.getDialogControl('fileStatus');
    Obj.Prompt='autoblks_shared:autoblkInteriorPmsm:blkfileLoadFail';


    modelName=extractBefore(Block,'/');
    autoblksparamerrorcheck('isSimRunning',modelName);


    fileFullName=get_param(Block,'FilePath');
    fileFullName=strtrim(fileFullName);
    autoblksparamerrorcheck('isFileExists',fileFullName);


    [filePath,fileName,fileExtn]=fileparts(fileFullName);
    autoblksparamerrorcheck('isValidFileExtn',fileExtn);

    switch fileExtn
    case '.m'
        addpath(filePath);
        Axis=eval(fileName);
        loadfromworkspace(Block,Axis);
    case '.mat'
        Axis=readstructname(Block,fileFullName);
    case '.xlsx'
    otherwise
    end
    Obj.Prompt='autoblks_shared:autoblkInteriorPmsm:blkfileLoadSuccess';
end

function loadfromworkspace(Block,Axis)

    blockName=slResolve(get_param(Block,'RefBlkName'),Block);
    switch blockName
    case 'autolibpmsmexterior/Surface Mount PMSM'

        set_param(Block,'Ldq_',num2str(Axis.Ld));
        setpmsmparameter(Block,Axis)
    case 'autolibpmsminterior/Interior PMSM'
        setpmsmparameter(Block,Axis)
    case 'autolibim/Induction Motor'
        setimparameter(Block,Axis)
    otherwise
    end

end

function retAxis=readstructname(Block,fileFullName)




    load(fileFullName);
    blockName=slResolve(get_param(Block,'RefBlkName'),Block);
    switch blockName
    case 'autolibpmsmexterior/Surface Mount PMSM'
        autoblksparamerrorcheck('isValidStruct',fileFullName,'motorParam');

        set_param(Block,'Ldq_',num2str(motorParam.Ld));
        setpmsmparameter(Block,motorParam)
        retAxis=motorParam;
    case 'autolibpmsminterior/Interior PMSM'
        autoblksparamerrorcheck('isValidStruct',fileFullName,'motorParam');
        setpmsmparameter(Block,motorParam)
        retAxis=motorParam;
    case 'autolibim/Induction Motor'
        autoblksparamerrorcheck('isValidStruct',fileFullName,'motorParam');
        setimparameter(Block,motorParam)
        retAxis=motorParam;
    otherwise
    end
end

function setpmsmparameter(Block,motor_temp_var)

    if(isfield(motor_temp_var,'p')&&...
        isfield(motor_temp_var,'Rs')&&...
        isfield(motor_temp_var,'Ld')&&...
        isfield(motor_temp_var,'Lq')&&...
        isfield(motor_temp_var,'Ke')&&...
        isfield(motor_temp_var,'J')&&...
        isfield(motor_temp_var,'B'))

        set_param(Block,'P',num2str(motor_temp_var.p));
        set_param(Block,'Rs',num2str(motor_temp_var.Rs));
        strPrint=sprintf('[%f, %f]',motor_temp_var.Ld,motor_temp_var.Lq);
        set_param(Block,'Ldq',strPrint);
        strPrint=sprintf('[%f,%f,0]',motor_temp_var.J,motor_temp_var.B);
        set_param(Block,'mechanical',strPrint);


        lambda_pmVal=((motor_temp_var.Ke/motor_temp_var.p)*(60/(2*pi()))*(1/sqrt(3))*(1/1000));
        set_param(Block,'lambda_pm',num2str(lambda_pmVal));
        set_param(Block,'lambda_pm_calc',num2str(lambda_pmVal));

        Kt_shadowVal=lambda_pmVal*motor_temp_var.p*3/2;
        set_param(Block,'Kt',num2str(Kt_shadowVal));



        set_param(Block,'KConstText','Back-emf constant (Ke):');
        autoblksenableparameters(Block,{'Ke'},{'lambda_pm','Kt'},[],[]);
        set_param(Block,'Ke',num2str(motor_temp_var.Ke));
        set_param(Block,'KConst',num2str(motor_temp_var.Ke));

        MaskObject=get_param(Block,'MaskObject');
        Obj=MaskObject.getDialogControl('KConstUnit');
        Obj.Prompt='autoblks_shared:autoblkInteriorPmsm:blkPrm_KeUnit';
    else
        autoblksparamerrorcheck('inValidStructParam');
    end
end

function setimparameter(Block,motor_temp_var)

    if(isfield(motor_temp_var,'p')&&...
        isfield(motor_temp_var,'Rs')&&...
        isfield(motor_temp_var,'Lls')&&...
        isfield(motor_temp_var,'Rr')&&...
        isfield(motor_temp_var,'Llr')&&...
        isfield(motor_temp_var,'Lm')&&...
        isfield(motor_temp_var,'J')&&...
        isfield(motor_temp_var,'B'))


        set_param(Block,'P',num2str(motor_temp_var.p));
        strPrint=sprintf('[%f, %f]',motor_temp_var.Rs,motor_temp_var.Lls);
        set_param(Block,'Zs',strPrint);
        strPrint=sprintf('[%f, %f]',motor_temp_var.Rr,motor_temp_var.Llr);
        set_param(Block,'Zr',strPrint);
        set_param(Block,'Lm',num2str(motor_temp_var.Lm));
        strPrint=sprintf('[%f,%f,0]',motor_temp_var.J,motor_temp_var.B);
        set_param(Block,'mechanical',strPrint);
    else

        autoblksparamerrorcheck('inValidStructParam');
    end
end
