function v=validateBlock(this,hC)





    ports=gatherinputoutputports(this,hC);


    v=this.baseValidateRealComplexPorts(ports);

    hD=hdlcurrentdriver;
    muxes=get_param(hD.ModelConnection.ModelName,'MuxUsedAsBusCreator');
    if~isempty(muxes)&&isfield(muxes,'muxBlock')
        [muxblk{1:numel(muxes)}]=deal(muxes.muxBlock);
        muxblk_mat=cell2mat(muxblk);

        if any(muxblk_mat==hC.SimulinkHandle)
            v(end+1)=hdlvalidatestruct(1,message('hdlcoder:validate:UnsupportedMuxAsBusCreator'));
        end
    end

    for ii=1:numel(hC.PirInputSignals)
        hT=hC.PirInputSignals(ii).Type;
        if hT.isRecordType
            v(end+1)=hdlvalidatestruct(1,...
            message('hdlcoder:validate:UnsupportedMuxAsVectorBusCreator'));%#ok<AGROW>
        end
        break;
    end
end
