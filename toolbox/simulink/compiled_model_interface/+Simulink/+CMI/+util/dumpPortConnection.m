function dumpPortConnection(parr)
    for i=1:length(parr)
        for j=1:parr(i).size


            pOwner=parr(i).getOwner;
            portType=Simulink.CMI.util.portType(pOwner);
            rpci=parr(i).element(j);
            po=getPort(rpci);
            if strcmp(portType,'inport')||strcmp(portType,'enable')||...
                strcmp(portType,'trigger')||strcmp(portType,'enable')
                fprintf('%s --> %s\n',...
                getIdentifierString(po),...
                getIdentifierString(pOwner));
            elseif strcmp(portType,'outport')||strcmp(portType,'state')
                fprintf('%s --> %s\n',...
                getIdentifierString(pOwner),...
                getIdentifierString(po));
            end
            try
                fprintf('\tregionLen: %d\n',rpci.regionLen);
                fprintf('\tstartEl: %d\n',rpci.startEl);
                fprintf('\tbusSelElIdx: %d\n',rpci.busSelElIdx);
                fprintf('\tsrcStartEl: %d\n',rpci.srcStartEl);
            catch
            end
        end
    end
end