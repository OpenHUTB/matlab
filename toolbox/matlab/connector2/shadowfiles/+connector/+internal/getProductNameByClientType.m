function productName=getProductNameByClientType
    clientType=connector.internal.getClientType;

    productName='';
    if startsWith(clientType,'motw')||strcmp(clientType,'jsd_rmt_tmw')

        if matlab.internal.environment.context.isMATLABOnline
            productName='MATLAB Online';
        end
    elseif startsWith(clientType,'mobile')
        productName='MATLAB Mobile';
    elseif startsWith(clientType,'matlab-academy')
        productName='MATLAB Academy';
    end
