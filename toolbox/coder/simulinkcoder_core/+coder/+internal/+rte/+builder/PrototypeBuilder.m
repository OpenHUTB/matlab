classdef PrototypeBuilder<handle




    properties
Prototype
CodeDesc
    end

    methods
        function this=PrototypeBuilder(prototype,codeDesc)
            this.Prototype=prototype;
            this.CodeDesc=codeDesc;
        end

        function str=emit(this)
            str=this.CodeDesc.getServiceFunctionDeclaration(this.Prototype);
        end

        function writeToFile(this,writer)
            writer.wLine([this.emit,';']);
        end
    end
end


