


classdef SubsystemCopyStrategy<handle
    enumeration
        Block(0,0)
        Content(0,1)
        BlockWithBEPs(1,0)
    end

    properties
        useTemporaryModel;
        copyContent;
    end

    methods(Access=public,Static)
        function strategy=copyStrategy(useNewTemporaryModel,isCopyContent)




            if useNewTemporaryModel
                strategy=Simulink.ModelReference.Conversion.SubsystemCopyStrategy.BlockWithBEPs;
            else
                if isCopyContent
                    strategy=Simulink.ModelReference.Conversion.SubsystemCopyStrategy.Content;
                else
                    strategy=Simulink.ModelReference.Conversion.SubsystemCopyStrategy.Block;
                end
            end
        end
    end

    methods(Access=public)
        function this=SubsystemCopyStrategy(useTemporaryModel,copyContent)
            this.useTemporaryModel=useTemporaryModel;
            this.copyContent=copyContent;
        end
        function tf=isCopySubsystemBlock(obj)
            tf=(Simulink.ModelReference.Conversion.SubsystemCopyStrategy.Block==obj);
        end
        function tf=isCopySubsystemContent(obj)
            tf=(Simulink.ModelReference.Conversion.SubsystemCopyStrategy.Content==obj);
        end
        function tf=isCopySubsystemBlockWithBEPs(obj)
            tf=(Simulink.ModelReference.Conversion.SubsystemCopyStrategy.BlockWithBEPs==obj);
        end
    end
end
