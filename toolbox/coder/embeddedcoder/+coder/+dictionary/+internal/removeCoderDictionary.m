function removeCoderDictionary(srcName)






    if isnumeric(srcName)
        coderdictionary.data.SlCoderDataClient.removeModelCoderDictionary(srcName);
    else
        coderdictionary.data.api.removeSharedCoderDictionary(srcName)
    end


