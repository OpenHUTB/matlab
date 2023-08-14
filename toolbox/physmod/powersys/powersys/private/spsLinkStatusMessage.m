function out=spsLinkStatusMessage(in)










    persistent value;

    if nargin
        value=in;
    else
        out=value;
    end