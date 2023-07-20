classdef Map<asam.cdfx.instance.Instance




    properties


SWAxisContainer



HasVG



ArrayDims
    end

    methods
        function obj=Map(root,sys,inst)



            obj=obj@asam.cdfx.instance.Instance(root,sys,inst);


            obj.PhysicalValue=obj.getPhysicalValues();


            obj.ArrayDims=size(obj.PhysicalValue);


            contElementArray=obj.ParameterSet.SW_AXIS_CONTS.SW_AXIS_CONT.toArray;
            obj.InstanceElement=obj.ParameterSet.SW_VALUE_CONT.SW_VALUES_PHYS.VG.toArray;


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
                error(message('asam_cdfx:CDFX:NumericValueElementMismatch',obj.ShortName));
            end

            if strcmp(obj.ValueType,"VT")&&~isstring(value.PhysicalValue)&&~ischar(value.PhysicalValue)
                error(message('asam_cdfx:CDFX:TextValueElementMismatch',obj.ShortName));
            end



            for jdx=1:obj.ArrayDims(1)
                for idx=1:obj.ArrayDims(2)

                    switch obj.ValueType
                    case "V"
                        obj.ValueContainerElement.SW_VALUES_PHYS.VG(jdx).V(idx).elementValue=string(value.PhysicalValue(jdx,idx));
                    case "VT"
                        obj.ValueContainerElement.SW_VALUES_PHYS.VG(jdx).VT(idx).elementValue=string(value.PhysicalValue(jdx,idx));
                    end

                end
            end


            for idx=1:numel(obj.SWAxisContainer)


                fieldName="Axis"+num2str(idx);


                if~obj.SWAxisContainer(idx).isReferencedAxis()
                    elementArray=obj.SWAxisContainer(idx).AxisContElement.SW_VALUES_PHYS.V.toArray;


                    for valIdx=1:numel(elementArray)
                        elementArray(valIdx).elementValue=string(value.(fieldName).PhysicalValue(valIdx));
                    end

                elseif~isequal(value.(fieldName),obj.Value.(fieldName))&&~isInternalModify

                    error(message('asam_cdfx:CDFX:ModifyReferencedAxis',obj.ShortName,obj.SWAxisContainer(idx).InstanceReference));
                end
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


            VG=obj.ValueContainerElement.SW_VALUES_PHYS.VG;
            value=openString;


            for vgIndex=1:VG.Size

                if vgIndex>1
                    value=value+"; ";
                end


                switch obj.ValueType
                case "V"
                    V=VG(vgIndex).V;
                case "VT"
                    V=VG(vgIndex).VT;
                end


                for vIndex=1:V.Size
                    if vIndex>1
                        value=value+", ";
                    end

                    value=value+" "+quoteString+string(V(vIndex).elementValue)+quoteString;
                end
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




            axisVals=cell(1,numel(obj.SWAxisContainer));


            for idx=1:numel(obj.SWAxisContainer)
                if(~obj.SWAxisContainer(idx).isReferencedAxis())
                    axisValue=struct("ReferenceName","","Category",obj.SWAxisContainer(idx).Category,"PhysicalValue",obj.SWAxisContainer(idx).PhysicalValue,"IsReferenced",false);
                else

                    axisInstanceName=obj.SWAxisContainer(idx).InstanceReference;


                    referencedInstance=obj.ParentSystem.SystemInstanceTable(strcmp(obj.ParentSystem.SystemInstanceTable.ShortName,axisInstanceName),:);


                    curveAxis=strcmp(referencedInstance.Category,"CURVE_AXIS");



                    if curveAxis
                        actualReferenceSize=size(referencedInstance.ObjectHandles(1).PhysicalValue,2);
                    else
                        actualReferenceSize=size(referencedInstance.ObjectHandles(1).PhysicalValue,1);
                    end
                    containerSize=actualReferenceSize;
                    if~isempty(obj.SWAxisContainer(idx).ReferenceSize)
                        containerSize=obj.SWAxisContainer(idx).ReferenceSize;
                        if obj.SWAxisContainer(idx).ReferenceSize>actualReferenceSize
                            error(message('asam_cdfx:CDFX:ContainerReferenceTooLarge',idx,obj.ShortName,obj.SWAxisContainer(idx).InstanceReference));
                        end
                    end

                    if curveAxis
                        axisValue=struct("ReferenceName",referencedInstance.ObjectHandles(1).ShortName,"Category",referencedInstance.ObjectHandles(1).Category,"PhysicalValue",referencedInstance.ObjectHandles(1).PhysicalValue(:,1:containerSize),"IsReferenced",true);
                    else
                        axisValue=struct("ReferenceName",referencedInstance.ObjectHandles(1).ShortName,"Category",referencedInstance.ObjectHandles(1).Category,"PhysicalValue",referencedInstance.ObjectHandles(1).PhysicalValue(1:containerSize,:),"IsReferenced",true);
                    end


                    if axisValue.Category=="CURVE_AXIS"
                        referencedInstance.ObjectHandles(1).resolveAxisValues();
                        axisValue.Axis1=referencedInstance.ObjectHandles(1).Value.Axis1;
                    end

                    referencedInstance.ObjectHandles(1).addReferencingInstance(obj,idx);
                end

                axisVals{idx}=axisValue;
            end


            obj.Value=struct("PhysicalValue",obj.PhysicalValue,"Axis1",axisVals{1},"Axis2",axisVals{2});
        end

        function valType=getValueType(~,valueContainer)



            if~isequal(valueContainer.SW_VALUES_PHYS.VG(1).V.Size,0)
                valType="V";
            else
                valType="VT";
            end
        end
    end
end


