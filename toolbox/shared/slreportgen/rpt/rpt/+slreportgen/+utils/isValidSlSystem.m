function isValid=isValidSlSystem(system)









    isValid=false;
    if isValidSlObject(slroot,system)
        try
            type=get_param(system,"Type");
            if strcmp(type,"block_diagram")

                isValid=true;
            elseif strcmp(type,"block")
                blockType=get_param(system,"BlockType");
                if strcmp(blockType,"SubSystem")

                    isValid=true;
                end
            end
        catch
            isValid=false;
        end
    end

end

