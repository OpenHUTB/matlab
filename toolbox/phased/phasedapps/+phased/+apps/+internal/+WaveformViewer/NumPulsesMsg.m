function NumPulsesMsg(self,View,index)



    Elem=self.StoreData.Elements;
    k=numel(index);
    j=1;
    for i=1:k
        if~isa(Elem{index(i)},'phased.apps.internal.WaveformViewer.FMCWWaveform')
            NumPulses=Elem{index(i)}.NumPulses;
            if NumPulses~=1
                j=j+1;
            end
        end

    end
    if j~=1
        if View.Toolstrip.IsAppContainer
            uialert(View.Toolstrip.AppContainer,getString(message('phased:apps:waveformapp:SetNumPulses')),getString(message('MATLAB:uistring:popupdialogs:WarnDialogTitle')),'Modal',true,'Icon','warning');
        else
            p=warndlg(getString(message('phased:apps:waveformapp:SetNumPulses')),getString(message('MATLAB:uistring:popupdialogs:WarnDialogTitle')),'modal');
            uiwait(p);
        end
    end

end