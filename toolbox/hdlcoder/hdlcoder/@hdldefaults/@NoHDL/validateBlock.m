function v=validateBlock(this,hC)





    v=hdlvalidatestruct;


    if~isempty(hC.SLOutputPorts)
        v(end+1)=hdlvalidatestruct(2,message('hdlcoder:validate:OutputPortsDetectedInNoHDLBlocks'));
    end


