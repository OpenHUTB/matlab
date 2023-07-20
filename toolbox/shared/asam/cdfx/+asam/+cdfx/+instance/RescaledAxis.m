classdef RescaledAxis<asam.cdfx.instance.Instance




    properties
HasVG
ArrayDims
        ReferencingInstances asam.cdfx.instance.Instance
ReferencingAxisIndices
    end


    methods
        function obj=RescaledAxis(root,sys,inst)



            obj=obj@asam.cdfx.instance.Instance(root,sys,inst);


            obj.PhysicalValue=obj.getPhysicalValues();
            obj.Value=obj.PhysicalValue;


            obj.InstanceElement=obj.ParameterSet.SW_VALUE_CONT.SW_VALUES_PHYS.VG.toArray;


            obj.ArrayDims=size(obj.PhysicalValue);
        end

        function setValue(obj,value,~)




            if~isnumeric(value)&&~isstring(value)&&~ischar(value)
                error(message('asam_cdfx:CDFX:CategoryValueTypeMismatch',obj.Category));
            end

            if~all(size(value)==size(obj.PhysicalValue))||size(value,2)~=2
                error(message('asam_cdfx:CDFX:CategoryValueSizeMismatch',obj.Category));
            end

            if strcmp(obj.ValueType,"V")&&~isnumeric(value)
                error(message('asam_cdfx:CDFX:NumericValueElementMismatch',obj.ShortName))
            end

            if strcmp(obj.ValueType,"VT")&&~isstring(value)&&~ischar(value)
                error(message('asam_cdfx:CDFX:TextValueElementMismatch',obj.ShortName))
            end



            obj.Value=value;
            obj.PhysicalValue=value;


            for jdx=1:obj.ArrayDims(1)
                for idx=1:obj.ArrayDims(2)

                    switch obj.ValueType
                    case "V"
                        obj.ValueContainerElement.SW_VALUES_PHYS.VG(jdx).V(idx).elementValue=string(value(jdx,idx));
                    case "VT"
                        obj.ValueContainerElement.SW_VALUES_PHYS.VG(jdx).VT(idx).elementValue=string(value(jdx,idx));
                    end
                end
            end




            for idx=1:numel(obj.ReferencingInstances)

                instanceValue=getValue(obj.Root,obj.ReferencingInstances(idx).ShortName,obj.ParentSystem.ShortName);



                axisPropertyName="Axis"+num2str(obj.ReferencingAxisIndices(idx));


                instanceValue.(axisPropertyName).PhysicalValue=value;



                setValueInternal(obj.Root,obj.ReferencingInstances(idx).ShortName,obj.ParentSystem.ShortName,instanceValue);
            end

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


            for vgIndex=1:VG.Size;

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

        function addReferencingInstance(obj,refInstance,axisIndex)




            obj.ReferencingInstances(end+1)=refInstance;
            obj.ReferencingAxisIndices(end+1)=axisIndex;
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

