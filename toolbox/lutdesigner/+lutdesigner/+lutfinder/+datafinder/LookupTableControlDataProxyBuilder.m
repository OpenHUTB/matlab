classdef LookupTableControlDataProxyBuilder<handle
    properties(SetAccess=immutable)
MaskOwnerPath
ControlObject
    end

    methods
        function this=LookupTableControlDataProxyBuilder(maskOwner,controlName)
            this.MaskOwnerPath=regexprep(getfullname(maskOwner),'\n',' ');
            this.ControlObject=Simulink.Mask.get(this.MaskOwnerPath).getDialogControl(controlName);
        end

        function tf=isControlUsingLookupTableObject(this)
            if isempty(this.ControlObject.DataSpecification)
                tf=~isempty(this.ControlObject.LookupTableObject);
            else
                tf=strcmp(get_param(this.MaskOwnerPath,this.ControlObject.DataSpecification),'Lookup table object');
            end
        end

        function dataProxy=getDataProxy(this)
            import lutdesigner.data.proxy.LookupTableWithImposedWriteRestriction
            import lutdesigner.data.restriction.WriteRestriction

            if this.isControlUsingLookupTableObject()
                dataProxy=this.getDataProxyForObject();
            else
                dataProxy=this.getDataProxyForBreakpointsAndTable();
            end

            if strcmp(this.ControlObject.Enabled,'off')
                dataProxy=LookupTableWithImposedWriteRestriction(...
                dataProxy,WriteRestriction('lutdesigner:data:accessedFromDisabledLookupTableControl'));
            end
        end
    end

    methods(Access=private)
        function dataProxy=getDataProxyForObject(this)
            import lutdesigner.lutfinder.datafinder.internal.findParameterStringSource
            import lutdesigner.data.proxy.LookupTableObject
            import lutdesigner.data.proxy.BreakpointObject
            import lutdesigner.data.proxy.LUTOTableObject
            import lutdesigner.data.proxy.CompoundLookupTable

            objectSource=findParameterStringSource(this.MaskOwnerPath,this.ControlObject.LookupTableObject,...
            get_param(this.MaskOwnerPath,this.ControlObject.LookupTableObject));

            if~isempty(objectSource.getReadRestrictions())

                dataProxy=LookupTableObject(objectSource);
                return;
            end

            luto=objectSource.read();
            if strcmp(luto.BreakpointsSpecification,'Reference')

                tableProxy=LUTOTableObject(objectSource);
                numAxes=numel(luto.Breakpoints);
                axisProxies=cell(1,numAxes);
                for i=1:numAxes
                    axisSource=findParameterStringSource(this.MaskOwnerPath,this.ControlObject.LookupTableObject,luto.Breakpoints{i});
                    axisProxies{i}=BreakpointObject(axisSource);
                end
                dataProxy=CompoundLookupTable(axisProxies,tableProxy);
                return;
            end


            dataProxy=LookupTableObject(objectSource);
        end

        function dataProxy=getDataProxyForBreakpointsAndTable(this)
            import lutdesigner.data.source.lookuptablecontrol.Breakpoint
            import lutdesigner.data.source.lookuptablecontrol.Table
            import lutdesigner.data.proxy.CompoundLookupTable

            axisProxies=arrayfun(@(dimIndex)this.getPropertyProxy(Breakpoint(dimIndex)),...
            1:numel(this.ControlObject.Breakpoints),'UniformOutput',false);
            tableProxy=this.getPropertyProxy(Table);
            dataProxy=CompoundLookupTable(axisProxies,tableProxy);
        end

        function propertyProxy=getPropertyProxy(this,controlPropertyAccessStrategy)
            import lutdesigner.lutfinder.datafinder.internal.findParameterStringSource
            import lutdesigner.data.source.LookupTableControlMetaField
            import lutdesigner.data.proxy.BreakpointObject
            import lutdesigner.data.proxy.SimulinkParameter
            import lutdesigner.data.proxy.CompoundExplicitMatrix
            import lutdesigner.data.proxy.MatrixParameterWithImposedUnit
            import lutdesigner.data.proxy.MatrixParameterWithImposedFieldName

            propertyControl=controlPropertyAccessStrategy.getControl(this.ControlObject);
            propertySource=findParameterStringSource(this.MaskOwnerPath,propertyControl.Name,...
            get_param(this.MaskOwnerPath,propertyControl.Name));

            if~isempty(propertySource.getReadRestrictions())

                propertyProxy=CompoundExplicitMatrix(propertySource);
                return;
            end

            data=propertySource.read();
            if isa(data,'Simulink.Parameter')
                propertyProxy=SimulinkParameter(propertySource);
            elseif isa(data,'Simulink.Breakpoint')
                propertyProxy=BreakpointObject(propertySource);
            else
                propertyProxy=CompoundExplicitMatrix(propertySource);
            end

            if~isempty(propertyControl.Unit)
                propertyProxy=MatrixParameterWithImposedUnit(propertyProxy,...
                LookupTableControlMetaField(this.MaskOwnerPath,this.ControlObject.Name,controlPropertyAccessStrategy,'Unit'));
            end

            if~isempty(propertyControl.FieldName)
                propertyProxy=MatrixParameterWithImposedFieldName(propertyProxy,...
                LookupTableControlMetaField(this.MaskOwnerPath,this.ControlObject.Name,controlPropertyAccessStrategy,'FieldName'));
            end
        end
    end
end
