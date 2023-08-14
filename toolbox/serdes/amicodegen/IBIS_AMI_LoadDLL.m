

function IBIS_AMI_LoadDLL(hCS,~,~,varargin)
    ws=get_param(bdroot,'ModelWorkspace');
    tgdata=get_param(hCS,'CoderTargetData');
    dllDir=tgdata.Placement.dllFileLocation;
    arch=computer('arch');
    switch arch
    case 'win64'
        ext='.dll';
    otherwise
        ext='.so';
    end


    dllFile=[bdroot,ext];

    if contains(get_param(bdroot,'Name'),'Tx')
        dllFileRenamed=char(evalin(ws,'SerdesIBIS.TxDLL;'));
    elseif contains(get_param(bdroot,'Name'),'Rx')
        dllFileRenamed=char(evalin(ws,'SerdesIBIS.RxDLL;'));
    else
        error(message('serdes:rtwserdes:ModelMustBeTxRx'));
    end
    if~exist(dllDir,'dir')
        mkdir(dllDir);
    end
    if~isempty(dllFile)
        movefile(['..',filesep,dllFile],[dllDir,filesep,dllFileRenamed]);
    end
