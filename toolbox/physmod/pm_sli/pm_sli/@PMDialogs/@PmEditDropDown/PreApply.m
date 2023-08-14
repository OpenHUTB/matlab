function[status,messageString]=PreApply(hThis)





    status=true;
    messageString='';
    if~isempty(hThis.PreApplyFcn)
        [status,messageString]=hThis.PreApplyFcn(hThis.Value);
    end
end

