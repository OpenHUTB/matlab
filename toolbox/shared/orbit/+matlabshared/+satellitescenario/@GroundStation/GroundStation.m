classdef GroundStation<matlabshared.satellitescenario.internal.PrimaryAssetWrapper %#codegen




    properties(Dependent,SetAccess=private)













Name














Latitude















Longitude











Altitude
    end

    properties(Dependent)


















MinElevationAngle




MarkerColor



MarkerSize



ShowLabel



LabelFontSize




LabelFontColor
    end

    methods(Access={?matlabshared.satellitescenario.internal.ObjectArray,...
        ?matlabshared.satellitescenario.coder.internal.ObjectArrayCG,...
        ?matlabshared.satellitescenario.internal.Asset,...
        ?matlabshared.satellitescenario.internal.AddAssetsAndAnalyses,...
        ?satcom.satellitescenario.internal.AddAssetsAndAnalyses,...
        ?matlabshared.satellitescenario.ScenarioGraphic,...
        ?satelliteScenario})
        function gs=GroundStation(varargin)



            coder.allowpcode('plain');


            if~coder.target('MATLAB')
                gs.Handles={matlabshared.satellitescenario.internal.GroundStation};
                gs.Handles=cell(1,0);
            else
                gs.Handles=cell(1,0);
            end






            if nargin~=0

                names=varargin{1};
                latitude=varargin{2};
                longitude=varargin{3};
                altitude=varargin{4};
                minElevationAngle=varargin{5};
                simulator=varargin{6};
                scenarioHandle=varargin{7};


                numGs=max(1,numel(latitude));


                handles=cell(1,numGs);

                if simulator.NumGroundStations==0
                    simulator.GroundStations=repmat(simulator.GroundStationStruct,1,numGs);
                else
                    newGroundStationStruct=repmat(simulator.GroundStationStruct,1,numGs);
                    simulator.GroundStations=[simulator.GroundStations,newGroundStationStruct];
                end
                for idx=1:numGs


                    if numel(names)==1
                        nameString=names{1};
                    else
                        nameString=names{idx};
                    end



                    handles{idx}=matlabshared.satellitescenario.internal.GroundStation(...
                    nameString,latitude(idx),longitude(idx),altitude(idx),...
                    minElevationAngle(idx),simulator,scenarioHandle);
                end


                gs.Handles=handles;
            end
        end
    end

    methods
        function gsName=get.Name(gs)


            coder.allowpcode('plain');

            if~coder.target('MATLAB')
                validateattributes(gs,...
                {'matlabshared.satellitescenario.GroundStation'},...
                {'scalar'},'get.Name','GS');
                gsName=gs.Handles{1}.Name;
                return
            end

            handles=[gs.Handles{:}];

            if isempty(handles)
                gsName=strings(0,0);
            else
                gsName=[handles.Name];
            end
        end

        function lat=get.Latitude(gs)


            coder.allowpcode('plain');

            if~coder.target('MATLAB')
                lat=zeros(1,numel(gs.Handles));
                for idx=1:numel(gs.Handles)
                    lat(idx)=gs.Handles{idx}.Latitude;
                end
                return
            end

            handles=[gs.Handles{:}];

            if isempty(handles)
                lat=[];
            else
                lat=[handles.Latitude];
            end
        end

        function lon=get.Longitude(gs)


            coder.allowpcode('plain');

            if~coder.target('MATLAB')
                lon=zeros(1,numel(gs.Handles));
                for idx=1:numel(gs)
                    lon(idx)=gs.Handles{idx}.Longitude;
                end
                return
            end

            handles=[gs.Handles{:}];

            if isempty(handles)
                lon=[];
            else
                lon=[handles.Longitude];
            end
        end

        function alt=get.Altitude(gs)


            coder.allowpcode('plain');

            if~coder.target('MATLAB')
                alt=zeros(1,numel(gs.Handles));
                for idx=1:numel(gs)
                    alt(idx)=gs.Handles{idx}.Altitude;
                end
                return
            end

            handles=[gs.Handles{:}];

            if isempty(handles)
                alt=[];
            else
                alt=[handles.Altitude];
            end
        end

        function el=get.MinElevationAngle(gs)


            coder.allowpcode('plain');

            if~coder.target('MATLAB')
                el=zeros(1,numel(gs.Handles));
                for idx=1:numel(gs)
                    el(idx)=gs.Handles{idx}.MinElevationAngle;
                end
                return
            end

            handles=[gs.Handles{:}];

            if isempty(handles)
                el=[];
            else
                el=[handles.MinElevationAngle];
            end
        end

        function gs=set.MinElevationAngle(gs,el)


            coder.allowpcode('plain');

            if~coder.target('MATLAB')
                msg='shared_orbit:orbitPropagator:UnsupportedPropertySetCodegen';
                coder.internal.error(msg,'MinElevationAngle','matlabshared.satellitescenario.GroundStation');
            end

            gsHandles=[gs.Handles{:}];
            for idx=1:numel(gsHandles)
                gsHandles(idx).MinElevationAngle=el;
            end
        end

        function c=get.MarkerColor(asset)


            coder.allowpcode('plain');

            if~coder.target('MATLAB')
                msg='shared_orbit:orbitPropagator:UnsupportedPropertyGetSetCodegen';
                coder.internal.error(msg,'MarkerColor','matlabshared.satellitescenario.GroundStation');
            end

            handles=[asset.Handles{:}];

            if isempty(handles)
                c=[];
            else
                c=[handles.MarkerColor];
            end
        end

        function asset=set.MarkerColor(asset,c)


            coder.allowpcode('plain');

            if~coder.target('MATLAB')
                msg='shared_orbit:orbitPropagator:UnsupportedPropertyGetSetCodegen';
                coder.internal.error(msg,'MarkerColor','matlabshared.satellitescenario.GroundStation');
            end

            handles=[asset.Handles{:}];
            for idx=1:numel(handles)
                handles(idx).MarkerColor=c;
            end
        end

        function s=get.MarkerSize(asset)


            coder.allowpcode('plain');

            if~coder.target('MATLAB')
                msg='shared_orbit:orbitPropagator:UnsupportedPropertyGetSetCodegen';
                coder.internal.error(msg,'MarkerSize','matlabshared.satellitescenario.GroundStation');
            end

            handles=[asset.Handles{:}];

            if isempty(handles)
                s=[];
            else
                s=[handles.MarkerSize];
            end
        end

        function asset=set.MarkerSize(asset,s)


            coder.allowpcode('plain');

            if~coder.target('MATLAB')
                msg='shared_orbit:orbitPropagator:UnsupportedPropertyGetSetCodegen';
                coder.internal.error(msg,'MarkerSize','matlabshared.satellitescenario.GroundStation');
            end

            handles=[asset.Handles{:}];
            matlabshared.satellitescenario.ScenarioGraphic.setGraphicalField(handles,"MarkerSize",s);
        end

        function s=get.ShowLabel(asset)


            coder.allowpcode('plain');

            if~coder.target('MATLAB')
                msg='shared_orbit:orbitPropagator:UnsupportedPropertyGetSetCodegen';
                coder.internal.error(msg,'ShowLabel','matlabshared.satellitescenario.GroundStation');
            end

            handles=[asset.Handles{:}];

            if isempty(handles)
                s=false(0,0);
            else
                s=[handles.ShowLabel];
            end
        end

        function asset=set.ShowLabel(asset,s)


            coder.allowpcode('plain');

            if~coder.target('MATLAB')
                msg='shared_orbit:orbitPropagator:UnsupportedPropertyGetSetCodegen';
                coder.internal.error(msg,'ShowLabel','matlabshared.satellitescenario.GroundStation');
            end

            handles=[asset.Handles{:}];
            matlabshared.satellitescenario.ScenarioGraphic.setGraphicalField(handles,"ShowLabel",s);
        end

        function c=get.LabelFontColor(asset)


            coder.allowpcode('plain');

            if~coder.target('MATLAB')
                msg='shared_orbit:orbitPropagator:UnsupportedPropertyGetSetCodegen';
                coder.internal.error(msg,'LabelFontColor','matlabshared.satellitescenario.GroundStation');
            end

            handles=[asset.Handles{:}];

            if isempty(handles)
                c=[];
            else
                c=[handles.LabelFontColor];
            end
        end

        function asset=set.LabelFontColor(asset,c)


            coder.allowpcode('plain');

            if~coder.target('MATLAB')
                msg='shared_orbit:orbitPropagator:UnsupportedPropertyGetSetCodegen';
                coder.internal.error(msg,'LabelFontColor','matlabshared.satellitescenario.GroundStation');
            end

            handles=[asset.Handles{:}];
            for idx=1:numel(handles)
                handles(idx).LabelFontColor=c;
            end
        end

        function s=get.LabelFontSize(asset)


            coder.allowpcode('plain');

            if~coder.target('MATLAB')
                msg='shared_orbit:orbitPropagator:UnsupportedPropertyGetSetCodegen';
                coder.internal.error(msg,'LabelFontSize','matlabshared.satellitescenario.GroundStation');
            end

            handles=[asset.Handles{:}];

            if isempty(handles)
                s=[];
            else
                s=[handles.LabelFontSize];
            end
        end

        function asset=set.LabelFontSize(asset,s)


            coder.allowpcode('plain');

            if~coder.target('MATLAB')
                msg='shared_orbit:orbitPropagator:UnsupportedPropertyGetSetCodegen';
                coder.internal.error(msg,'LabelFontSize','matlabshared.satellitescenario.GroundStation');
            end

            handles=[asset.Handles{:}];
            matlabshared.satellitescenario.ScenarioGraphic.setGraphicalField(handles,"LabelFontSize",s);
        end
    end

    methods(Hidden)
        disp(gs)
    end

    methods(Hidden,Static)
        function gs=loadobj(s)


            coder.allowpcode('plain');

            if isa(s,'matlabshared.satellitescenario.internal.ObjectArray')


                gs=s;
            else





                gs=matlabshared.satellitescenario.GroundStation;

                if isfield(s,'Handles')


                    gs.Handles=s.Handles;
                else





                    gsHandle=matlabshared.satellitescenario.internal.GroundStation;
                    gs.Handles={gsHandle};


                    gsHandle.GroundStationGraphic=s.GroundStationGraphic;
                    gsHandle.LabelGraphic=s.LabelGraphic;
                    gsHandle.pMinElevationAngle=s.pMinElevationAngle;

                    if isa(s.Gimbals,'double')




                        gsHandle.Gimbals=matlabshared.satellitescenario.Gimbal;
                    else







                        handles=[s.Gimbals.Handles];
                        if~isempty(handles)
                            gsHandle.pGimbalsAddedBefore=true;
                            handles=reshape(handles,1,[]);
                        end



                        for idx=1:numel(handles)
                            handles{idx}.Parent=gs;
                        end



                        gim=matlabshared.satellitescenario.Gimbal;
                        gim.Handles=handles;



                        gsHandle.Gimbals=gim;
                    end

                    if isa(s.ConicalSensors,'double')





                        gsHandle.ConicalSensors=matlabshared.satellitescenario.ConicalSensor;
                    else







                        handles=[s.ConicalSensors.Handles];
                        if~isempty(handles)
                            gsHandle.pConicalSensorsAddedBefore=true;
                            handles=reshape(handles,1,[]);
                        end



                        for idx=1:numel(handles)
                            handles{idx}.Parent=gs;
                        end



                        cs=matlabshared.satellitescenario.ConicalSensor;
                        cs.Handles=handles;



                        gsHandle.ConicalSensors=cs;
                    end

                    if isa(s.Accesses,'double')




                        gsHandle.Accesses=matlabshared.satellitescenario.Access;
                    else







                        handles=[s.Accesses.Handles];
                        if~isempty(handles)
                            gsHandle.pAccessesAddedBefore=true;
                            handles=reshape(handles,1,[]);
                        end



                        for idx=1:numel(handles)
                            handles{idx}.Parent=gs;
                        end



                        ac=matlabshared.satellitescenario.Access;
                        ac.Handles=handles;



                        gsHandle.Accesses=ac;
                    end

                    if isa(s.Transmitters,'double')




                        gsHandle.Transmitters=satcom.satellitescenario.Transmitter;
                    else







                        handles=[s.Transmitters.Handles];
                        if~isempty(handles)
                            gsHandle.pTransmittersAddedBefore=true;
                            handles=reshape(handles,1,[]);
                        end



                        for idx=1:numel(handles)
                            handles{idx}.Parent=gs;
                        end



                        tx=satcom.satellitescenario.Transmitter;
                        tx.Handles=handles;



                        gsHandle.Transmitters=tx;
                    end

                    if isa(s.Receivers,'double')




                        gsHandle.Receivers=satcom.satellitescenario.Receiver;
                    else







                        handles=[s.Receivers.Handles];
                        if~isempty(handles)
                            gsHandle.pReceiversAddedBefore=true;
                            handles=reshape(handles,1,[]);
                        end



                        for idx=1:numel(handles)
                            handles{idx}.Parent=gs;
                        end



                        rx=satcom.satellitescenario.Receiver;
                        rx.Handles=handles;



                        gsHandle.Receivers=rx;
                    end


                    gsHandle.pName=s.pName;
                    gsHandle.Simulator=s.Simulator;
                    gsHandle.SimulatorID=s.SimulatorID;
                    gsHandle.Type=s.Type;
                    gsHandle.pMarkerSize=s.pMarkerSize;
                    gsHandle.pMarkerColor=s.pMarkerColor;
                    gsHandle.pShowLabel=s.pShowLabel;
                    gsHandle.pLabelFontSize=s.pLabelFontSize;
                    gsHandle.pLabelFontColor=s.pLabelFontColor;
                    gsHandle.ZoomHeight=s.ZoomHeight;
                    gsHandle.ColorConverter=s.ColorConverter;
                end
            end
        end
    end
end

