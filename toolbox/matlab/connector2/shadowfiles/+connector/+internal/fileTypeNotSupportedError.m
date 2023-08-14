function ex=fileTypeNotSupportedError(file)



    [fileDir,fileName,fileExt]=fileparts(file);
    fileMsg=[fileName,fileExt];


    if~isempty(findstr(fileExt,'.'))
        fileExt=strtok(fileExt,'.');
    end







    productName=connector.internal.getProductNameByClientType;
    if isempty(productName)
        ex=MException(message(['MATLAB:connector:Platform:FileTypeNotSupported_',fileExt],fileMsg));
    else
        ex=MException(message(['MATLAB:connector:Platform:FileTypeNotSupportedForProduct_',fileExt],fileMsg,productName));
    end





