function out=disableRunSpecificCustomization(in)



    mlock;
    persistent disableSpecificCustomization;
    if nargin
        disableSpecificCustomization=in;
    end
    out=disableSpecificCustomization;
end