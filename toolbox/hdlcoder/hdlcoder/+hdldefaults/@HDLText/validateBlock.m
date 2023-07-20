function v=validateBlock(this,hC)%#ok<INUSL>


    v=[];

    slbh=hC.SimulinkHandle;
    dtype=get_param(slbh,'DocumentType');


    v=hdlvalidatestruct(1,message('hdlcoder:validate:noverbatimtextNoIPBlock'));





end


