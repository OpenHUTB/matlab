function connectTestpoints(this,gmDUT,~)













    gmTop=this.hPir.getTopNetwork;

    if~testpointsPresent(gmTop)
        return;
    end

    posOfDut=get_param(gmDUT,'Position');


    tpScopeMap=containers.Map('KeyType','double','ValueType','double');

    outFileName=char(fileparts(gmDUT));
    for ii=1:numel(gmTop.PirOutputPorts)
        if(gmTop.PirOutputPorts(ii).isTestpoint())

            portYDiff=(posOfDut(4)-posOfDut(2))/numel(gmTop.PirOutputPorts);
            portYLoc=(ii-1)*portYDiff+portYDiff/2;
            outPortLocation=[posOfDut(3),posOfDut(2)+portYLoc,posOfDut(3),posOfDut(2)+portYLoc];


            portType=getDutOutportType(gmTop,ii);
            if portType.isRecordType&&...
                get_param(gmTop.getOutputPortSignal(ii-1).SimulinkHandle,'CompiledBusType')=="VIRTUAL_BUS"
                posTerminator=outPortLocation+[60,0,90,30];
                terminatorH=addBlockUnique('simulink/Sinks/Terminator',[outFileName,'/tpTerminator']);
                set_param(terminatorH,'commented','on');
                new_terminator=getfullname(terminatorH);
                set_param(new_terminator,'Position',posTerminator);
                blkPort=[char(get_param(gmDUT,'Name')),'/',char(num2str(ii))];
                terminatorInput=[char(get_param(new_terminator,'Name')),'/1'];
                add_line(outFileName,blkPort,terminatorInput,'autorouting','on');
            else

                simRate=gmTop.PirOutputPorts(ii).Signal.SimulinkRate;


                [new_scope,portID,tpScopeMap]=getScopeFor(tpScopeMap,outFileName,simRate,outPortLocation);


                src_scope=[char(get_param(new_scope,'Name')),'/',char(num2str(portID))];
                blkPort=[char(get_param(gmDUT,'Name')),'/',char(num2str(ii))];
                add_line(outFileName,blkPort,src_scope,'autorouting','on');
            end
        end
    end
end






function[new_scope,portID,tpScopeMap]=getScopeFor(tpScopeMap,gmTop,simRate,refPortLoc)
    if isKey(tpScopeMap,simRate)
        new_scope=tpScopeMap(simRate);
        s=get_param(new_scope,'ScopeConfiguration');
        totalPortsScoped=str2double(s.NumInputPorts);
    else
        tpScopeName=[gmTop,'/TestpointScope'];
        new_scope=addBlockUnique('simulink/Sinks/Scope',tpScopeName);
        set_param(new_scope,'commented','on');
        tpScopeMap(simRate)=new_scope;
        position=refPortLoc+[200,0,230,30];
        scope_name=getfullname(new_scope);
        set_param(scope_name,'Position',position);
        totalPortsScoped=0;
    end
    s=get_param(new_scope,'ScopeConfiguration');
    s.NumInputPorts=num2str(totalPortsScoped+1);
    portID=totalPortsScoped+1;

    if portID>95


        remove(tpScopeMap,simRate);
    end
end






function blkH=addBlockUnique(blkType,tgtBlkPath)
    blkH=add_block(blkType,tgtBlkPath,'MakeNameUnique','on');
end





function outType=getDutOutportType(hn,idx)
    outType=[];
    hs=hn.getOutputPortSignal(idx-1);
    if~isempty(hs)
        outType=hs.Type;
    end
end





function retval=testpointsPresent(top)
    retval=false;
    for ii=1:numel(top.PirOutputPorts)
        if top.PirOutputPorts(ii).isTestpoint()
            retval=true;
            break;
        end
    end
end