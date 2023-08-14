function ThreePhaseVIMeasurementCback(block,PUsel)






    PhasorSimulation=strcmp(get_param(block,'PhasorSimulation'),'on');
    VoltageMeasurements=get_param(block,'VoltageMeasurement');
    MeasureVoltage=~strcmp('no',VoltageMeasurements);
    MeasureCurrent=strcmp('yes',get_param(block,'CurrentMeasurement'));
    WantVlabel=strcmp('on',get_param(block,'SetLabelV'));
    WantIlabel=strcmp('on',get_param(block,'SetLabelI'));
    WantVpu=strcmp('on',get_param(block,'Vpu'));
    WantVpuLL=strcmp('on',get_param(block,'VpuLL'));
    WantIpu=strcmp('on',get_param(block,'Ipu'));

    ME=get_param(block,'MaskEnables');
    v=get_param(block,'MaskVisibilities');



    if PhasorSimulation
        v{12}='on';
        if strcmp(get_param(bdroot(block),'EditingMode'),'Restricted')
            ME{12}='off';
        else
            ME{12}='on';
        end
    else
        ME{12}='off';
        v{12}='off';
    end
    set_param(block,'Maskenables',ME)



    v{2}='off';
    v{3}='off';
    v{4}='off';
    v{5}='off';

    v{7}='off';
    v{8}='off';
    v{9}='off';

    v{10}='off';
    v{11}='off';

    if MeasureVoltage
        v{2}='on';
        if WantVlabel
            v{3}='on';
        end
        if strcmp('phase-to-ground',VoltageMeasurements)
            v{4}='on';
            v{5}='off';
            if~exist('PUsel','var')
                PUsel='Vpu';
            end
        else
            v{4}='on';
            v{5}='on';
            if~exist('PUsel','var')
                PUsel='VpuLL';
            end
        end
        if WantVpu||WantVpuLL
            v{11}='on';
        end
        if WantVpu&&WantVpuLL

            if strcmp(PUsel,'Vpu')

                set_param(block,'VpuLL','off');
            end
            if strcmp(PUsel,'VpuLL')||strcmp(PUsel,'Vselector')

                set_param(block,'Vpu','off');
            end
        end

    end

    if MeasureCurrent
        v{7}='on';
        if WantIlabel
            v{8}='on';
        end
        v{9}='on';
        if WantIpu
            v{10}='on';
            v{11}='on';
        end
    end

    if~MeasureVoltage&&~MeasureCurrent
        v{12}='off';
    end

    set_param(block,'maskvisibilities',v);