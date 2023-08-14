function v=validateBlock(~,~)


    v=hdlvalidatestruct;

    if~targetcodegen.targetCodeGenerationUtils.isNFPMode()
        v(end+1)=hdlvalidatestruct(1,message('hdlcoder:validate:nfponlyblock'));
    end

