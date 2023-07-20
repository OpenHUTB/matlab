function mtreeIR=operand2mtree(operand)


    m=mtree(operand);
    if strcmp(m.select(1).kind,'DCALL')
        import plccore.common.plcThrowError
        plcThrowError('plccoder:plccore:DirectCallUnsupported',deblank(m.select(1).tree2str));
    else
        firstNonPRINTNode=2;
        mtreeIR=m.select(firstNonPRINTNode);
    end
end

