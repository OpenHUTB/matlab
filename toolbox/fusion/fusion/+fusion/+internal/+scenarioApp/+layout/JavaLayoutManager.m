classdef JavaLayoutManager<fusion.internal.scenarioApp.layout.BaseLayoutManager



    methods
        function updateComponents(this,notFirstCall)

            platformPanel=this.PlatformPanel.Figure;
            scenarioCanvas=this.ScenarioCanvas.Figure;
            scenarioView=this.ScenarioView.Figure;


            if~notFirstCall
                allVisibleFigs=[platformPanel,scenarioCanvas,scenarioView];
                set(allVisibleFigs,'Visible','on');
            end

            toolGroup=getToolGroupName(this.Application);
drawnow

            md=com.mathworks.mlservices.MatlabDesktopServices.getDesktop;
            md.setDocumentArrangement(toolGroup,md.TILED,java.awt.Dimension(3,1));





            if notFirstCall
drawnow
            end

            md.setDocumentColumnWidths(toolGroup,[0.25,0.40,0.35]);



            column=com.mathworks.widgets.desk.DTLocation.create(0);
            this.setLocation(platformPanel,md,toolGroup,column);

            column=com.mathworks.widgets.desk.DTLocation.create(1);
            this.setLocation(scenarioCanvas,md,toolGroup,column);

            column=com.mathworks.widgets.desk.DTLocation.create(2);
            this.setLocation(scenarioView,md,toolGroup,column)
        end

        function updateTrajectoryTableComponent(this,state)
            if strcmpi(state,'off')
                updateComponents(this,true);
            elseif strcmpi(state,'on')
                toolGroup=getToolGroupName(this.Application);
                md=com.mathworks.mlservices.MatlabDesktopServices.getDesktop;

                pause(0.05);

                md.setDocumentArrangement(toolGroup,md.TILED,java.awt.Dimension(3,2));
                md.setDocumentColumnWidths(toolGroup,[0.25,0.40,0.35]);
drawnow

                column=com.mathworks.widgets.desk.DTLocation.create(0);
                this.setLocation(this.PlatformPanel.Figure,md,toolGroup,column);

                column=com.mathworks.widgets.desk.DTLocation.create(1);
                this.setLocation(this.ScenarioCanvas.Figure,md,toolGroup,column);

                column=com.mathworks.widgets.desk.DTLocation.create(2);
                this.setLocation(this.ScenarioView.Figure,md,toolGroup,column)

                column=com.mathworks.widgets.desk.DTLocation.create(4);
                this.setLocation(this.TrajectoryTable.Figure,md,toolGroup,column)
drawnow
                md.setDocumentRowSpan(toolGroup,0,0,2);
                md.setDocumentRowSpan(toolGroup,0,2,2);
                md.setDocumentRowHeights(toolGroup,[0.66,0.34]);
            end
            updateSensorComponents(this,strcmp(this.SensorPanel.Figure.Visible,'on'));
        end

        function updateSensorComponents(this,visible)


            if nargin<2
                visible=true;
            end

            if visible
                this.SensorPanel.Figure.Visible='on';
                this.SensorCanvas.Figure.Visible='on';
drawnow
                toolGroup=getToolGroupName(this.Application);

                md=com.mathworks.mlservices.MatlabDesktopServices.getDesktop;
                column0=com.mathworks.widgets.desk.DTLocation.create(0);
                this.setLocation(this.SensorPanel.Figure,md,toolGroup,column0);

                column1=com.mathworks.widgets.desk.DTLocation.create(1);
                this.setLocation(this.SensorCanvas.Figure,md,toolGroup,column1);
            else
                this.SensorCanvas.Figure.Visible='off';
                this.SensorPanel.Figure.Visible='off';
            end
        end

        function layoutSimulation(this)

            this.SensorPanel.Figure.Visible='off';
            this.PlatformPanel.Figure.Visible='off';
            this.ScenarioCanvas.Figure.Visible='off';
            this.SensorCanvas.Figure.Visible='off';
            this.TrajectoryTable.Figure.Visible='off';

            md=com.mathworks.mlservices.MatlabDesktopServices.getDesktop;
            toolGroupName=this.Application.ToolGroup.Name;
            md.setDocumentArrangement(toolGroupName,md.TILED,java.awt.Dimension(1,1));
        end

        function pos=getPositionAroundCenter(this,size)

            pos=matlabshared.application.getCenterPosition(...
            size,...
            getToolGroupName(this.Application));
        end
    end

    methods(Static)
        function setLocation(comp,md,toolGroup,column)
            name=comp.Name;
            tl=md.getClientLocation(md.getClient(name,toolGroup));
            if isempty(tl)
                disp(['empty client location for ',name]);
            end

            if tl.getTile~=column.getTile
                md.setClientLocation(name,toolGroup,column);
            end
        end
    end
end


