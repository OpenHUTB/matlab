function varargout=forAllComponents(this,hPir,func,portReqTraceFlag)








    if nargin==3
        portReqTraceFlag=false;
    end


    vNetworks=hPir.Networks;
    numNetworks=length(vNetworks);

    if(nargout>0)
        chk=[];
    end

    for i=1:numNetworks
        hN=vNetworks(i);
        vComps=hN.Components;
        numComps=length(vComps);
        for j=1:numComps
            hC=vComps(j);
            if nargout>0
                chk=cat(2,chk,feval(func,this,hC));
            else
                feval(func,this,hC);
            end
        end


        if portReqTraceFlag
            portReqTrace(this,hN,func);
        end
    end

    if(nargout>0)
        varargout={chk};
    end

end

function portReqTrace(this,hN,func)
    if isempty(hN.SLInputPorts)&&isempty(hN.SLOutputPorts)
        return;
    end

    inPorts=find_system(hN.Name,'SearchDepth','1','LookUnderMasks','all',...
    'MatchFilter',@Simulink.match.allVariants,...
    'FollowLinks','on','BlockType','Inport');
    outPorts=find_system(hN.Name,'SearchDepth','1','LookUnderMasks','all',...
    'MatchFilter',@Simulink.match.allVariants,...
    'FollowLinks','on','BlockType','Outport');




    inPortHdls=get_param(inPorts,'Handle');
    outPortHdls=get_param(outPorts,'Handle');


    inPortHdlNames=get_param([inPortHdls{:}],'Name');
    outPortHdlNames=get_param([outPortHdls{:}],'Name');


    nPirInports=numel(hN.PirInputPorts);
    nPirOutports=numel(hN.PirOutputPorts);

    for j=1:nPirInports
        hC=hN.PirInputPorts(j);
        inName=hC.Name;
        inNamePresent=strcmp(inPortHdlNames,inName);
        if any(inNamePresent)
            feval(func,this,hC,inPortHdls{inNamePresent});
        end
    end

    for j=1:nPirOutports
        hC=hN.PirOutputPorts(j);
        outName=hC.Name;
        outNamePresent=strcmp(outPortHdlNames,outName);
        if any(outNamePresent)
            feval(func,this,hC,outPortHdls{outNamePresent});
        end
    end
end
