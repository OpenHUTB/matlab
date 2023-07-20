function renderCustomLayerMLFB(gcb,customLayersInfo)


















































    try
        blocks=find_system(gcb,'LookUnderMasks','all','SearchDepth','1');
        for i=1:length(blocks)
            if(strcmp(get_param(blocks{i},'BlockType'),'SubSystem')&&...
                strcmp(get_param(blocks{i},'Name'),get_param(gcb,'Name')))||...
                strcmp(get_param(blocks{i},'BlockType'),'Inport')||...
                strcmp(get_param(blocks{i},'BlockType'),'Outport')
                continue;
            end
            delete_block(blocks{i});
        end


        lines=find_system(gcb,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'LookUnderMasks','all','FindAll','on','type','line');
        delete_line(lines);
    catch me
        error(me.message);
    end

    numCustomLayers=numel(customLayersInfo);
    multipleCustomLayers=numCustomLayers>1;

    if multipleCustomLayers

        add_block('hdlsllib/Signal Routing/Multiport Switch',[gcb,'/multiPort1'],'Inputs',num2str(numCustomLayers),'DiagnosticForDefault','None');
        add_line(gcb,'layerMode/1','multiPort1/1','autorouting','on');
        add_line(gcb,'multiPort1/1','output/1','autorouting','on');


        add_block('hdlsllib/Signal Routing/Multiport Switch',[gcb,'/multiPort2'],'Inputs',num2str(numCustomLayers),'DiagnosticForDefault','None');
        add_line(gcb,'layerMode/1','multiPort2/1','autorouting','on');
        add_line(gcb,'multiPort2/1','outputValid/1','autorouting','on');


        add_block('hdlsllib/Signal Routing/Multiport Switch',[gcb,'/multiPort3'],'Inputs',num2str(numCustomLayers),'DiagnosticForDefault','None');
        add_line(gcb,'layerMode/1','multiPort3/1','autorouting','on');
        add_line(gcb,'multiPort3/1','inputReady/1','autorouting','on');
    else

        add_block('built-in/Terminator',[gcb,'/TerminateLayerMode']);
        add_line(gcb,'layerMode/1','TerminateLayerMode/1','autorouting','on');
    end



    NumValidModels=1;
    maxCustomLayerInputNum=1;


    idx=1;
    while idx<=numCustomLayers

        functionName=sprintf('dnnfpgaCustomLayer_%d',idx);
        customLayerInfo=customLayersInfo(idx);

        if customLayerInfo.LayerOnly

            blockPrefix='MLFB_';
            curBlockName=[blockPrefix,functionName];


            add_block('hdlsllib/User-Defined Functions/MATLAB Function',[gcb,'/',curBlockName]);
            hdlset_param([gcb,'/',curBlockName],'Architecture','MATLAB Datapath','FlattenHierarchy','on');
            curBlockConfig=get_param([gcb,'/',curBlockName],'MATLABFunctionConfiguration');


            curBlockConfig.FunctionScript=customLayerInfo.FunctionContent;
        else

            blockPrefix='Reference_';
            curBlockName=[blockPrefix,functionName];


            add_block('simulink/Ports & Subsystems/Subsystem Reference',[gcb,'/',curBlockName]);
            set_param([gcb,'/',curBlockName],'ReferencedSubsystem',customLayerInfo.ModelName);
            hdlset_param([gcb,'/',curBlockName],'FlattenHierarchy','on');

        end








        add_block('hdlsllib/Discrete/Delay',[gcb,'/delay',num2str(idx)],'DelayLength',num2str(customLayerInfo.DelayLength));
        add_block('hdlsllib/Discrete/Delay',[gcb,'/delayValid',num2str(idx)],'DelayLength',num2str(customLayerInfo.DelayLength));
        add_block('hdlsllib/Discrete/Delay',[gcb,'/delayReady',num2str(idx)],'DelayLength',num2str(customLayerInfo.DelayLength));


        add_line(gcb,'layer/1',sprintf('%s/1',curBlockName),'autorouting','on');
        add_line(gcb,'input1/1',sprintf('%s/2',curBlockName),'autorouting','on');
        if customLayerInfo.NumInputs==2
            add_line(gcb,'input2/1',sprintf('%s/3',curBlockName),'autorouting','on');
            maxCustomLayerInputNum=2;
        end
        add_line(gcb,[curBlockName,'/1'],['delay',num2str(idx),'/1'],'autorouting','on');


        if customLayerInfo.LayerOnly
            add_line(gcb,'inputValid/1',['delayValid',num2str(idx),'/1'],'autorouting','on');
        else
            add_line(gcb,'inputValid/1',sprintf('%s/%d',curBlockName,customLayerInfo.NumInputs+2),'autorouting','on');
            add_line(gcb,[curBlockName,'/2'],['delayValid',num2str(idx),'/1'],'autorouting','on');
        end


        if customLayerInfo.LayerOnly
            add_line(gcb,'outputReady/1',['delayReady',num2str(idx),'/1'],'autorouting','on');
        else




            if customLayerInfo.NumSharedLayers>1
                portoffset=4;
            else
                portoffset=3;
            end
            try
                add_line(gcb,'outputReady/1',sprintf('%s/%d',curBlockName,customLayerInfo.NumInputs+portoffset),'autorouting','on');
                add_line(gcb,[curBlockName,'/3'],['delayReady',num2str(idx),'/1'],'autorouting','on');
            catch
                add_line(gcb,'outputReady/1',['delayReady',num2str(idx),'/1'],'autorouting','on');
            end
        end


        if multipleCustomLayers

            add_line(gcb,['delay',num2str(idx),'/1'],['multiPort1/',num2str(idx+1)],'autorouting','on');


            add_line(gcb,['delayValid',num2str(idx),'/1'],['multiPort2/',num2str(idx+1)],'autorouting','on');


            add_line(gcb,['delayReady',num2str(idx),'/1'],['multiPort3/',num2str(idx+1)],'autorouting','on');
        else

            add_line(gcb,['delay',num2str(idx),'/1'],'output/1','autorouting','on');


            add_line(gcb,['delayValid',num2str(idx),'/1'],'outputValid/1','autorouting','on');


            add_line(gcb,['delayReady',num2str(idx),'/1'],'inputReady/1','autorouting','on');
        end


        if customLayerInfo.NumSharedLayers>1
            constantBlockName=['Constant_',customLayerInfo.ModelName];
            subtractorBockName=['Subtract_',customLayerInfo.ModelName];
            add_block('hdlsllib/Sources/Constant',[gcb,'/',constantBlockName],...
            'Value',num2str(idx),'OutDataTypeStr','uint32');
            add_block('hdlsllib/Math Operations/Subtract',[gcb,'/',subtractorBockName],...
            'SaturateOnIntegerOverflow','on');
            add_line(gcb,'layerMode/1',[subtractorBockName,'/1'],'autorouting','on');
            add_line(gcb,[constantBlockName,'/1'],[subtractorBockName,'/2'],'autorouting','on');
            add_line(gcb,[subtractorBockName,'/1'],sprintf('%s/%d',curBlockName,customLayerInfo.NumInputs+3),'autorouting','on');
            idx=idx+customLayerInfo.NumSharedLayers-1;
        end


        idx=idx+1;
        NumValidModels=NumValidModels+1;

    end



    if maxCustomLayerInputNum==1
        add_block('built-in/Terminator',[gcb,'/TerminateInput2']);
        add_line(gcb,'input2/1','TerminateInput2/1','autorouting','on');
    end


    NumValidModels=NumValidModels-1;
    if NumValidModels>1
        set_param([gcb,'/multiPort1'],'Inputs',num2str(NumValidModels));
        set_param([gcb,'/multiPort2'],'Inputs',num2str(NumValidModels));
        set_param([gcb,'/multiPort3'],'Inputs',num2str(NumValidModels));
    end

end


