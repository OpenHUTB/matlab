




function[D,inPortHandles,outPortHandles]=CreateBlockDMatrix(Hblock,passD)

    import Simulink.Structure.Utils.*

    portHandles=get_param(Hblock,'PortHandles');
    inPortHandles=getAllInportHandles(portHandles);
    outPortHandles=portHandles.Outport;

    ho=get_param(Hblock,'Object');




    if strcmp(ho.BlockType,'From')
        srcO=get_param(ho.getGraphicalSrc,'Object');
        ports=srcO.PortHandles;
        inPortHandles=getAllInportHandles(ports);
    end

    if strcmp(ho.BlockType,'Goto')
        dstO=get_param(ho.getGraphicalDst,'Object');
        if~isempty(dstO)
            for i=1:length(dstO)
                if length(dstO)>1
                    ports=dstO{i}.PortHandles;
                else
                    ports=dstO.PortHandles;
                end
                outPortHandles(i)=ports.Outport;
            end
        end
    end

    m=length(inPortHandles);
    n=length(outPortHandles);


    if ho.isPostCompileVirtual
        D=sparse(ones(m,n));
        return;
    end

    try
        rto=get_param(Hblock,'runtimeObject');
    catch
        D=sparse(ones(m,n));
        return;
    end

    if isempty(rto)
        D=sparse(ones(m,n));
        return;
    end


    if passD
        D=ones(m,n);
        return;
    else
        D=sparse(m,n);
    end

    for i=1:m
        oIp=get_param(inPortHandles(i),'Object');
        try
            if rto.InputPort(i).DirectFeedthrough||isCtrlPort(oIp)
                D(i,:)=1;
            end
        catch
            D(i,:)=1;
        end
    end

end