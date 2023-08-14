classdef Transmitter<satcom.satellitescenario.internal.CommDeviceWrapper %#codegen




    properties(Dependent,SetAccess=protected)


















Name
    end

    properties(Dependent)
















Frequency
















BitRate
















Power
    end

    properties(Dependent,SetAccess={?satcom.satellitescenario.internal.Link,...
        ?satcom.satellitescenario.Link,...
        ?satcom.satellitescenario.internal.AddAssetsAndAnalyses,...
        ?satcom.satellitescenario.internal.Transmitter,...
        ?satcom.satellitescenario.Transmitter,...
        ?matlabshared.satellitescenario.internal.ObjectArray,...
        ?matlabshared.satellitescenario.coder.internal.ObjectArrayCG})


Links
    end

    properties(Dependent,Access={?satcom.satellitescenario.internal.AddAssetsAndAnalyses})
pLinksAddedBefore
    end

    methods(Access={?satelliteScenario,...
        ?matlabshared.satellitescenario.internal.ObjectArray,...
        ?matlabshared.satellitescenario.coder.internal.ObjectArrayCG,...
        ?matlabshared.satellitescenario.internal.Asset,...
        ?matlabshared.satellitescenario.internal.AddAssetsAndAnalyses,...
        ?satcom.satellitescenario.internal.AddAssetsAndAnalyses,...
        ?matlabshared.satellitescenario.ScenarioGraphic})
        function tx=Transmitter(varargin)


            coder.allowpcode('plain');


            if~coder.target('MATLAB')
                tx.Handles={satcom.satellitescenario.internal.Transmitter};
                tx.Handles=cell(1,0);
            else
                tx.Handles=cell(1,0);
            end

            if nargin~=0


                handles={satcom.satellitescenario.internal.Transmitter(...
                varargin{:})};


                tx.Handles=handles;
            end
        end
    end

    methods
        function name=get.Name(tx)


            coder.allowpcode('plain');

            if~coder.target('MATLAB')
                validateattributes(tx,...
                {'satcom.satellitescenario.Transmitter'},...
                {'scalar'},'get.Name','TX');
                name=tx.Handles{1}.Name;
                return
            end

            handles=[tx.Handles{:}];

            if isempty(handles)
                name=string.empty;
            else
                name=[handles.Name];
            end
        end

        function f=get.Frequency(tx)


            coder.allowpcode('plain');

            if~coder.target('MATLAB')

                numAssets=numel(tx.Handles);


                f=zeros(1,numAssets);


                for idx=1:numAssets
                    f(idx)=tx.Handles{idx}.Frequency;
                end

                return
            end

            handles=[tx.Handles{:}];

            if isempty(handles)
                f=[];
            else
                f=[handles.Frequency];
            end
        end

        function tx=set.Frequency(tx,f)


            coder.allowpcode('plain');

            if~coder.target('MATLAB')
                msg='shared_orbit:orbitPropagator:UnsupportedPropertySetCodegen';
                coder.internal.error(msg,'Frequency','satcom.satellitescenario.Transmitter');
            end

            handles=[tx.Handles{:}];
            for idx=1:numel(handles)
                handles(idx).Frequency=f;
            end
        end

        function br=get.BitRate(tx)


            coder.allowpcode('plain');

            if~coder.target('MATLAB')

                numAssets=numel(tx.Handles);


                br=zeros(1,numAssets);


                for idx=1:numAssets
                    br(idx)=tx.Handles{idx}.BitRate;
                end

                return
            end

            handles=[tx.Handles{:}];

            if isempty(handles)
                br=[];
            else
                br=[handles.BitRate];
            end
        end

        function tx=set.BitRate(tx,br)


            coder.allowpcode('plain');

            if~coder.target('MATLAB')
                msg='shared_orbit:orbitPropagator:UnsupportedPropertySetCodegen';
                coder.internal.error(msg,'BitRate','satcom.satellitescenario.Transmitter');
            end

            handles=[tx.Handles{:}];
            for idx=1:numel(handles)
                handles(idx).BitRate=br;
            end
        end

        function p=get.Power(tx)


            coder.allowpcode('plain');

            if~coder.target('MATLAB')

                numAssets=numel(tx.Handles);


                p=zeros(1,numAssets);


                for idx=1:numAssets
                    p(idx)=tx.Handles{idx}.Power;
                end

                return
            end

            handles=[tx.Handles{:}];

            if isempty(handles)
                p=[];
            else
                p=[handles.Power];
            end
        end

        function tx=set.Power(tx,p)


            coder.allowpcode('plain');

            if~coder.target('MATLAB')
                msg='shared_orbit:orbitPropagator:UnsupportedPropertySetCodegen';
                coder.internal.error(msg,'Power','satcom.satellitescenario.Transmitter');
            end

            handles=[tx.Handles{:}];
            for idx=1:numel(handles)
                handles(idx).Power=p;
            end
        end

        function lnk=get.Links(tx)


            coder.allowpcode('plain');

            if~coder.target('MATLAB')
                validateattributes(tx,...
                {'satcom.satellitescenario.Transmitter'},...
                {'scalar'},'get.Links','TX');
                lnk=tx.Handles{1}.Links;
                return
            end

            handles=[tx.Handles{:}];

            if isempty(handles)
                lnk=satcom.satellitescenario.Link;
            else
                lnk=[handles.Links];
            end
        end

        function tx=set.Links(tx,lnk)


            coder.allowpcode('plain');

            if~coder.target('MATLAB')
                tx.Handles{1}.Links=lnk;
                return
            end

            handles=[tx.Handles{:}];
            handles.Links=lnk;
        end

        function tf=get.pLinksAddedBefore(tx)


            coder.allowpcode('plain');

            if~coder.target('MATLAB')
                tf=tx.Handles{1}.pLinksAddedBefore;
                return
            end

            handles=[tx.Handles{:}];

            if isempty(handles)
                tf=false(0,0);
            else
                tf=[handles.pLinksAddedBefore];
            end
        end

        function tx=set.pLinksAddedBefore(tx,tf)


            coder.allowpcode('plain');

            if~coder.target('MATLAB')
                tx.Handles{1}.pLinksAddedBefore=tf;
                return
            end

            handles=[tx.Handles{:}];
            handles.pLinksAddedBefore=tf;
        end
    end

    methods
        lnk=link(source,varargin)
        pat=pattern(tx,varargin)
    end

    methods(Hidden)
        disp(tx)
    end

    methods(Hidden,Static)
        function tx=loadobj(s)


            coder.allowpcode('plain');

            if isa(s,'matlabshared.satellitescenario.internal.ObjectArray')


                tx=s;
            else





                tx=satcom.satellitescenario.Transmitter;

                if isfield(s,'Handles')


                    tx.Handles=s.Handles;
                else





                    txHandle=satcom.satellitescenario.internal.Transmitter;
                    tx.Handles={txHandle};

                    if isa(s.Links,'double')




                        txHandle.Links=satcom.satellitescenario.Link;
                    else






                        handles=[s.Links.Handles];
                        if~isempty(handles)
                            txHandle.pLinksAddedBefore=true;
                            handles=reshape(handles,1,[]);
                        end


                        for idx=1:numel(handles)
                            handles{idx}.Parent=tx;
                        end



                        lnk=satcom.satellitescenario.Link;
                        lnk.Handles=handles;



                        txHandle.Links=lnk;
                    end


                    txHandle.Antenna=s.Antenna;
                    txHandle.ParentSimulatorID=s.ParentSimulatorID;
                    txHandle.ParentType=s.ParentType;
                    txHandle.Graphic=s.Graphic;
                    txHandle.pMarkerColor=s.pMarkerColor;
                    txHandle.pName=s.pName;
                    txHandle.Simulator=s.Simulator;
                    txHandle.SimulatorID=s.SimulatorID;
                    txHandle.Type=s.Type;
                    txHandle.VisibilityMode=s.VisibilityMode;
                    txHandle.pMarkerSize=s.pMarkerSize;
                    txHandle.ZoomHeight=s.ZoomHeight;
                    txHandle.ColorConverter=s.ColorConverter;

                    if~isempty(s.Parent)



                        txHandle.Parent=s.Parent;
                        s.Parent.Transmitters=[s.Parent.Transmitters,tx];



                        ids=s.Parent.Transmitters.ID;
                        [~,sortIdx]=sort(ids);
                        s.Parent.Transmitters=s.Parent.Transmitters(sortIdx);
                    end
                end
            end
        end
    end
end

