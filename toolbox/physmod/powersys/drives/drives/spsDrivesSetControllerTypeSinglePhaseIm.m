function[]=spsDrivesSetControllerTypeSinglePhaseIm(block)










    handle1=get_param([block,'/','Measures'],'PortHandles');
    handle2=get_param([block,'/','SPIM'],'PortHandles');
    handle3=get_param([block,'/','pc'],'PortHandles');

    controllerParent=get_param(block,'controllerType');
    controllerChildren=get_param([block,'/','Controller'],'controllerType');

    if~strcmp(controllerParent,controllerChildren)

        if strcmp(controllerParent,'FOC')


            delete_line(block,handle3.RConn(2),handle2.LConn(3));
            delete_line(block,handle1.RConn(2),handle2.LConn(4));

            add_line(block,handle3.RConn(2),handle2.LConn(4),'AUTOROUTING','ON');
            add_line(block,handle1.RConn(2),handle2.LConn(3),'AUTOROUTING','ON');

        elseif strcmp(controllerParent,'DTC (two-level hysteresis)')||strcmp(controllerParent,'DTC (five-level hysteresis)')

            if strcmp(controllerChildren,'FOC')

                delete_line(block,handle3.RConn(2),handle2.LConn(4));
                delete_line(block,handle1.RConn(2),handle2.LConn(3));


                add_line(block,handle3.RConn(2),handle2.LConn(3),'AUTOROUTING','ON');
                add_line(block,handle1.RConn(2),handle2.LConn(4),'AUTOROUTING','ON');
            end
        end

        set_param([block,'/','Controller'],'controllerType',controllerParent);

    end