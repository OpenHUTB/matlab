classdef RuntimeEnvironment<coder.dictionary.internal.CoderDataEntry




    methods(Static)


        function allprops=getAllProps(~)
            allprops={'Name','Description','DataSource'};
        end

        function allowedVals=getAllowedPropVals(~,~)
            allowedVals='';
        end



        function out=isValidPropertyForSection(propName,entry)
            props=coder.dictionary.internal.RuntimeEnvironment.getAllProps(entry);
            out=any(ismember(props,propName));
        end


        function checkValidProperty(entry,propName,~)
            import coder.dictionary.internal.FunctionCustomizationTemplate.*;
            checkValidPropertyForSection(propName,entry);
        end


        function checkValidPropertyForSection(propName,entry)
            if~coder.dictionary.internal.RuntimeEnvironment.isValidPropertyForSection(propName,entry)
                DAStudio.error('SimulinkCoderApp:data:InvalidPropertyName',propName);
            end
        end



        function fc=copy(entry,dest)
            fc=entry.copyTo(dest);
        end
    end
end


