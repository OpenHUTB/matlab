classdef AccessMethodBuilder<handle




    properties
        Name;
        Rule;
        Data;
        Functions;
        DataBuilder;
        CodeDesc;
        ProtoBuilders={};
        DefBuilders={};
    end

    methods
        function this=AccessMethodBuilder(baseName,rule,data,functions,codeDesc)
            this.Name=baseName;
            this.Rule=rule;
            this.Functions=functions;
            this.Data=data;
            this.CodeDesc=codeDesc;
            this.constructBuilders;
        end
    end

    methods(Access=private)
        function constructBuilders(this)
            this.DataBuilder=coder.internal.rte.builder.AccessMethodBuilder.constructDataBuilder(this.Data,this.Name);
            for i=1:this.Functions.Size
                fcn=this.Functions(i);
                this.populateDataBuilder(fcn);
                this.ProtoBuilders{end+1}=this.constructPrototypeBuilder(fcn.Prototype,this.CodeDesc);
                this.DefBuilders{end+1}=this.constructDefinitionBuilder(this.ProtoBuilders{end},fcn.FunctionType);
            end
        end

        function populateDataBuilder(this,func)
            if~this.returnVarItself(func)



                assert(func.Prototype.Arguments.Size==1);
                if func.FunctionType==coder.descriptor.DataTransferFunctionType.Get
                    this.DataBuilder.assignReader(func.Prototype.Arguments(1));
                else
                    assert(func.FunctionType==coder.descriptor.DataTransferFunctionType.Set);
                    this.DataBuilder.assignWriter(func.Prototype.Arguments(1));
                end
            end
        end

        function res=returnVarItself(~,func)
            if func.IOAccessMode==coder.descriptor.IOAccessModes.BY_REFERENCE


                res=true;
            elseif func.IOAccessMode==coder.descriptor.IOAccessModes.NOT_ACCESS_IO
                res=true;
            elseif func.IOAccessMode==coder.descriptor.IOAccessModes.BY_VALUE

                res=func.FunctionType==coder.descriptor.DataTransferFunctionType.Get;
            else
                res=false;
            end
        end

        function builder=constructPrototypeBuilder(~,proto,codeDesc)
            assert(~isempty(proto));
            builder=coder.internal.rte.builder.PrototypeBuilder(proto,codeDesc);
        end

        function builder=constructDefinitionBuilder(this,protoBuilder,fcnType)
            builder=coder.internal.rte.builder.DefinitionBuilder(protoBuilder,this.DataBuilder,fcnType);
        end
    end

    methods(Static)
        function builder=makeBuilder(dataTransElem,codeDesc)
            import coder.internal.rte.builder.*
            baseName=dataTransElem.Name;
            rule=dataTransElem.DataCommunicationMethod;
            functions=dataTransElem.Functions;
            data=AccessMethodBuilder.getDataTransElemData(dataTransElem);
            builder=AccessMethodBuilder(baseName,rule,data,functions,codeDesc);
        end

        function builder=constructDataBuilder(Data,Name)
            if Data.isScalar
                builder=coder.internal.rte.builder.ScalarDataBuilder(Data,Name);
            elseif Data.isPointer&&Data.BaseType.isComplex
                builder=coder.internal.rte.builder.ComplexDataBuilder(Data,Name);
            elseif Data.isPointer&&Data.BaseType.isStructure
                builder=coder.internal.rte.builder.StructDataBuilder(Data,Name);
            else
                builder=coder.internal.rte.builder.ArrayDataBuilder(Data,Name);
            end
        end


        function data=getDataTransElemData(dataTransElem)
            assert(dataTransElem.Functions.Size>0);



            proto=dataTransElem.Functions(1).Prototype;
            if~isempty(proto.Return)
                data=proto.Return.Type;
            else
                assert(proto.Arguments.Size>0);
                data=proto.Arguments(1).Type;
            end
        end
    end
end
