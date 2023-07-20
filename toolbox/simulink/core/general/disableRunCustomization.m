function out=disableRunCustomization(in)



    mlock;
    persistent disableCustomization;
    if nargin
        disableCustomization=in;
    end
    out=disableCustomization;
end