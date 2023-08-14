function v=validateMultichannel(this,hC)




    v=hdlvalidatestruct;
    bfp=hC.SimulinkHandle;
    block=get_param(bfp,'Object');

    hF=this.createHDLFilterObj(hC);
    s=this.applyFilterImplParams(hF,hC);
    hF.setimplementation;
    this.unApplyParams(s.pcache);

    ip=hC.SLInputPorts(1).Signal;
    if max(hdlsignalvector(ip))>1

        if~strcmpi(get_param(bfp,'InputProcessing'),'Elements as channels (sample based)')
            if isempty(block.HDLData)
                v(end+1)=hdlvalidatestruct(1,...
                message('hdlcoder:filters:validateFrameBased:frameBasedInputNotFrameArch','default'));
            else
                v(end+1)=hdlvalidatestruct(1,...
                message('hdlcoder:filters:validateFrameBased:frameBasedInputNotFrameArch',block.HDLData.archSelection));
            end

            return;
        end

        if~strcmpi(hF.Implementation,'parallel')
            v(end+1)=hdlvalidatestruct(1,...
            message('hdlcoder:validate:UnsupportedMultichannelFIRArch'));
        end
    else
        fParams=this.filterImplParamNames;
        if any(strcmpi('channelsharing',fParams))
            if strcmpi(this.getImplParams('channelsharing'),'on')
                v(end+1)=hdlvalidatestruct(1,...
                message('hdlcoder:validate:SingleInputChannelSharing'));
            end
        end
    end