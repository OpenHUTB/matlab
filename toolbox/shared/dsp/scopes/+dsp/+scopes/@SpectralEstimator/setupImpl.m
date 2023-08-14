function setupImpl(obj,x)




    try
        obj.pInputFrameLength=size(x,1);
    catch %#ok<CTCH>
    end
    thisSetup(obj,x);
    syncOldProperties(obj);


    obj.pIsLockedFlag=true;
end

