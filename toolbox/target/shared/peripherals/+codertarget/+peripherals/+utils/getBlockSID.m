function id=getBlockSID(blkH,makeValidVar)




    if nargin==1
        makeValidVar=false;
    end

    sid=Simulink.ID.getSID(blkH);
    if makeValidVar
        id=matlab.lang.makeValidName(sid);
    else
        id=sid;
    end
end
