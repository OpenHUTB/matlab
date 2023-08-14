function CR=gen_CR(CRm,CRs)


    CR=randn(1,1)*CRs+CRm;
    while CR<0||CR>1

        CR=randn(1,1)*CRs+CRm;
    end

