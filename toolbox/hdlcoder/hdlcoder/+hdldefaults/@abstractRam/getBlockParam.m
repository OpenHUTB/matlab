function hdlparam=getBlockParam(this,hC,param)%#ok


    hN=hC.Owner;
    nameforuser=[hC.Name,hdlgetparameter('filename_suffix')];

    hdlparam.fullPathName=strrep(hN.FullPath,char(10),char(32));
    hDrv=hdlcurrentdriver;
    hdlparam.fullFileName=fullfile(hDrv.hdlGetCodegendir,nameforuser);

    if nargin<3
        param=hC.HDLUserData;
    end

    hdlparam.ramIsComplex=param.ramIsComplex;
    hdlparam.ramIsGeneric=param.ramIsGeneric;
    hdlparam.hasClkEn=param.hasClkEn;
    if isfield(param,'readNewData')
        hdlparam.readNewData=param.readNewData;
    end


