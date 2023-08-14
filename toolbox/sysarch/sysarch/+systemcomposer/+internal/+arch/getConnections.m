function[connNames,conns]=getConnections(app)



    rootArch=systemcomposer.arch.Architecture(app.getTopLevelCompositionArchitecture);
    conns=rootArch.Connectors;

    connNames=cell(1,numel(conns));
    for i=1:numel(conns)
        conn=conns(i);

        if(isa(conn.SourcePort,'systemcomposer.arch.ArchitecturePort'))
            sourceName=conn.SourcePort.Name;
        else
            sourceName=[conn.SourcePort.Parent.Name,'/',conn.SourcePort.Name];
        end

        if(isa(conn.DestinationPort,'systemcomposer.arch.ArchitecturePort'))
            destinationName=conn.DestinationPort.Name;
        else
            destinationName=[conn.DestinationPort.Parent.Name,'/',conn.DestinationPort.Name];
        end

        connNames{i}=[conn.Name,' : ',sourceName,' --> ',destinationName];
    end
