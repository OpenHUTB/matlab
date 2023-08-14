function unconnectedSolvers=connectSolverConfig(systemHandle,physicalNetworks)






    solverConfigurations=find_system(systemHandle,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'LookUnderMasks','on','BlockType','SubSystem','MaskType','Solver Configuration');


    for idx=1:numel(physicalNetworks)
        if strcmp(physicalNetworks{idx}.solver,'Unconnected')

            if~isempty(solverConfigurations)
                sourceSolver=solverConfigurations{1};
                parent=get_param(sourceSolver,'parent');
                blocks=get_param(parent,'Blocks');
                if numel(blocks)==2&&any(strcmp(blocks,'f(x)=0'))&&any(strcmp(blocks,['Solver',newline,'Configuration']))
                    sourceSolver=parent;
                end
            else
                sourceSolver='nesl_utility/Solver Configuration';
            end


            thisNetWork=physicalNetworks{idx}.netWork;
            highLevelList=ee.internal.assistant.utils.getHighLevelNetwork(thisNetWork);
            if isempty(highLevelList)
                continue
            end

            positions=get_param(highLevelList,'position');
            [xmin,ixmin]=min(cellfun(@(x)x(1),positions));
            temp=cellfun(@(x)x(2),positions);
            ymin=temp(ixmin);
            targetBlock=highLevelList{ixmin};
            temp='./Solver Configuration';
            destination=[fileparts(targetBlock),temp(2:end),num2str(idx)];
            solverHandle=add_block(sourceSolver,destination,'MakeNameUnique','on');


            Pos=get_param(solverHandle,'Position');
            xdelta=xmin-Pos(1)-200;
            ydelta=ymin-Pos(2);
            Pos=Pos+[xdelta,ydelta,xdelta,ydelta];
            set_param(solverHandle,'Position',Pos);


            temp=get_param(solverHandle,'PortHandles');
            sourcePort=temp.RConn;
            temp=get_param(targetBlock,'PortHandles');
            targetPorts=[temp.LConn,temp.RConn];
            targetPort=targetPorts(1);
            subSystemHandle=get_param(targetBlock,'Parent');
            add_line(subSystemHandle,sourcePort,targetPort);
        end
    end


    solverConfigurations_copy=solverConfigurations;
    for idx=1:numel(physicalNetworks)
        if strcmp(physicalNetworks{idx}.solver,'Connected')
            solverName=physicalNetworks{idx}.solverName;
            solverConfigurations_copy(ismember(solverConfigurations_copy,solverName))=[];
        end
    end
    unconnectedSolvers=solverConfigurations_copy;

end