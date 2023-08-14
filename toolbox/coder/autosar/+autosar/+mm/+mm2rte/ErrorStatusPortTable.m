classdef ErrorStatusPortTable<handle





    properties(Access=private)
        PortAndDataElementList(:,2)string;
    end

    methods(Access=private)
        function obj=ErrorStatusPortTable(portList,dataElementList)


            obj.PortAndDataElementList=[string(portList(:)),string(dataElementList(:))];
        end
    end

    methods(Access=public)
        function ret=hasErrorStatusPort(obj,port,dataElement)




            ret=ismember([string(port),string(dataElement)],...
            obj.PortAndDataElementList,...
            'rows');
        end
    end

    methods(Access=public,Static)
        function obj=fromDataInterfaceArray(inports,expInports)





            isErrorStatus=arrayfun(@autosar.mm.mm2rte.ErrorStatusPortTable.isErrorStatus,inports);
            errorStatusPorts=inports(isErrorStatus);


            graphicalReceiverPortNumbers=arrayfun(@(x)str2double(x.Implementation.ReceiverPortNumber),errorStatusPorts);
            if isempty(expInports)
                codeInfoReceiverPortNumbers=graphicalReceiverPortNumbers;
            else


                codeInfoReceiverPortNumbers=...
                arrayfun(@(x)autosar.mm.mm2rte.ErrorStatusPortTable.getCodeInfoReceiverPortNumber(x,expInports),...
                graphicalReceiverPortNumbers);
            end


            [portList,dataElementList]=arrayfun(...
            @autosar.mm.mm2rte.ErrorStatusPortTable.getPortAndDataElementForReceiverPort,...
            inports(codeInfoReceiverPortNumbers));

            obj=autosar.mm.mm2rte.ErrorStatusPortTable(portList,dataElementList);
        end
    end

    methods(Access=private,Static)
        function[port,dataElement,dataAccessMode]=getFields(blockMapping)


            port=string(blockMapping.MappedTo.Port);
            dataElement=string(blockMapping.MappedTo.Element);
            dataAccessMode=string(blockMapping.MappedTo.DataAccessMode);
        end

        function ret=isErrorStatus(currDataInterface)


            ret=~isempty(currDataInterface.Implementation)&&...
            isprop(currDataInterface.Implementation,'DataAccessMode')&&...
            strcmp(currDataInterface.Implementation.DataAccessMode,'ErrorStatus');
        end

        function codeInfoReceiverPortNumber=getCodeInfoReceiverPortNumber(graphicalReceiverPortNumber,expInports)



            codeInfoReceiverPortNumber=expInports(graphicalReceiverPortNumber).Index;
        end

        function[port,dataElement]=getPortAndDataElementForReceiverPort(receiverPort)



            port=string(receiverPort.Implementation.Port);
            dataElement=string(receiverPort.Implementation.DataElement);
        end
    end

end
