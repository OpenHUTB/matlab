function changeValue=excludeInactiveVariant(obj,explorer,value)




    try
        changeValue=true;
        currentCheckboxValue=obj.excludeInactiveVariantCheckboxValue;
        if(isequal(value,currentCheckboxValue))
            changeValue=false;
            return;
        end
        if(obj.isActiveRoot)
            obj.rememberToExcludeVariant=1;
            obj.rememberToExcludeVariantValue=value;
            if(isa(obj.data.cvd,'cvdata'))
                obj.data.getCvd().excludeInactiveVariants=value;
            else
                cvdg=obj.data.cvd.getAll;
                for i=1:length(cvdg)
                    if(value)
                        cvdg{i}.excludeInactiveVariants=true;
                    else
                        cvdg{i}.excludeInactiveVariants=false;
                    end
                end
            end
        else
            if(isa(obj.data.cvd,'cvdata'))
                data=obj.data;
                cvd=data.getCvd();
                if(value)
                    cvd.excludeInactiveVariants=true;
                else
                    cvd.excludeInactiveVariants=false;
                end
                obj.rememberToExcludeVariantValue=value;
            else
                cvdg=obj.data.cvd.getAll;
                obj.rememberToExcludeVariantValue=value;
                if~isempty(cvdg{1})

                    for i=1:length(cvdg)
                        if(value)
                            cvdg{i}.excludeInactiveVariants=true;
                        else
                            cvdg{i}.excludeInactiveVariants=false;
                        end
                    end
                end
            end
        end

        obj.data.resetSummary;

    catch MEx
        rethrow(MEx);
    end
end
