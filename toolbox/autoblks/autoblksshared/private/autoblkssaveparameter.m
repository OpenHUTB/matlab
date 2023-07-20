function autoblkssaveparameter(Block)






    MaskObject=get_param(Block,'MaskObject');
    Obj=MaskObject.getDialogControl('fileStatus');
    Obj.Prompt='autoblks_shared:autoblkInteriorPmsm:blkfileSaveFail';
    fileFullName=get_param(Block,'FilePath');
    autoblksparamerrorcheck('isValidFilepath',fileFullName);
    fileFullName=strtrim(fileFullName);
    [~,fileName,fileExtn]=fileparts(fileFullName);
    autoblksparamerrorcheck('isFileNameAvbl',fileName);
    autoblksparamerrorcheck('isValidFileExtn',fileExtn);

    switch fileExtn
    case '.m'
        blockName=slResolve(get_param(Block,'RefBlkName'),Block);
        switch blockName
        case{'autolibpmsmexterior/Surface Mount PMSM','autolibpmsminterior/Interior PMSM'}
            writePMSMParam_mfile(Block,fileFullName);
        case 'autolibim/Induction Motor'
            writeIMparam_mfile(Block,fileFullName);
        end

    case '.mat'
        writeMATfile(Block,fileFullName);
    otherwise
    end
    Obj.Prompt='autoblks_shared:autoblkInteriorPmsm:blkfileSaveSuccess';
end


function motor_temp_var=initBlockParam(Block)

    blockName=slResolve(get_param(Block,'RefBlkName'),Block);
    switch blockName
    case{'autolibpmsmexterior/Surface Mount PMSM','autolibpmsminterior/Interior PMSM'}
        motor_temp_var=struct('p','4',...
        'Rs','0.75',...
        'Ld','0.0011',...
        'Lq','0.0011',...
        'FluxPM','0.0052',...
        'Ke','3.8',...
        'Kt','0.0314',...
        'J','2e-6',...
        'B','1.2e-5');
    case 'autolibim/Induction Motor'
        motor_temp_var=struct('p','4',...
        'Rs','1.77',...
        'Lls','0.0139',...
        'Rr','1.34',...
        'Llr','0.0121',...
        'Lm','0.3687',...
        'J','0.001',...
        'B','0.0');

    otherwise
    end
end

function writeMATfile(Block,fileFullName)

    blockName=slResolve(get_param(Block,'RefBlkName'),Block);
    switch blockName
    case{'autolibpmsmexterior/Surface Mount PMSM','autolibpmsminterior/Interior PMSM'}
        motorParam=initBlockParam(Block);
        if isfile(fileFullName)


            load(fileFullName);
        end
        motorParam=readPMSMBlockParam(Block,motorParam);
        save(fileFullName,'motorParam');
    case 'autolibim/Induction Motor'
        motorParam=initBlockParam(Block);
        if isfile(fileFullName)


            load(fileFullName);
        end
        motorParam=readIMBlockParam(Block,motorParam);
        save(fileFullName,'motorParam');
    end
end

function writePMSMParam_mfile(Block,fileFullName)

    motor_temp_var=initBlockParam(Block);

    motor_param=readPMSMBlockParam(Block,motor_temp_var);
    [~,fileName,~]=fileparts(fileFullName);
    strList(1)=sprintf("function motorParam = %s(varargin)\n",fileName);
    strList(2)=sprintf("motorParam.p = %d;\n",(motor_param.p));
    strList(3)=sprintf("motorParam.Rs = %f;\n",(motor_param.Rs));
    strList(4)=sprintf("motorParam.Ld = %f;\n",(motor_param.Ld));
    strList(5)=sprintf("motorParam.Lq = %f;\n",(motor_param.Lq));
    strList(6)=sprintf("motorParam.FluxPM = %f;\n",(motor_param.FluxPM));
    strList(7)=sprintf("motorParam.Ke = %f;\n",(motor_param.Ke));
    strList(8)=sprintf("motorParam.Kt = %f;\n",(motor_param.Kt));
    strList(9)=sprintf("motorParam.J = %f;\n",(motor_param.J));
    strList(10)=sprintf("motorParam.B = %f;\n",(motor_param.B));
    strList(11)=sprintf("end");

    fid=fopen(fileFullName,'w+');
    for i=1:length(strList)
        fprintf(fid,strList(1,i));
    end
    fclose(fid);
end

function writeIMparam_mfile(Block,fileFullName)

    motor_temp_var=initBlockParam(Block);

    motor_param=readIMBlockParam(Block,motor_temp_var);
    [~,fileName,~]=fileparts(fileFullName);
    strList(1)=sprintf("function motorParam = %s(varargin)\n",fileName);
    strList(2)=sprintf("motorParam.p = %d;\n",(motor_param.p));
    strList(3)=sprintf("motorParam.Rs = %f;\n",(motor_param.Rs));
    strList(4)=sprintf("motorParam.Lls = %f;\n",(motor_param.Lls));
    strList(5)=sprintf("motorParam.Rr = %f;\n",(motor_param.Rs));
    strList(6)=sprintf("motorParam.Llr = %f;\n",(motor_param.Lls));
    strList(7)=sprintf("motorParam.Lm = %f;\n",(motor_param.Lm));
    strList(8)=sprintf("motorParam.J = %f;\n",(motor_param.J));
    strList(9)=sprintf("motorParam.B = %f;\n",(motor_param.B));
    strList(10)=sprintf("end");

    fid=fopen(fileFullName,'w+');
    for i=1:length(strList)
        fprintf(fid,strList(1,i));
    end
    fclose(fid);
end

function retMotorParam=readPMSMBlockParam(Block,motorParam)


    motorParam.p=str2double(get_param(Block,'P'));
    motorParam.Rs=str2double(get_param(Block,'Rs'));
    blockName=slResolve(get_param(Block,'RefBlkName'),Block);
    if strcmp(blockName,'autolibpmsmexterior/Surface Mount PMSM')
        Ldq=str2num(get_param(Block,'Ldq_'));
        motorParam.Ld=Ldq;
        motorParam.Lq=Ldq;
    else
        Ldq=str2num(get_param(Block,'Ldq'));
        motorParam.Ld=Ldq(1);
        motorParam.Lq=Ldq(2);
    end
    const_type=get_param(Block,'KConstText');
    switch const_type
    case 'Permanent flux linkage constant (lambda_pm):'

        motorParam.FluxPM=str2double(get_param(Block,'lambda_pm'));
        motorParam.Ke=motorParam.FluxPM*motorParam.p*((2*pi())/60)*1000*sqrt(3);
        motorParam.Kt=motorParam.FluxPM*motorParam.p*(3/2);
    case 'Back-emf constant (Ke):'

        motorParam.Ke=str2double(get_param(Block,'Ke'));
        motorParam.FluxPM=((motorParam.Ke/motorParam.p)*(60/(2*pi()))*(1/sqrt(3))*(1/1000));
        motorParam.Kt=motorParam.FluxPM*motorParam.p*(3/2);
    case 'Torque constant (Kt):'

        motorParam.Kt=str2double(get_param(Block,'Kt'));
        motorParam.FluxPM=(motorParam.Kt/motorParam.p)*(2/3);
        motorParam.Ke=motorParam.FluxPM*motorParam.p*((2*pi())/60)*1000*sqrt(3);
    end

    mech=str2num(get_param(Block,'mechanical'));
    motorParam.J=mech(1);
    motorParam.B=mech(2);
    retMotorParam=motorParam;
end

function retMotorParam=readIMBlockParam(Block,motorParam)


    motorParam.p=str2double(get_param(Block,'P'));
    Zs=str2num(get_param(Block,'Zs'));
    motorParam.Rs=Zs(1);
    motorParam.Lls=Zs(2);
    Zr=str2num(get_param(Block,'Zr'));
    motorParam.Rr=Zr(1);
    motorParam.Llr=Zr(2);
    motorParam.Lm=str2num(get_param(Block,'Lm'));
    mech=str2num(get_param(Block,'mechanical'));
    motorParam.J=mech(1);
    motorParam.B=mech(2);
    retMotorParam=motorParam;
end