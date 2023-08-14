function plotPumpMotorCharacteristic(blkHandle)









    import sh.internal.mask.getConcreteBlockParam


    if~ishandle(blkHandle)
        blockHandle=get_param(blkHandle,'Handle');
    else
        blockHandle=blkHandle;
    end
    componentPath=get_param(blockHandle,'ComponentPath');
    modelDir=[matlabroot,'/toolbox/physmod/sh/utils/'];

    switch componentPath
    case{'sh.pumps_motors.fx_displ_pump'}
        testModelName='sh_fixed_pump_characteristic_model';
        testBlock='Fixed-Displacement Pump';

    case{'sh.pumps_motors.hydraulic_motor'}
        testModelName='sh_fixed_motor_characteristic_model';
        testBlock='Fixed-Displacement Motor';
    end


    userModelHandle=bdroot(blockHandle);
    UserBlockName=get_param(blockHandle,'Name');
    modelBlockName=matlab.lang.makeValidName(strrep(UserBlockName,sprintf('\n'),'_'));
    fluidPropBlock=getFluidPropertyBlock(userModelHandle);


    paramPairs=getConcreteBlockParam(blockHandle);


    OrigTestModelName=[testModelName,'_',modelBlockName];
    [newTestModelName,modified]=matlab.lang.makeValidName(OrigTestModelName);

    if modified
        warning(message('physmod:sh:library:ModifiedTestModelName',OrigTestModelName,newTestModelName));


        modelList=get_param(Simulink.allBlockDiagrams(),'Name');
        modelOpenNdx=(ismember(modelList,newTestModelName));
        if~any(modelOpenNdx,'all')
            modelOpen=[];
        else
            modelOpen=modelList(modelOpenNdx);
        end



        if~isempty(modelOpen)
            error(message('physmod:sh:library:InvalidSharedName',newTestModelName,UserBlockName));
        end
    end




    modelList=get_param(Simulink.allBlockDiagrams(),'Name');
    modelOpenNdx=(ismember(modelList,newTestModelName));
    if~any(modelOpenNdx,'all')
        modelOpen=[];
    else
        modelOpen=modelList(modelOpenNdx);
    end


    if isempty(modelOpen)
        testModelHandle=load_system([modelDir,'/',testModelName]);
        fluidPropHandle=getSimulinkBlockHandle([testModelName,'/Fluid properties']);
        replace_block(testModelHandle,'Name',testBlock,getfullname(blockHandle),'noprompt');
        testBlockHandle=getSimulinkBlockHandle([testModelName,'/',testBlock]);
        set_param(testBlockHandle,'name',UserBlockName)
        set_param(testModelHandle,'name',newTestModelName);

    else
        testModelHandle=get_param(modelOpen{1},'Handle');
        if testModelHandle==userModelHandle
            return
        end
        fluidPropHandle=getSimulinkBlockHandle([newTestModelName,'/Fluid properties']);
        replace_block(testModelHandle,'Name',UserBlockName,getfullname(blockHandle),'noprompt');
        testBlockHandle=getSimulinkBlockHandle([newTestModelName,'/',UserBlockName]);
    end


    try
        set_param(testBlockHandle,paramPairs{:});
    catch error_msg
        if(strcmp(error_msg.identifier,'Simulink:Commands:InvSimulinkObjHandle'))
            cause=MException(message('physmod:sh:library:InvalidSharedName',newTestModelName,UserBlockName));
            error_msg=cause;
        end
        throw(error_msg)
    end


    objParam=get_param(testModelHandle,'ModelWorkspace');
    objParam.assignin('newTestBlockName',UserBlockName);


    popupObj=get_param(fluidPropHandle,'MaskObject');
    popupObj.Parameters.TypeOptions=cellfun((@(s)s{1}),fluidPropBlock,'UniformOutput',false);
    set_param(fluidPropHandle,'MaskObject',popupObj);


    objParam.assignin('FluidPropBlockList',fluidPropBlock);


    open_system(testModelHandle);

end

function fluidPropBlock=getFluidPropertyBlock(userModelHandle)

    blockPath={'foundation.hydraulic.utilities.custom_fluid','sh.utilities.hydraulic_fluid'};
    foundationBlock=find_system(userModelHandle,'LookUnderMasks','all',...
    'MatchFilter',@Simulink.match.allVariants,'ComponentPath',blockPath{1});
    shBlock=find_system(userModelHandle,'LookUnderMasks','all','MatchFilter',@Simulink.match.allVariants,...
    'ComponentPath',blockPath{2});


    fluidPropHandle=[foundationBlock;shBlock];
    n=length(fluidPropHandle);
    fluidPropBlock=cell(n+1,1);
    fluidPropBlock{1}{1}='Custom Hydraulic Fluid (Default settings)';
    fluidPropBlock{1}{2}=sprintf('Custom Hydraulic\nFluid (Default settings)');
    for i=1:n
        fluidPropBlock{i+1}{1}=...
        strrep([get_param(fluidPropHandle(i),'Parent'),'/',get_param(fluidPropHandle(i),'Name')],sprintf('\n'),' ');
        fluidPropBlock{i+1}{2}=get_param(fluidPropHandle(i),'Name');
    end

end