classdef SignalInvalidationPortTable<handle








    properties(Access=private)
        PortAndDataElementList(:,2)string;
    end

    methods(Access=private)
        function obj=SignalInvalidationPortTable(portList,dataElementList)


            obj.PortAndDataElementList=[string(portList(:)),string(dataElementList(:))];
        end
    end

    methods(Access=public)
        function ret=hasSourceSignalInvalidationBlock(obj,port,dataElement)



            ret=ismember([string(port),string(dataElement)],...
            obj.PortAndDataElementList,...
            'rows');
        end
    end

    methods(Access=public,Static)
        function obj=fromModelMapping(modelMapping)



            outports=modelMapping.Outports;
            [portList,dataElementList]=...
            arrayfun(@autosar.mm.mm2rte.SignalInvalidationPortTable.getFields,...
            outports);
            hasSourceSignalInvalidationBlockList=...
            arrayfun(@(x)~isempty(x.getSourceSignalInvalidationBlock),outports);
            obj=autosar.mm.mm2rte.SignalInvalidationPortTable(...
            portList(hasSourceSignalInvalidationBlockList),...
            dataElementList(hasSourceSignalInvalidationBlockList));
        end

        function obj=fromM3IComp(m3iComp)




            portList=string.empty;
            dataElementList=string.empty;
            m3iBehavior=m3iComp.Behavior;
            nRunnables=m3iBehavior.Runnables.size;
            for kRunnable=1:nRunnables
                m3iRunnable=m3iBehavior.Runnables.at(kRunnable);
                nFlowDataAccess=m3iRunnable.dataAccess.size;
                for kFlowDataAccess=1:nFlowDataAccess
                    m3iFlowDataAccess=m3iRunnable.dataAccess.at(kFlowDataAccess);
                    isExplicitWrite=strcmp(m3iFlowDataAccess.Kind.toString,'ExplicitWrite');
                    if isExplicitWrite
                        m3iInstanceRef=m3iFlowDataAccess.instanceRef;
                        m3iPort=m3iInstanceRef.Port;
                        m3iData=m3iInstanceRef.DataElements;
                        portInfo=autosar.mm.Model.findPortInfo(m3iPort,m3iData,'DataElements');
                        hasComSpec=~isempty(portInfo)&&~isempty(portInfo.comSpec);
                        hasInitCond=hasComSpec&&...
                        (portInfo.comSpec.InitialValue.isvalid()||...
                        ~isempty(portInfo.comSpec.InitValue));
                        if hasInitCond
                            portList(end+1)=string(m3iPort.Name);%#ok<AGROW>
                            dataElementList(end+1)=string(m3iData.Name);%#ok<AGROW>



                            if portInfo.comSpec.InitialValue.isvalid()
                                initValue=portInfo.comSpec.InitialValue;
                            else
                                initValue=portInfo.comSpec.InitValue;
                            end

                            if isempty(initValue.Type)


                                m3iModel=m3iComp.rootModel;
                                tran=M3I.Transaction(m3iModel);
                                initValue.Type=m3iData.Type;
                                tran.commit();
                            end
                        end
                    end
                end
            end
            obj=autosar.mm.mm2rte.SignalInvalidationPortTable(portList,dataElementList);
        end
    end

    methods(Access=private,Static)
        function[port,dataElement]=getFields(blockMapping)


            port=string(blockMapping.MappedTo.Port);
            dataElement=string(blockMapping.MappedTo.Element);
        end
    end
end
