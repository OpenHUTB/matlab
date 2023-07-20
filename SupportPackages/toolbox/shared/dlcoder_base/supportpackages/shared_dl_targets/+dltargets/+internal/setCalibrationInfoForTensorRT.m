













function setCalibrationInfoForTensorRT(dlCodegenOptionsCallback,...
    hN,...
    codegentarget,...
    codegendir,...
    networkClassName,...
    dlcfg,...
    networkIdentifier)









    precision='fp32';

    if isprop(dlcfg,'DataType')&&...
        (strcmpi(dlcfg.DataType,'int8')||strcmpi(dlcfg.DataType,'fp16'))
        precision=lower(dlcfg.DataType);
    elseif~isempty(dlCodegenOptionsCallback)


        codegenOptionsCallbackClass=feval(dlCodegenOptionsCallback);
        precision=codegenOptionsCallbackClass.getDataType(networkIdentifier);
        precision=lower(precision);
    end

    if strcmpi(codegentarget,'mex')

        codegenDir=codegendir;
    else

        cdir=pwd;
        codegenDir=strrep(codegendir,cdir,'.');
    end

    calibrationBatchDir=fullfile(codegenDir,'tensorrt',networkClassName);


    if ispc&&~strcmpi(codegentarget,'mex')
        calibrationBatchDir=strrep(calibrationBatchDir,'\','/');
    end

    switch precision
    case 'int8'
        hN.setNetworkPrecision(0);
        hN.setCalibrationDataPath(calibrationBatchDir);
    case 'fp16'
        hN.setNetworkPrecision(1);
    otherwise
        hN.setNetworkPrecision(2);
    end
end
