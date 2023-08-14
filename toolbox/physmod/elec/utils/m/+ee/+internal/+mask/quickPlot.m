function varargout=quickPlot(blockHandle)






    if ishandle(blockHandle)
        name=get_param(blockHandle,'Name');
        parent=get_param(blockHandle,'Parent');
        blockName=[parent,'/',name];
    else
        blockName=blockHandle;
    end
    componentPath=get_param(blockName,'ComponentPath');
    column_subplot=false;
    reverse_xaxis=false;
    switch componentPath
    case 'ee.ic.logic.cmos_and'

        parameterNameValueList=ee.internal.mask.getParameterNameValueList(blockName,false);
        ds=ee.internal.mask.populateDataStructure(parameterNameValueList);


        Vil=ee.internal.mask.getParamWithUnit(blockHandle,'V_IL');
        Vil=value(Vil,'V');
        Vih=ee.internal.mask.getParamWithUnit(blockHandle,'V_IH');
        Vih=value(Vih,'V');
        Delay=ee.internal.mask.getParamWithUnit(blockHandle,'Delay');
        Delay=value(Delay,'ns');


        inputSourceTypes={'source1','source2'};
        for ii=1:length(inputSourceTypes)
            ds.addCharacteristic(simscapeCharacteristic);

            ds.characteristicData(ii).addCurve(simscapeLogicAndCurve(inputSourceTypes{ii},[Vil,Vih,Delay],ds.parameters));
        end
        xlab{1}=getString(message('physmod:ee:library:comments:utils:mask:quickPlot:label_Time'));
        ylab{1}=getString(message('physmod:ee:library:comments:utils:mask:quickPlot:label_InputVoltageA'));
        xlab{2}=getString(message('physmod:ee:library:comments:utils:mask:quickPlot:label_Time'));
        ylab{2}=getString(message('physmod:ee:library:comments:utils:mask:quickPlot:label_InputVoltageB'));


        ds.addCharacteristic(simscapeCharacteristic);
        ds.characteristicData(3).addCurve(simscapeLogicAndCurve('logic',[Vil,Vih,Delay],ds.parameters));
        xlab{3}=getString(message('physmod:ee:library:comments:utils:mask:quickPlot:label_Time'));
        ylab{3}=getString(message('physmod:ee:library:comments:utils:mask:quickPlot:label_OutputVoltage'));
        column_subplot=true;
    case 'ee.ic.logic.cmos_nand'

        parameterNameValueList=ee.internal.mask.getParameterNameValueList(blockName,false);
        ds=ee.internal.mask.populateDataStructure(parameterNameValueList);


        Vil=ee.internal.mask.getParamWithUnit(blockHandle,'V_IL');
        Vil=value(Vil,'V');
        Vih=ee.internal.mask.getParamWithUnit(blockHandle,'V_IH');
        Vih=value(Vih,'V');
        Delay=ee.internal.mask.getParamWithUnit(blockHandle,'Delay');
        Delay=value(Delay,'ns');


        inputSourceTypes={'source1','source2'};
        for ii=1:length(inputSourceTypes)
            ds.addCharacteristic(simscapeCharacteristic);

            ds.characteristicData(ii).addCurve(simscapeLogicNandCurve(inputSourceTypes{ii},[Vil,Vih,Delay],ds.parameters));
        end
        xlab{1}=getString(message('physmod:ee:library:comments:utils:mask:quickPlot:label_Time'));
        ylab{1}=getString(message('physmod:ee:library:comments:utils:mask:quickPlot:label_InputVoltageA'));
        xlab{2}=getString(message('physmod:ee:library:comments:utils:mask:quickPlot:label_Time'));
        ylab{2}=getString(message('physmod:ee:library:comments:utils:mask:quickPlot:label_InputVoltageB'));


        ds.addCharacteristic(simscapeCharacteristic);
        ds.characteristicData(3).addCurve(simscapeLogicNandCurve('logic',[Vil,Vih,Delay],ds.parameters));
        xlab{3}=getString(message('physmod:ee:library:comments:utils:mask:quickPlot:label_Time'));
        ylab{3}=getString(message('physmod:ee:library:comments:utils:mask:quickPlot:label_OutputVoltage'));
        column_subplot=true;
    case 'ee.ic.logic.cmos_nor'

        parameterNameValueList=ee.internal.mask.getParameterNameValueList(blockName,false);
        ds=ee.internal.mask.populateDataStructure(parameterNameValueList);


        Vil=ee.internal.mask.getParamWithUnit(blockHandle,'V_IL');
        Vil=value(Vil,'V');
        Vih=ee.internal.mask.getParamWithUnit(blockHandle,'V_IH');
        Vih=value(Vih,'V');
        Delay=ee.internal.mask.getParamWithUnit(blockHandle,'Delay');
        Delay=value(Delay,'ns');


        inputSourceTypes={'source1','source2'};
        for ii=1:length(inputSourceTypes)
            ds.addCharacteristic(simscapeCharacteristic);

            ds.characteristicData(ii).addCurve(simscapeLogicNorCurve(inputSourceTypes{ii},[Vil,Vih,Delay],ds.parameters));
        end
        xlab{1}=getString(message('physmod:ee:library:comments:utils:mask:quickPlot:label_Time'));
        ylab{1}=getString(message('physmod:ee:library:comments:utils:mask:quickPlot:label_InputVoltageA'));
        xlab{2}=getString(message('physmod:ee:library:comments:utils:mask:quickPlot:label_Time'));
        ylab{2}=getString(message('physmod:ee:library:comments:utils:mask:quickPlot:label_InputVoltageB'));


        ds.addCharacteristic(simscapeCharacteristic);
        ds.characteristicData(3).addCurve(simscapeLogicNorCurve('logic',[Vil,Vih,Delay],ds.parameters));
        xlab{3}=getString(message('physmod:ee:library:comments:utils:mask:quickPlot:label_Time'));
        ylab{3}=getString(message('physmod:ee:library:comments:utils:mask:quickPlot:label_OutputVoltage'));
        column_subplot=true;
    case 'ee.ic.logic.cmos_not'

        parameterNameValueList=ee.internal.mask.getParameterNameValueList(blockName,false);
        ds=ee.internal.mask.populateDataStructure(parameterNameValueList);


        Vil=ee.internal.mask.getParamWithUnit(blockHandle,'V_IL');
        Vil=value(Vil,'V');
        Vih=ee.internal.mask.getParamWithUnit(blockHandle,'V_IH');
        Vih=value(Vih,'V');
        Delay=ee.internal.mask.getParamWithUnit(blockHandle,'Delay');
        Delay=value(Delay,'ns');


        inputSourceTypes='source1';
        ds.addCharacteristic(simscapeCharacteristic);

        ds.characteristicData(1).addCurve(simscapeLogicNotCurve(inputSourceTypes,[Vil,Vih,Delay],ds.parameters));

        xlab{1}=getString(message('physmod:ee:library:comments:utils:mask:quickPlot:label_Time'));
        ylab{1}=getString(message('physmod:ee:library:comments:utils:mask:quickPlot:label_InputVoltage'));


        ds.addCharacteristic(simscapeCharacteristic);
        ds.characteristicData(2).addCurve(simscapeLogicNotCurve('logic',[Vil,Vih,Delay],ds.parameters));
        xlab{2}=getString(message('physmod:ee:library:comments:utils:mask:quickPlot:label_Time'));
        ylab{2}=getString(message('physmod:ee:library:comments:utils:mask:quickPlot:label_OutputVoltage'));
        column_subplot=true;
    case 'ee.ic.logic.cmos_or'

        parameterNameValueList=ee.internal.mask.getParameterNameValueList(blockName,false);
        ds=ee.internal.mask.populateDataStructure(parameterNameValueList);


        Vil=ee.internal.mask.getParamWithUnit(blockHandle,'V_IL');
        Vil=value(Vil,'V');
        Vih=ee.internal.mask.getParamWithUnit(blockHandle,'V_IH');
        Vih=value(Vih,'V');
        Delay=ee.internal.mask.getParamWithUnit(blockHandle,'Delay');
        Delay=value(Delay,'ns');


        inputSourceTypes={'source1','source2'};
        for ii=1:length(inputSourceTypes)
            ds.addCharacteristic(simscapeCharacteristic);

            ds.characteristicData(ii).addCurve(simscapeLogicOrCurve(inputSourceTypes{ii},[Vil,Vih,Delay],ds.parameters));
        end
        xlab{1}=getString(message('physmod:ee:library:comments:utils:mask:quickPlot:label_Time'));
        ylab{1}=getString(message('physmod:ee:library:comments:utils:mask:quickPlot:label_InputVoltageA'));
        xlab{2}=getString(message('physmod:ee:library:comments:utils:mask:quickPlot:label_Time'));
        ylab{2}=getString(message('physmod:ee:library:comments:utils:mask:quickPlot:label_InputVoltageB'));


        ds.addCharacteristic(simscapeCharacteristic);
        ds.characteristicData(3).addCurve(simscapeLogicOrCurve('logic',[Vil,Vih,Delay],ds.parameters));
        xlab{3}=getString(message('physmod:ee:library:comments:utils:mask:quickPlot:label_Time'));
        ylab{3}=getString(message('physmod:ee:library:comments:utils:mask:quickPlot:label_OutputVoltage'));
        column_subplot=true;
    case 'ee.ic.logic.cmos_xor'

        parameterNameValueList=ee.internal.mask.getParameterNameValueList(blockName,false);
        ds=ee.internal.mask.populateDataStructure(parameterNameValueList);


        Vil=ee.internal.mask.getParamWithUnit(blockHandle,'V_IL');
        Vil=value(Vil,'V');
        Vih=ee.internal.mask.getParamWithUnit(blockHandle,'V_IH');
        Vih=value(Vih,'V');
        Delay=ee.internal.mask.getParamWithUnit(blockHandle,'Delay');
        Delay=value(Delay,'ns');


        inputSourceTypes={'source1','source2'};
        for ii=1:length(inputSourceTypes)
            ds.addCharacteristic(simscapeCharacteristic);

            ds.characteristicData(ii).addCurve(simscapeLogicXorCurve(inputSourceTypes{ii},[Vil,Vih,Delay],ds.parameters));
        end
        xlab{1}=getString(message('physmod:ee:library:comments:utils:mask:quickPlot:label_Time'));
        ylab{1}=getString(message('physmod:ee:library:comments:utils:mask:quickPlot:label_InputVoltageA'));
        xlab{2}=getString(message('physmod:ee:library:comments:utils:mask:quickPlot:label_Time'));
        ylab{2}=getString(message('physmod:ee:library:comments:utils:mask:quickPlot:label_InputVoltageB'));


        ds.addCharacteristic(simscapeCharacteristic);
        ds.characteristicData(3).addCurve(simscapeLogicXorCurve('logic',[Vil,Vih,Delay],ds.parameters));
        xlab{3}=getString(message('physmod:ee:library:comments:utils:mask:quickPlot:label_Time'));
        ylab{3}=getString(message('physmod:ee:library:comments:utils:mask:quickPlot:label_OutputVoltage'));
        column_subplot=true;
    case{'ee.semiconductors.sp_nmos'}
        numIdVdsCurves=4;
        numIdVgsCurves=2;
        VgsmaxMultiple=5;
        VdsmaxMultiple=3;


        parameterNameValueList=ee.internal.mask.getParameterNameValueList(blockName,false);
        ds=ee.internal.mask.populateDataStructure(parameterNameValueList);


        paramTerminal=get_param(blockHandle,'paramTerminal');

        vfb=ee.internal.mask.getParamWithUnit(blockHandle,'Vfbref');
        vfb=value(vfb,'V');
        phib2=ee.internal.mask.getParamWithUnit(blockHandle,'phib2ref');
        phib2=value(phib2,'V');
        gamma=ee.internal.mask.getParamWithUnit(blockHandle,'gamma');
        gamma=value(gamma,'V^0.5');
        Tref=ee.internal.mask.getParamWithUnit(blockHandle,'Tref');
        Tref=value(Tref,'K');
        phit=8.617332478e-5*Tref;

        VT=vfb+phib2+gamma*sqrt(phib2+2*phit);

        Vgsmax=round(VT+abs(VT)*(VgsmaxMultiple-1),1,'significant');
        Vdsmax=round((Vgsmax-VT)*VdsmaxMultiple,1,'significant');
        Vdsmin=round((Vgsmax-VT)/VdsmaxMultiple,1,'significant');
        VgsSteps=linspace(VT,Vgsmax,numIdVdsCurves+1);
        VgsSteps=sort(round(VgsSteps(2:end),2,'significant'),'descend');
        VdsSteps=sort(round(linspace(Vdsmin,Vdsmax,numIdVgsCurves),2,'significant'),'descend');
        VdsSweep=[0,Vdsmax];
        VgsSweep=[0,Vgsmax];
        VbsSteps=0;


        ds.addCharacteristic(simscapeCharacteristic);
        switch paramTerminal
        case 'ee.enum.mosfet.numberOfTerminals.three'
            for ii=1:length(VgsSteps)
                ds.characteristicData(1).addCurve(simscapeSimulatedSpNmosCurve({'voltage','voltage','reference'},{VdsSweep,VgsSteps(ii)},'current',1,ds.parameters));
                leg{1}{ii}=sprintf('V_{GS}=%gV',VgsSteps(ii));
            end
        case 'ee.enum.mosfet.numberOfTerminals.four'
            for ii=1:length(VgsSteps)
                ds.characteristicData(1).addCurve(simscapeSimulatedSpFourTerminalsNmosCurve({'voltage','voltage','reference','voltage'},{VdsSweep,VgsSteps(ii),VbsSteps},'current',1,ds.parameters));
                leg{1}{ii}=sprintf('V_{GS}=%gV',VgsSteps(ii));
            end
        otherwise
            pm_error('physmod:ee:library:NotFound',getString(message('physmod:ee:library:comments:utils:mask:quickPlot:error_ValidNChannelMOSFETParameterization')));
        end
        xlab{1}='V_{DS} (V)';
        ylab{1}='I_{D} (A)';


        ds.addCharacteristic(simscapeCharacteristic);
        switch paramTerminal
        case 'ee.enum.mosfet.numberOfTerminals.three'
            for ii=1:length(VdsSteps)
                ds.characteristicData(2).addCurve(simscapeSimulatedSpNmosCurve({'voltage','voltage','reference'},{VdsSteps(ii),VgsSweep},'current',1,ds.parameters));
                leg{2}{ii}=sprintf('V_{DS}=%gV',VdsSteps(ii));
            end
        case 'ee.enum.mosfet.numberOfTerminals.four'
            for ii=1:length(VdsSteps)
                ds.characteristicData(2).addCurve(simscapeSimulatedSpFourTerminalsNmosCurve({'voltage','voltage','reference','voltage'},{VdsSteps(ii),VgsSweep,VbsSteps},'current',1,ds.parameters));
                leg{2}{ii}=sprintf('V_{DS}=%gV',VdsSteps(ii));
            end
        otherwise
            pm_error('physmod:ee:library:NotFound',getString(message('physmod:ee:library:comments:utils:mask:quickPlot:error_ValidNChannelMOSFETParameterization')));
        end
        xlab{2}='V_{GS} (V)';
        ylab{2}='I_{D} (A)';

    case{'ee.semiconductors.sp_pmos'}
        numIdVdsCurves=4;
        numIdVgsCurves=2;
        VgsmaxMultiple=5;
        VdsmaxMultiple=3;


        parameterNameValueList=ee.internal.mask.getParameterNameValueList(blockName,false);
        ds=ee.internal.mask.populateDataStructure(parameterNameValueList);


        paramTerminal=get_param(blockHandle,'paramTerminal');

        vfb=ee.internal.mask.getParamWithUnit(blockHandle,'Vfbref');
        vfb=value(vfb,'V');
        phib2=ee.internal.mask.getParamWithUnit(blockHandle,'phib2ref');
        phib2=value(phib2,'V');
        gamma=ee.internal.mask.getParamWithUnit(blockHandle,'gamma');
        gamma=value(gamma,'V^0.5');
        Tref=ee.internal.mask.getParamWithUnit(blockHandle,'Tref');
        Tref=value(Tref,'K');
        phit=8.617332478e-5*Tref;

        VT=vfb+phib2+gamma*sqrt(phib2+2*phit);

        Vgsmax=round(VT+abs(VT)*(VgsmaxMultiple-1),1,'significant');
        Vdsmax=round((Vgsmax-VT)*VdsmaxMultiple,1,'significant');
        Vdsmin=round((Vgsmax-VT)/VdsmaxMultiple,1,'significant');
        VgsSteps=linspace(-VT,-Vgsmax,numIdVdsCurves+1);
        VgsSteps=sort(round(VgsSteps(2:end),2,'significant'),'descend');
        VdsSteps=sort(round(linspace(-Vdsmin,-Vdsmax,numIdVgsCurves),2,'significant'),'descend');
        VdsSweep=[0,-Vdsmax];
        VgsSweep=[0,-Vgsmax];
        VbsSteps=0;


        ds.addCharacteristic(simscapeCharacteristic);
        switch paramTerminal
        case 'ee.enum.mosfet.numberOfTerminals.three'
            for ii=1:length(VgsSteps)
                ds.characteristicData(1).addCurve(simscapeSimulatedSpPmosCurve({'voltage','voltage','reference'},{VdsSweep,VgsSteps(ii)},'current',1,ds.parameters));
                leg{1}{ii}=sprintf('V_{GS}=%gV',VgsSteps(ii));
            end
        case 'ee.enum.mosfet.numberOfTerminals.four'
            for ii=1:length(VgsSteps)
                ds.characteristicData(1).addCurve(simscapeSimulatedSpFourTerminalsPmosCurve({'voltage','voltage','reference','voltage'},{VdsSweep,VgsSteps(ii),VbsSteps},'current',1,ds.parameters));
                leg{1}{ii}=sprintf('V_{GS}=%gV',VgsSteps(ii));
            end
        otherwise
            pm_error('physmod:ee:library:NotFound',getString(message('physmod:ee:library:comments:utils:mask:quickPlot:error_ValidPChannelMOSFETParameterization')));
        end
        xlab{1}='V_{DS} (V)';
        ylab{1}='I_{D} (A)';


        ds.addCharacteristic(simscapeCharacteristic);
        switch paramTerminal
        case 'ee.enum.mosfet.numberOfTerminals.three'
            for ii=1:length(VdsSteps)
                ds.characteristicData(2).addCurve(simscapeSimulatedSpPmosCurve({'voltage','voltage','reference'},{VdsSteps(ii),VgsSweep},'current',1,ds.parameters));
                leg{2}{ii}=sprintf('V_{DS}=%gV',VdsSteps(ii));
            end
        case 'ee.enum.mosfet.numberOfTerminals.four'
            for ii=1:length(VdsSteps)
                ds.characteristicData(2).addCurve(simscapeSimulatedSpFourTerminalsPmosCurve({'voltage','voltage','reference','voltage'},{VdsSteps(ii),VgsSweep,VbsSteps},'current',1,ds.parameters));
                leg{2}{ii}=sprintf('V_{DS}=%gV',VdsSteps(ii));
            end
        otherwise
            pm_error('physmod:ee:library:NotFound',getString(message('physmod:ee:library:comments:utils:mask:quickPlot:error_ValidPChannelMOSFETParameterization')));
        end
        xlab{2}='V_{GS} (V)';
        ylab{2}='I_{D} (A)';
    case 'ee.semiconductors.n_mosfet'
        numIdVdsCurves=4;
        numIdVgsCurves=2;
        VgsmaxMultiple=5;
        VdsmaxMultiple=3;


        parameterNameValueList=ee.internal.mask.getParameterNameValueList(blockName,false);
        ds=ee.internal.mask.populateDataStructure(parameterNameValueList);


        paramTerminal=get_param(blockHandle,'paramTerminal');

        switch paramTerminal
        case 'ee.enum.mosfet.numberOfTerminals.three'
            VT=ee.internal.mask.getParamWithUnit(blockHandle,'Vth');
        otherwise
            VT=ee.internal.mask.getParamWithUnit(blockHandle,'Vth0');
        end
        VT=value(VT,'V');

        Vgsmax=round(VT+abs(VT)*(VgsmaxMultiple-1),1,'significant');
        Vdsmax=round((Vgsmax-VT)*VdsmaxMultiple,1,'significant');
        Vdsmin=round((Vgsmax-VT)/VdsmaxMultiple,1,'significant');
        VgsSteps=linspace(VT,Vgsmax,numIdVdsCurves+1);
        VgsSteps=sort(round(VgsSteps(2:end),2,'significant'),'descend');
        VdsSteps=sort(round(linspace(Vdsmin,Vdsmax,numIdVgsCurves),2,'significant'),'descend');
        VdsSweep=[0,Vdsmax];
        VgsSweep=[0,Vgsmax];
        VbsSteps=0;


        ds.addCharacteristic(simscapeCharacteristic);
        switch paramTerminal
        case 'ee.enum.mosfet.numberOfTerminals.three'
            for ii=1:length(VgsSteps)
                ds.characteristicData(1).addCurve(simscapeSimulatedVtNmosCurve({'voltage','voltage','reference'},{VdsSweep,VgsSteps(ii)},'current',1,ds.parameters));
                leg{1}{ii}=sprintf('V_{GS}=%gV',VgsSteps(ii));
            end
        case 'ee.enum.mosfet.numberOfTerminals.four'
            for ii=1:length(VgsSteps)
                ds.characteristicData(1).addCurve(simscapeSimulatedVtFourTerminalsNmosCurve({'voltage','voltage','reference','voltage'},{VdsSweep,VgsSteps(ii),VbsSteps},'current',1,ds.parameters));
                leg{1}{ii}=sprintf('V_{GS}=%gV',VgsSteps(ii));
            end
        otherwise
            pm_error('physmod:ee:library:NotFound',getString(message('physmod:ee:library:comments:utils:mask:quickPlot:error_ValidNChannelMOSFETParameterization')));
        end
        xlab{1}='V_{DS} (V)';
        ylab{1}='I_{D} (A)';


        ds.addCharacteristic(simscapeCharacteristic);
        switch paramTerminal
        case 'ee.enum.mosfet.numberOfTerminals.three'
            for ii=1:length(VdsSteps)
                ds.characteristicData(2).addCurve(simscapeSimulatedVtNmosCurve({'voltage','voltage','reference'},{VdsSteps(ii),VgsSweep},'current',1,ds.parameters));
                leg{2}{ii}=sprintf('V_{DS}=%gV',VdsSteps(ii));
            end
        case 'ee.enum.mosfet.numberOfTerminals.four'
            for ii=1:length(VdsSteps)
                ds.characteristicData(2).addCurve(simscapeSimulatedVtFourTerminalsNmosCurve({'voltage','voltage','reference','voltage'},{VdsSteps(ii),VgsSweep,VbsSteps},'current',1,ds.parameters));
                leg{2}{ii}=sprintf('V_{DS}=%gV',VdsSteps(ii));
            end
        otherwise
            pm_error('physmod:ee:library:NotFound',getString(message('physmod:ee:library:comments:utils:mask:quickPlot:error_ValidNChannelMOSFETParameterization')));
        end
        xlab{2}='V_{GS} (V)';
        ylab{2}='I_{D} (A)';
    case 'ee.semiconductors.p_mosfet'
        numIdVdsCurves=4;
        numIdVgsCurves=2;
        VgsmaxMultiple=5;
        VdsmaxMultiple=3;


        parameterNameValueList=ee.internal.mask.getParameterNameValueList(blockName,false);
        ds=ee.internal.mask.populateDataStructure(parameterNameValueList);


        paramTerminal=get_param(blockHandle,'paramTerminal');

        switch paramTerminal
        case 'ee.enum.mosfet.numberOfTerminals.three'
            VT=-ee.internal.mask.getParamWithUnit(blockHandle,'Vth');
        otherwise
            VT=-ee.internal.mask.getParamWithUnit(blockHandle,'Vth0');
        end
        VT=value(VT,'V');

        Vgsmax=round(VT+abs(VT)*(VgsmaxMultiple-1),1,'significant');
        Vdsmax=round((Vgsmax-VT)*VdsmaxMultiple,1,'significant');
        Vdsmin=round((Vgsmax-VT)/VdsmaxMultiple,1,'significant');
        VgsSteps=linspace(-VT,-Vgsmax,numIdVdsCurves+1);
        VgsSteps=sort(round(VgsSteps(2:end),2,'significant'),'descend');
        VdsSteps=sort(round(linspace(-Vdsmin,-Vdsmax,numIdVgsCurves),2,'significant'),'descend');
        VdsSweep=[0,-Vdsmax];
        VgsSweep=[0,-Vgsmax];
        VbsSteps=0;


        ds.addCharacteristic(simscapeCharacteristic);
        switch paramTerminal
        case 'ee.enum.mosfet.numberOfTerminals.three'
            for ii=1:length(VgsSteps)
                ds.characteristicData(1).addCurve(simscapeSimulatedVtPmosCurve({'voltage','voltage','reference'},{VdsSweep,VgsSteps(ii)},'current',1,ds.parameters));
                leg{1}{ii}=sprintf('V_{GS}=%gV',VgsSteps(ii));
            end
        case 'ee.enum.mosfet.numberOfTerminals.four'
            for ii=1:length(VgsSteps)
                ds.characteristicData(1).addCurve(simscapeSimulatedVtFourTerminalsPmosCurve({'voltage','voltage','reference','voltage'},{VdsSweep,VgsSteps(ii),VbsSteps},'current',1,ds.parameters));
                leg{1}{ii}=sprintf('V_{GS}=%gV',VgsSteps(ii));
            end
        otherwise
            pm_error('physmod:ee:library:NotFound',getString(message('physmod:ee:library:comments:utils:mask:quickPlot:error_ValidPChannelMOSFETParameterization')));
        end
        xlab{1}='V_{DS} (V)';
        ylab{1}='I_{D} (A)';


        ds.addCharacteristic(simscapeCharacteristic);
        switch paramTerminal
        case 'ee.enum.mosfet.numberOfTerminals.three'
            for ii=1:length(VdsSteps)
                ds.characteristicData(2).addCurve(simscapeSimulatedVtPmosCurve({'voltage','voltage','reference'},{VdsSteps(ii),VgsSweep},'current',1,ds.parameters));
                leg{2}{ii}=sprintf('V_{DS}=%gV',VdsSteps(ii));
            end
        case 'ee.enum.mosfet.numberOfTerminals.four'
            for ii=1:length(VdsSteps)
                ds.characteristicData(2).addCurve(simscapeSimulatedVtFourTerminalsPmosCurve({'voltage','voltage','reference','voltage'},{VdsSteps(ii),VgsSweep,VbsSteps},'current',1,ds.parameters));
                leg{2}{ii}=sprintf('V_{DS}=%gV',VdsSteps(ii));
            end
        otherwise
            pm_error('physmod:ee:library:NotFound',getString(message('physmod:ee:library:comments:utils:mask:quickPlot:error_ValidPChannelMOSFETParameterization')));
        end
        xlab{2}='V_{GS} (V)';
        ylab{2}='I_{D} (A)';
    case 'ee.semiconductors.bjt_npn'
        numIcVceCurves=4;
        numIcVbeCurves=1;
        VbemaxMultiple=1.5;
        IbminDivisor=10;
        VcemaxMultiple=2;


        parameterNameValueList=ee.internal.mask.getParameterNameValueList(blockName,false);
        ds=ee.internal.mask.populateDataStructure(parameterNameValueList);


        prm=get_param(blockHandle,'parameterization');

        temperature=ee.internal.mask.getParamWithUnit(blockHandle,'Tmeas');
        temperature=value(temperature,'K');
        phit=8.617332478e-5*temperature;
        switch prm
        case '1'
            hfe=ee.internal.mask.getParamWithUnit(blockHandle,'hfe');
            hoe=ee.internal.mask.getParamWithUnit(blockHandle,'hoe');
            ich=ee.internal.mask.getParamWithUnit(blockHandle,'Ic_h');
            vceh=ee.internal.mask.getParamWithUnit(blockHandle,'Vce_h');
            br=ee.internal.mask.getParamWithUnit(blockHandle,'BR');
            ec=ee.internal.mask.getParamWithUnit(blockHandle,'ec');
            vbeactive=ee.internal.mask.getParamWithUnit(blockHandle,'V1');
            ibactive=ee.internal.mask.getParamWithUnit(blockHandle,'I1');
            [gain,is]=ee_bipolar_datasheet2params(hfe,hoe,ich,vceh,br,ec*simscape.Value(temperature,'K'),vbeactive,ibactive,[],[]);
            gain=value(gain,'1');
            is=value(is,'A');
            vceh_val=value(vceh,'V');
            ibactive_val=value(ibactive,'A');
        case '2'
            gain=ee.internal.mask.getParamWithUnit(blockHandle,'BF');
            gain=value(gain,'1');
            is=ee.internal.mask.getParamWithUnit(blockHandle,'IS');
            is=value(is,'A');
            vceh_val=inf;
            ibactive_val=500e-6;
        otherwise
            pm_error('physmod:ee:library:NotFound',getString(message('physmod:ee:library:comments:utils:mask:quickPlot:error_ValidBJTParameterization')));
        end
        rc=ee.internal.mask.getParamWithUnit(blockHandle,'RC');
        rc=value(rc,'Ohm');
        re=ee.internal.mask.getParamWithUnit(blockHandle,'RE');
        re=value(re,'Ohm');
        Vj=phit*log(ibactive_val*gain/is);
        Ibmax=min(Vj*(VcemaxMultiple-1)/((gain+1)*re+gain*rc),0.5);
        Vbemax=Vj*VbemaxMultiple;
        Ibmin=Ibmax/IbminDivisor;
        Vcemax=round(VcemaxMultiple*Vbemax,1,'significant');
        VceSweep=[0,Vcemax];
        VbeSweep=[0,Vbemax];
        IbSteps=sort(round(linspace(Ibmin,Ibmax,numIcVceCurves),2,'significant'),'descend');
        if isinf(vceh_val)
            VceSteps=sort(round(linspace(Vbemax,Vcemax,numIcVbeCurves),2,'significant'),'descend');
        else
            VceSteps=sort(round(linspace(Vbemax,vceh_val,numIcVbeCurves),2,'significant'),'descend');
        end


        ds.addCharacteristic(simscapeCharacteristic);
        for ii=1:length(IbSteps)
            ds.characteristicData(1).addCurve(simscapeSimulatedNPNCurve({'voltage','current','reference'},{VceSweep,IbSteps(ii)},'current',1,ds.parameters));
            leg{1}{ii}=sprintf('I_{B}=%gA',IbSteps(ii));
        end
        xlab{1}='V_{CE} (V)';
        ylab{1}='I_{C} (A)';


        ds.addCharacteristic(simscapeCharacteristic);
        for ii=1:length(VceSteps)
            ds.characteristicData(2).addCurve(simscapeSimulatedNPNCurve({'voltage','voltage','reference'},{VceSteps(ii),VbeSweep},'current',1,ds.parameters));
            leg{2}{ii}=sprintf('V_{CE}=%gV',VceSteps(ii));
        end
        xlab{2}='V_{BE} (V)';
        ylab{2}='I_{C} (A)';
    case 'ee.semiconductors.bjt_pnp'
        numIcVceCurves=4;
        numIcVbeCurves=1;
        VbemaxMultiple=1.5;
        IbminDivisor=10;
        VcemaxMultiple=2;


        parameterNameValueList=ee.internal.mask.getParameterNameValueList(blockName,false);
        ds=ee.internal.mask.populateDataStructure(parameterNameValueList);


        prm=get_param(blockHandle,'parameterization');

        temperature=ee.internal.mask.getParamWithUnit(blockHandle,'Tmeas');
        temperature=value(temperature,'K');
        phit=8.617332478e-5*temperature;
        switch prm
        case '1'
            hfe=ee.internal.mask.getParamWithUnit(blockHandle,'hfe');
            hoe=ee.internal.mask.getParamWithUnit(blockHandle,'hoe');
            ich=-ee.internal.mask.getParamWithUnit(blockHandle,'Ic_h');
            vceh=-ee.internal.mask.getParamWithUnit(blockHandle,'Vce_h');
            br=ee.internal.mask.getParamWithUnit(blockHandle,'BR');
            ec=ee.internal.mask.getParamWithUnit(blockHandle,'ec');
            vbeactive=-ee.internal.mask.getParamWithUnit(blockHandle,'V1');
            ibactive=-ee.internal.mask.getParamWithUnit(blockHandle,'I1');
            [gain,is]=ee_bipolar_datasheet2params(hfe,hoe,ich,vceh,br,ec*simscape.Value(temperature,'K'),vbeactive,ibactive,[],[]);
            gain=value(gain,'1');
            is=value(is,'A');
            vceh_val=value(vceh,'V');
            ibactive_val=value(ibactive,'A');
        case '2'
            gain=ee.internal.mask.getParamWithUnit(blockHandle,'BF');
            gain=value(gain,'1');
            is=ee.internal.mask.getParamWithUnit(blockHandle,'IS');
            is=value(is,'A');
            vceh_val=inf;
            ibactive_val=500e-6;
        otherwise
            pm_error('physmod:ee:library:NotFound',getString(message('physmod:ee:library:comments:utils:mask:quickPlot:error_ValidBJTParameterization')));
        end
        rc=ee.internal.mask.getParamWithUnit(blockHandle,'RC');
        rc=value(rc,'Ohm');
        re=ee.internal.mask.getParamWithUnit(blockHandle,'RE');
        re=value(re,'Ohm');
        Vj=phit*log(ibactive_val*gain/is);
        Ibmax=min(Vj*(VcemaxMultiple-1)/((gain+1)*re+gain*rc),0.5);
        Vbemax=Vj*VbemaxMultiple;
        Ibmin=Ibmax/IbminDivisor;
        Vcemax=round(VcemaxMultiple*Vbemax,1,'significant');
        VceSweep=[0,-Vcemax];
        VbeSweep=[0,-Vbemax];
        IbSteps=sort(round(linspace(-Ibmin,-Ibmax,numIcVceCurves),2,'significant'),'descend');
        if isinf(vceh_val)
            VceSteps=sort(round(linspace(-Vbemax,-Vcemax,numIcVbeCurves),2,'significant'),'descend');
        else
            VceSteps=sort(round(linspace(-Vbemax,-vceh_val,numIcVbeCurves),2,'significant'),'descend');
        end


        ds.addCharacteristic(simscapeCharacteristic);
        for ii=1:length(IbSteps)
            ds.characteristicData(1).addCurve(simscapeSimulatedPNPCurve({'voltage','current','reference'},{VceSweep,IbSteps(ii)},'current',1,ds.parameters));
            leg{1}{ii}=sprintf('I_{B}=%gA',IbSteps(ii));
        end
        xlab{1}='V_{CE} (V)';
        ylab{1}='I_{C} (A)';


        ds.addCharacteristic(simscapeCharacteristic);
        for ii=1:length(VceSteps)
            ds.characteristicData(2).addCurve(simscapeSimulatedPNPCurve({'voltage','voltage','reference'},{VceSteps(ii),VbeSweep},'current',1,ds.parameters));
            leg{2}{ii}=sprintf('V_{CE}=%gV',VceSteps(ii));
        end
        xlab{2}='V_{BE} (V)';
        ylab{2}='I_{C} (A)';
    case 'ee.semiconductors.n_jfet'
        numIdVdsCurves=4;
        numIdVgsCurves=2;
        VdsmaxMultiple=3;


        parameterNameValueList=ee.internal.mask.getParameterNameValueList(blockName,false);
        ds=ee.internal.mask.populateDataStructure(parameterNameValueList);



        prm=get_param(blockHandle,'parameterization');
        switch prm
        case '1'
            Idss=ee.internal.mask.getParamWithUnit(blockHandle,'Idss');
            Idss=value(Idss,'A');
            Idss_v=ee.internal.mask.getParamWithUnit(blockHandle,'Idss_v');
            Idss_v=value(Idss_v,'V');
            Vgss=Idss_v(1);
            Vdss=Idss_v(2);
            ssig=ee.internal.mask.getParamWithUnit(blockHandle,'ssig');
            ssig=value(ssig,'S');
            gm=ssig(1);
            gds=ssig(2);
            ssig_v=ee.internal.mask.getParamWithUnit(blockHandle,'ssig_v');
            ssig_v=value(ssig_v,'V');
            Vgsm=ssig_v(1);
            Vdsm=ssig_v(2);
            Igss=ee.internal.mask.getParamWithUnit(blockHandle,'Igss');
            Igss=value(Igss,'A');
            Is=abs(Igss)/2;


            if abs(Vgss-Vgsm)<1e-6
                Vgss=Vgss+1e-6;
            end

            Beta=-1/2*(-gm*Vgsm+Vgss*gm-Idss+(-Idss*(-2*gm*Vgsm+2*Vgss*gm-Idss))^(1/2))/((Vgss-Vgsm)*(Vgss-Vgsm));
            Vt0=-(gm-2*Beta*Vgsm)/(2*Beta);
            L=0;


            not_converged=1;
            max_iter=10;
            n_iter=0;
            while not_converged
                L_previous=L;
                Beta_previous=Beta;
                Vt0_previous=Vt0;
                L=gds/(Beta*(Vgsm-Vt0)^2);
                Beta=-1/2*(-Idss*L*Vdsm+Vgss*L*Vdss*gm-L*Vdss*gm*Vgsm-gm*Vgsm-Idss+Vgss*gm+(-Idss*(1+L*Vdsm)*(-Idss*L*Vdsm-2*L*Vdss*gm*Vgsm+2*Vgss*L*Vdss*gm+2*Vgss*gm-2*gm*Vgsm-Idss))^(1/2))/(Vgss-Vgsm)^2/(1+L*Vdss)/(1+L*Vdsm);
                Vt0=(2*Beta*Vgsm-gm+2*Beta*L*Vdsm*Vgsm)/(2*Beta+2*Beta*L*Vdsm);
                if(abs((L-L_previous)/L)<0.01)&&(abs((Beta-Beta_previous)/Beta)<0.01)&&(abs((Vt0-Vt0_previous)/Vt0)<0.01)
                    not_converged=0;
                end
                if n_iter>max_iter
                    not_converged=0;
                    pm_error('physmod:ee:library:InitializationFailedToConverge',getString(message('physmod:ee:library:comments:utils:mask:quickPlot:error_LBetaVt0')))
                else
                    n_iter=n_iter+1;
                end
            end
            VT=Vt0;
        case '2'
            VT=ee.internal.mask.getParamWithUnit(blockHandle,'Vt0');
            VT=value(VT,'V');
            Is=ee.internal.mask.getParamWithUnit(blockHandle,'IS');
            Is=value(Is,'A');
        otherwise
            pm_error('physmod:ee:library:NotFound',getString(message('physmod:ee:library:comments:utils:mask:quickPlot:error_ValidNChannelJFETParameterization')));
        end
        temp=ee.internal.mask.getParamWithUnit(blockHandle,'Tmeas');
        temp=value(temp,'K');
        phit=8.617332478e-5*temp;
        ig_fwd=500e-6;
        Vbi=phit*log(ig_fwd/Is);
        Vgsmax=round(0.75*Vbi,1,'significant');
        Vdsmax=round((Vgsmax-VT)*VdsmaxMultiple,1,'significant');
        Vdsmin=round((Vgsmax-VT)/VdsmaxMultiple,1,'significant');
        VgsSteps=linspace(VT,Vgsmax,numIdVdsCurves+1);
        VgsSteps=sort(round(VgsSteps(2:end),2,'significant'),'descend');
        VdsSteps=sort(round(linspace(Vdsmin,Vdsmax,numIdVgsCurves),2,'significant'),'descend');
        VdsSweep=[0,Vdsmax];
        VgsSweep=[min([0,VT]),Vgsmax];


        ds.addCharacteristic(simscapeCharacteristic);
        for ii=1:length(VgsSteps)
            ds.characteristicData(1).addCurve(simscapeSimulatedNJfetCurve({'voltage','voltage','reference'},{VdsSweep,VgsSteps(ii)},'current',1,ds.parameters));
            leg{1}{ii}=sprintf('V_{GS}=%gV',VgsSteps(ii));
        end
        xlab{1}='V_{DS} (V)';
        ylab{1}='I_{D} (A)';


        ds.addCharacteristic(simscapeCharacteristic);
        for ii=1:length(VdsSteps)
            ds.characteristicData(2).addCurve(simscapeSimulatedNJfetCurve({'voltage','voltage','reference'},{VdsSteps(ii),VgsSweep},'current',1,ds.parameters));
            leg{2}{ii}=sprintf('V_{DS}=%gV',VdsSteps(ii));
        end
        xlab{2}='V_{GS} (V)';
        ylab{2}='I_{D} (A)';
    case 'ee.semiconductors.p_jfet'
        numIdVdsCurves=4;
        numIdVgsCurves=2;
        VdsmaxMultiple=3;


        parameterNameValueList=ee.internal.mask.getParameterNameValueList(blockName,false);
        ds=ee.internal.mask.populateDataStructure(parameterNameValueList);



        prm=get_param(blockHandle,'parameterization');
        switch prm
        case '1'
            Idss=-ee.internal.mask.getParamWithUnit(blockHandle,'Idss');
            Idss=value(Idss,'A');
            Idss_v=-ee.internal.mask.getParamWithUnit(blockHandle,'Idss_v');
            Idss_v=value(Idss_v,'V');
            Vgss=Idss_v(1);
            Vdss=Idss_v(2);
            ssig=ee.internal.mask.getParamWithUnit(blockHandle,'ssig');
            ssig=value(ssig,'S');
            gm=ssig(1);
            gds=ssig(2);
            ssig_v=-ee.internal.mask.getParamWithUnit(blockHandle,'ssig_v');
            ssig_v=value(ssig_v,'V');
            Vgsm=ssig_v(1);
            Vdsm=ssig_v(2);
            Igss=ee.internal.mask.getParamWithUnit(blockHandle,'Igss');
            Igss=value(Igss,'A');
            Is=abs(Igss)/2;


            if abs(Vgss-Vgsm)<1e-6
                Vgss=Vgss+1e-6;
            end

            Beta=-1/2*(-gm*Vgsm+Vgss*gm-Idss+(-Idss*(-2*gm*Vgsm+2*Vgss*gm-Idss))^(1/2))/((Vgss-Vgsm)*(Vgss-Vgsm));
            Vt0=-(gm-2*Beta*Vgsm)/(2*Beta);
            L=0;


            not_converged=1;
            max_iter=10;
            n_iter=0;
            while not_converged
                L_previous=L;
                Beta_previous=Beta;
                Vt0_previous=Vt0;
                L=gds/(Beta*(Vgsm-Vt0)^2);
                Beta=-1/2*(-Idss*L*Vdsm+Vgss*L*Vdss*gm-L*Vdss*gm*Vgsm-gm*Vgsm-Idss+Vgss*gm+(-Idss*(1+L*Vdsm)*(-Idss*L*Vdsm-2*L*Vdss*gm*Vgsm+2*Vgss*L*Vdss*gm+2*Vgss*gm-2*gm*Vgsm-Idss))^(1/2))/(Vgss-Vgsm)^2/(1+L*Vdss)/(1+L*Vdsm);
                Vt0=(2*Beta*Vgsm-gm+2*Beta*L*Vdsm*Vgsm)/(2*Beta+2*Beta*L*Vdsm);
                if(abs((L-L_previous)/L)<0.01)&&(abs((Beta-Beta_previous)/Beta)<0.01)&&(abs((Vt0-Vt0_previous)/Vt0)<0.01)
                    not_converged=0;
                end
                if n_iter>max_iter
                    not_converged=0;
                    pm_error('physmod:ee:library:InitializationFailedToConverge',getString(message('physmod:ee:library:comments:utils:mask:quickPlot:error_LBetaVt0')))
                else
                    n_iter=n_iter+1;
                end
            end
            VT=Vt0;
        case '2'
            VT=-ee.internal.mask.getParamWithUnit(blockHandle,'Vt0');
            VT=value(VT,'V');
            Is=ee.internal.mask.getParamWithUnit(blockHandle,'IS');
            Is=value(Is,'A');
        otherwise
            pm_error('physmod:ee:library:NotFound',getString(message('physmod:ee:library:comments:utils:mask:quickPlot:error_ValidPChannelJFETParameterization')));
        end
        temp=ee.internal.mask.getParamWithUnit(blockHandle,'Tmeas');
        temp=value(temp,'K');
        phit=8.617332478e-5*temp;
        ig_fwd=500e-6;
        Vbi=phit*log(ig_fwd/Is);
        Vgsmax=round(0.75*Vbi,1,'significant');
        Vdsmax=round((Vgsmax-VT)*VdsmaxMultiple,1,'significant');
        Vdsmin=round((Vgsmax-VT)/VdsmaxMultiple,1,'significant');
        VgsSteps=linspace(-VT,-Vgsmax,numIdVdsCurves+1);
        VgsSteps=sort(round(VgsSteps(2:end),2,'significant'),'descend');
        VdsSteps=sort(round(linspace(-Vdsmin,-Vdsmax,numIdVgsCurves),2,'significant'),'descend');
        VdsSweep=[0,-Vdsmax];
        VgsSweep=-[min([0,VT]),Vgsmax];


        ds.addCharacteristic(simscapeCharacteristic);
        for ii=1:length(VgsSteps)
            ds.characteristicData(1).addCurve(simscapeSimulatedPJfetCurve({'voltage','voltage','reference'},{VdsSweep,VgsSteps(ii)},'current',1,ds.parameters));
            leg{1}{ii}=sprintf('V_{GS}=%gV',VgsSteps(ii));
        end
        xlab{1}='V_{DS} (V)';
        ylab{1}='I_{D} (A)';


        ds.addCharacteristic(simscapeCharacteristic);
        for ii=1:length(VdsSteps)
            ds.characteristicData(2).addCurve(simscapeSimulatedPJfetCurve({'voltage','voltage','reference'},{VdsSteps(ii),VgsSweep},'current',1,ds.parameters));
            leg{2}{ii}=sprintf('V_{DS}=%gV',VdsSteps(ii));
        end
        xlab{2}='V_{GS} (V)';
        ylab{2}='I_{D} (A)';
    case{'ee.semiconductors.n_igbt'}
        numIcVceCurves=4;
        numIcVgeCurves=2;
        VcemaxMultiple=3;


        parameterNameValueList=ee.internal.mask.getParameterNameValueList(blockName,false);
        ds=ee.internal.mask.populateDataStructure(parameterNameValueList);


        prm=get_param(blockHandle,'model_type');
        switch prm
        case 'ee.enum.igbt.parameterization.equation'
            Vth=ee.internal.mask.getParamWithUnit(blockHandle,'Vth');
            Vth=value(Vth,'V');
            Vgesat=ee.internal.mask.getParamWithUnit(blockHandle,'Vge_sat');
            Vgesat=value(Vgesat,'V');
            Vgemax=round(Vgesat,1,'significant');
            Vcemax=round((Vgemax-Vth)*VcemaxMultiple,1,'significant');
            Vgemin=Vth;
            Vcemin=Vth/2;
        case 'ee.enum.igbt.parameterization.lookuptable2D'
            Vgevec=ee.internal.mask.getParamWithUnit(blockHandle,'Vge_vec');
            Vgevec=value(Vgevec,'V');
            Vcevec=ee.internal.mask.getParamWithUnit(blockHandle,'Vce_vec');
            Vcevec=value(Vcevec,'V');
            Icmat=ee.internal.mask.getParamWithUnit(blockHandle,'Ic_mat');
            Icmat=value(Icmat,'A');
            gm=gradient(Icmat(:,end),Vgevec);
            gdex=find(gm==max(gm),1);
            if gm(gdex)==0
                Vth=Vgevec(gdex);
            else
                Vth=Vgevec(gdex)-Icmat(gdex)/gm(gdex);
            end
            Vgemax=round(max(Vgevec),1,'significant');
            Vcemax=round(max(Vcevec),1,'significant');
            Vgemin=round(Vth,1,'significant');
            Vcemin=Vth/2;
        case 'ee.enum.igbt.parameterization.lookuptable3D'
            Vgevec=ee.internal.mask.getParamWithUnit(blockHandle,'Vge_vec');
            Vgevec=value(Vgevec,'V');
            Vcevec=ee.internal.mask.getParamWithUnit(blockHandle,'Vce_vec');
            Vcevec=value(Vcevec,'V');
            Tvec=ee.internal.mask.getParamWithUnit(blockHandle,'T_vec');
            Tvec=value(Tvec,'K');
            T=ee.internal.mask.getParamWithUnit(blockHandle,'Tdevice_3D');
            T=value(T,'K');
            Icmat=ee.internal.mask.getParamWithUnit(blockHandle,'Ic_mat_3D');
            Icmat=value(Icmat,'A');
            Icvec=interp2(Tvec,Vgevec,squeeze(Icmat(:,end,:)),T,Vgevec);
            gm=gradient(Icvec,Vgevec);
            gdex=find(gm==max(gm),1);
            if gm(gdex)==0
                Vth=Vgevec(gdex);
            else
                Vth=Vgevec(gdex)-Icmat(gdex)/gm(gdex);
            end
            Vgemax=round(max(Vgevec),1,'significant');
            Vcemax=round(max(Vcevec),1,'significant');
            Vgemin=round(Vth,1,'significant');
            Vcemin=Vth/2;
        otherwise
            pm_error('physmod:ee:library:NotFound',getString(message('physmod:ee:library:comments:utils:mask:quickPlot:error_ValidNChannelIGBTParameterization')));
        end
        if abs(Vcemin-Vcemax)<abs(0.1*Vcemax)
            Vcemin=Vcemax/2;
        end
        VgeSteps=linspace(Vgemin,Vgemax,numIcVceCurves+1);
        VgeSteps=sort(round(VgeSteps(2:end),2,'significant'),'descend');
        VceSteps=linspace(Vcemin,Vcemax,numIcVgeCurves);
        VceSteps=sort(round(VceSteps,2,'significant'),'descend');
        VceSweep=[min([0,Vcemin]),Vcemax];
        VgeSweep=[min([0,Vgemin]),Vgemax];


        ds.addCharacteristic(simscapeCharacteristic);
        for ii=1:length(VgeSteps)
            ds.characteristicData(1).addCurve(simscapeSimulatedIgbtCurve({'voltage','voltage','reference'},{VceSweep,VgeSteps(ii)},'current',1,ds.parameters));
            leg{1}{ii}=sprintf('V_{GE}=%gV',VgeSteps(ii));
        end
        xlab{1}='V_{CE} (V)';
        ylab{1}='I_{C} (A)';


        ds.addCharacteristic(simscapeCharacteristic);
        for ii=1:length(VceSteps)
            ds.characteristicData(2).addCurve(simscapeSimulatedIgbtCurve({'voltage','voltage','reference'},{VceSteps(ii),VgeSweep},'current',1,ds.parameters));
            leg{2}{ii}=sprintf('V_{CE}=%gV',VceSteps(ii));
        end
        xlab{2}='V_{GE} (V)';
        ylab{2}='I_{D} (A)';
    case 'ee.semiconductors.sp_n_hvmos'
        numIdVdsCurves=4;
        numIdVgsCurves=2;
        VgsmaxMultiple=4;
        VdsmaxMultiple=3;


        parameterNameValueList=ee.internal.mask.getParameterNameValueList(blockName,false);
        ds=ee.internal.mask.populateDataStructure(parameterNameValueList);

        vfb=ee.internal.mask.getParamWithUnit(blockHandle,'Vfbref');
        vfb=value(vfb(1),'V');
        phib2=ee.internal.mask.getParamWithUnit(blockHandle,'phib2ref');
        phib2=value(phib2(1),'V');
        gamma=ee.internal.mask.getParamWithUnit(blockHandle,'gamma');
        gamma=value(gamma(1),'V^0.5');
        Tsim=ee.internal.mask.getParamWithUnit(blockHandle,'Tmeas');
        Tsim=value(Tsim,'K');
        phit=8.617332478e-5*Tsim;

        VT=vfb+phib2+gamma*sqrt(phib2+2*phit);

        Vgsmax=round(VT+abs(VT)*(VgsmaxMultiple-1),1,'significant');
        Vdsmax=round((Vgsmax-VT)*VdsmaxMultiple,1,'significant');
        Vdsmin=round((Vgsmax-VT)/VdsmaxMultiple,1,'significant');
        VgsSteps=linspace(VT,Vgsmax,numIdVdsCurves+1);
        VgsSteps=sort(round(VgsSteps(2:end),2,'significant'),'descend');
        VdsSteps=sort(round(linspace(Vdsmin,Vdsmax,numIdVgsCurves),2,'significant'),'descend');
        VdsSweep=[0,Vdsmax];
        VgsSweep=[0,Vgsmax];


        ds.addCharacteristic(simscapeCharacteristic);
        for ii=1:length(VgsSteps)
            ds.characteristicData(1).addCurve(simscapeSimulatedNLdmosCurve({'voltage','voltage','reference'},{VdsSweep,VgsSteps(ii)},'current',1,ds.parameters));
            leg{1}{ii}=sprintf('V_{GS}=%gV',VgsSteps(ii));
        end
        xlab{1}='V_{DS} (V)';
        ylab{1}='I_{D} (A)';


        ds.addCharacteristic(simscapeCharacteristic);
        for ii=1:length(VdsSteps)
            ds.characteristicData(2).addCurve(simscapeSimulatedNLdmosCurve({'voltage','voltage','reference'},{VdsSteps(ii),VgsSweep},'current',1,ds.parameters));
            leg{2}{ii}=sprintf('V_{DS}=%gV',VdsSteps(ii));
        end
        xlab{2}='V_{GS} (V)';
        ylab{2}='I_{D} (A)';
    case 'ee.semiconductors.sp_p_hvmos'
        numIdVdsCurves=4;
        numIdVgsCurves=2;
        VgsmaxMultiple=4;
        VdsmaxMultiple=3;


        parameterNameValueList=ee.internal.mask.getParameterNameValueList(blockName,false);
        ds=ee.internal.mask.populateDataStructure(parameterNameValueList);

        vfb=ee.internal.mask.getParamWithUnit(blockHandle,'Vfbref');
        vfb=value(vfb(1),'V');
        phib2=ee.internal.mask.getParamWithUnit(blockHandle,'phib2ref');
        phib2=value(phib2(1),'V');
        gamma=ee.internal.mask.getParamWithUnit(blockHandle,'gamma');
        gamma=value(gamma(1),'V^0.5');
        Tsim=ee.internal.mask.getParamWithUnit(blockHandle,'Tmeas');
        Tsim=value(Tsim,'K');
        phit=8.617332478e-5*Tsim;

        VT=vfb+phib2+gamma*sqrt(phib2+2*phit);

        Vgsmax=round(VT+abs(VT)*(VgsmaxMultiple-1),1,'significant');
        Vdsmax=round((Vgsmax-VT)*VdsmaxMultiple,1,'significant');
        Vdsmin=round((Vgsmax-VT)/VdsmaxMultiple,1,'significant');
        VgsSteps=linspace(-VT,-Vgsmax,numIdVdsCurves+1);
        VgsSteps=sort(round(VgsSteps(2:end),2,'significant'),'descend');
        VdsSteps=sort(round(linspace(-Vdsmin,-Vdsmax,numIdVgsCurves),2,'significant'),'descend');
        VdsSweep=[0,-Vdsmax];
        VgsSweep=[0,-Vgsmax];


        ds.addCharacteristic(simscapeCharacteristic);
        for ii=1:length(VgsSteps)
            ds.characteristicData(1).addCurve(simscapeSimulatedPLdmosCurve({'voltage','voltage','reference'},{VdsSweep,VgsSteps(ii)},'current',1,ds.parameters));
            leg{1}{ii}=sprintf('V_{GS}=%gV',VgsSteps(ii));
        end
        xlab{1}='V_{DS} (V)';
        ylab{1}='I_{D} (A)';


        ds.addCharacteristic(simscapeCharacteristic);
        for ii=1:length(VdsSteps)
            ds.characteristicData(2).addCurve(simscapeSimulatedPLdmosCurve({'voltage','voltage','reference'},{VdsSteps(ii),VgsSweep},'current',1,ds.parameters));
            leg{2}{ii}=sprintf('V_{DS}=%gV',VdsSteps(ii));
        end
        xlab{2}='V_{GS} (V)';
        ylab{2}='I_{D} (A)';
    case{'ee.semiconductors.diode'}

        parameterNameValueList=ee.internal.mask.getParameterNameValueList(blockName,false);
        ds=ee.internal.mask.populateDataStructure(parameterNameValueList);

        VfmaxMultiple=30;


        modeltype=get_param(blockHandle,'ModelType');

        vf=ee.internal.mask.getParamWithUnit(blockHandle,'Vf');
        vf=value(vf,'V');

        prmExp=get_param(blockHandle,'prmExp');
        i12=ee.internal.mask.getParamWithUnit(blockHandle,'I12');
        i12=value(i12,'A');
        v12=ee.internal.mask.getParamWithUnit(blockHandle,'V12');
        v12=value(v12,'V');
        IS=ee.internal.mask.getParamWithUnit(blockHandle,'IS');
        IS=value(IS,'A');
        ec=ee.internal.mask.getParamWithUnit(blockHandle,'ec');
        ec=value(ec,'1');
        i1=ee.internal.mask.getParamWithUnit(blockHandle,'I1');
        i1=value(i1,'A');
        v1=ee.internal.mask.getParamWithUnit(blockHandle,'V1');
        v1=value(v1,'V');
        rs=ee.internal.mask.getParamWithUnit(blockHandle,'RS');
        rs=value(rs,'Ohm');
        tmeas=ee.internal.mask.getParamWithUnit(blockHandle,'Tmeas');
        tmeas=value(tmeas,'K');
        n_series=ee.internal.mask.getParamWithUnit(blockHandle,'N_series');
        n_series=value(n_series,'1');

        VfVec=ee.internal.mask.getParamWithUnit(blockHandle,'VfVec');
        VfVec=value(VfVec,'V');

        t_param=get_param(blockHandle,'T_param');
        IS_t2=ee.internal.mask.getParamWithUnit(blockHandle,'IS_T2');
        IS_t2=value(IS_t2,'A');
        i1_t2=ee.internal.mask.getParamWithUnit(blockHandle,'I1_T2');
        i1_t2=value(i1_t2,'A');
        v1_t2=ee.internal.mask.getParamWithUnit(blockHandle,'V1_T2');
        v1_t2=value(v1_t2,'V');
        tmeas2=ee.internal.mask.getParamWithUnit(blockHandle,'Tmeas2');
        tmeas2=value(tmeas2,'K');
        EG_param=get_param(blockHandle,'EG_param');
        EG=ee.internal.mask.getParamWithUnit(blockHandle,'EG');
        EG=value(EG,'eV');
        XTI_param=get_param(blockHandle,'XTI_param');
        XTI=ee.internal.mask.getParamWithUnit(blockHandle,'XTI');
        XTI=value(XTI,'1');
        tsim=ee.internal.mask.getParamWithUnit(blockHandle,'Tdevice');
        tsim=value(tsim,'K');
        switch modeltype
        case 'ee.enum.diode.modelType.pwl'
            VfmaxMultiple=5;
            Vfmax=round(vf*n_series+abs(vf*n_series)*(VfmaxMultiple-1),1,'significant');
            VSweep=[0,Vfmax];
        case 'ee.enum.diode.modelType.exponential'
            [N1,IS1]=ee.internal.semiconductors.ee_diode_coefficient(prmExp,i12,v12,IS,ec,i1,v1,rs,tmeas);
            switch t_param
            case 'ee.enum.diode.temperatureParam.off'
                temp=tmeas;
                phit_sim=8.617332478e-5*temp;
                Vfmax=N1*phit_sim*VfmaxMultiple*n_series;
            otherwise
                temp=tsim;
                phit_sim=8.617332478e-5*temp;
                [EG1,~]=ee.internal.semiconductors.ee_diode_energy_gap(N1,IS1,tmeas,XTI_param,XTI,t_param,IS_t2,i1_t2,v1_t2,tmeas2,EG_param,EG);
                Vfmax=(N1*phit_sim*VfmaxMultiple+EG1*(1-temp/tmeas))*n_series;
            end
            Vfmax=round(Vfmax,1,'significant');
            VSweep=[0,Vfmax];
        case 'ee.enum.diode.modelType.tabulated'
            VSweep=[VfVec(1),VfVec(end)];
        otherwise
            pm_error('physmod:ee:library:NotFound',getString(message('physmod:ee:library:comments:utils:mask:quickPlot:error_ValidDiodeParameterization')));
        end


        ds.addCharacteristic(simscapeCharacteristic);
        ds.characteristicData(1).addCurve(simscapeSimulatedDiodeCurve({'voltage','reference'},{VSweep},'current',1,ds.parameters));
        xlab{1}='V_{} (V)';
        ylab{1}='I_{} (A)';

    case 'ee.sensors.led'
        VfmaxMultiple=30;

        parameterNameValueList=ee.internal.mask.getParameterNameValueList(blockName,false);
        ds=ee.internal.mask.populateDataStructure(parameterNameValueList);


        prmExp=get_param(blockHandle,'prmExp');
        i12=ee.internal.mask.getParamWithUnit(blockHandle,'I12');
        i12=value(i12,'A');
        v12=ee.internal.mask.getParamWithUnit(blockHandle,'V12');
        v12=value(v12,'V');
        IS=ee.internal.mask.getParamWithUnit(blockHandle,'IS');
        IS=value(IS,'A');
        ec=ee.internal.mask.getParamWithUnit(blockHandle,'ec');
        ec=value(ec,'1');
        rs=ee.internal.mask.getParamWithUnit(blockHandle,'RS');
        rs=value(rs,'Ohm');
        tmeas=ee.internal.mask.getParamWithUnit(blockHandle,'Tmeas');
        tmeas=value(tmeas,'K');


        t_param=get_param(blockHandle,'T_param');
        IS_t2=ee.internal.mask.getParamWithUnit(blockHandle,'IS_T2');
        IS_t2=value(IS_t2,'A');
        i1_t2=ee.internal.mask.getParamWithUnit(blockHandle,'I1_T2');
        i1_t2=value(i1_t2,'A');
        v1_t2=ee.internal.mask.getParamWithUnit(blockHandle,'V1_T2');
        v1_t2=value(v1_t2,'V');
        tmeas2=ee.internal.mask.getParamWithUnit(blockHandle,'Tmeas2');
        tmeas2=value(tmeas2,'K');
        EG_param=get_param(blockHandle,'EG_param');
        EG=ee.internal.mask.getParamWithUnit(blockHandle,'EG');
        EG=value(EG,'eV');
        XTI_param=get_param(blockHandle,'XTI_param');
        XTI=ee.internal.mask.getParamWithUnit(blockHandle,'XTI');
        XTI=value(XTI,'1');
        tsim=ee.internal.mask.getParamWithUnit(blockHandle,'Tdevice');
        tsim=value(tsim,'K');

        [N1,IS1]=ee.internal.semiconductors.ee_diode_coefficient(prmExp,i12,v12,IS,ec,0,0,rs,tmeas);
        switch t_param
        case '1'
            temp=tmeas;
            phit_sim=8.617332478e-5*temp;
            Vfmax=N1*phit_sim*VfmaxMultiple;
        case '2'
            temp=tsim;
            phit_sim=8.617332478e-5*temp;
            [EG1,~]=ee.internal.semiconductors.ee_diode_energy_gap(N1,IS1,tmeas,XTI_param,XTI,t_param,IS_t2,i1_t2,v1_t2,tmeas2,EG_param,EG);
            Vfmax=(N1*phit_sim*VfmaxMultiple+EG1*(1-temp/tmeas));
        otherwise
            pm_error('physmod:ee:library:NotFound',getString(message('physmod:ee:library:comments:utils:mask:quickPlot:error_ValidLedParameterization')));
        end

        Vfmax=round(Vfmax,1,'significant');
        VSweep=[0,Vfmax];
        Ifmax=max(simscapeSimulatedLedCurve({'voltage','reference'},{VSweep},'current',1,ds.parameters).getData.y);
        ISweep=[0,Ifmax];


        ds.addCharacteristic(simscapeCharacteristic);
        ds.characteristicData(1).addCurve(simscapeSimulatedLedCurve({'voltage','reference'},{VSweep},'current',1,ds.parameters));
        xlab{1}='V (V)';
        ylab{1}='I (A)';

        ds.addCharacteristic(simscapeCharacteristic);
        ds.characteristicData(2).addCurve(simscapeSimulatedLedCurve({'current','reference'},{ISweep},{},-1,ds.parameters,1));
        xlab{2}='I (A)';
        ylab{2}=[getString(message('physmod:ee:library:comments:utils:mask:quickPlot:label_OpticalPower')),' (W)'];

    case 'ee.sensors.photodiode'
        VfmaxMultiple=30;
        VbmaxMultiple=8;
        numOpticalCurves=4;


        parameterNameValueList=ee.internal.mask.getParameterNameValueList(blockName,false);
        ds=ee.internal.mask.populateDataStructure(parameterNameValueList);


        prmExp=get_param(blockHandle,'prmExp');
        i2=ee.internal.mask.getParamWithUnit(blockHandle,'I2');
        i2=value(i2,'A');
        v2=ee.internal.mask.getParamWithUnit(blockHandle,'V2');
        v2=value(v2,'V');
        IS=ee.internal.mask.getParamWithUnit(blockHandle,'IS');
        IS=value(IS,'A');
        ec=ee.internal.mask.getParamWithUnit(blockHandle,'ec');
        ec=value(ec,'1');
        rs=ee.internal.mask.getParamWithUnit(blockHandle,'RS');
        rs=value(rs,'Ohm');
        tmeas=ee.internal.mask.getParamWithUnit(blockHandle,'Tmeas');
        tmeas=value(tmeas,'K');


        t_param=get_param(blockHandle,'T_param');
        IS_t2=ee.internal.mask.getParamWithUnit(blockHandle,'IS_T2');
        IS_t2=value(IS_t2,'A');
        i1_t2=ee.internal.mask.getParamWithUnit(blockHandle,'I1_T2');
        i1_t2=value(i1_t2,'A');
        v1_t2=ee.internal.mask.getParamWithUnit(blockHandle,'V1_T2');
        v1_t2=value(v1_t2,'V');
        tmeas2=ee.internal.mask.getParamWithUnit(blockHandle,'Tmeas2');
        tmeas2=value(tmeas2,'K');
        EG_param=get_param(blockHandle,'EG_param');
        EG=ee.internal.mask.getParamWithUnit(blockHandle,'EG');
        EG=value(EG,'eV');
        XTI_param=get_param(blockHandle,'XTI_param');
        XTI=ee.internal.mask.getParamWithUnit(blockHandle,'XTI');
        XTI=value(XTI,'1');
        tsim=ee.internal.mask.getParamWithUnit(blockHandle,'Tdevice');
        tsim=value(tsim,'K');
        prmFlux=ee.internal.mask.getParamWithUnit(blockHandle,'prmFlux');
        prmFlux=value(prmFlux,'1');
        FluxD=ee.internal.mask.getParamWithUnit(blockHandle,'FluxD');
        FluxD=value(FluxD,'W/m^2');
        G=ee.internal.mask.getParamWithUnit(blockHandle,'G');
        G=value(G,'A/(W/m^2)');

        switch prmExp
        case '1'
            prmExp1='3';
        case '2'
            prmExp1='2';
        otherwise
            pm_error('physmod:ee:library:NotFound',getString(message('physmod:ee:library:comments:utils:mask:quickPlot:error_ValidPhotodiodeParameterization')));
        end
        [N1,IS1]=ee.internal.semiconductors.ee_diode_coefficient(prmExp1,0,0,IS,ec,i2,v2,rs,tmeas);
        switch t_param
        case '1'
            temp=tmeas;
            phit_sim=8.617332478e-5*temp;
            Is=IS1;
            Vfmax=N1*phit_sim*VfmaxMultiple;
            Vbmax=N1*phit_sim*VbmaxMultiple;
        otherwise
            temp=tsim;
            phit_sim=8.617332478e-5*temp;
            [EG1,XTI1]=ee.internal.semiconductors.ee_diode_energy_gap(N1,IS1,tmeas,XTI_param,XTI,t_param,IS_t2,i1_t2,v1_t2,tmeas2,EG_param,EG);
            Is=IS1*(tsim/tmeas)^(XTI1/N1)*exp(-EG1/(N1*8.617332478e-5*tsim)*(1-tsim/tmeas));
            Vfmax=(N1*phit_sim*VfmaxMultiple+EG1*(1-temp/tmeas));
            Vbmax=(N1*phit_sim*VbmaxMultiple+EG1*(1-temp/tmeas));
        end

        Vfmax=round(Vfmax,2,'significant');
        Vbmax=round(Vbmax,2,'significant');
        VSweep=[0,Vfmax];


        ds.addCharacteristic(simscapeCharacteristic);
        ds.characteristicData(1).addCurve(simscapeSimulatedPhotodiodeCurve({'voltage','reference'},{VSweep},'current',1,ds.parameters,'constant',0));
        leg{1}=sprintf([getString(message('physmod:ee:library:comments:utils:mask:quickPlot:label_FluxDensity')),'=',num2str(0),'W/m^{2}']);
        xlab{1}='V (V)';
        ylab{1}='I (A)';

        if prmFlux==1
            MaxFluxDensity=FluxD;
        else
            MaxFluxDensity=Is/G*5e3;




        end

        FluxDensity=sort(round(linspace(0,MaxFluxDensity,numOpticalCurves),2,'significant'),'descend');
        VSbweep=[-Vfmax,Vbmax];

        ds.addCharacteristic(simscapeCharacteristic);
        for ii=1:length(FluxDensity)
            ds.characteristicData(2).addCurve(simscapeSimulatedPhotodiodeCurve({'voltage','reference'},{VSbweep},'current',1,ds.parameters,'constant',FluxDensity(ii)));
            leg{2}{ii}=sprintf([getString(message('physmod:ee:library:comments:utils:mask:quickPlot:label_FluxDensity')),'=',num2str(FluxDensity(ii)),'W/m^{2}']);
        end
        xlab{2}='V_{} (V)';
        ylab{2}='I_{} (A)';

    case 'ee.passive.resistor_thermal'

        ds=simscapeBlockDataset('parameterHelper','');


        R=ee.internal.mask.getParamWithUnit(blockHandle,'R');
        R=value(R,'Ohm');
        alpha=ee.internal.mask.getParamWithUnit(blockHandle,'alpha');
        alpha=value(alpha,'1/K');
        Tmeas=ee.internal.mask.getParamWithUnit(blockHandle,'Tmeas');
        Tmeas=value(Tmeas,'degC');
        R_tol=ee.internal.mask.getParamWithUnit(blockHandle,'R_tol');
        R_tol=value(R_tol,'1');
        enable_R_tol=ee.internal.mask.getParamWithUnit(blockHandle,'enable_R_tol');
        enable_R_tol=value(enable_R_tol,'1');


        ds.addCharacteristic(simscapeCharacteristic);
        xlab{1}=getString(message('physmod:ee:library:comments:utils:mask:quickPlot:label_Temperature'));
        ylab{1}=getString(message('physmod:ee:library:comments:utils:mask:quickPlot:label_Resistance'));


        temp=linspace(1,150,150);
        RT=R*(1+alpha*(temp-Tmeas));
        RT_maxTol=(1+R_tol/100)*R*(1+alpha*(temp-Tmeas));
        RT_minTol=(1-R_tol/100)*R*(1+alpha*(temp-Tmeas));
        ds.characteristicData.addCurve(simscapeTargetCurve({'current','reference'},{temp},'voltage',1,RT));
        if enable_R_tol==1
            ds.characteristicData.addCurve(simscapeTargetCurve({'current','reference'},{temp},'voltage',1,RT_maxTol));
            ds.characteristicData.addCurve(simscapeTargetCurve({'current','reference'},{temp},'voltage',1,RT_minTol));
        elseif enable_R_tol==2
            ds.characteristicData.addCurve(simscapeTargetCurve({'current','reference'},{temp},'voltage',1,RT_maxTol));
        elseif enable_R_tol==3
            ds.characteristicData.addCurve(simscapeTargetCurve({'current','reference'},{temp},'voltage',1,RT_minTol));
        end


        if enable_R_tol==0

            leg{1}={'Resistance'};
        else

            leg{1}={'Resistance','Tolerance limit'};
        end

        curveFormat={{'[0 0.4470 0.7410]','-'},...
        {'[0 0.4470 0.7410]',':'},...
        {'[0 0.4470 0.7410]',':'}};
    otherwise
        pm_error('physmod:ee:library:NotFound',getString(message('physmod:ee:library:comments:utils:mask:quickPlot:error_HarnessForThisComponentType')));
    end


    hFigure=figure('Name',blockName);
    numPlots=length(ds.characteristicData);
    hLine=cell(1,numPlots);
    hAxes=zeros(1,numPlots);
    for plotIdx=1:numPlots
        set(0,'CurrentFigure',hFigure);
        if column_subplot
            hAxes(plotIdx)=subplot(numPlots,1,plotIdx);
        else
            hAxes(plotIdx)=subplot(1,numPlots,plotIdx);
        end
        hLine{plotIdx}=zeros(1,length(ds.characteristicData(plotIdx).curves));
        for curveIdx=1:length(ds.characteristicData(plotIdx).curves)
            try
                if curveIdx==length(ds.characteristicData(plotIdx).curves)
                    result=ds.characteristicData(plotIdx).curves{curveIdx}.getData;
                else
                    result=ds.characteristicData(plotIdx).curves{curveIdx}.getData('holdFastRestart');
                end
            catch ME
                close(hFigure);
                throwAsCaller(ME.cause{1});
            end
            if~exist('curveFormat','var')
                hLine{plotIdx}(curveIdx)=plot(hAxes(plotIdx),result.x,result.y,'-');
                hold(hAxes(plotIdx),'on');
            else
                hLine{plotIdx}(curveIdx)=plot(hAxes(plotIdx),result.x,result.y,...
                'Color',curveFormat{curveIdx}{1},'LineStyle',curveFormat{curveIdx}{2});
                hold(hAxes(plotIdx),'on');
            end
        end
        if reverse_xaxis(min(plotIdx,length(reverse_xaxis)))
            set(hAxes(plotIdx),'XDir','reverse');
        end
    end
    if column_subplot
        linkaxes(hAxes,'x');
    end


    hLegend=zeros(1,numPlots);
    for plotIdx=1:numPlots
        xlabel(hAxes(plotIdx),xlab{plotIdx});
        ylabel(hAxes(plotIdx),ylab{plotIdx});
        if exist('leg','var')
            hLegend(plotIdx)=legend(hAxes(plotIdx),leg{plotIdx},'Location','Best');
        else
            hLegend(plotIdx)=nan;
        end
        axis tight;
    end

    if nargout>=1
        varargout{1}=hFigure;
        if nargout>=2
            varargout{2}=hAxes;
        end
        if nargout>=3
            varargout{3}=hLine;
        end
        if nargout>=4
            varargout{4}=hLegend;
        end
    end
end





