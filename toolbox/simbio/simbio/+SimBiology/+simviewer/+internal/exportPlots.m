function exportPlots(sbioAppUI)












    [fname,dname]=uiputfile('*.jpg; *.png; *.pdf; *.tiff','Save plot as',sbioAppUI.LastDirectory);

    if fname~=0
        sbioAppUI.LastDirectory=dname;
        plots=sbioAppUI.Plots;


        f=figure('visible','off','Color','white');

        if strcmp(sbioAppUI.Handles.SubPlotPanel.Visible,'on')

            y=0;
            x=0;
            for i=1:length(sbioAppUI.axesHandles)
                ax1=copyobj(sbioAppUI.axesHandles(i),f);
                SimBiology.simviewer.internal.uiController([],[],'configureAxesProperties',ax1,plots(i));



                pos=ax1.Position;
                pos(1)=pos(1)+40;
                pos(2)=pos(2)+10;
                ax1.Position=pos;
                pos=ax1.Position;


                if pos(2)>y
                    y=pos(2);
                end
                if pos(1)>x
                    x=pos(1);
                end
                height=pos(4);
                width=pos(3);
            end
            pos=f.Position;
            pos(2)=10;
            pos(3)=width+x+40;
            pos(4)=y+height+30;
            f.Position=pos;
        else
            tab=sbioAppUI.Handles.PlotTabPanelGroup.SelectedTab;
            names=sbioAppUI.Handles.PlotSetup.PlotComboBox.String;
            value=strcmp(tab.Title,names);
            ax=sbioAppUI.axesHandles(value);
            ax1=copyobj(ax,f);
            SimBiology.simviewer.internal.uiController([],[],'configureAxesProperties',ax1,plots(value));
        end


        saveas(f,fullfile(dname,fname));



        if ispc||ismac
            SimBiology.simviewer.internal.uiController([],[],'openFile',fullfile(dname,fname));
        end


        close(f);
    end


