


classdef(Hidden=true)FMUInterfaceBuilder<handle
    properties(Access=private)
ModelInfoUtils
CFileName
XMLFileName
DocFileName
    end


    methods(Access=public)
        function this=FMUInterfaceBuilder(modelInfoUtils,cFileName,xmlFileName)
            this.ModelInfoUtils=modelInfoUtils;
            this.CFileName=cFileName;
            this.XMLFileName=xmlFileName;
            this.DocFileName='index.html';
        end

        function writerObj=getWrapperWriterObject(this)
            writerObj=coder.internal.fmuexport.fmi2WrapperWriter(this.ModelInfoUtils,this.CFileName);
        end
        function writerObj=getXMLWriterObject(this)
            writerObj=Simulink.fmuexport.internal.fmi2ModelDescriptionWriter(this.ModelInfoUtils,this.XMLFileName);
            writerObj.write
        end
        function writerObj=getDocWriterObject(this)
            writerObj=coder.internal.fmuexport.fmi2DocWriter(this.ModelInfoUtils,this.DocFileName);
        end
    end
end
