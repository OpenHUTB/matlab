function populateErrorContainer(obj,mExObject,compIndex)















    obj.MExTracker{compIndex}=mExObject;





    obj.proceedToNextStep(compIndex)=false;

    if~obj.isInBatchMode



        throw(obj.MExTracker{compIndex});
    end
end


