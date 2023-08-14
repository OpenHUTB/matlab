classdef CharValueParser<handle
















    methods(Access={?FunctionApproximation.internal.AbstractUtils})
        function this=CharValueParser()
        end
    end

    methods
        function parsedValue=parse(~,value)
            parsedValue=value;
            isSimulinkModel=false;
            if ischar(value)||isstring(value)

                value=convertStringsToChars(value);
                try


                    [~,~,ext]=fileparts(which(Simulink.ID.getModel(value)));
                    isSimulinkModel=any(strcmp({'slx','mdl','slxp','mdlp'},ext(2:end)));
                catch
                end
            end

            if isSimulinkModel
                parsedValue=value;
            elseif iscell(value)
                parsedValue=zeros(size(value));
                for ii=1:numel(value)
                    parsedLocalValue=FunctionApproximation.internal.Utils.parseCharValue(value{ii});
                    if isnumeric(parsedLocalValue)
                        parsedValue(ii)=parsedLocalValue;
                    else
                        parsedValue=value;
                        break;
                    end
                end
            elseif ischar(value)||isstring(value)
                try
                    parsedValue=eval(value);
                    if isnumeric(parsedValue)
                        parsedValue=double(parsedValue);
                    end
                catch
                end
            end
        end
    end
end


