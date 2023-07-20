classdef(Sealed)ParsedDataTypeInBaseWorkspace<SimulinkFixedPoint.DataTypeContainer.ParsedDataTypeContainer








    methods
        function this=ParsedDataTypeInBaseWorkspace(dataTypeString)
            try

                evaluatedObject=evalin('base',dataTypeString);
            catch
                evaluatedObject=[];
            end

            newString=dataTypeString;
            context=[];
            if(isa(evaluatedObject,'Simulink.NumericType')||isnumerictype(evaluatedObject))

                newString=evaluatedObject.tostring();
            elseif isa(evaluatedObject,'Simulink.AliasType')


                parsedObject=SimulinkFixedPoint.DataTypeContainer.ParsedDataTypeInBaseWorkspace(evaluatedObject.BaseType);
                newString=parsedObject.ResolvedString;
            elseif(ischar(evaluatedObject)||isstring(evaluatedObject))


                parsedObject=SimulinkFixedPoint.DataTypeContainer.ParsedDataTypeInBaseWorkspace(evaluatedObject);
                newString=parsedObject.ResolvedString;
            elseif isa(evaluatedObject,'Simulink.Bus')
                context=get_param(new_system(),'Object');
            end

            this=this@SimulinkFixedPoint.DataTypeContainer.ParsedDataTypeContainer(newString,context);
            this.OriginalString=dataTypeString;
            if~isempty(context)

                close_system(context.Name);
            end
        end
    end
end


