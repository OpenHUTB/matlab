function checkNonASCII(inputStr,paramName)




    if downstream.tool.isNonASCII(inputStr)
        error(message('hdlcommon:workflow:I18nInName',paramName,inputStr));
    end

end
