function setSLDV(mdlName,setting)




    sldvParamList={};

    if ischar(setting)
        setting=strcmpi(setting,'on');
    end
    SLDVOn=setting;

    topPLCBlks=plc_find_system(mdlName,...
    'LookUnderMasks','all',...
    'FollowLinks','on',...
    'regexp','on',...
    'PLCBlockType','(^PLCController$)|(^AOIRunner$)');

    for blkCount=1:numel(topPLCBlks)
        blk=topPLCBlks{blkCount};
        sldvParamList=loc_setSLDV(blk,SLDVOn,sldvParamList);
    end

    defaultParamFile='sldv_params_template.m';
    ladderlogiParamFile=[bdroot(mdlName),'_sldv_params.m'];

    plcLadderLogciSLDVConfig=Sldv.ConfigComp;
    if~SLDVOn
        plcLadderLogciSLDVConfig.DVParameters='off';
        plcLadderLogciSLDVConfig.DVParametersConfigFileName=defaultParamFile;
        evalin('base','clear -regexp ^PLC_\w+_SLDV;');
    else
        create_param_file(ladderlogiParamFile,sldvParamList);
        plcLadderLogciSLDVConfig.DVParameters='on';
        plcLadderLogciSLDVConfig.DVParametersConfigFileName=ladderlogiParamFile;
    end
    attachComponent(getActiveConfigSet(bdroot(mdlName)),plcLadderLogciSLDVConfig);

end


function sldvParamList=loc_setSLDV(blk,SLDVOn,sldvParamList)

    paramValue='true';
    PRSBlks=plc_find_system(blk,'LookUnderMasks','all','FollowLinks','on','PLCBlockType','PowerRailStart');
    for blkCount=1:numel(PRSBlks)
        if SLDVOn
            paramValue=['PLC_PowerOn_',num2str(blkCount),'_SLDV'];
            evalin('base',[paramValue,' = true;']);
            sldvParamList{end+1}=paramValue;
        end
        set_param([PRSBlks{blkCount},'/PLCPowerOn'],'Value',paramValue);
    end



    plcBlkType=slplc.utils.getParam(blk,'PLCBlockType');
    if~isempty(plcBlkType)&&strcmpi(plcBlkType,'AOIRunner')
        paramValue='true';
        if SLDVOn
            paramValue='PLC_EnableIn_SLDV';
            evalin('base',[paramValue,' = true;']);
            sldvParamList{end+1}=paramValue;
        end
        aoiRunnerLogicBlock=slplc.utils.getInternalBlockPath(blk,'Logic');
        EnableInBlks=plc_find_system(aoiRunnerLogicBlock,'SearchDepth',1,'LookUnderMasks','all','FollowLinks','on','BlockType','Constant','Name','EnableIn');
        for blkCount=1:numel(EnableInBlks)
            set_param(EnableInBlks{blkCount},'Value',paramValue);
        end
    end



    blockEnableLabelConstantBlks=plc_find_system(blk,'LookUnderMasks','all','FollowLinks','on',...
    'regexp','on',...
    'Name','^_s\w+__Block_Enable_LabelInitValue$',...
    'BlockType','Constant');
    sldvParamList=setLabelConstantBlocks(blockEnableLabelConstantBlks,'true',SLDVOn,sldvParamList);

end

function sldvParamList=setLabelConstantBlocks(labelConstantBlks,defaultParamValue,SLDVOn,sldvParamList)
    paramValue=defaultParamValue;
    for blkCount=1:numel(labelConstantBlks)
        labelBlk=labelConstantBlks{blkCount};
        labelBlkName=get_param(labelBlk,'Name');
        if SLDVOn
            paramValue=['PLC_',labelBlkName,'_SLDV'];
            evalin('base',sprintf('%s = %s;',paramValue,defaultParamValue));
            sldvParamList{end+1}=paramValue;%#ok<*AGROW>
        end
        set_param(labelBlk,'Value',paramValue);
    end
end

function create_param_file(ladderlogiParamFile,sldvParamList)
    [~,ladderlogiParamFunName]=fileparts(ladderlogiParamFile);
    funDef=sprintf('function params = %s',ladderlogiParamFunName);
    funLines=strcat('params.',sldvParamList,' = [];');
    funBody=strjoin(funLines,'\n');
    fid=fopen(ladderlogiParamFile,'w');
    fprintf(fid,'%s\n%s\n%s\n',funDef,funBody,'end');
    fclose(fid);
end
