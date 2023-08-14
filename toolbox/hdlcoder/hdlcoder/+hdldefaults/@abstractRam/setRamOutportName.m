function setRamOutportName(this,hC,complexPostfix)





    bfp=hC.SimulinkHandle;
    phan=get_param(bfp,'PortHandles');
    localOffset=0;

    for n=1:length(phan.Outport)

        oport=get(get_param(phan.Outport(n),'Object'),'PortNumber');
        lowerport=find_system(bfp,'SearchDepth',1,'LookUnderMasks','all',...
        'FollowLinks','on','BlockType','Outport','Port',num2str(oport));

        if isempty(lowerport)
            pname=['outport',num2str(oport)];
        else
            pname=get_param(lowerport,'Name');
        end

        portIsComplex=logical(get_param(phan.Outport(n),'CompiledPortComplexSignal'));
        if portIsComplex
            hC.setOutputPortName((n+localOffset)-1,...
            hdllegalnamersvd([pname,complexPostfix.real]));
            hC.setOutputPortName((n+localOffset),...
            hdllegalnamersvd([pname,complexPostfix.imag]));
            localOffset=localOffset+1;
        else
            hC.setOutputPortName((n+localOffset)-1,hdllegalnamersvd(pname));
        end

    end


