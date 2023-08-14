classdef pulseWaveformAnalyzer<handle



    properties
Model
View
Controller
    end
    methods
        function self=pulseWaveformAnalyzer(varargin)

            parserObject=inputParser;

            defaultImportData=[];
            defaultImportDataName=[];
            defaultAppContainer=false;
            addOptional(parserObject,'importData',defaultImportData,...
            @(x)phased.apps.internal.WaveformViewer.pulseWaveformAnalyzer.validateCheck(x));
            addParameter(parserObject,'AppContainer',defaultAppContainer,@(x)islogical(x));
            addOptional(parserObject,'importDataName',defaultImportDataName,@(x)ischar(x));
            parse(parserObject,varargin{:});
            UseAppContainer=parserObject.Results.AppContainer;
            importData=parserObject.Results.importData;
            importDataName=parserObject.Results.importDataName;

            self.Model=phased.apps.internal.WaveformViewer.Model();
            self.View=phased.apps.internal.WaveformViewer.View(self,UseAppContainer);
            self.Controller=phased.apps.internal.WaveformViewer.Controller(self.Model,self.View);

            self.View.addplotAction('real and imaginary');
            self.View.addplotAction('spectrum');

            if~UseAppContainer
                self.View.Canvas.WaveformList.setRowSelection(1);
                addlistener(self.View.Toolstrip.ToolGroup,'GroupAction',...
                @(h,e)closeCallback(self,e));
                self.View.Toolstrip.ToolGroup.approveClose();
            else
                self.View.Toolstrip.AppContainer.CanCloseFcn=@(src,event)closeCallbackAC(self);
            end

            if~isempty(importData)
                if isstruct(importData)
                    self.Model.openSession(importData);
                elseif ischar(importData)
                    Session=load(importData);
                    importData=Session.LibrarySession;
                    self.Model.openSession(importData);
                else
                    self.Model.importObject(self.View,{importData},{importDataName});
                end
            end
        end

        function closeCallback(self,event)
            et=event.EventData.EventType;
            if strcmp(et,'CLOSING')
                title=self.View.Toolstrip.ToolGroup.Title;
                if strcmp(title(end),'*')

                    dlg=questdlg(getString(message('phased:apps:waveformapp:SaveSession')),...
                    getString(message('phased:apps:waveformapp:title')),...
                    getString(message('phased:apps:waveformapp:yes')),getString(message('phased:apps:waveformapp:no')),getString(message('phased:apps:waveformapp:cancel')),getString(message('phased:apps:waveformapp:yes')));
                    switch dlg
                    case getString(message('phased:apps:waveformapp:yes'))
                        flag=savePopupActions(self.Model,self.View,getString(message('phased:apps:waveformapp:SaveasLabel')));
                    case getString(message('phased:apps:waveformapp:cancel'))
                        return
                    case getString(message('phased:apps:waveformapp:no'))
                        flag=0;
                    end
                    if isempty(dlg)||(flag==1)
                        return
                    end
                end
                deleteFigure(self.View)
                delete(self)
            end
        end

        function closeApprovalFlag=closeCallbackAC(self)

            title=self.View.Toolstrip.AppContainer.Title;
            if endsWith(title,'*')

                dlg=uiconfirm(self.View.Toolstrip.AppContainer,getString(message('phased:apps:waveformapp:SaveSession')),...
                getString(message('phased:apps:waveformapp:title')),...
                'Options',{getString(message('phased:apps:waveformapp:yes')),...
                getString(message('phased:apps:waveformapp:no')),...
                getString(message('phased:apps:waveformapp:cancel'))},...
                'DefaultOption',getString(message('phased:apps:waveformapp:yes')));
                switch dlg
                case getString(message('phased:apps:waveformapp:yes'))
                    flag=savePopupActions(self.Model,self.View,getString(message('phased:apps:waveformapp:SaveasLabel')));
                    closeApprovalFlag=true;
                case getString(message('phased:apps:waveformapp:cancel'))
                    closeApprovalFlag=false;
                    return
                case getString(message('phased:apps:waveformapp:no'))
                    flag=0;
                    closeApprovalFlag=true;
                end
                if isempty(dlg)||(flag==1)
                    closeApprovalFlag=true;
                    return
                end
            else
                closeApprovalFlag=true;
            end
        end
    end

    methods(Static,Hidden)
        function validateCheck(importData)
            if isa(importData,'phased.PulseWaveformLibrary')


                tempData=clone(importData);
                for i=1:numel(tempData.WaveformSpecification)
                    if isa(tempData.WaveformSpecification{i}{1},'function_handle')
                        error(message('phased:apps:waveformapp:CustomInput'));
                    end
                end
                try
                    step(tempData,1);
                    release(tempData);
                catch me
                    error(me.message);
                    return
                end
            elseif isa(importData,'phased.RectangularWaveform')...
                ||isa(importData,'phased.LinearFMWaveform')||isa(importData,'phased.SteppedFMWaveform')...
                ||isa(importData,'phased.PhaseCodedWaveform')||isa(importData,'phased.FMCWWaveform')
                try


                    tempData=clone(importData);
                    step(tempData);
                    release(tempData);
                catch me
                    error(me.message);
                    return
                end
            elseif isa(importData,'phased.PulseCompressionLibrary')
                tempData=clone(importData);
                pwl=phased.PulseWaveformLibrary('SampleRate',tempData.SampleRate,...
                'WaveformSpecification',tempData.WaveformSpecification);
                for i=1:numel(tempData.WaveformSpecification)
                    if isa(tempData.WaveformSpecification{i}{1},'function_handle')
                        error(message('phased:apps:waveformapp:CustomInput'));
                    end
                    try
                        wave=pwl(i);
                        tempData(wave,i);
                    catch me
                        error(me.message);
                        return
                    end
                end
                release(tempData);
            else
                try
                    if isa(importData,'char')
                        Session=load(importData);
                        importData=Session.LibrarySession;
                    end
                    if isa((importData.data{1}.Elements{1}),'phased.apps.internal.WaveformViewer.RectangularWaveform')||isa((importData.data{1}.Elements{1}),'phased.apps.internal.WaveformViewer.LinearFMWaveform')...
                        ||isa((importData.data{1}.Elements{1}),'phased.apps.internal.WaveformViewer.SteppedFMWaveform')||isa((importData.data{1}.Elements{1}),'phased.apps.internal.WaveformViewer.PhaseCodedWaveform')...
                        ||isa((importData.data{1}.Elements{1}),'phased.apps.internal.WaveformViewer.FMCWWaveform')||isa((importData.data{1}.Elements{1}),'phased.PulseCompressionLibrary')
                    else
                        error(message('phased:apps:waveformapp:InvalidInput'))
                    end
                catch
                    error(message('phased:apps:waveformapp:InvalidInput'))
                end
            end
        end
    end
end
