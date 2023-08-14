classdef ComponentToSubsystemReferenceConverter<systemcomposer.internal.arch.internal.ComponentToImplConverter







    methods(Access=public)
        function obj=ComponentToSubsystemReferenceConverter(blkH,mdlName,dirPath)

            if(nargin==2)
                dirPath=string(pwd);
            end



            obj@systemcomposer.internal.arch.internal.ComponentToImplConverter(blkH,mdlName,dirPath);
        end
    end

    methods(Access=protected)
        function createImplModelHook(obj)

            bdH=new_system(obj.ModelName,'Subsystem');
            obj.ModelHandle=get_param(bdH,'Handle');
        end

        function postCopyContentsToModelHook(obj)
            obj.autoLayoutInportsOutports();


            physicalPortBlocks=find_system(obj.ModelName,'BlockType','PMIOPort');
            if~isempty(physicalPortBlocks)
                set_param(physicalPortBlocks{1},'Position',[600,100,630,114]);
                for i=2:numel(physicalPortBlocks)
                    pos=get_param(physicalPortBlocks{i-1},'Position');
                    pos(2)=pos(2)+25;
                    pos(4)=pos(4)+25;
                    set_param(physicalPortBlocks{i},'Position',pos);
                end
            end
        end

        function linkComponentToModelHook(obj)

            compToSubsystemReferenceLinker=systemcomposer.internal.arch.internal.ComponentToSubsystemReferenceLinker(obj.BlockHandle,obj.ModelName);
            obj.BlockHandle=compToSubsystemReferenceLinker.linkComponentToSubsystemReference();
        end

        function postLinkComponentToModelHook(~)

        end
    end
end

