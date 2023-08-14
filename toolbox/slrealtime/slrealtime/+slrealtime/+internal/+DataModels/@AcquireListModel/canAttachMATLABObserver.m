function[canAttachFlag]=canAttachMATLABObserver(this,signalStruct,xcpSignal)







    canAttachFlag=true;


    if length(xcpSignal.dimensions)>2
        canAttachFlag=false;
    end


    if xcpSignal.isFixedPoint||xcpSignal.isHalf
        canAttachFlag=false;
    end








end
