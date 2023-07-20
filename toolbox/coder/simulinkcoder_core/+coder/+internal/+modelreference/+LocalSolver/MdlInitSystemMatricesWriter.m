classdef MdlInitSystemMatricesWriter<coder.internal.modelreference.MdlInitSystemMatricesWriter




    methods(Access=public)
        function this=MdlInitSystemMatricesWriter(modelInterface,writer,headerWriter)
            this@coder.internal.modelreference.MdlInitSystemMatricesWriter(modelInterface,writer);
            this.Linkage=coder.internal.modelreference.FunctionLinkage.External;
            this.HeaderWriter=headerWriter;
        end
    end



    methods(Access=protected)
        function p=getFunctionPrototype(this)
            p=['void mdlInitSystemMatrices_',this.ModelInterface.Name,'(SimStruct *S)'];
        end
    end
end
