function removePulses(psObj,idxRemove)



























    validateattributes(psObj,{'Battery.PulseSequence'},{'scalar'});


    if islogical(idxRemove)
        validateattributes(idxRemove,{'logical'},{'vector','numel',numel(psObj.Pulse)})
    else
        validateattributes(idxRemove,{'numeric'},{'integer','>=',1,'<=',numel(psObj.Pulse)});
    end





    psObj.Pulse(idxRemove)=[];


    psObj.populatePulseParameters();
