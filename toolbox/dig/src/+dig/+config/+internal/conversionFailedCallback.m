function conversionFailedCallback(userdata,~)
    throw(MException(message('dig:config:resources:CallbackConversionFailed',userdata)));
end