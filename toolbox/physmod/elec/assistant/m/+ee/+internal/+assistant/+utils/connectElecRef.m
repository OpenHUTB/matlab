function connectElecRef(physicalNetworks)




    for idx=1:numel(physicalNetworks)
        if strcmp(physicalNetworks{idx}.elecRef,'Unconnected')

            rootName=sprintf('High Z\nElectrical\nReference');
            sourceBlock=sprintf('elec_conv_HighZElecRef/%s',rootName);


            thisNetWork=physicalNetworks{idx}.netWork;
            highLevelList=ee.internal.assistant.utils.getHighLevelNetwork(thisNetWork);
            if isempty(highLevelList)
                continue
            end

            positions=get_param(highLevelList,'position');
            xmean=mean(cellfun(@(x)x(1),positions));
            [ymax,iymax]=max(cellfun(@(x)x(2),positions));
            targetBlock=highLevelList{iymax};
            temp='./High Z\nElectrical\nReference';
            destination=[fileparts(targetBlock),temp(2:end),num2str(idx)];
            solverHandle=add_block(sourceBlock,destination,'MakeNameUnique','on');


            Pos=get_param(solverHandle,'Position');
            xdelta=xmean-Pos(1);
            ydelta=ymax-Pos(2)+200;
            Pos=Pos+[xdelta,ydelta,xdelta,ydelta];
            set_param(solverHandle,'Position',Pos);


            temp=get_param(solverHandle,'PortHandles');
            sourcePort=temp.LConn;
            temp=get_param(targetBlock,'PortHandles');
            targetPorts=[temp.LConn,temp.RConn];
            targetPort=targetPorts(1);
            subSystemHandle=get_param(targetBlock,'Parent');
            add_line(subSystemHandle,sourcePort,targetPort);
        end
    end


end