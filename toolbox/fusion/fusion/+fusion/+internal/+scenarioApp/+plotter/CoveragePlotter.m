classdef CoveragePlotter<radarfusion.internal.coveragePlotter
    properties
Tag
Visible
    end

    properties(Access=protected)
        ButtonDownCallback=[]
    end

    methods

        function this=CoveragePlotter(hAxes,buttonDownCb)
            this@radarfusion.internal.coveragePlotter(hAxes);
            this.Tag='coverage';
            if nargin==2
                this.ButtonDownCallback=buttonDownCb;
            end
        end

        function set.Visible(this,value)
            if strcmpi(value,'off')&&~strcmpi(this.Visible,'off')

                vis=findall([this.Beams,this.Coverages],'Visible','on');
                set(vis,'Visible','off');
            elseif strcmpi(value,'on')&&~strcmpi(this.Visible,'on')

                unvis=findall([this.Beams,this.Coverages],'Visible','off');
                set(unvis,'Visible','on');
            end
            this.Visible=value;
        end

        function plotCoverage(this,sensors,positions,orientations)



            if nargin==2
                [configs,indices,colors]=coverageConfig(this,sensors);
            elseif nargin==3
                [configs,indices,colors]=coverageConfig(this,sensors,positions);
            else
                [configs,indices,colors]=coverageConfig(this,sensors,positions,orientations);
            end
            if length(configs)>0 %#ok<ISMT>

                allids=[configs.Index];
                currids=[this.Map];
                toClear=currids(~ismember(currids,allids));
                clear(this,toClear);
                plotCoverage@radarfusion.internal.coveragePlotter(this,configs,indices,colors);
            else

                clear(this);
            end
        end

        function clear(this,toDel)
            if nargin==1
                clearData(this);
            else
                removeCoverage(this,toDel);
            end
        end

    end
    methods(Access=protected)

        function opts=getBeamOptions(this)
            opts={'FaceAlpha',this.Alpha(1),...
            'EdgeColor','none',...
            'AlphaDataMapping','none',...
            'HandleVisibility','off',...
            'XLimInclude','off',...
            'YLimInclude','off',...
            'ZLimInclude','off'};
            if~isempty(this.ButtonDownCallback)
                opts=[opts,{'ButtonDownFcn',@this.ButtonDownCallback}];
            end
        end

        function opts=getCoverageOptions(this)
            opts={'FaceAlpha',this.Alpha(2),...
            'EdgeColor','none',...
            'AlphaDataMapping','none',...
            'HandleVisibility','off',...
            'XLimInclude','off',...
            'YLimInclude','off',...
            'ZLimInclude','off'};
            if~isempty(this.ButtonDownCallback)
                opts=[opts,{'ButtonDownFcn',@this.ButtonDownCallback}];
            end
        end

        function[configs,indices,colors]=coverageConfig(this,sensors,positions,orientations)

            numSensors=numel(sensors);
            if nargin<3
                positions=zeros(numSensors,3);
            end
            if nargin<4
                orientations=zeros(numSensors,3);
            end

            configTemplate=struct(...
            'Index',1,...
            'LookAngle',[0;0],...
            'FieldOfView',[1;5],...
            'ScanLimits',[0,360;0,360],...
            'Range',1000,...
            'Position',[0,0,0],...
            'Orientation',quaternion(1,0,0,0)...
            );
            configs=repmat(configTemplate,1,numSensors);
            indices=zeros(1,numSensors);
            colors=cell(1,numSensors);

            for i=1:numSensors
                sensor=sensors(i);
                config=configs(i);
                config.Index=sensor.ID;
                config.LookAngle=sensor.LookAngle;
                config.FieldOfView=sensor.FieldOfView;
                switch sensor.ScanMode
                case 'Mechanical'
                    scanLimits=sensor.MechanicalScanLimits;
                case 'Electronic'
                    scanLimits=sensor.ElectronicScanLimits;
                case 'Mechanical and electronic'
                    scanLimits=[sensor.MechanicalScanLimits(:,1)+sensor.ElectronicScanLimits(:,1),...
                    sensor.MechanicalScanLimits(:,2)+sensor.ElectronicScanLimits(:,2)];
                otherwise
                    scanLimits=zeros(1,2);
                end
                config.ScanLimits=scanLimits;

                config.Range=sensor.MaxUnambiguousRange;


                qOrient=quaternion(orientations(i,[3,2,1]),'eulerd','zyx','frame');
                scene2plat=rotmat(qOrient,'frame');
                position=positions(i,:)'+scene2plat'*sensor.MountingLocation(:);

                plat2sens=quaternion(sensor.MountingAngles([3,2,1]),'eulerd','ZYX','frame');
                scene2sens=plat2sens*qOrient;

                config.Position=position';
                config.Orientation=scene2sens;
                configs(i)=config;
                indices(i)=config.Index;
                colors{i}=getPlatformColor(this,sensor.PlatformID);
            end
        end

        function col=getPlatformColor(this,id)
            cid=mod(id+1,7);
            if cid==0
                cid=7;
            end
            col=this.Parent.ColorOrder(cid,:);
        end
    end
end
