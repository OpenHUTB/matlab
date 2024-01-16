function connectNtwkGenericPorts(this,hN,tgtParentPath)

    numMdlRefGenericPorts=hN.NumberOfPirGenericPorts;
    slbh=hN.SimulinkHandle;
    if slbh>0
        if hN.isBusExpansionSubsystem
            blkType=get_param(hN.FullPath,'Type');
        else
            blkType=get_param(slbh,'Type');
        end
        if(numMdlRefGenericPorts>0)&&(strcmpi(blkType,'block_diagram')==1)...
            &&~isempty(hN.getFirstCRCInstanceSimulinkHandle)
            if~isempty(get_param(tgtParentPath,'ParameterArgumentNames'))
                return;
            end
            params={};
            for i=0:(numMdlRefGenericPorts-1)
                params{end+1}=hN.getGenericPortName(i);%#ok<*AGROW>
            end
            paramStr=strjoin(params,',');
            set_param(tgtParentPath,'ParameterArgumentNames',paramStr);
        end
    end
end