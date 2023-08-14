function[nonMaskExists,nonMask]=logicBlockNonMask(blockH)



    coder.inline('always');
    coder.allowpcode('plain');

    coder.const(blockH);
    coder.extrinsic('sldvprivate');
    [nonMaskExists,nonMask]=coder.const(@sldvprivate,'getLogicBlockNonMask',blockH);
end
