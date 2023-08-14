function SPSErrorOut=showSPSerror(SPSErrorIn)








    persistent SPS_ERROR;

    if nargin>0
        if isempty(SPSErrorIn)

            SPS_ERROR=[];
        else
            SPS_ERROR=cat(2,SPS_ERROR,SPSErrorIn);
        end

    end
    SPSErrorOut=SPS_ERROR;

end
