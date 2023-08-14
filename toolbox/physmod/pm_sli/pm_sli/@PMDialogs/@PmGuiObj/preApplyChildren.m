function[status,messageString]=preApplyChildren(hThis)





    status=true;
    messageString='';
    nItems=length(hThis.Items);
    for idx=1:nItems
        [status,messageString]=hThis.Items(idx).PreApply();
        if(~status)
            return;
        end
    end
