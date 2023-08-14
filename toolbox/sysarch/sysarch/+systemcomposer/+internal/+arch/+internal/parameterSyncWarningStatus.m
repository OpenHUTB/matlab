function status=parameterSyncWarningStatus(newStatus)





    persistent warningStatus;


    if isempty(warningStatus)
        warningStatus=false;
    end


    status=warningStatus;


    if nargin==1
        warningStatus=newStatus;
    end

end