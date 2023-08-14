function[vars,bRefreshNeeded]=getParametersUsedByBlk(blk)



    try
        varsTemp=Simulink.findVars(blk,'SearchMethod','cached');
    catch me %#ok<NASGU>
        bRefreshNeeded=true;
        vars=[];
        return;
    end


    isCompiled=get_param(bdroot(blk),'CompiledSinceLastChange');
    bRefreshNeeded=strcmpi(isCompiled,'off');


    vars=repmat(struct('ParamName',{},'VarName',{},'WksType',{},'BlockPath',{}),1,length(varsTemp));
    for i=1:length(varsTemp)
        switch varsTemp(i).SourceType
        case 'base workspace'
            vars(i).ParamName='';
            vars(i).VarName=varsTemp(i).Name;
            vars(i).WksType='base workspace';
            vars(i).BlockPath=Simulink.BlockPath('');
        case 'data dictionary'
            vars(i).ParamName='';
            vars(i).VarName=varsTemp(i).Name;
            vars(i).WksType=varsTemp(i).Source;
            vars(i).BlockPath=Simulink.BlockPath('');
        case 'model workspace'
            vars(i).ParamName='';
            vars(i).VarName=varsTemp(i).Name;
            vars(i).WksType='model workspace';
            vars(i).BlockPath=Simulink.BlockPath(varsTemp(i).Source);
        case 'mask workspace'
            vars(i).ParamName=varsTemp(i).Name;
            vars(i).VarName='';
            vars(i).WksType='';
            vars(i).BlockPath=Simulink.BlockPath(varsTemp(i).Source);
        otherwise
            assert(false,'unexpected source type %s',varsTemp(i).SourceType);
        end
    end
end
