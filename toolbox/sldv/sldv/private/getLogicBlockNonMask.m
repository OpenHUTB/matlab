function[nonMaskExists,nonMask]=getLogicBlockNonMask(blockH)





    op=get_param(blockH,'Operator');

    if strcmp(op,'AND')||strcmp(op,'NAND')
        nonMaskExists=true;
        nonMask=true;
    elseif strcmp(op,'OR')||strcmp(op,'NOR')
        nonMaskExists=true;
        nonMask=false;
    else
        nonMaskExists=false;
        nonMask=false;
    end
end
