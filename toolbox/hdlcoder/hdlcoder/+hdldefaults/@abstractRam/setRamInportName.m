function setRamInportName(this,hC,complexPostfix,inportOffset)





    bfp=hC.SimulinkHandle;
    phan=get_param(bfp,'PortHandles');
    localOffset=inportOffset;

    for n=1:length(phan.Inport)

        iport=get(get_param(phan.Inport(n),'Object'),'PortNumber');
        lowerport=find_system(bfp,'SearchDepth',1,'LookUnderMasks','all',...
        'FollowLinks','on','BlockType','Inport','Port',num2str(iport));

        if isempty(lowerport)
            pname=['inport',num2str(iport)];
        else
            pname=get_param(lowerport,'Name');
        end

        portIsComplex=logical(get_param(phan.Inport(n),'CompiledPortComplexSignal'));
        if portIsComplex
            hC.setInputPortName((n+localOffset)-1,...
            hdllegalnamersvd([pname,complexPostfix.real]));
            hC.setInputPortName((n+localOffset),...
            hdllegalnamersvd([pname,complexPostfix.imag]));
            localOffset=localOffset+1;
        else
            hC.setInputPortName((n+localOffset)-1,hdllegalnamersvd(pname));
        end

    end


