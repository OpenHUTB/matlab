function v=validateBlock(~,hC)




    v=hdlvalidatestruct;
    bfp=hC.OrigModelHandle;

    p=get_param(bfp,'parent');
    while~isempty(p)
        tmp=p;
        p=get_param(p,'parent');
    end

    level=get_param(tmp,'StrictBusMsg');
    if(strcmpi(level,'None')||strcmpi(level,'Warning'))
        v(end+1)=hdlvalidatestruct(1,message('hdlcoder:validate:MuxUsedasBusUnsupported'));
    end

    inputType=hC.PirInputSignals(1).Type;
    if~inputType.BaseType.isRecordType()





        phan=get_param(bfp,'PortHandles');
        inportHandle=phan.Inport(1);
        if get_param(inportHandle,'CompiledPortBusMode')~=1
            v(end+1)=hdlvalidatestruct(1,message('hdlcoder:validate:BusSelectorInputNonBus'));
        end
    end


end


