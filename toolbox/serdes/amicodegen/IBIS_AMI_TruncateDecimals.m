

function integers=IBIS_AMI_TruncateDecimals(decimals)
    integers=regexprep(decimals,'\.\d*','');
