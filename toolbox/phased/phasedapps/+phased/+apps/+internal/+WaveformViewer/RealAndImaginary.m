classdef RealAndImaginary<phased.apps.internal.WaveformViewer.PlotData



    properties
View
Figure
Panel
TopAxes
BottomAxes
Layout
    end
    methods
        function self=RealAndImaginary(parent)
            self.View=parent;
            self.Figure=self.View.RealAndImaginaryFig;
            if self.View.Toolstrip.IsAppContainer
                self.Layout=uigridlayout(self.Figure);
                self.Layout.RowHeight={'1x'};
                self.Layout.ColumnWidth={'1x'};
                self.Panel=uipanel(self.Layout);
            else
                self.Layout=...
                matlabshared.application.layout.ScrollableGridBagLayout(...
                self.Figure,...
                'VerticalGap',8,...
                'HorizontalGap',6,...
                'VerticalWeights',[0,1],...
                'HorizontalWeights',1);
                self.Panel=uipanel(...
                'Parent',self.Figure,...
                'Title','',...
                'BorderType','none',...
                'Visible','on');
            end
            self.TopAxes=axes('Parent',self.Panel,'Position',[0.15,0.57,0.8,0.35]);
            self.BottomAxes=axes('Parent',self.Panel,'Position',[0.15,0.11,0.8,0.35]);
            linkaxes([self.TopAxes,self.BottomAxes],'x')
        end

        function realImaginaryPlot(self,data)

            self.updatePlot(data)
            l=(0:length(self.Wav)-1)/self.SampleRate;
            [~,eng_exp,de_units]=engunits(l(end));
            l=l*eng_exp;
            ind=self.View.Canvas.WaveformList.getSelectedRows;
            k=numel(self.View.Canvas.WaveformList.getSelectedRows);
            if k==1
                self.View.Toolstrip.WaveformScriptPopup.Enabled=true;
            end
            if k>1
                if data.Index~=ind(1)
                    hold(self.TopAxes,'on');
                end
                prevLowerLim=self.TopAxes.YLim(1);
                prevUpperLim=self.TopAxes.YLim(2);
            end
            plot(self.TopAxes,l,real(self.Wav));

            phased.apps.internal.WaveformViewer.SetLimits(real(self.Wav),self.TopAxes)
            set(self.TopAxes,'Tag','RealAxes');
            if k>1
                updatedLowerLim=self.TopAxes.YLim(1);
                updatedUpperLim=self.TopAxes.YLim(2);
                if prevLowerLim>=updatedLowerLim&&prevUpperLim>=updatedUpperLim
                    self.TopAxes.YLim=[updatedLowerLim,prevUpperLim];
                elseif prevLowerLim<=updatedLowerLim&&prevUpperLim>=updatedUpperLim
                    self.TopAxes.YLim=[prevLowerLim,prevUpperLim];
                elseif prevLowerLim>=updatedLowerLim&&prevUpperLim<=updatedUpperLim
                    self.TopAxes.YLim=[updatedLowerLim,updatedUpperLim];
                elseif prevLowerLim<=updatedLowerLim&&prevUpperLim<=updatedUpperLim
                    self.TopAxes.YLim=[updatedLowerLim,updatedUpperLim];
                else
                    self.TopAxes.YLim=[prevLowerLim,prevUpperLim];
                end
            end
            if strcmp(de_units,'u')
                de_units='\mu';
            end
            ylabel(self.TopAxes,getString(message('phased:apps:waveformapp:RealPlotYLabel')));
            grid(self.TopAxes,'on');
            hold(self.TopAxes,'off');
            if self.View.Toolstrip.IsAppContainer
                axtoolbar(self.Figure.CurrentAxes,{'export','rotate','datacursor',...
                'pan','zoomin','zoomout','restoreview'});
            end
            if k>1
                if data.Index~=ind(1)
                    hold(self.BottomAxes,'on');
                end
                prevLowerLim=self.BottomAxes.YLim(1);
                prevUpperLim=self.BottomAxes.YLim(2);
            end
            plot(self.BottomAxes,l,imag(self.Wav));
            phased.apps.internal.WaveformViewer.SetLimits(imag(self.Wav),self.BottomAxes)
            set(self.BottomAxes,'Tag','ImagAxes');
            if k>1
                updatedLowerLim=self.BottomAxes.YLim(1);
                updatedUpperLim=self.BottomAxes.YLim(2);
                if prevLowerLim>=updatedLowerLim&&prevUpperLim>=updatedUpperLim
                    self.BottomAxes.YLim=[updatedLowerLim,prevUpperLim];
                elseif prevLowerLim<=updatedLowerLim&&prevUpperLim>=updatedUpperLim
                    self.BottomAxes.YLim=[prevLowerLim,prevUpperLim];
                elseif prevLowerLim>=updatedLowerLim&&prevUpperLim<=updatedUpperLim
                    self.BottomAxes.YLim=[updatedLowerLim,updatedUpperLim];
                else
                    self.BottomAxes.YLim=[updatedLowerLim,updatedUpperLim];
                end
                if ind(k)==data.Index
                    stringLegend={};
                    legend(self.TopAxes,stringLegend,'Interpreter','none');
                    self.TopAxes.Legend.Visible='off';
                    for i=1:k
                        stringLegend{end+1}=self.View.Canvas.WaveformList.Data{ind(i)};
                    end
                    if numel(stringLegend)==numel(self.TopAxes.Legend.String)
                        legend(self.TopAxes,stringLegend,'Interpreter','none');
                        legend(self.BottomAxes,stringLegend,'Interpreter','none');
                    end
                end
            end
            if strcmp(de_units,'u')
                de_units='\mu';
            end
            xlabel(self.BottomAxes,getString(message('phased:apps:waveformapp:RealPlotXLabel',de_units)));
            ylabel(self.BottomAxes,getString(message('phased:apps:waveformapp:ImaginaryPlotYLabel')));
            self.TopAxes.YLabel.Position(1)=self.BottomAxes.YLabel.Position(1);
            grid(self.BottomAxes,'on');
            hold(self.BottomAxes,'off');
            if self.View.Toolstrip.IsAppContainer
                axtoolbar(self.TopAxes,{'export','rotate','datacursor',...
                'pan','zoomin','zoomout','restoreview'});
                axtoolbar(self.BottomAxes,{'export','rotate','datacursor',...
                'pan','zoomin','zoomout','restoreview'});
            end
        end
        function genCode(self,strWriter)

            self.axesHelper(self.TopAxes)
            xlimBottomAxes=get(self.BottomAxes,'XLim');
            ylimBottomAxes=get(self.BottomAxes,'YLim');
            xlabelBottomAxes=get(get(self.BottomAxes,'Xlabel'),'String');
            ylabelBottomAxes=get(get(self.BottomAxes,'Ylabel'),'String');

            addcr(strWriter,['l = (0:length(x)-1)/Fs;',newline...
            ,'subplot(2,1,1);',newline...
            ,'[~, scale, ~] = engunits(l(end));',newline...
            ,'l = l*scale;'...
            ,newline,'plot(l,real(x));'...
            ,newline,'axis([',num2str(self.xlimTopAxes(1)),' ',num2str(self.xlimTopAxes(2)),' ',num2str(self.ylimTopAxes(1)),' ',num2str(self.ylimTopAxes(2)),']);'...
            ,newline,'xlabel(''',self.xlabelTopAxes,''');'...
            ,newline,'ylabel(''',self.ylabelTopAxes,''');'...
            ,newline,'grid on;',newline...
            ,'subplot(2,1,2);',newline,'plot(l,imag(x));'...
            ,newline,'axis([',num2str(xlimBottomAxes(1)),' ',num2str(xlimBottomAxes(2)),' ',num2str(ylimBottomAxes(1)),' ',num2str(ylimBottomAxes(2)),']);'...
            ,newline,'xlabel(''',xlabelBottomAxes,''');'...
            ,newline,'ylabel(''',ylabelBottomAxes,''');'...
            ,newline,'grid on;',newline]);
        end
    end
end