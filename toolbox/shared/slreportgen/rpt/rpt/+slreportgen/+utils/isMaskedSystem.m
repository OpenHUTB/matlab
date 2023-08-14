function isMasked=isMaskedSystem(obj)







    isMasked=false;

    if isValidSlObject(slroot,obj)
        if isa(obj,'Simulink.Object')
            type=get(obj,"Type");
        else
            type=get_param(obj,"Type");
        end

        if strcmp(type,"block")
            blockType=get_param(obj,"BlockType");

            if strcmp(blockType,"SubSystem")


                if isstring(obj)
                    obj=char(obj);
                end

                if~isempty(Simulink.Mask.get(obj))
                    isMasked=true;
                end
            end
        end
    end

end
