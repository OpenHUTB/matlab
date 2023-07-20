classdef UDDObjectReporter<mlreportgen.report.internal.variable.StructuredObjectReporter




    methods
        function this=UDDObjectReporter(reportOptions,varName,varValue)



            this@mlreportgen.report.internal.variable.StructuredObjectReporter(reportOptions,...
            varName,varValue);
        end
    end

    methods(Access=protected)

        function propNames=getObjectProperties(this)



            propNames={};
            if~isa(this.VarValue,'handle.listener')

                if isa(this.VarValue,'Simulink.DABaseObject')
                    metaclassObj=metaclass(this.VarValue);
                    allProps=metaclassObj.PropertyList;
                    if~isempty(allProps)
                        nProps=length(allProps);
                        props=cell(nProps,1);
                        for i=1:length(allProps)
                            if(allProps(i).Hidden==0)
                                props{i}=allProps(i);
                            end
                        end

                        visibleProps=props(~cellfun(@isempty,props));

                        propNames=getFilteredPropNames(this,visibleProps);
                    end
                else
                    metaclassObj=classhandle(this.VarValue);
                    if~isempty(metaclassObj.Properties)
                        propSchemas=find(metaclassObj.Properties,'Visible','on');
                        nProps=length(propSchemas);
                        props=cell(nProps,1);
                        for i=1:nProps
                            props{i}=propSchemas(i);
                        end


                        propNames=getFilteredPropNames(this,props);
                    end
                end
            end
        end

        function tf=isFilteredProperty(this,object,property)



            try
                value=object.(property.Name);

                if isa(property,'meta.property')
                    accessPublicGet=strcmp(property.GetAccess,"public");
                    isEqualDefault=property.HasDefault&&isequal(value,property.DefaultValue);
                else
                    accessPublicGet=strcmp(property.Access.PublicGet,"on");
                    isEqualDefault=isequal(value,property.FactoryValue);
                end


                tf=...
...
                (~accessPublicGet)||...
...
...
                (~this.ReportOptions.ShowDefaultValues&&isEqualDefault)||...
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

