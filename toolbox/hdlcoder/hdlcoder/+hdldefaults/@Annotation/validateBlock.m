function v=validateBlock(this,hC)





    v=hdlvalidatestruct;

    isDocBlk=getBlockInfo(this,hC);

    if isDocBlk
        slbh=hC.SimulinkHandle;
        dtype=get_param(slbh,'DocumentType');

        if~strcmp(dtype,'Text')
            v(end+1)=hdlvalidatestruct(3,message('hdlcoder:validate:nocommenttext',dtype));
        end
    end


