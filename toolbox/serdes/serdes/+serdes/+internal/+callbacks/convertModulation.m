



function to=convertModulation(from)
    to=[];
    for fromIdx=1:length(from)
        if isa(from(fromIdx),"numeric")
            if from(fromIdx)==2
                to=[to,"NRZ"];%#ok<*AGROW> 
            elseif from(fromIdx)>1
                to=[to,"PAM"+mat2str(from(fromIdx))];
            else
                error(message("serdes:callbacks:InvalidModulation"))
            end
        elseif isa(from(fromIdx),"string")
            if strcmp(from(fromIdx),"NRZ")
                to=[to,2];
            elseif startsWith(from(fromIdx),"PAM")
                to=[to,str2double(extractAfter(from(fromIdx),"PAM"))];
            else
                error(message("serdes:callbacks:InvalidModulation"))
            end
        elseif isa(from,'char')

            if strcmp(from,"NRZ")
                to=[to,2];
                return
            elseif startsWith(from,"PAM")
                to=[to,str2double(extractAfter(from,"PAM"))];
                return
            elseif~isnan(str2double(from))
                to=serdes.internal.callbacks.convertModulation(str2double(from));
            else
                error(message("serdes:callbacks:InvalidModulation"))
            end
        else
            error(message("serdes:callbacks:InvalidModulation"))
        end
    end
end