function ex=notSupportedError




    stack=dbstack(1);

    unsupportedFile=stack(1).name;
    topfile=stack(end).name;
    productName=connector.internal.getProductNameByClientType;

    if strcmp(unsupportedFile,topfile)
        if isempty(productName)
            ex=MException(message('MATLAB:connector:Platform:FunctionNotSupported',unsupportedFile));
        else
            ex=MException(message('MATLAB:connector:Platform:FunctionNotSupportedForProduct',unsupportedFile,productName));
        end
    else
        if isempty(productName)
            ex=MException(message('MATLAB:connector:Platform:DependentFunctionNotSupported',topfile,unsupportedFile));
        else
            ex=MException(message('MATLAB:connector:Platform:DependentFunctionNotSupportedForProduct',...
            topfile,unsupportedFile,productName));
        end
    end

    if~isempty(productName)&&strcmp(productName,'MATLAB Online')

        exTripwire=MException(message('MATLAB:connector:Platform:FunctionTripwireSuffix'));
        ex=MException(ex.identifier,[ex.message,' ',exTripwire.message]);
    end
