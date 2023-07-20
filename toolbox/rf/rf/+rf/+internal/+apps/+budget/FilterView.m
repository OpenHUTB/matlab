classdef FilterView<rf.internal.apps.budget.ElementView





    properties
Icon
        Type='lowpass';
    end

    methods

        function self=FilterView(elem,varargin)



            self=self@rf.internal.apps.budget.ElementView(varargin{:});
            self.Type=elem.ResponseType;
            if~strcmpi(elem.ResponseType,'lowpass')
                if self.Canvas.View.UseAppContainer
                    self.Picture.Block.ImageSource=self.Icon;
                else
                    self.Picture.Block.CData=self.Icon;
                end
            end
        end


        function val=get.Icon(self)
            val=imread([fullfile('+rf','+internal','+apps','+budget')...
            ,filesep,lower(self.Type),'_60.png']);
        end


        function unselectElement(self)


            dlg=self.Canvas.View.Parameters.ElementDialog;
            dlg.Parent.View.setStatusBarMsg('');
            if self.Canvas.View.UseAppContainer
                dlg.Parent.notify('DisableCanvas',...
                rf.internal.apps.budget.ElementParameterChangedEventData(1,...
                'ApplyButton','inactive'));
            else
                dlg.Parent.notify('DisableCanvas',...
                rf.internal.apps.budget.ElementParameterChangedEventData(1,...
                'ApplyTag','inactive'));
            end
            unselectElement@rf.internal.apps.budget.ElementView(self)
        end

        function selectElement(self,elem)


            selectElement@rf.internal.apps.budget.ElementView(self,elem)

            dlg=self.Canvas.View.Parameters.ElementDialog;
            setListenersEnable(dlg,false)
            dlg.Name=elem.Name;
            dlg.Implementation=elem.Implementation;
            dlg.Zin=elem.Zin;
            dlg.Zout=elem.Zout;
            dlg.UseFilterOrder=true;
            setListenersEnable(dlg,true)
            setFigureKeyPress(dlg);
            dlg.ResponseType=elem.ResponseType;
            dlg.UseFilterOrder=elem.UseFilterOrder;
            dlg.FilterType=elem.FilterType;
            switch lower(elem.FilterType)
            case 'butterworth'
                if elem.UseFilterOrder
                    if strcmpi(elem.ResponseType,'BandStop')
                        dlg.FilterOrder=elem.FilterOrder;
                        dlg.StopbandFrequency=elem.StopbandFrequency;
                        dlg.StopbandAttenuation=elem.StopbandAttenuation;
                    else
                        dlg.FilterOrder=elem.FilterOrder;
                        dlg.PassbandFrequency=elem.PassbandFrequency;
                        dlg.PassbandAttenuation=elem.PassbandAttenuation;
                    end
                else
                    dlg.PassbandFrequency=elem.PassbandFrequency;
                    dlg.PassbandAttenuation=elem.PassbandAttenuation;
                    dlg.StopbandFrequency=elem.StopbandFrequency;
                    dlg.StopbandAttenuation=elem.StopbandAttenuation;
                end
            case 'chebyshev'
                if elem.UseFilterOrder
                    if strcmpi(elem.ResponseType,'BandStop')
                        dlg.FilterOrder=elem.FilterOrder;
                        dlg.PassbandAttenuation=elem.PassbandAttenuation;
                        dlg.StopbandFrequency=elem.StopbandFrequency;
                        dlg.StopbandAttenuation=elem.StopbandAttenuation;
                    else
                        dlg.FilterOrder=elem.FilterOrder;
                        dlg.PassbandFrequency=elem.PassbandFrequency;
                        dlg.PassbandAttenuation=elem.PassbandAttenuation;
                    end
                else
                    dlg.PassbandFrequency=elem.PassbandFrequency;
                    dlg.PassbandAttenuation=elem.PassbandAttenuation;
                    dlg.StopbandFrequency=elem.StopbandFrequency;
                    dlg.StopbandAttenuation=elem.StopbandAttenuation;
                end
            case 'inversechebyshev'
                if elem.UseFilterOrder
                    dlg.FilterOrder=elem.FilterOrder;
                    switch elem.ResponseType
                    case{'Lowpass','Highpass','Bandpass'}
                        dlg.PassbandFrequency=elem.PassbandFrequency;
                        dlg.PassbandAttenuation=elem.PassbandAttenuation;
                        dlg.StopbandAttenuation=elem.StopbandAttenuation;
                    otherwise
                        dlg.StopbandFrequency=elem.StopbandFrequency;
                        dlg.StopbandAttenuation=elem.StopbandAttenuation;
                    end
                else
                    dlg.PassbandFrequency=elem.PassbandFrequency;
                    dlg.PassbandAttenuation=elem.PassbandAttenuation;
                    dlg.StopbandFrequency=elem.StopbandFrequency;
                    dlg.StopbandAttenuation=elem.StopbandAttenuation;
                end
            end
            if self.Canvas.View.UseAppContainer

                strengunits={'','k','M','G','T'};
                [~,~,u]=engunits(elem.PassbandFrequency);
                i=strcmp(u,strengunits);
                if any(i)
                    STRUnit=[strengunits(i),'Hz'];
                    InputToseValue=join(STRUnit,'');
                    rf.internal.apps.budget.setValue(self,...
                    dlg,'FpUnits',InputToseValue);
                else


                    rf.internal.apps.budget.setValue(self,dlg,'FpUnits','Hz');
                end

                [~,~,u]=engunits(elem.StopbandFrequency);
                j=strcmp(u,strengunits);
                if any(j)
                    STRUnit1=[strengunits(j),'Hz'];
                    InputToseValue1=join(STRUnit1,'');
                    rf.internal.apps.budget.setValue(self,...
                    dlg,'FsUnits',InputToseValue1);
                else
                    rf.internal.apps.budget.setValue(self,dlg,'FsUnits','Hz');
                end
            end

            resetDialogAccess(dlg);
            if self.Canvas.View.UseAppContainer
                dlg.Parent.notify('DisableCanvas',...
                rf.internal.apps.budget.ElementParameterChangedEventData(1,...
                'ApplyButton','inactive'));
            else
                dlg.Parent.notify('DisableCanvas',...
                rf.internal.apps.budget.ElementParameterChangedEventData(1,...
                'ApplyTag','inactive'));
            end
            enableUIControls(dlg,true);
        end
    end
end


