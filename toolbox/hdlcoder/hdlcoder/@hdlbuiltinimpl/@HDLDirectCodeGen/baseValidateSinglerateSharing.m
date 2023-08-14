function v=baseValidateSinglerateSharing(~,~,~)%#ok<*INUSL>



    v=hdlvalidatestruct;

    maxOversampling=hdlgetparameter('maxoversampling');

    if maxOversampling>0&&maxOversampling~=inf
        msgobj=message('hdlcoder:makehdl:DeprecateMaxOverSampling');
        warning(msgobj);
        hdlsetparameter('maxoversampling',inf);
    end
