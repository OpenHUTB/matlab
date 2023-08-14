classdef SubsystemToSubsystemReferenceConverter<systemcomposer.internal.arch.internal.ComponentToSubsystemReferenceConverter






    methods(Access=public)
        function obj=SubsystemToSubsystemReferenceConverter(blkH,mdlName,dirPath)

            if(nargin==2)
                dirPath=string(pwd);
            end



            obj@systemcomposer.internal.arch.internal.ComponentToSubsystemReferenceConverter(blkH,mdlName,dirPath);
            obj.ShouldBeLeaf=false;
        end

        function newBlockHdl=convertToSubsystemReference(obj)
            newBlockHdl=convertComponentToImpl(obj);
        end
    end

    methods(Access=protected)
        function postCopyContentsToModelHook(~)

        end
    end
end

