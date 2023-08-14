function v=validateBlock(this,hC)





    v=hdlvalidatestruct;



    v=[v,validateInitialCondition(this,hC)];


    if any([v.Status])
        return;
    end


    bfp=hC.SimulinkHandle;
    block=get_param(bfp,'Object');

    ip=hC.SLInputPorts(1).Signal;
    if max(hdlsignalvector(ip))>1

        if~strcmpi(get_param(bfp,'InputProcessing'),'Elements as channels (sample based)')
            if isempty(block.HDLData)
                v(end+1)=hdlvalidatestruct(1,...
                message('hdlcoder:filters:validateFrameBased:frameBasedInputNotFrameArch','default'));
                return;
            elseif strcmpi(block.HDLData.archSelection,'Frame Based')

            else
                v(end+1)=hdlvalidatestruct(1,...
                message('hdlcoder:filters:validateFrameBased:frameBasedInputNotFrameArch',block.HDLData.archSelection));
                return;
            end
        end
    end


    v=[v,validateFilterParams(this,hC)];
