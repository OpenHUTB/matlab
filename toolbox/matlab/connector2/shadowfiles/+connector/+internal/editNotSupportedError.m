function ex=editNotSupportedError



    stack=dbstack(1);

    unsupportedFile=stack(1).name;
    topfile=stack(end).name;
    productName=connector.internal.getProductNameByClientType;

    if strcmp(unsupportedFile,topfile)
        if isempty(productName)
            ex=MException(message('MATLAB:connector:Platform:EditNotSupported',unsupportedFile));
        else
            ex=MException(message('MATLAB:connector:Platform:EditNotSupportedForProduct',unsupportedFile,productName));
        end
    else
        if isempty(productName)
            ex=MException(message('MATLAB:connector:Platform:DependentFunctionNotSupported',topfile,unsupportedFile));
        else
            ex=MException(message('MATLAB:connector:Platform:DependentFunctionNotSupportedForProduct',...
            topfile,unsupportedFile,productName));
        end
    end