function addPowerMeterBlock(hSpectrumAnalyzer)




    if~Simulink.scopes.SpectrumAnalyzerUtils.isPhysicalModelingMode()


        mdl=bdroot(hSpectrumAnalyzer);
        dirtyFlag=get_param(mdl,'Dirty');
        c=onCleanup(@()set_param(mdl,'Dirty',dirtyFlag));
        hParent=get_param(hSpectrumAnalyzer,'Parent');
        saName=get_param(hSpectrumAnalyzer,'Name');
        saPosition=get_param(hSpectrumAnalyzer,'Position');
        saOrientation=get_param(hSpectrumAnalyzer,'Orientation');
        saCommented=get_param(hSpectrumAnalyzer,'Commented');
        pmPos=[saPosition(1),saPosition(2)+60,saPosition(3)+60,saPosition(4)+60];

        hPowerMeter=add_block('dspstat3/Power Meter',[hParent,'/',saName,'_CCDF'],...
        'Orientation',saOrientation,...
        'Position',pmPos,...
        'Commented',saCommented);

        set_param(hPowerMeter,'Measurement','Peak-to-average power ratio');

        set_param(hPowerMeter,'ComputeCCDF','On');

        set_param(hPowerMeter,'CCDFOutput','Relative power (dB above average power)');

        hSpectrumAnalyzerPorts=get_param(hSpectrumAnalyzer,'PortHandles');
        numInputs=length(hSpectrumAnalyzerPorts.Inport);
        hPowerMeterPorts=get_param(hPowerMeter,'PortHandles');
        hLines=-ones(numInputs,1);
        hLineSrcPort=-ones(numInputs,1);
        for indx=1:length(hSpectrumAnalyzerPorts.Inport)
            hLines(indx)=get_param(hSpectrumAnalyzerPorts.Inport(indx),'Line');
            if hLines(indx)~=-1
                hLineSrcPort(indx)=get_param(hLines(indx),'SrcPortHandle');
            end
        end

        convertPosition=[saPosition(1)-60,saPosition(2)+65,saPosition(3)-60,saPosition(4)+65];
        hConvertBlk=add_block('built-in/DataTypeConversion',...
        [hParent,'/',saName,'_Convert'],...
        'Orientation',saOrientation,...
        'Position',convertPosition,...
        'Commented',saCommented);
        set_param(hConvertBlk,'OutDataTypeStr','double');
        hConvertPorts=get_param(hConvertBlk,'PortHandles');

        if numInputs>1
            concatPosition=[saPosition(1)-120,saPosition(2)+65,saPosition(3)-120,saPosition(4)+65];
            hConcatBlk=add_block('dspmtrx3/Matrix Concatenate',...
            [hParent,'/',saName,'_MatrixConcatenator'],...
            'MakeNameUnique','on',...
            'ShowName','off',...
            'NumInputs',num2str(numInputs),...
            'Mode','Multidimensional array',...
            'ConcatenateDimension','2',...
            'Orientation',saOrientation,...
            'Position',concatPosition,...
            'Commented',saCommented);
            hConcatPorts=get_param(hConcatBlk,'PortHandles');
            for indx=1:numInputs
                if hLineSrcPort(indx)~=-1
                    lineName=get_param(hLines(indx),'Name');
                    newLine=add_line(hParent,hLineSrcPort(indx),...
                    hConcatPorts.Inport(indx),'autorouting','on');
                    set_param(newLine,'Name',lineName);
                end
            end

            add_line(hParent,hConcatPorts.Outport(1),hConvertPorts.Inport(1));
        else

            if hLineSrcPort(1)~=-1
                lineName=get_param(hLines(1),'Name');
                newLine=add_line(hParent,hLineSrcPort(1),...
                hConvertPorts.Inport(1),'autorouting','on');
                set_param(newLine,'Name',lineName);
            end
        end

        add_line(hParent,hConvertPorts.Outport(1),hPowerMeterPorts.Inport(1));

        hPowerMeterConnectivity=get_param(hPowerMeter,'PortConnectivity');
        numOutputs=numel(hPowerMeterPorts.Outport);
        outputNamesPrefix={'_PAPR','_RelPwr'};
        for indx=1:numOutputs
            hPowerMeterOutputPortPosition=hPowerMeterConnectivity(indx+1).Position;
            displayPosition=[hPowerMeterOutputPortPosition(1)+30...
            ,hPowerMeterOutputPortPosition(2)-10...
            ,hPowerMeterOutputPortPosition(1)+70...
            ,hPowerMeterOutputPortPosition(2)+10];

            hDisplayBlk=add_block('built-in/Display',[hParent,'/',saName,outputNamesPrefix{indx}],...
            'Position',displayPosition,...
            'Commented',saCommented);

            hDisplayPorts=get_param(hDisplayBlk,'PortHandles');
            add_line(hParent,hPowerMeterPorts.Outport(indx),hDisplayPorts.Inport);
        end
    end
end
