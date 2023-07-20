function ret=isBuildForTargetWithoutEC(mdl)




    usingEC=isequal(get_param(mdl,'IsECInUse'),'on');
    ret=~usingEC&&...
    (codertarget.target.isCoderTarget(mdl)||coder.oneclick.Utils.isModelRTT(mdl));
end
