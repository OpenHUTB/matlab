function formattedString=utilFormatToString(originalVar)

    if ischar(originalVar)
        formattedString=originalVar;
        return;
    end


    if rem(originalVar,1)==0
        formattedString=sprintf('%d',int32(originalVar));
    else

        if originalVar>10
            formattedString=sprintf('%3.2f',originalVar);
        elseif originalVar>0.01
            formattedString=sprintf('%1.2f',originalVar);
        else
            formattedString=sprintf('%1.2e',originalVar);
        end
    end
end