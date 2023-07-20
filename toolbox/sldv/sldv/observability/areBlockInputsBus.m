function yesno=areBlockInputsBus(blockH)



    coder.inline('always');
    coder.allowpcode('plain');

    coder.const(blockH);
    coder.extrinsic('sldvprivate');
    yesno=coder.const(sldvprivate('areBlockInputsBusType',blockH));
end
