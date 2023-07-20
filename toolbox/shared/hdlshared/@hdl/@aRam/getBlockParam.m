function hdlparam=getBlockParam(this,hC,param)


    hN=hC.Owner;
    nameforuser=[hC.Name,hdlgetparameter('filename_suffix')];

    hdlparam.fullPathName=strrep(hN.FullPath,char(10),char(32));
    hdlparam.fullFileName=fullfile(hdlGetCodegendir,nameforuser);

    if nargin<3
        param=hC.HDLUserData;
    end
    hdlparam.ramIsComplex=param.ramIsComplex;
    hdlparam.hasClkEn=param.hasClkEn;

    if isfield(param,'readNewData')
        hdlparam.readNewData=param.readNewData;
        this.readNewData=hdlparam.readNewData;
    end

    this.fullFileName=hdlparam.fullFileName;
    this.fullPathName=hdlparam.fullPathName;
    this.hasClkEn=hdlparam.hasClkEn;



