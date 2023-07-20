function varargout=validateSource(this,hSource)




    this.IsRemoveScreenMsg=true;
    if nargin<2
        hSource=this.Application.DataSource;
    end
    b=true;
    exception=MException.empty;
    if strcmp(hSource.Type,'Simulink')

        isConnected=false;
        if strcmp(hSource.BlockHandle.IOType,'viewer')
            ioSignals=hSource.BlockHandle.IOSignals;
            for wndx=1:length(ioSignals)
                for xndx=1:length(ioSignals{wndx})
                    if(ioSignals{wndx}(xndx).Handle~=-1)

                        isConnected=true;
                        break;
                    end
                end
            end
            if~isConnected
                b=false;
                exception=MException(message('dspshared:SpectrumAnalyzer:ViewerDisconnected'));
            end
        else
            pc=get_param(hSource.BlockHandle.Handle,'PortConnectivity');
            for wndx=1:length(pc)
                if(pc(wndx).SrcBlock~=-1)

                    isConnected=true;
                    break;
                end
            end
            if~isConnected
                b=false;
                exception=MException(message('dspshared:SpectrumAnalyzer:PortsDisconnected'));
            end
        end


        sampleTimes=getSampleTimes(hSource);
        if b&&(any(sampleTimes==0)||any(isinf(sampleTimes)))
            b=false;
            exception=MException(message('dspshared:SpectrumAnalyzer:InvalidSpectrumSampleTimes'));
        end
    end

    if b&&any(hSource.isInputComplex)&&~this.getPropertyValue('TwoSidedSpectrum')
        b=false;
        exception=MException(message('dspshared:SpectrumAnalyzer:InvalidSpectrumType'));
    end

    if~b
        toggleSpectrumSettingsDialog(this,false);
        this.IsRemoveScreenMsg=false;
        setSpectrumSettingMenus(this,false);
    end

    if nargout
        varargout={b,exception};
    else
        throw(exception);
    end
end
