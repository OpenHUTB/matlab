function[archModel,custIdUUIDTableContainer,importLog,errorLog]=importModel(mdlInfo,compTable,portTable,connxnTable,portInterfaceTable,requirementLinksTable)





    domain=getString(message('SystemArchitecture:Import:SystemDomain'));
    functionsTable=cell2table(cell(0,4),'VariableNames',{'Name','ExecutionOrder','CompID','Period'});
    if isstruct(compTable)
        inputStruct=compTable;
        if isfield(inputStruct,'components')
            compTable=inputStruct.components;
        else
            compTable=cell2table(cell(0,3),'VariableNames',{'Name','ID','ParentID'});
        end
        if isfield(inputStruct,'ports')
            portTable=inputStruct.ports;
        else
            portTable=cell2table(cell(0,4),'VariableNames',{'Name','Direction','ID','CompID'});
        end
        if isfield(inputStruct,'connections')
            connxnTable=inputStruct.connections;
        else
            connxnTable=cell2table(cell(0,4),'VariableNames',{'Name','ID','SourcePortID','DestPortID'});
        end
        if isfield(inputStruct,'portInterfaces')
            portInterfaceTable=inputStruct.portInterfaces;
        else
            portInterfaceTable=cell2table(cell(0,9),'VariableNames',{'Name','ID','ParentID','DataType','Dimensions','Units','Complexity','Minimum','Maximum'});

        end
        if isfield(inputStruct,'requirementLinks')
            requirementLinksTable=inputStruct.requirementLinks;
        else
            requirementLinksTable=cell2table(cell(0,4),'VariableNames',{'Label','SourceID','DestinationID','DestinationType'});
        end
        if isfield(inputStruct,'domain')
            domain=inputStruct.domain;
        end
        if isfield(inputStruct,'functions')
            functionsTable=inputStruct.functions;
        end
    else
        if(nargin<3)
            portTable=cell2table(cell(0,4),'VariableNames',{'Name','Direction','ID','CompID'});
        end
        if(nargin<4)
            connxnTable=cell2table(cell(0,4),'VariableNames',{'Name','ID','SourcePortID','DestPortID'});
        end
        if(nargin<5)
            portInterfaceTable=cell2table(cell(0,9),'VariableNames',{'Name','ID','ParentID','DataType','Dimensions','Units','Complexity','Minimum','Maximum'});
        end
        if(nargin<6)
            requirementLinksTable=cell2table(cell(0,4),'VariableNames',{'Label','SourceID','DestinationID','DestinationType'});
        end
    end
    obj=systemcomposer.internal.importModelClass(mdlInfo,compTable,portTable,connxnTable,...
    portInterfaceTable,requirementLinksTable,...
    functionsTable,domain);
    archModel=obj.archModel;
    custIdUUIDTableContainer.compTable=obj.compIDTable;
    custIdUUIDTableContainer.portsTable=obj.portIDTable;
    custIdUUIDTableContainer.connxnTable=obj.connxnIDTable;
    custIdUUIDTableContainer.requirementLinksTable=obj.requirementLinksTable;

    if(size(obj.importErrorsLog)>0)
        warning(message('SystemArchitecture:Import:ImportErrorMessage'));
    end
    importLog=obj.importLogger;
    errorLog=obj.importErrorsLog;
end


