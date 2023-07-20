


classdef SimulinkServicesWriter<handle
    properties(SetAccess=private,GetAccess=private)
ModelInterfaceUtils
ModelInterface
CodeInfo
Writer
    end


    methods(Access=public)
        function this=SimulinkServicesWriter(modelInterfaceUtils,codeInfoUtils,writer)
            this.ModelInterfaceUtils=modelInterfaceUtils;
            this.ModelInterface=modelInterfaceUtils.getModelInterface;
            this.CodeInfo=codeInfoUtils.getCodeInfo;
            this.Writer=writer;
        end
    end



    methods(Access=public)
        function write(this,isProviding)
            if this.ModelInterface.NumServicePorts<=0
                return;
            end

            servicePorts=coder.internal.modelreference.Utilities.getFieldData(...
            this.ModelInterface,'ServicePort');

            for i=1:this.ModelInterface.NumServicePorts
                svcPort=servicePorts{i};
                writerObjects={...
                coder.internal.modelreference.MessageServiceWriter(...
                this.ModelInterfaceUtils,this.CodeInfo,this.Writer,svcPort)...
                };

                cellfun(@(obj)obj.write(isProviding),writerObjects);
            end
        end
    end
end
