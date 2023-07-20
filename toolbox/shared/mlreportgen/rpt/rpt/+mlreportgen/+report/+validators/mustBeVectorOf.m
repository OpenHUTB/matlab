function mustBeVectorOf(classes,value)







    if~condition(classes,value)
        classStr=strjoin(classes,"', '");
        throw(createValidatorException(...
        "mlreportgen:report:validators:mustBeVectorOf",classStr));
    end
end

function isValid=condition(classes,items)

    isValid=true;
    if~isempty(items)

        if~isvector(items)
            isValid=false;
        else

            if~iscell(items)
                items=num2cell(items);
            end


            nItems=numel(items);
            try
                for itemIdx=1:nItems
                    mlreportgen.report.validators.mustBeInstanceOfMultiClass(classes,items{itemIdx});
                end
            catch
                isValid=false;
            end
        end
    end

end
