function toggleImpairments(obj,~)




    if obj.pImpairBtn.Value
        if~isKey(obj.pParameters.DialogsMap,'wirelessWaveformGenerator.ImpairDialog')

            params=obj.pParameters;
            if obj.useAppContainer
                document=matlab.ui.internal.FigurePanel(...
                'Title',getString(message('comm:waveformGenerator:ImpairmentsFig')),...
                'Tag','ImpairmentsFig');
                addPanel(obj.AppContainer,document);
                obj.pImpairmentsFig=document.Figure;
                params.LayoutImpair=uigridlayout(obj.pImpairmentsFig,[1,1]);
                params.AccordionImpair=matlab.ui.container.internal.Accordion('Parent',params.LayoutImpair);
            else
                obj.pImpairmentsFig=figure('Name',getString(message('comm:waveformGenerator:ImpairmentsFig')),...
                'NumberTitle','off','HandleVisibility','off','Tag','ImpairmentsFig');
                obj.ToolGroup.addFigure(obj.pImpairmentsFig);
            end

            impairDialog=wirelessWaveformGenerator.ImpairDialog(params,obj.pImpairmentsFig);
            obj.pParameters.DialogsMap('wirelessWaveformGenerator.ImpairDialog')=impairDialog;

            if~obj.useAppContainer
                params.LayoutImpair=...
                matlabshared.application.layout.ScrollableGridBagLayout(...
                params.WaveformGenerator.pImpairmentsFig,...
                'VerticalGap',8,...
                'HorizontalGap',6,...
                'VerticalWeights',[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1],...
                'HorizontalWeights',1);

                add(params.LayoutImpair,impairDialog.getPanels,1,1,...
                'MinimumWidth',impairDialog.Width(1),...
                'Fill','Horizontal',...
                'MinimumHeight',impairDialog.Height(1),...
                'Anchor','North')

                drawnow;
                params.LayoutImpair.update();
                params.LayoutImpair.clean();
            else
                impairDialog.getPanels.Parent=params.AccordionImpair;
            end

            sr=obj.pParameters.CurrentDialog.getSampleRate();
            impairDialog.PhaseNoiseFrequencies=[0.2*sr,0.4*sr];
        elseif obj.useAppContainer
            impairPanel=obj.AppContainer.getPanel(getString(message('comm:waveformGenerator:ImpairmentsFig')));
            impairPanel.Opened=true;
        end


        if~obj.useAppContainer
            obj.pImpairmentsFig.Visible='on';
            drawnow;
            md=com.mathworks.mlservices.MatlabDesktopServices.getDesktop;
            loc=com.mathworks.widgets.desk.DTLocation.create(0);
            javaMethodEDT('setClientLocation',md,obj.pImpairmentsFig.Name,obj.ToolGroup.Name,loc);

            prop=com.mathworks.widgets.desk.DTClientProperty.PERMIT_USER_CLOSE;
            state=java.lang.Boolean.FALSE;
            md.getClient(obj.pImpairmentsFig.Name,obj.ToolGroup.Name).putClientProperty(prop,state);
        else

            wavegenPanel=obj.AppContainer.getPanel(getString(message('comm:waveformGenerator:WaveformFig')));
            wavegenPanel.Collapsed=true;

            layoutUIControls(obj.pParameters.ImpairDialog);
        end
    else
        if obj.useAppContainer
            impairPanel=obj.AppContainer.getPanel(getString(message('comm:waveformGenerator:ImpairmentsFig')));
            impairPanel.Opened=false;


            wavegenPanel=obj.AppContainer.getPanel(getString(message('comm:waveformGenerator:WaveformFig')));
            wavegenPanel.Collapsed=false;

            layoutPanels(obj.pParameters.CurrentDialog);
        else
            obj.pImpairmentsFig.Visible='off';
            drawnow;pause(1);
        end
    end

