function PMIOPortHandle=findPMIOPortInSubSystem(portHandle)








    subSystem=get_param(portHandle,'Parent');
    f=Simulink.FindOptions('SearchDepth',1);
    if Simulink.internal.useFindSystemVariantsMatchFilter()





        f.MatchFilter=@Simulink.match.activeVariants;
    else



        f.Variants='ActiveVariants';
    end
    PMIOPorts=getfullname(Simulink.findBlocksOfType(subSystem,'PMIOPort',f));
    if ischar(PMIOPorts)
        PMIOPorts={PMIOPorts};
    end


    s=get_param(subSystem,'PortHandles');
    indexLConn=find(s.LConn==portHandle);
    if~isempty(indexLConn)
        Port=indexLConn;
        Side='Left';
    end
    indexRConn=find(s.RConn==portHandle);
    if~isempty(indexRConn)
        Port=indexRConn;
        Side='Right';
    end



    PMIOPortsTable=cell(numel(PMIOPorts),3);
    for idx=1:numel(PMIOPorts)
        portNumber=str2num(get_param(PMIOPorts{idx},'Port'));
        PMIOPortsTable(portNumber,1)={portNumber};
        PMIOPortsTable(portNumber,2)={get_param(PMIOPorts{idx},'Side')};
        PMIOPortsTable(portNumber,3)={get_param(PMIOPorts{idx},'Handle')};
    end


    PMIOPortHandle={};
    count=0;
    for idx=1:numel(PMIOPorts)
        if strcmp(PMIOPortsTable{idx,2},Side)
            count=count+1;
            if count==Port
                PMIOPortHandle=PMIOPortsTable{idx,3};
                break;
            end
        end
    end

end
