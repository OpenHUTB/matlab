function validateBlock(platform,blk,customfcn,varargin)





    model=codertarget.utils.getModelForBlock(blk);

    cs=getActiveConfigSet(model);

    systemTargetFile=get_param(model,'SystemTargetFile');

    if isequal(systemTargetFile,'raccel.tlc')||...
        isequal(get_param(model,'SimulationMode'),'accelerator')

    else
        if cs.isHierarchyBuilding&&...
            ~isequal(get_param(model,'SystemTargetFile'),'realtime.tlc')
            error(message('realtime:build:WrongSystemTargetFile',...
            platform,platform));
        end
    end

    if isequal(systemTargetFile,'realtime.tlc')
        target=get_param(model,'TargetExtensionPlatform');
        if~strcmpi(target,'None')&&~isequal(platform,target)
            error(message('realtime:build:MismatchedBlocksAndPlatform',...
            platform,target));
        end
    end

    opts.familyName='RTT';
    opts.parameterName='platform';
    opts.parameterValue=platform;
    opts.parameterCallback={'allSame'};
    opts.blockCallback=[];
    opts.targetPrefCallback=[];
    opts.errorID={'realtime:build:MixedBlocks'};
    opts.errorArgs={};
    lf_registerBlockCallbackInfo(opts);

    if~isempty(customfcn)
        fhandle=str2func(customfcn);
        fhandle(blk,varargin);
    end

