function v=validateBlock(~,hC)




    v=hdlvalidatestruct;

    bfp=hC.OrigModelHandle;

    p=get_param(bfp,'parent');
    while(~isempty(p))
        tmp=p;
        p=get_param(p,'parent');
    end

    level=get_param(tmp,'StrictBusMsg');

    if(strcmpi(level,'None')||strcmpi(level,'Warning'))
        v(end+1)=hdlvalidatestruct(1,message('hdlcoder:validate:MuxUsedasBusUnsupported'));
    end

    ins=hC.PirInputSignals;
    prate=-1;
    for ii=1:length(ins)
        if isinf(ins(ii).SimulinkRate)
            continue;
        end

        if prate<0
            prate=ins(ii).SimulinkRate;
        elseif ins(ii).SimulinkRate~=prate
            blk=get_param(hC.SimulinkHandle,'Object');
            if blk.isSynthesized&&strcmp(blk.getSyntReason,'SL_SYNT_BLK_REASON_BUSEXPANSION')
                v(end+1)=hdlvalidatestruct(1,message('hdlcoder:validate:unsupportedmultiratesignaltobuselementports'));%#ok
                break;
            else
                v(end+1)=hdlvalidatestruct(1,message('hdlcoder:validate:busMultirateUnsupported'));%#ok
                break;
            end
        end
    end

    if strcmpi(get_param(bfp,'nonVirtualBus'),'on')&&~hdlgetparameter('GenerateRecordType')
        v(end+1)=hdlvalidatestruct(3,message('hdlcoder:validate:nonvirtualBus'));
    end


