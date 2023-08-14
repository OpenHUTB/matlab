function isDesired=isDesiredOp(key,desiredOp)
    persistent simdKeys;

    if isempty(simdKeys)
        simdKeys={'VADD';'VBROADCAST';'VMUL';'VMAC';'VCAST';...
        'VLOAD';'VSTORE';'VSUB';'VDIV';'VMAS';...
        'VCEIL';'VFLOOR';'VMINIMUM';'VMAXIMUM';'VSQRT'};
    end

    switch key
    case{'RTW_OP_SRL','RTW_OP_SRA'}
        isDesired=strcmp(desiredOp,'RTW_OP_SR');
    case{'RTW_OP_ADD','RTW_OP_MINUS','RTW_OP_MUL','RTW_OP_DIV',...
        'RTW_OP_CAST','RTW_OP_SL','RTW_OP_ELEM_MUL','RTW_OP_TRANS',...
        'RTW_OP_CONJUGATE','RTW_OP_HERMITIAN','RTW_OP_TRMUL','RTW_OP_HMMUL',...
        'RTW_OP_GREATER_THAN','RTW_OP_GREATER_THAN_OR_EQ','RTW_OP_LESS_THAN',...
        'RTW_OP_LESS_THAN_OR_EQ','RTW_OP_EQUAL','RTW_OP_NOT_EQUAL'}
        isDesired=strcmp(key,desiredOp);
    otherwise
        if ismember(upper(key),simdKeys)
            isDesired=strcmp(desiredOp,'SIMD');
        else
            isDesired=isempty(desiredOp);
        end

    end
end
