function[]=spsDrivesMaskController(block,driveType,averageValue);%#ok




    wantAverageValueModel=averageValue==1;
    handlemask=Simulink.Mask.get(block);


    Ts=drivelibInitSampleTime(block);






    switch driveType

    case{'DC1','DC3'}
        regulationType=get_param(block,'regulationType');

        maskParameters=ones(1,45);
        maskParameters(:,44)=0;


        if wantAverageValueModel






            p=handlemask.getDialogControl('Externalvoltagesource');
            p.Visible='on';
            p=handlemask.getDialogControl('Synchronizedpulsegenerator');
            p.Visible='off';

            if strcmp(regulationType,'Speed regulation')

                p=handlemask.getDialogControl('Speedramp');
                p.Visible='on';
                p=handlemask.getDialogControl('PIregulator');
                p.Visible='on';
            elseif strcmp(regulationType,'Torque regulation')

                p=handlemask.getDialogControl('Speedramp');
                p.Visible='off';
                p=handlemask.getDialogControl('PIregulator');
                p.Visible='off';
                maskParameters(:,22:24)=zeros(1,3);
            end




        elseif~wantAverageValueModel







            p=handlemask.getDialogControl('Externalvoltagesource');
            p.Visible='off';
            p=handlemask.getDialogControl('Synchronizedpulsegenerator');
            p.Visible='on';

            if strcmp(regulationType,'Speed regulation')

                p=handlemask.getDialogControl('Speedramp');
                p.Visible='on';
                p=handlemask.getDialogControl('PIregulator');
                p.Visible='on';
            elseif strcmp(regulationType,'Torque regulation')

                p=handlemask.getDialogControl('Speedramp');
                p.Visible='off';
                p=handlemask.getDialogControl('PIregulator');
                p.Visible='off';
                maskParameters(:,22:24)=zeros(1,3);
            end

        end

    case 'DC2'
        regulationType=get_param(block,'regulationType');

        maskParameters=ones(1,50);
        maskParameters(:,49)=0;


        if wantAverageValueModel





            p=handlemask.getDialogControl('Externalvoltagesource');
            p.Visible='on';
            p=handlemask.getDialogControl('Synchronizedpulsegenerator');
            p.Visible='off';

            if strcmp(regulationType,'Speed regulation')

                p=handlemask.getDialogControl('Speedramp');
                p.Visible='on';
                p=handlemask.getDialogControl('PIregulator');
                p.Visible='on';
            elseif strcmp(regulationType,'Torque regulation')

                p=handlemask.getDialogControl('Speedramp');
                p.Visible='off';
                p=handlemask.getDialogControl('PIregulator');
                p.Visible='off';
                maskParameters(:,27:29)=zeros(1,3);
            end




        elseif~wantAverageValueModel






            p=handlemask.getDialogControl('Externalvoltagesource');
            p.Visible='off';
            p=handlemask.getDialogControl('Synchronizedpulsegenerator');
            p.Visible='on';

            if strcmp(regulationType,'Speed regulation')

                p=handlemask.getDialogControl('Speedramp');
                p.Visible='on';
                p=handlemask.getDialogControl('PIregulator');
                p.Visible='on';
            elseif strcmp(regulationType,'Torque regulation')

                p=handlemask.getDialogControl('Speedramp');
                p.Visible='off';
                p=handlemask.getDialogControl('PIregulator');
                p.Visible='off';
                maskParameters(:,27:29)=zeros(1,3);
            end

        end

    case 'DC4'
        regulationType=get_param(block,'regulationType');

        maskParameters=ones(1,49);
        maskParameters(:,48)=0;


        if wantAverageValueModel





            p=handlemask.getDialogControl('Externalvoltagesource');
            p.Visible='on';
            p=handlemask.getDialogControl('Synchronizedpulsegenerator');
            p.Visible='off';

            if strcmp(regulationType,'Speed regulation')

                p=handlemask.getDialogControl('Speedramp');
                p.Visible='on';
                p=handlemask.getDialogControl('PIregulator');
                p.Visible='on';
            elseif strcmp(regulationType,'Torque regulation')

                p=handlemask.getDialogControl('Speedramp');
                p.Visible='off';
                p=handlemask.getDialogControl('PIregulator');
                p.Visible='off';
                maskParameters(:,26:28)=zeros(1,3);
            end




        elseif~wantAverageValueModel






            p=handlemask.getDialogControl('Externalvoltagesource');
            p.Visible='off';
            p=handlemask.getDialogControl('Synchronizedpulsegenerator');
            p.Visible='on';

            if strcmp(regulationType,'Speed regulation')

                p=handlemask.getDialogControl('Speedramp');
                p.Visible='on';
                p=handlemask.getDialogControl('PIregulator');
                p.Visible='on';
            elseif strcmp(regulationType,'Torque regulation')

                p=handlemask.getDialogControl('Speedramp');
                p.Visible='off';
                p=handlemask.getDialogControl('PIregulator');
                p.Visible='off';
                maskParameters(:,26:28)=zeros(1,3);
            end

        end

    case{'DC5','DC6','DC7'}
        regulationType=get_param(block,'regulationType');

        maskParameters=ones(1,42);
        maskParameters(:,41)=0;


        if wantAverageValueModel








            p=handlemask.getDialogControl('IGBTDiodedevice');
            p.Visible='off';

            if strcmp(regulationType,'Speed regulation')

                p=handlemask.getDialogControl('Speedramps');
                p.Visible='on';
                p=handlemask.getDialogControl('PIregulator');
                p.Visible='on';
            elseif strcmp(regulationType,'Torque regulation')

                p=handlemask.getDialogControl('Speedramps');
                p.Visible='off';
                p=handlemask.getDialogControl('PIregulator');
                p.Visible='off';
                maskParameters(:,20:23)=zeros(1,4);
            end




        elseif~wantAverageValueModel









            p=handlemask.getDialogControl('IGBTDiodedevice');
            p.Visible='on';

            if strcmp(regulationType,'Speed regulation')

                p=handlemask.getDialogControl('Speedramps');
                p.Visible='on';
                p=handlemask.getDialogControl('PIregulator');
                p.Visible='on';
            elseif strcmp(regulationType,'Torque regulation')

                p=handlemask.getDialogControl('Speedramps');
                p.Visible='off';
                p=handlemask.getDialogControl('PIregulator');
                p.Visible='off';
                maskParameters(:,20:23)=zeros(1,4);
            end

        end

    case 'AC1'
        deviceType=get_param(block,'deviceType');
        maskParameters=ones(1,59);
        maskParameters(:,58)=0;





        if strcmp(deviceType,'IGBT / Diodes')
            maskParameters(:,36:37)=zeros(1,2);
            p=handlemask.getDialogControl('Forwardvoltages');
            p.Visible='on';
            p=handlemask.getDialogControl('Turnoff');
            p.Visible='on';
        elseif strcmp(deviceType,'GTO / Diodes')
            maskParameters(:,34:35)=zeros(1,2);
            p=handlemask.getDialogControl('Forwardvoltages');
            p.Visible='on';
            p=handlemask.getDialogControl('Turnoff');
            p.Visible='on';
        elseif strcmp(deviceType,'MOSFET / Diodes')
            maskParameters(:,32:37)=zeros(1,6);
            p=handlemask.getDialogControl('Forwardvoltages');
            p.Visible='off';
            p=handlemask.getDialogControl('Turnoff');
            p.Visible='off';
        end

    case 'AC2'
        deviceType=get_param(block,'deviceType');
        maskParameters=ones(1,64);
        maskParameters(:,63)=0;
        if wantAverageValueModel







            maskParameters(:,31:40)=zeros(1,10);
            p=handlemask.getDialogControl('Inverter');
            p.Visible='off';


        elseif~wantAverageValueModel





            p=handlemask.getDialogControl('Inverter');
            p.Visible='on';


            if strcmp(deviceType,'IGBT / Diodes')
                maskParameters(:,37:38)=zeros(1,2);
                p=handlemask.getDialogControl('Forwardvoltages');
                p.Visible='on';
                p=handlemask.getDialogControl('Turnoff');
                p.Visible='on';
            elseif strcmp(deviceType,'GTO / Diodes')
                maskParameters(:,35:36)=zeros(1,2);
                p=handlemask.getDialogControl('Forwardvoltages');
                p.Visible='on';
                p=handlemask.getDialogControl('Turnoff');
                p.Visible='on';
            elseif strcmp(deviceType,'MOSFET / Diodes')
                maskParameters(:,33:38)=zeros(1,6);
                p=handlemask.getDialogControl('Forwardvoltages');
                p.Visible='off';
                p=handlemask.getDialogControl('Turnoff');
                p.Visible='off';
            end

        end

    case 'AC3'

        deviceType=get_param(block,'deviceType');
        regulationType=get_param(block,'regulationType');
        modulationType=get_param(block,'modulationType');
        sensorless=get_param(block,'sensorless');
        maskParameters=ones(1,83);
        maskParameters(:,82)=0;

        if strcmp(sensorless,'on')
            p=handlemask.getDialogControl('sensorlessTab');
            p.Visible='on';

        elseif strcmp(sensorless,'off')
            p=handlemask.getDialogControl('sensorlessTab');
            p.Visible='off';

        end

        if wantAverageValueModel







            maskParameters(1,32)=0;


            p=handlemask.getDialogControl('Forwardvoltages');
            p.Visible='off';
            p=handlemask.getDialogControl('Turnoff');
            p.Visible='off';
            p=handlemask.getDialogControl('InvSnubbers');
            p.Visible='off';


            maskParameters(:,58:66)=zeros(1,9);
            p=handlemask.getDialogControl('d_axiscurrentregulator');
            p.Visible='off';
            p=handlemask.getDialogControl('q_axiscurrentregulator');
            p.Visible='off';


            if strcmp(regulationType,'Speed regulation')
                p=handlemask.getDialogControl('Speedramp');
                p.Visible='on';
                p=handlemask.getDialogControl('PIregulator');
                p.Visible='on';
            elseif strcmp(regulationType,'Torque regulation')

                maskParameters(1,47)=0;
                p=handlemask.getDialogControl('Speedramp');
                p.Visible='off';
                p=handlemask.getDialogControl('PIregulator');
                p.Visible='off';
            end

        elseif~wantAverageValueModel







            maskParameters(1,31)=0;
            p=handlemask.getDialogControl('InvSnubbers');
            p.Visible='on';
            if strcmp(deviceType,'IGBT / Diodes')
                maskParameters(:,38:39)=zeros(1,2);
                p=handlemask.getDialogControl('Forwardvoltages');
                p.Visible='on';
                p=handlemask.getDialogControl('Turnoff');
                p.Visible='on';
            elseif strcmp(deviceType,'GTO / Diodes')
                maskParameters(:,36:37)=zeros(1,2);
                p=handlemask.getDialogControl('Forwardvoltages');
                p.Visible='on';
                p=handlemask.getDialogControl('Turnoff');
                p.Visible='on';
            elseif strcmp(deviceType,'MOSFET / Diodes')

                p=handlemask.getDialogControl('Forwardvoltages');
                p.Visible='off';
                p=handlemask.getDialogControl('Turnoff');
                p.Visible='off';
            end


            if strcmp(modulationType,'Hysteresis')
                maskParameters(:,60:65)=zeros(1,6);
                p=handlemask.getDialogControl('d_axiscurrentregulator');
                p.Visible='off';
                p=handlemask.getDialogControl('q_axiscurrentregulator');
                p.Visible='off';

            elseif strcmp(modulationType,'SVM')
                maskParameters(1,59)=0;
                maskParameters(1,66)=0;
                p=handlemask.getDialogControl('d_axiscurrentregulator');
                p.Visible='on';
                p=handlemask.getDialogControl('q_axiscurrentregulator');
                p.Visible='on';

            end

            if strcmp(regulationType,'Speed regulation')
                p=handlemask.getDialogControl('Speedramp');
                p.Visible='on';
                p=handlemask.getDialogControl('PIregulator');
                p.Visible='on';
            elseif strcmp(regulationType,'Torque regulation')

                maskParameters(1,47)=0;
                p=handlemask.getDialogControl('Speedramp');
                p.Visible='off';
                p=handlemask.getDialogControl('PIregulator');
                p.Visible='off';
            end

        end

    case 'AC4'
        deviceType=get_param(block,'deviceType');
        regulationType=get_param(block,'regulationType');
        modulationType=get_param(block,'modulationType');
        maskParameters=ones(1,68+4-1);
        maskParameters(:,67+4-1)=0;





        if strcmp(modulationType,'Hysteresis')
            maskParameters(:,55:60)=zeros(1,6);
            p=handlemask.getDialogControl('Torquecontroller');
            p.Visible='off';
            p=handlemask.getDialogControl('Fluxcontroller');
            p.Visible='off';
        elseif strcmp(modulationType,'SVM')
            maskParameters(:,53:54)=zeros(1,2);
            maskParameters(1,61)=0;
            p=handlemask.getDialogControl('Torquecontroller');
            p.Visible='on';
            p=handlemask.getDialogControl('Fluxcontroller');
            p.Visible='on';
        end


        if strcmp(deviceType,'IGBT / Diodes')
            maskParameters(:,37:38)=zeros(1,2);
            p=handlemask.getDialogControl('Forwardvoltages');
            p.Visible='on';
            p=handlemask.getDialogControl('Turnoff');
            p.Visible='on';
        elseif strcmp(deviceType,'GTO / Diodes')
            maskParameters(:,35:36)=zeros(1,2);
            p=handlemask.getDialogControl('Forwardvoltages');
            p.Visible='on';
            p=handlemask.getDialogControl('Turnoff');
            p.Visible='on';
        elseif strcmp(deviceType,'MOSFET / Diodes')
            maskParameters(:,33:38)=zeros(1,6);
            p=handlemask.getDialogControl('Forwardvoltages');
            p.Visible='off';
            p=handlemask.getDialogControl('Turnoff');
            p.Visible='off';
        end


        if strcmp(regulationType,'Speed regulation')
            p=handlemask.getDialogControl('Speedramp');
            p.Visible='on';
            p=handlemask.getDialogControl('PIregulator');
            p.Visible='on';
        elseif strcmp(regulationType,'Torque regulation')
            maskParameters(:,42:46)=zeros(1,5);
            p=handlemask.getDialogControl('Speedramp');
            p.Visible='off';
            p=handlemask.getDialogControl('PIregulator');
            p.Visible='off';
        end

    case 'AC5'
        deviceType_rec=get_param(block,'deviceType_rec');
        deviceType_inv=get_param(block,'deviceType_inv');
        regulationType=get_param(block,'regulationType');

        maskParameters=ones(1,85);
        maskParameters(:,84)=0;


        if wantAverageValueModel






            maskParameters(:,78)=0;





            maskParameters(1,29)=0;
            p=handlemask.getDialogControl('RecForwardvoltages');
            p.Visible='off';
            p=handlemask.getDialogControl('RecTurnoff');
            p.Visible='off';
            p=handlemask.getDialogControl('RecSnubbers');
            p.Visible='off';


            maskParameters(1,42)=0;

            p=handlemask.getDialogControl('InvForwardvoltages');
            p.Visible='on';
            p=handlemask.getDialogControl('InvTurnoff');
            p.Visible='off';
            p=handlemask.getDialogControl('InvSnubbers');
            p.Visible='off';


            if strcmp(regulationType,'Speed regulation')
                p=handlemask.getDialogControl('Speedramp');
                p.Visible='on';
                p=handlemask.getDialogControl('PIregulator');
                p.Visible='on';
            elseif strcmp(regulationType,'Torque regulation')
                maskParameters(:,53:57)=zeros(1,5);
                p=handlemask.getDialogControl('Speedramp');
                p.Visible='off';
                p=handlemask.getDialogControl('PIregulator');
                p.Visible='off';
            end

        elseif~wantAverageValueModel







            maskParameters(:,27)=0;
            maskParameters(:,28)=0;



            p=handlemask.getDialogControl('RecSnubbers');
            p.Visible='on';

            if strcmp(deviceType_rec,'IGBT / Diodes')
                maskParameters(:,35:36)=zeros(1,2);
                p=handlemask.getDialogControl('RecForwardvoltages');
                p.Visible='on';
                p=handlemask.getDialogControl('RecTurnoff');
                p.Visible='on';
            elseif strcmp(deviceType_rec,'GTO / Diodes')
                maskParameters(:,33:34)=zeros(1,2);
                p=handlemask.getDialogControl('RecForwardvoltages');
                p.Visible='on';
                p=handlemask.getDialogControl('RecTurnoff');
                p.Visible='on';
            elseif strcmp(deviceType_rec,'MOSFET / Diodes')

                p=handlemask.getDialogControl('RecForwardvoltages');
                p.Visible='off';
                p=handlemask.getDialogControl('RecTurnoff');
                p.Visible='off';
            end


            p=handlemask.getDialogControl('InvSnubbers');
            p.Visible='on';
            if strcmp(deviceType_inv,'IGBT / Diodes')
                maskParameters(:,48:49)=zeros(1,2);
                p=handlemask.getDialogControl('InvForwardvoltages');
                p.Visible='on';
                p=handlemask.getDialogControl('InvTurnoff');
                p.Visible='on';
            elseif strcmp(deviceType_inv,'GTO / Diodes')
                maskParameters(:,46:47)=zeros(1,2);
                p=handlemask.getDialogControl('InvForwardvoltages');
                p.Visible='on';
                p=handlemask.getDialogControl('InvTurnoff');
                p.Visible='on';
            elseif strcmp(deviceType_inv,'MOSFET / Diodes')

                p=handlemask.getDialogControl('InvForwardvoltages');
                p.Visible='off';
                p=handlemask.getDialogControl('InvTurnoff');
                p.Visible='off';
            end


            if strcmp(regulationType,'Speed regulation')
                p=handlemask.getDialogControl('Speedramp');
                p.Visible='on';
                p=handlemask.getDialogControl('PIregulator');
                p.Visible='on';
            elseif strcmp(regulationType,'Torque regulation')
                maskParameters(:,53:57)=zeros(1,5);
                p=handlemask.getDialogControl('Speedramp');
                p.Visible='off';
                p=handlemask.getDialogControl('PIregulator');
                p.Visible='off';
            end

        end

    case 'AC6'
        deviceType=get_param(block,'deviceType');
        regulationType=get_param(block,'regulationType');
        modulationType=get_param(block,'modulationType');
        machineConstant=get_param(block,'MachineConstant');
        maskParameters=ones(1,60+4-1);
        maskParameters(:,59+4-1)=0;

        if wantAverageValueModel







            if strcmp(machineConstant,'Flux linkage established by magnets (V.s)')
                maskParameters(:,6:7)=zeros(1,2);
            elseif strcmp(machineConstant,'Voltage Constant (V_peak L-L / krpm)')
                maskParameters(1,5)=0;
                maskParameters(1,7)=0;
            elseif strcmp(machineConstant,'Torque Constant (N.m / A_peak)')
                maskParameters(1,5:6)=zeros(1,2);
            end


            maskParameters(1,25)=0;

            p=handlemask.getDialogControl('Forwardvoltages');
            p.Visible='off';
            p=handlemask.getDialogControl('Turnoff');
            p.Visible='off';
            p=handlemask.getDialogControl('InvSnubbers');
            p.Visible='off';


            maskParameters(:,44:52)=zeros(1,9);
            p=handlemask.getDialogControl('d_axiscurrentregulator');
            p.Visible='off';
            p=handlemask.getDialogControl('q_axiscurrentregulator');
            p.Visible='off';


            if strcmp(regulationType,'Speed regulation')
                p=handlemask.getDialogControl('Speedramp');
                p.Visible='on';
                p=handlemask.getDialogControl('PIregulator');
                p.Visible='on';
            elseif strcmp(regulationType,'Torque regulation')

                maskParameters(1,40)=0;
                p=handlemask.getDialogControl('Speedramp');
                p.Visible='off';
                p=handlemask.getDialogControl('PIregulator');
                p.Visible='off';
            end

        elseif~wantAverageValueModel






            if strcmp(machineConstant,'Flux linkage established by magnets (V.s)')
                maskParameters(:,6:7)=zeros(1,2);
            elseif strcmp(machineConstant,'Voltage Constant (V_peak L-L / krpm)')
                maskParameters(1,5)=0;
                maskParameters(1,7)=0;
            elseif strcmp(machineConstant,'Torque Constant (N.m / A_peak)')
                maskParameters(1,5:6)=zeros(1,2);
            end


            maskParameters(1,24)=0;
            p=handlemask.getDialogControl('InvSnubbers');
            p.Visible='on';
            if strcmp(deviceType,'IGBT / Diodes')
                maskParameters(:,31:32)=zeros(1,2);
                p=handlemask.getDialogControl('Forwardvoltages');
                p.Visible='on';
                p=handlemask.getDialogControl('Turnoff');
                p.Visible='on';
            elseif strcmp(deviceType,'GTO / Diodes')
                maskParameters(:,29:30)=zeros(1,2);
                p=handlemask.getDialogControl('Forwardvoltages');
                p.Visible='on';
                p=handlemask.getDialogControl('Turnoff');
                p.Visible='on';
            elseif strcmp(deviceType,'MOSFET / Diodes')

                p=handlemask.getDialogControl('Forwardvoltages');
                p.Visible='off';
                p=handlemask.getDialogControl('Turnoff');
                p.Visible='off';
            end


            if strcmp(modulationType,'Hysteresis')
                maskParameters(:,46:51)=zeros(1,6);
                p=handlemask.getDialogControl('d_axiscurrentregulator');
                p.Visible='off';
                p=handlemask.getDialogControl('q_axiscurrentregulator');
                p.Visible='off';
            elseif strcmp(modulationType,'SVM')
                maskParameters(1,45)=0;
                maskParameters(1,52)=0;
                p=handlemask.getDialogControl('d_axiscurrentregulator');
                p.Visible='on';
                p=handlemask.getDialogControl('q_axiscurrentregulator');
                p.Visible='on';
            end

            if strcmp(regulationType,'Speed regulation')
                p=handlemask.getDialogControl('Speedramp');
                p.Visible='on';
                p=handlemask.getDialogControl('PIregulator');
                p.Visible='on';
            elseif strcmp(regulationType,'Torque regulation')

                maskParameters(1,40)=0;
                p=handlemask.getDialogControl('Speedramp');
                p.Visible='off';
                p=handlemask.getDialogControl('PIregulator');
                p.Visible='off';
            end

        end

    case 'AC7'
        deviceType=get_param(block,'deviceType');
        regulationType=get_param(block,'regulationType');
        machineConstant=get_param(block,'MachineConstant');
        sensorless=get_param(block,'sensorless');
        maskParameters=ones(1,55+3-1);
        maskParameters(:,54+3-1)=0;


        if strcmp(sensorless,'on')
            p=handlemask.getDialogControl('sensorlessTab');
            p.Visible='on';

        elseif strcmp(sensorless,'off')
            p=handlemask.getDialogControl('sensorlessTab');
            p.Visible='off';

        end


        if wantAverageValueModel







            if strcmp(machineConstant,'Flux linkage established by magnets (V.s)')
                maskParameters(:,6:7)=zeros(1,2);
            elseif strcmp(machineConstant,'Voltage Constant (V_peak L-L / krpm)')
                maskParameters(1,5)=0;
                maskParameters(1,7)=0;
            elseif strcmp(machineConstant,'Torque Constant (N.m / A_peak)')
                maskParameters(1,5:6)=zeros(1,2);
            end


            maskParameters(1,24)=0;
            maskParameters(:,26:33)=zeros(1,8);
            p=handlemask.getDialogControl('Forwardvoltages');
            p.Visible='off';
            p=handlemask.getDialogControl('Turnoff');
            p.Visible='off';
            p=handlemask.getDialogControl('InvSnubbers');
            p.Visible='off';



            maskParameters(:,43:44)=zeros(1,2);


            if strcmp(regulationType,'Speed regulation')
                p=handlemask.getDialogControl('Speedramp');
                p.Visible='on';
                p=handlemask.getDialogControl('PIregulator');
                p.Visible='on';
            elseif strcmp(regulationType,'Torque regulation')
                maskParameters(:,35:39)=zeros(1,5);
                p=handlemask.getDialogControl('Speedramp');
                p.Visible='off';
                p=handlemask.getDialogControl('PIregulator');
                p.Visible='off';
            end


        elseif~wantAverageValueModel







            if strcmp(machineConstant,'Flux linkage established by magnets (V.s)')
                maskParameters(:,6:7)=zeros(1,2);
            elseif strcmp(machineConstant,'Voltage Constant (V_peak L-L / krpm)')
                maskParameters(1,5)=0;
                maskParameters(1,7)=0;
            elseif strcmp(machineConstant,'Torque Constant (N.m / A_peak)')
                maskParameters(1,5:6)=zeros(1,2);
            end


            p=handlemask.getDialogControl('InvSnubbers');
            p.Visible='on';
            if strcmp(deviceType,'IGBT / Diodes')
                maskParameters(:,30:31)=zeros(1,2);
                p=handlemask.getDialogControl('Forwardvoltages');
                p.Visible='on';
                p=handlemask.getDialogControl('Turnoff');
                p.Visible='on';
            elseif strcmp(deviceType,'GTO / Diodes')
                maskParameters(:,28:29)=zeros(1,2);
                p=handlemask.getDialogControl('Forwardvoltages');
                p.Visible='on';
                p=handlemask.getDialogControl('Turnoff');
                p.Visible='on';

            elseif strcmp(deviceType,'MOSFET / Diodes')
                maskParameters(:,26:31)=zeros(1,6);
                p=handlemask.getDialogControl('Forwardvoltages');
                p.Visible='off';
                p=handlemask.getDialogControl('Turnoff');
                p.Visible='off';
            end




            if strcmp(regulationType,'Speed regulation')
                p=handlemask.getDialogControl('Speedramp');
                p.Visible='on';
                p=handlemask.getDialogControl('PIregulator');
                p.Visible='on';
            elseif strcmp(regulationType,'Torque regulation')
                maskParameters(:,35:39)=zeros(1,5);
                p=handlemask.getDialogControl('Speedramp');
                p.Visible='off';
                p=handlemask.getDialogControl('PIregulator');
                p.Visible='off';
            end

        end

    case 'AC8'
        deviceType=get_param(block,'deviceType');
        regulationType=get_param(block,'regulationType');
        machineConstant=get_param(block,'MachineConstant');
        maskParameters=ones(1,54);
        maskParameters(:,53)=0;

        if wantAverageValueModel







            if strcmp(machineConstant,'Flux linkage established by magnets (V.s)')
                maskParameters(:,5:6)=zeros(1,2);
            elseif strcmp(machineConstant,'Voltage Constant (V_peak L-L / krpm)')
                maskParameters(1,4)=0;
                maskParameters(1,6)=0;
            elseif strcmp(machineConstant,'Torque Constant (N.m / A_peak)')
                maskParameters(1,4:5)=zeros(1,2);
            end


            maskParameters(1,26)=0;

            p=handlemask.getDialogControl('Forwardvoltages');
            p.Visible='off';
            p=handlemask.getDialogControl('Turnoff');
            p.Visible='off';
            p=handlemask.getDialogControl('InvSnubbers');
            p.Visible='off';



            maskParameters(:,45:46)=zeros(1,2);


            if strcmp(regulationType,'Speed regulation')
                p=handlemask.getDialogControl('Speedramp');
                p.Visible='on';
                p=handlemask.getDialogControl('PIregulator');
                p.Visible='on';
            elseif strcmp(regulationType,'Torque regulation')

                maskParameters(1,41)=0;
                p=handlemask.getDialogControl('Speedramp');
                p.Visible='off';
                p=handlemask.getDialogControl('PIregulator');
                p.Visible='off';
            end


        elseif~wantAverageValueModel







            if strcmp(machineConstant,'Flux linkage established by magnets (V.s)')
                maskParameters(:,5:6)=zeros(1,2);
            elseif strcmp(machineConstant,'Voltage Constant (V_peak L-L / krpm)')
                maskParameters(1,4)=0;
                maskParameters(1,6)=0;
            elseif strcmp(machineConstant,'Torque Constant (N.m / A_peak)')
                maskParameters(1,4:5)=zeros(1,2);
            end


            maskParameters(1,25)=0;
            p=handlemask.getDialogControl('InvSnubbers');
            p.Visible='on';
            if strcmp(deviceType,'IGBT / Diodes')
                maskParameters(:,32:33)=zeros(1,2);
                p=handlemask.getDialogControl('Forwardvoltages');
                p.Visible='on';
                p=handlemask.getDialogControl('Turnoff');
                p.Visible='on';
            elseif strcmp(deviceType,'GTO / Diodes')
                maskParameters(:,30:31)=zeros(1,2);
                p=handlemask.getDialogControl('Forwardvoltages');
                p.Visible='on';
                p=handlemask.getDialogControl('Turnoff');
                p.Visible='on';

            elseif strcmp(deviceType,'MOSFET / Diodes')

                p=handlemask.getDialogControl('Forwardvoltages');
                p.Visible='off';
                p=handlemask.getDialogControl('Turnoff');
                p.Visible='off';
            end




            if strcmp(regulationType,'Speed regulation')
                p=handlemask.getDialogControl('Speedramp');
                p.Visible='on';
                p=handlemask.getDialogControl('PIregulator');
                p.Visible='on';
            elseif strcmp(regulationType,'Torque regulation')

                maskParameters(1,41)=0;
                p=handlemask.getDialogControl('Speedramp');
                p.Visible='off';
                p=handlemask.getDialogControl('PIregulator');
                p.Visible='off';
            end

        end

    end

    maskVisibilities(1==maskParameters)={'on'};
    maskVisibilities(0==maskParameters)={'off'};


    switch driveType

    case{'DC1','DC2','DC3','DC4','DC5','DC6','DC7'}
        p=handlemask.getDialogControl('Mechanical');
        if strcmp('Speed w',get_param(block,'MechanicalLoad'))
            p.Visible='off';
        else
            p.Visible='on';
        end

    case{'AC1','AC2','AC3','AC4'}
        if strcmp('Speed w',get_param(block,'MechanicalLoad'))
            maskVisibilities{17}='off';
            maskVisibilities{18}='off';
            maskVisibilities{20}='off';
        else
            maskVisibilities{17}='on';
            maskVisibilities{18}='on';
            maskVisibilities{20}='on';
        end

    case 'AC5'
        if strcmp('Speed w',get_param(block,'MechanicalLoad'))
            maskVisibilities{22}='off';
            maskVisibilities{23}='off';
            maskVisibilities{25}='off';
        else
            maskVisibilities{22}='on';
            maskVisibilities{23}='on';
            maskVisibilities{25}='on';
        end

    case{'AC6','AC7'}
        if strcmp('Speed w',get_param(block,'MechanicalLoad'))
            maskVisibilities{10}='off';
            maskVisibilities{11}='off';
            maskVisibilities{13}='off';
        else
            maskVisibilities{10}='on';
            maskVisibilities{11}='on';
            maskVisibilities{13}='on';
        end

    case 'AC8'
        if strcmp('Speed w',get_param(block,'MechanicalLoad'))
            maskVisibilities{11}='off';
            maskVisibilities{12}='off';
            maskVisibilities{14}='off';
        else
            maskVisibilities{11}='on';
            maskVisibilities{12}='on';
            maskVisibilities{14}='on';
        end

    end

    maskEnables=maskVisibilities;

    inLibrary=strcmp(get_param(bdroot(block),'BlockDiagramType'),'library');
    if~inLibrary&&~strcmp(get_param(bdroot(block),'EditingMode'),'Restricted')
        set_param(block,'MaskEnables',maskEnables);
        set_param(block,'MaskVisibilities',maskVisibilities);
    end
