function v=validateBlock(this,hC)




    v=hdlvalidatestruct;


    inp=hC.PirInputSignals(1);
    op=hC.PirOutputSignals(1);

    if(hdlissignalvector(inp)||hdlissignalvector(op))
        v(end+1)=...
        hdlvalidatestruct(1,...
        message('comm:hdl:GenMuxIntDeint:validateBlock:VectorInputOutput')...
        );
    end


    rtype=this.getImplParams('ResetType');
    if strcmpi(rtype,'none')
        v(end+1)=...
        hdlvalidatestruct(2,...
        message('comm:hdl:GenMuxIntDeint:validateBlock:ResetTypeNone')...
        );
    end

    intdelay=this.getIntDelay(hC);
    if length(intdelay)<2
        v(end+1)=...
        hdlvalidatestruct(1,...
        message('comm:hdl:GenMuxIntDeint:validateBlock:NumberofRows')...
        );
    end


