function gCodeGen(this,config)







    if nargin<2
        config='';
    end


    propagateCodeGenProp(this);

    if strcmpi(this.Partition.Type,'MIXED')
        compList=this.ChildNode;

        for i=1:length(compList)
            comp=compList{i};
            partition=comp.Partition.Type;
            if strcmpi(partition,'HW')
                comp.hdlCodeGen(config);
                this.HDLFiles=comp.HDLFiles;
                this.SimScript=comp.SimScript;
            elseif strcmpi(partition,'SW')
                comp.cCodeGen(config);
            else
                error(message('EDALink:Node:gCodeGen:partitiontype'));
            end
        end

    elseif strcmpi(this.Partition.Type,'HW')
        this.hdlCodeGen(config);
    elseif strcmpi(this.Partition.Type,'SW')
        this.cCodeGen(config);
    elseif strcmpi(this.Partition.Type,'FIL')
        if~isempty(this.Partition.Device)
            verbose=hdlgetparameter('verbose');
            hdlsetparameter('verbose',0);
            top=eda.internal.filhdl.FILTop(this);
            top.gBuild;
            top.gUnify;
            top.hdlCodeGen(config);
            hdlsetparameter('verbose',verbose);
        else
            error(message('EDALink:Node:gCodeGen:unknownDevice'));
        end
    elseif strcmpi(this.Partition.Type,'SDR')
        if~isempty(this.Partition.Device)
            verbose=hdlgetparameter('verbose');
            hdlsetparameter('verbose',0);
            top=sdr.internal.sdrhdl.SDRTop(this);
            top.gBuild;
            top.gUnify;
            top.hdlCodeGen(config);
            hdlsetparameter('verbose',verbose);
        else
            error(message('EDALink:Node:gCodeGen:unknownDevice'));
        end
    else
        error(message('EDALink:Node:gCodeGen:partitiontype'));
    end

end

