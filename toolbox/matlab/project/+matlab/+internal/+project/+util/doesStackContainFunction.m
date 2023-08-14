function functionPresent=doesStackContainFunction(functionName)





    stack=dbstack();
    functionPresent=false;

    for idx=1:numel(stack)
        if strcmp(stack(idx).name,functionName)
            functionPresent=true;
            break;
        end
    end

end