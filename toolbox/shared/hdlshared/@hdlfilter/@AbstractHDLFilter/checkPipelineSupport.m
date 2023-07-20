function v=checkPipelineSupport(this)








    v=struct('Status',0,'Message','','MessageID','');

    pipes=this.isPipelineSupported;
    if(this.getHDLParameter('multiplier_input_pipeline')>0&&~pipes.multinput)
        msg='Multiplier input pipelines are not supported for this filter structure.';
        v=struct('Status',1,'Message',msg,'MessageID','HDLShared:hdlfilter:multpipenotsupported');
        return
    end
    if(this.getHDLParameter('multiplier_output_pipeline')>0&&~pipes.multoutput)
        msg='Multiplier output pipelines are not supported for this filter structure';
        v=struct('Status',1,'Message',msg,'MessageID','HDLShared:hdlfilter:multpipenotsupported');
        return
    end

