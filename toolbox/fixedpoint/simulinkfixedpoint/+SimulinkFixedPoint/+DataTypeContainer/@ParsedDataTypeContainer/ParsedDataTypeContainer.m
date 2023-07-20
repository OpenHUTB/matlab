classdef ParsedDataTypeContainer<SimulinkFixedPoint.DataTypeContainer.Interface






    properties(SetAccess=protected)
        OriginalString;
        ResolvedString;
        ResolvedType;
    end

    properties(Access=protected)
        DataTypeContainerInfo;
    end

    methods
        function this=ParsedDataTypeContainer(dataTypeString,context)

            stringAdapter=SimulinkFixedPoint.DataTypeContainer.CompiledTypeStringAdapter(dataTypeString);


            dTContainerInfo=SimulinkFixedPoint.DTContainerInfo(stringAdapter.NewString,context);


            this.DataTypeContainerInfo=dTContainerInfo;
            this.OriginalString=dataTypeString;
            this.ResolvedString=dTContainerInfo.evaluatedDTString;
            this.ResolvedType=dTContainerInfo.evaluatedNumericType;
        end
        function flag=isUnknown(this)
            flag=isUnknown(this.DataTypeContainerInfo);
        end
        function flag=isFloat(this)
            flag=isFloat(this.DataTypeContainerInfo);
        end
        function flag=isFixed(this)
            flag=isFixed(this.DataTypeContainerInfo);
        end
        function flag=isInherited(this)
            flag=isInherited(this.DataTypeContainerInfo);
        end
        function flag=isAlias(this)
            flag=isAlias(this.DataTypeContainerInfo);
        end
        function flag=isEnum(this)
            flag=isEnum(this.DataTypeContainerInfo);
        end
        function flag=isBoolean(this)
            flag=isBoolean(this.DataTypeContainerInfo);
        end
        function flag=isBus(this)
            flag=isBus(this.DataTypeContainerInfo);
        end
        function flag=isDouble(this)
            flag=isDouble(this.DataTypeContainerInfo);
        end
        function flag=isSingle(this)
            flag=isSingle(this.DataTypeContainerInfo);
        end
        function flag=isHalf(this)
            flag=isHalf(this.DataTypeContainerInfo);
        end
        function flag=isBuiltInInteger(this)
            flag=isBuiltInInteger(this.DataTypeContainerInfo);
        end
        function flag=isScaledDouble(this)
            flag=isScaledDouble(this.DataTypeContainerInfo);
        end
        function minimum=min(this)
            minimum=min(this.DataTypeContainerInfo);
        end
        function maximum=max(this)
            maximum=max(this.DataTypeContainerInfo);
        end
        function epsValue=getEps(this)
            epsValue=getEps(this.DataTypeContainerInfo);
        end
        function object=struct(this)


            object=this;
        end
    end

    methods(Hidden)
        function resolvedObject=getResolvedObject(this)






            resolvedObject=getResolvedObj(this.DataTypeContainerInfo);
        end
    end

    methods(Hidden)
        function childContainer=getChildContainer(this)

            childContainer=this.DataTypeContainerInfo;
        end
    end
end


