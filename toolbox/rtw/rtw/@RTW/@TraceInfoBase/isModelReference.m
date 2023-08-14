function out=isModelReference(h)




    if strcmp(h.CurrentModelReferenceTargetType,'mdlref')

        out=true;
    elseif strcmp(h.CurrentModelReferenceTargetType,'none')

        out=false;
    else


        out=false;
    end

