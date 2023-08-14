classdef TimingInterface




    methods(Static)
        function matchedCodeDescRunnables=getRunnablesAccessingDataStore(codeDescriptor,codeDescDataStoreObj)


            codeDescTimingList=...
            autosar.mm.sl2mm.utils.TimingInterface.getDataStoreTimingInterfaces(codeDescDataStoreObj);
            matchedCodeDescRunnables=...
            autosar.mm.sl2mm.utils.TimingInterface.getRunnablesWithMatchedTimings(codeDescriptor,codeDescTimingList);
        end
    end

    methods(Static,Access=private)
        function matchedCodeDescRunnables=getRunnablesWithMatchedTimings(codeDescriptor,codeDescTimingList)


            assert(isa(codeDescriptor,'coder.codedescriptor.CodeDescriptor'),...
            'Expect a code descriptor object');


            codeDescRunnables=codeDescriptor.getFunctionInterfaces('Output');

            matchedCodeDescRunnables=[];

            for runnableIdx=1:numel(codeDescRunnables)
                codeDescRunnable=codeDescRunnables(runnableIdx);

                for timingIdx=1:numel(codeDescTimingList)
                    codeDescTiming=codeDescTimingList(timingIdx);
                    if codeDescTiming.isEquivalentTo(codeDescRunnable.Timing)
                        matchedCodeDescRunnables=[matchedCodeDescRunnables,codeDescRunnable];%#ok<AGROW>
                        break;
                    end
                end
            end
        end

        function codeDescTimingInterfaceList=getDataStoreTimingInterfaces(codeDescDataStoreObj)


            codeDescTimingInterfaceList=...
            autosar.mm.sl2mm.utils.TimingInterface.getDiscreteTimingInterfaces(codeDescDataStoreObj.Timing);

            for ii=1:codeDescDataStoreObj.DataReads.Size
                codeDescTimingInterfaceList=[codeDescTimingInterfaceList...
                ,autosar.mm.sl2mm.utils.TimingInterface.getDiscreteTimingInterfaces(...
                codeDescDataStoreObj.DataReads(ii))];%#ok<AGROW>
            end

            for ii=1:codeDescDataStoreObj.DataWrites.Size
                codeDescTimingInterfaceList=[codeDescTimingInterfaceList...
                ,autosar.mm.sl2mm.utils.TimingInterface.getDiscreteTimingInterfaces(...
                codeDescDataStoreObj.DataWrites(ii))];%#ok<AGROW>
            end
        end

        function discreteTimingInterfaces=getDiscreteTimingInterfaces(codeDescTimingInterface)


            assert(isa(codeDescTimingInterface,'coder.descriptor.TimingInterface'),...
            'Expect Code Descriptor Timing Interface');
            if strcmp(codeDescTimingInterface.TimingMode,'UNION')
                discreteTimingInterfaces=codeDescTimingInterface.UnionTimingInfo.toArray;
            else
                discreteTimingInterfaces=codeDescTimingInterface;
            end
        end

    end

end


