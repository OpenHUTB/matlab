function v=baseValidateSharing(this,hN)%#ok<*INUSL>



    v=hdlvalidatestruct;

    if hN.getSharingFactor>0
        if hdlismatlabmode

            v(end+1)=hdlvalidatestruct(1,...
            message('hdlcoder:validate:illegalBlockSharingMATLAB'));
        else
            v(end+1)=hdlvalidatestruct(1,...
            message('hdlcoder:validate:illegalBlockSharing'));
        end
    end
