classdef InportMergedChecker<Simulink.ModelReference.Conversion.Checker




    properties
Systems
SubsystemPortBlocks
currentSubsystem
    end
    methods(Access=public)
        function this=InportMergedChecker(ConversionData,SubsystemPortBlocks,currentSubsystem)
            this@Simulink.ModelReference.Conversion.Checker(ConversionData.ConversionParameters,ConversionData.Logger);
            this.Systems=ConversionData.ConversionParameters.Systems;
            this.SubsystemPortBlocks=SubsystemPortBlocks;
            this.currentSubsystem=currentSubsystem;
        end

        function check(this)




            subsysIdx=this.Systems==this.currentSubsystem;
            ssInBlkHs=this.SubsystemPortBlocks{subsysIdx}.inportBlksH.blocks;

            sess=Simulink.CMI.EIAdapter(Simulink.EngineInterfaceVal.byFiat);
            numberOfBlocks=length(ssInBlkHs);
            for idx=1:numberOfBlocks
                h=get_param(ssInBlkHs(idx),'UDDObject');
                dsts=h.getActualDst;
                numRows=size(dsts,1);
                for jIdx=1:numRows
                    dstPortH=dsts(jIdx,1);
                    dstBlkH=get_param(dstPortH,'ParentHandle');
                    dstBlkType=get_param(dstBlkH,'BlockType');

                    if strcmp(dstBlkType,'Merge')
                        inBlkParent=get_param(ssInBlkHs(idx),'parent');
                        dstParent=get_param(dstBlkH,'parent');
                        inportAreMerged=strncmp(dstParent,inBlkParent,length(inBlkParent));
                        if inportAreMerged
                            this.handleDiagnostic(message('Simulink:modelReference:convertToModelReference_InvalidMergeConnection',...
                            Simulink.ModelReference.Conversion.MessageBeautifier.beautifyBlockName(...
                            getfullname(ssInBlkHs(idx)),ssInBlkHs(idx))));
                            break;
                        end
                    end
                end
            end
            delete(sess);
        end
    end
end
