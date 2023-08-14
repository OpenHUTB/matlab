classdef ValueBlock<asam.cdfx.instance.Instance




    properties
HasVG
ArrayDims
    end

    methods
        function obj=ValueBlock(root,sys,inst)



            obj=obj@asam.cdfx.instance.Instance(root,sys,inst);


            arraySizeElement=obj.ValueContainerElement.SW_ARRAYSIZE;
            numDims=arraySizeElement.V.Size;
            dims=zeros(1,numDims);
            for idx=1:numDims
                dims(idx)=str2double(arraySizeElement.V(idx).elementValue);
            end


            if numDims==1
                dims=[1,dims];
            elseif numDims>1




                newDims=dims;
                newDims(1)=dims(2);
                newDims(2)=dims(1);
                dims=newDims;
            end


            obj.ArrayDims=dims;


            obj.InstanceElement=obj.ValueContainerElement.SW_VALUES_PHYS.V.toArray;


            obj.PhysicalValue=obj.getPhysicalValues();


            obj.Value=obj.PhysicalValue;

        end

        function setValue(obj,value,~)




            value=convertCharsToStrings(value);


            if~isnumeric(value)&&~isstring(value)
                error(message('asam_cdfx:CDFX:CategoryValueTypeMismatch',obj.Category));
            end

            if strcmp(obj.ValueType,"V")&&~isnumeric(value)
                error(message('asam_cdfx:CDFX:NumericValueElementMismatch',obj.ShortName))
            end

            if strcmp(obj.ValueType,"VT")&&~isstring(value)
                error(message('asam_cdfx:CDFX:TextValueElementMismatch',obj.ShortName))
            end

            if~all(size(value)==size(obj.PhysicalValue))
                error(message('asam_cdfx:CDFX:CategoryValueSizeMismatch',obj.Category));
            end


            obj.Value=value;
            obj.PhysicalValue=value;


            if~(numel(obj.ArrayDims)==2)||~(obj.ArrayDims(1)==1)
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
            else
                for idx=1:numel(obj.InstanceElement)
                    obj.InstanceElement(idx).elementValue=string(value(idx));
                end
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


            if numel(obj.ArrayDims)==2&&obj.ArrayDims(1)==1

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
            else


                VG=obj.ValueContainerElement.SW_VALUES_PHYS.VG;
                value=openString;


                for vgIndex=1:obj.ValueContainerElement.SW_VALUES_PHYS.VG.Size

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
            end


            switch obj.ValueType
            case "V"

                physVals=eval(value);
            case "VT"

                physVals=eval(convertCharsToStrings(value));


                physVals=convertCharsToStrings(physVals);
            end
        end

        function valType=getValueType(obj,valueContainer)



            arraySizeElement=valueContainer.SW_ARRAYSIZE;


            if isempty(arraySizeElement)
                error(message('asam_cdfx:CDFX:ArraySizeMissingFromValBlk',obj.ShortName));
            end
            numDims=arraySizeElement.V.Size;
            dims=zeros(1,numDims);
            for idx=1:numDims
                dims(idx)=str2double(arraySizeElement.V(idx).elementValue);
            end


            if numDims==1
                dims=[dims,1];
            end


            if numel(dims)==2&&dims(2)==1

                if~isequal(valueContainer.SW_VALUES_PHYS.V.Size,0)
                    valType="V";
                else
                    valType="VT";
                end
            else


                if~isequal(valueContainer.SW_VALUES_PHYS.VG.Size,0)
                    valType="V";
                else
                    valType="VT";
                end
            end
        end
    end
end

