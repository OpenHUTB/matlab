classdef ComponentToArchitectureSubsystemReferenceConverter<systemcomposer.internal.arch.internal.ComponentToReferenceConverter





    methods(Access=public)
        function obj=ComponentToArchitectureSubsystemReferenceConverter(blkH,mdlName,dirPath)

            if(nargin==2)
                dirPath=string(pwd);
            end



            obj@systemcomposer.internal.arch.internal.ComponentToReferenceConverter(blkH,mdlName,dirPath);
        end

        function modelBlockHdl=convert(obj)

            modelBlockHdl=obj.convertComponentToReference();
        end
    end

    methods(Access=protected)
        function createReferenceModelHook(obj)
            if isempty(obj.Template)
                bdH=new_system(obj.ModelName,'Subsystem','SimulinkSubDomain','Architecture');
            else

                assert(false,'Template is not yet supported');
            end
            obj.ModelHandle=get_param(bdH,'Handle');
        end

        function linkComponentToModelHook(obj)

            compToSubsystemReferenceLinker=systemcomposer.internal.arch.internal.ComponentToSubsystemReferenceLinker(obj.BlockHandle,obj.ModelName);
            obj.ModelBlockHandle=compToSubsystemReferenceLinker.linkComponentToSubsystemReference();
        end


    end
end

