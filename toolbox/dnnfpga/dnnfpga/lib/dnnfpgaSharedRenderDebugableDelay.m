function dnnfpgaSharedRenderDebugableDelay(gcb,pipelineLatency,debugFromTag,debugGotoTag)



    if(isempty(pipelineLatency))
        return;
    end
    if(strcmpi(get_param([gcb,'/DebugGoto'],'blocktype'),'goto'))
        set_param([gcb,'/DebugFrom'],'GotoTag',debugFromTag);
        set_param([gcb,'/DebugGoto'],'GotoTag',debugGotoTag);
    end

    pipelineDelays={...
    'Delay1',...
    'Delay2',...
    'Delay3',...
    'Delay4',...
    'Delay5',...
    'pd',...
    };
    switch pipelineLatency
    case{0}
        for i=1:length(pipelineDelays)
            set_param([gcb,'/',pipelineDelays{i}],'DelayLength','0');
        end
    case{4}
        for i=1:length(pipelineDelays)
            set_param([gcb,'/',pipelineDelays{i}],'DelayLength','1');
        end
    otherwise
        assert(false);
    end
end

