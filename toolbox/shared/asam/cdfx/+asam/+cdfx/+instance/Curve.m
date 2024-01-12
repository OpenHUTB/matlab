classdef Curve<asam.cdfx.instance.Instance

    properties

SWAxisContainer

HasVG

ArrayDims
    end


    methods
        function obj=Curve(root,sys,inst)
            obj=obj@asam.cdfx.instance.Instance(root,sys,inst);
            obj.PhysicalValue=obj.getPhysicalValues();
            obj.ArrayDims=size(obj.PhysicalValue);
            contElementArray=obj.ParameterSet.SW_AXIS_CONTS.SW_AXIS_CONT.toArray;

            obj.InstanceElement=obj.ParameterSet.SW_VALUE_CONT.SW_VALUES_PHYS.V.toArray;

            for idx=1:numel(contElementArray)
                obj.SWAxisContainer=[obj.SWAxisContainer,asam.cdfx.AxisContainerFactory(root,sys,contElementArray(idx))];
            end

        end


        function setValue(obj,value,isInternalModify)

            if~isstruct(value)
                error(message('asam_cdfx:CDFX:CategoryValueTypeMismatch',obj.Category));
            end

            if~isscalar(value)||~all(size(value.PhysicalValue)==size(obj.PhysicalValue))
                error(message('asam_cdfx:CDFX:CategoryValueSizeMismatch',obj.Category));
            end

            if strcmp(obj.ValueType,"V")&&~isnumeric(value.PhysicalValue)
                error(message('asam_cdfx:CDFX:NumericValueElementMismatch',obj.ShortName))
            end

            if strcmp(obj.ValueType,"VT")&&~isstring(value.PhysicalValue)
                error(message('asam_cdfx:CDFX:TextValueElementMismatch',obj.ShortName))
            end


            for idx=1:numel(obj.InstanceElement)
                obj.InstanceElement(idx).elementValue=string(value.PhysicalValue(idx));
            end
            if~obj.SWAxisContainer.isReferencedAxis()
                elementArray=obj.SWAxisContainer.AxisContElement.SW_VALUES_PHYS.V.toArray;

                for idx=1:numel(elementArray)
                    elementArray(idx).elementValue=string(value.Axis1.PhysicalValue(idx));
                end
            elseif~isequal(value.Axis1,obj.Value.Axis1)&&~isInternalModify

                error(message('asam_cdfx:CDFX:ModifyReferencedAxis',obj.ShortName,obj.SWAxisContainer.InstanceReference));
            end

            obj.Value=value;
            obj.PhysicalValue=value.PhysicalValue;

        end


        function physVals=getPhysicalValues(obj)

            switch obj.ValueType
            case "V"
                quoteString="";
                openString="[";
                closeString="]";
            case "VT"
                quoteString="'";
                openString="{";
                closeString="}";
            end

            switch obj.ValueType
            case "V"
                V=obj.ValueContainerElement.SW_VALUES_PHYS.V;
            case "VT"
                V=obj.ValueContainerElement.SW_VALUES_PHYS.VT;
            end

            value=openString;
            for vIndex=1:V.Size
                if vIndex>1
                    value=value+", ";
                end
                value=value+quoteString+string(V(vIndex).elementValue)+quoteString;
            end
            value=value+closeString;

            switch obj.ValueType
            case "V"

                physVals=eval(value);
            case "VT"
                physVals=eval(convertCharsToStrings(value));
                physVals=convertCharsToStrings(physVals);
            end
        end


        function resolveAxisValues(obj)
            if(~obj.SWAxisContainer.isReferencedAxis())
                axisVals=struct("ReferenceName","","Category",obj.SWAxisContainer.Category,"PhysicalValue",obj.SWAxisContainer.PhysicalValue,"IsReferenced",false);
            else
                axisInstanceName=obj.SWAxisContainer.InstanceReference;
                referencedInstance=obj.ParentSystem.SystemInstanceTable(strcmp(obj.ParentSystem.SystemInstanceTable.ShortName,axisInstanceName),:);
                actualReferenceSize=size(referencedInstance.ObjectHandles(1).PhysicalValue,1);
                containerSize=actualReferenceSize;
                if~isempty(obj.SWAxisContainer.ReferenceSize)
                    containerSize=obj.SWAxisContainer.ReferenceSize;
                    if obj.SWAxisContainer.ReferenceSize>actualReferenceSize
                        error(message('asam_cdfx:CDFX:ContainerReferenceTooLarge',1,obj.ShortName,obj.SWAxisContainer.InstanceReference));
                    end
                end
                axisVals=struct("ReferenceName",referencedInstance.ObjectHandles(1).ShortName,"Category",referencedInstance.ObjectHandles(1).Category,"PhysicalValue",referencedInstance.ObjectHandles(1).PhysicalValue(1:containerSize,:),"IsReferenced",true);

                if axisVals.Category=="CURVE_AXIS"
                    referencedInstance.ObjectHandles(1).resolveAxisValues();
                    axisVals.Axis1=referencedInstance.ObjectHandles(1).Value.Axis1;
                end
                referencedInstance.ObjectHandles(1).addReferencingInstance(obj,1);
            end
            obj.Value=struct("PhysicalValue",obj.PhysicalValue,"Axis1",axisVals);

        end


        function valType=getValueType(~,valueContainer)
            if~isequal(valueContainer.SW_VALUES_PHYS.V.Size,0)
                valType="V";
            else
                valType="VT";
            end
        end
    end
end


