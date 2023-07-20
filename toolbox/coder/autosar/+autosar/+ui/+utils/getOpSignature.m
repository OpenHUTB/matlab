



function sigValue=getOpSignature(~,port,operation,m3iRun)
    sigValue='';
    isErrorStatus=false;
    runSymbol=m3iRun.symbol;
    compObj=m3iRun.containerM3I.containerM3I;
    serverPorts=autosar.mm.Model.findChildByTypeName(compObj,...
    autosar.ui.configuration.PackageString.Ports{5},false,false);
    for ii=1:length(serverPorts)
        if strcmp(serverPorts{ii}.Name,port)
            for jj=1:serverPorts{ii}.Interface.Operations.size()
                if strcmp(serverPorts{ii}.Interface.Operations.at(jj).Name,operation)
                    sigValue=[runSymbol,'('];
                    for kk=1:serverPorts{ii}.Interface.Operations.at(jj).Arguments.size()
                        if serverPorts{ii}.Interface.Operations.at(jj).Arguments.at(kk).Direction==...
                            Simulink.metamodel.arplatform.interface.ArgumentDataDirectionKind.Error
                            isErrorStatus=true;
                        else
                            sigValue=[sigValue,serverPorts{ii}.Interface.Operations.at(jj).Arguments.at(kk).Direction.toString...
                            ,' ',serverPorts{ii}.Interface.Operations.at(jj).Arguments.at(kk).Name,', '];%#ok<AGROW>
                        end
                    end
                    break
                end
            end
        end
        if~isempty(sigValue)
            sigValue=strtrim(sigValue);
            sigValue=[sigValue(1:length(sigValue)-1),')'];
            if isErrorStatus
                sigValue=[Simulink.metamodel.arplatform.interface.ArgumentDataDirectionKind.Error.toString...
                ,' ',sigValue];%#ok<AGROW>
            end
            break;
        end
    end

end
