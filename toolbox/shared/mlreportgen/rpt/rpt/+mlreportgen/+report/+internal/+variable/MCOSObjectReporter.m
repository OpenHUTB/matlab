classdef MCOSObjectReporter<mlreportgen.report.internal.variable.StructuredObjectReporter





    methods
        function this=MCOSObjectReporter(reportOptions,varName,varValue)



            this@mlreportgen.report.internal.variable.StructuredObjectReporter(reportOptions,...
            varName,varValue);
        end
    end

    methods(Access=protected)

        function propNames=getObjectProperties(this)




            metaclassObj=metaclass(this.VarValue);
            props=metaclassObj.Properties;






            isNumericMCOS=isnumeric(this.VarValue);
            props=props(cellfun(@(prop)((~prop.Hidden||isNumericMCOS&&strcmp(prop.Name,'Value'))&&(ischar(prop.GetAccess)&&strcmp(prop.GetAccess,'public'))),props));



            if isa(this.VarValue,"meta.property")
                if~this.VarValue.HasDefault
                    props=props(cellfun(@(prop)~strcmp(prop.Name,"DefaultValue"),props));
                end
            end


            propNames=getFilteredPropNames(this,props);

            if isNumericMCOS


                valueIdx=strcmp(propNames,'Value');
                if any(valueIdx)
                    propNames(valueIdx)=[];
                    propNames=[{'Value'};propNames];
                end
            end
        end

        function tf=isFilteredProperty(this,object,property)



            try
                value=object.(property.Name);


                tf=...
...
                (~strcmp(property.GetAccess,"public"))||...
...
...
                (~this.ReportOptions.ShowDefaultValues&&property.HasDefault&&isequal(value,property.DefaultValue))||...
...
...
                (~this.ReportOptions.ShowEmptyValues&&isempty(value))||...
...
...
                (isFilteredProperty@mlreportgen.report.internal.variable.StructuredObjectReporter(this,object,property));
            catch
                tf=true;
            end

        end

    end

end