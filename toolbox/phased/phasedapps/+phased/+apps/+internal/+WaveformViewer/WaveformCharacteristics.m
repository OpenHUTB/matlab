classdef WaveformCharacteristics<handle



    properties
Parent
characteristicsTable
Layout
    end

    methods
        function self=WaveformCharacteristics(parent)
            if nargin<1
                parent=figure;
            end
            self.Parent=parent;
            createUIControls(self)
            layoutUIControls(self)
        end
    end

    methods(Access=private)
        function createUIControls(self)
            if~self.Parent.View.Toolstrip.IsAppContainer
                parent=self.Parent.View.Characteristics;
            else
                self.Layout=uigridlayout(self.Parent.View.Characteristics,'Scrollable','on','ColumnWidth',{'1x'});
                self.Layout.RowHeight={190};
                parent=self.Layout;
            end
            self.characteristicsTable=uitable('Parent',parent,...
            'ColumnEditable',false,...
            'RowName','',...
            'Tag','CharTableTag',...
            'ColumnWidth',{100,120,120,200,200,120,150},...
            'ColumnName',{getString(message('phased:apps:waveformapp:WaveformName')),getString(message('phased:apps:waveformapp:RangeResolution')),getString(message('phased:apps:waveformapp:DopplerResolution')),getString(message('phased:apps:waveformapp:minunambiguousrange'))...
            ,getString(message('phased:apps:waveformapp:maxunambiguousrange')),getString(message('phased:apps:waveformapp:maxdoppler')),getString(message('phased:apps:waveformapp:timebwproduct')),getString(message('phased:apps:waveformapp:dutycycle'))},...
            'RowStriping','off');

            CalculateWaveformCharacteristics(self,self.Parent.View.AppHandle.Model.StoreData.Elements{1},1);
        end

        function layoutUIControls(self)
            if~self.Parent.View.Toolstrip.IsAppContainer
                self.Layout=...
                matlabshared.application.layout.ScrollableGridBagLayout(...
                self.Parent.View.Characteristics,...
                'VerticalWeights',1,...
                'HorizontalWeights',[1,0]);
                add(self.Layout,self.characteristicsTable,1,1,...
                'Fill','Both',...
                'Anchor','North')
            end
        end
    end

    methods
        function CalculateWaveformCharacteristics(self,waveformData,waveformIdx)
            WaveformType=phased.apps.internal.WaveformViewer.getWaveformString(class(waveformData));
            waveformObj=getWaveformObject(waveformData);
            switch WaveformType
            case 'PhaseCodedWaveform'
                Bandwidth=bandwidth(waveformObj);
                PRF=waveformObj.PRF;
                Numpulses=waveformObj.NumPulses;
                Pulsewidth=waveformObj.ChipWidth*waveformObj.NumChips;
                Dutycycle=dutycycle(Pulsewidth,PRF);
            case 'FMCWWaveform'
                SweepTime=waveformObj.SweepTime;
                PRF=1/(waveformObj.SweepTime);
                Numpulses=waveformObj.NumSweeps;
                Pulsewidth=0;
                Bandwidth=waveformObj.SweepBandwidth;
            otherwise
                Bandwidth=bandwidth(waveformObj);
                PRF=waveformObj.PRF;
                Numpulses=waveformObj.NumPulses;
                Pulsewidth=waveformObj.PulseWidth;
                Dutycycle=dutycycle(Pulsewidth,PRF);
            end


            self.characteristicsTable.Data{waveformIdx,1}=waveformData.Name;


            Propagationspeed=waveformData.PropagationSpeed;
            value=num2str((Propagationspeed/(2*Bandwidth))/1000);
            value=strcat(value,{' '},'km');
            self.characteristicsTable.Data{waveformIdx,2}=value{1};

            value=num2str((PRF/Numpulses)/1000);
            value=strcat(value,{' '},'kHz');
            self.characteristicsTable.Data{waveformIdx,3}=value{1};

            value=num2str((Propagationspeed*Pulsewidth/2)/1000);
            value=strcat(value,{' '},'km');
            self.characteristicsTable.Data{waveformIdx,4}=value{1};

            value=num2str((Propagationspeed/(2*PRF))/1000);
            value=strcat(value,{' '},'km');
            self.characteristicsTable.Data{waveformIdx,5}=value{1};

            value=num2str((PRF/2)/1000);
            value=strcat(value,{' '},'kHz');
            self.characteristicsTable.Data{waveformIdx,6}=value{1};

            if~isa(waveformData,'phased.apps.internal.WaveformViewer.FMCWWaveform')

                value=num2str(Pulsewidth*Bandwidth);
                self.characteristicsTable.Data{waveformIdx,7}=value;


                value=num2str(Dutycycle*100);
                value=strcat(value,{' '},'%');
                self.characteristicsTable.Data{waveformIdx,8}=value{1};
            else

                value=num2str(SweepTime*Bandwidth);
                self.characteristicsTable.Data{waveformIdx,7}=value;

                self.characteristicsTable.Data{waveformIdx,8}='N/A';
            end
        end
    end
end