function outputAc=access(source,varargin)%#codegen




    coder.allowpcode('plain');


    narginchk(2,inf);


    if coder.target('MATLAB')
        validateattributes(source,...
        {'matlabshared.satellitescenario.Satellite','matlabshared.satellitescenario.GroundStation',...
        'matlabshared.satellitescenario.ConicalSensor'},...
        {'nonempty','vector'},'access','ASSET1',1);
        source=source.Handles;
        for idx=1:numel(source)
            if~isvalid(source{idx})
                msg=message(...
                'shared_orbit:orbitPropagator:SatelliteScenarioInvalidObject',...
                'ASSET1');
                error(msg);
            end
        end
    else
        validateattributes(source,...
        {'matlabshared.satellitescenario.Satellite','matlabshared.satellitescenario.GroundStation',...
        'matlabshared.satellitescenario.ConicalSensor'},...
        {'nonempty','scalar'},'access','ASSET1',1);
        source=source.Handles;
    end


    if coder.target('MATLAB')
        if numel(varargin)>2&&strcmpi(varargin{end-1},"Viewer")




            viewer=varargin{end};


            matlabshared.satellitescenario.ScenarioGraphic.validateViewerScenario(viewer,source{1}.Scenario);
            if sum(~isvalid(viewer))>0
                msg=message(...
                'shared_orbit:orbitPropagator:SatelliteScenarioInvalidObject',...
                'Viewer');
                error(msg);
            end



            nodes=varargin(1:end-2);
        else



            if isa(source{1}.Scenario,'satelliteScenario')
                viewer=source{1}.Scenario.Viewers;
            else
                viewer=matlabshared.satellitescenario.Viewer.empty;
            end


            nodes=varargin;
        end
    else

        nodes=varargin;
    end



    numAc=numel(source);


    simulator=source{1}.Simulator;


    coder.internal.errorIf(simulator.SimulationMode==1&&simulator.SimulationStatus~=0,...
    'shared_orbit:orbitPropagator:UnableAddAssetOrAnalysisIncorrectSimStatus',...
    'access analysis');


    for idx1=1:numel(nodes)

        node=nodes{idx1};


        if coder.target('MATLAB')
            validateattributes(node,...
            {'matlabshared.satellitescenario.Satellite','matlabshared.satellitescenario.GroundStation',...
            'matlabshared.satellitescenario.ConicalSensor'},...
            {'nonempty','vector'},'access',...
            ['ASSET',sprintf('%.0f',(idx1+1))],idx1+1);
        else
            validateattributes(node,...
            {'matlabshared.satellitescenario.internal.Satellite','matlabshared.satellitescenario.internal.GroundStation',...
            'matlabshared.satellitescenario.internal.ConicalSensor'},...
            {'nonempty','scalar'},'access',...
            ['ASSET',sprintf('%.0f',(idx1+1))],idx1+1);
        end
        node=node.Handles;






        if numAc==1




            if~isscalar(node)
                numAc=numel(node);
            end
        else


            numelNode=numel(node);
            nodePosition=idx1+1;
            msg='shared_orbit:orbitPropagator:AccessNodeSizeMismatch';
            coder.internal.errorIf(~isscalar(node)&&(numAc~=numelNode),msg,nodePosition,numelNode,numAc);
        end

        if coder.target('MATLAB')
            for idx2=1:numel(node)

                if~isvalid(node{idx2})
                    msg=message(...
                    'shared_orbit:orbitPropagator:SatelliteScenarioInvalidObject',...
                    "ASSET"+(idx2+1));
                    error(msg);
                end



                if~isequal(node{idx2}.Simulator,simulator)
                    msg='shared_orbit:orbitPropagator:SatelliteScenarioAccessDifferentScenario';
                    error(message(msg));
                end
            end
        end
    end


    if simulator.NumAccesses==0
        simulator.Accesses=repmat(simulator.AccessStruct,1,numAc);
    else
        newAccessStruct=repmat(simulator.AccessStruct,1,numAc);
        simulator.Accesses=[simulator.Accesses,newAccessStruct];
    end

    if coder.target('MATLAB')

        outputAc=matlabshared.satellitescenario.Access;
        outputAc.Handles=cell(1,numAc);

        for idx=1:numAc

            if isscalar(source)
                formattedSource=source{1};
            else
                formattedSource=source{idx};
            end


            formattedNodes=cell(1,numel(nodes));
            for idx2=1:numel(nodes)
                node=nodes{idx2}.Handles;
                if isscalar(node)
                    formattedNodes{idx2}=node{1};
                else
                    formattedNodes{idx2}=node{idx};
                end
            end


            acs=matlabshared.satellitescenario.Access(formattedSource,formattedNodes{:});


            existingAc=formattedSource.Accesses;


            if isempty(existingAc)||~formattedSource.pAccessesAddedBefore
                formattedSource.Accesses=acs;
                formattedSource.pAccessesAddedBefore=true;
            else
                formattedSource.Accesses=[existingAc,acs];
            end


            outputAc.Handles{idx}=acs.Handles{1};
        end
    else
        outputAc=matlabshared.satellitescenario.Access(source,nodes{:});


        existingAc=source.Accesses;


        if isempty(existingAc)||~source.pAccessesAddedBefore
            source.Accesses=existingAc;
            source.pAccessesAddedBefore=true;
        else
            source.Accesses=[existingAc,outputAc];
        end
    end



    simulator.NeedToSimulate=true;
    if coder.target('MATLAB')&&isa(source{1}.Scenario,'satelliteScenario')
        scenario=source{1}.Scenario;
        scenario.NeedToSimulate=true;


        scenario.addToScenarioGraphics(outputAc);


        for idx=1:numAc
            scenario.Accesses{end+1}=outputAc(idx);
        end
    end



    advance(simulator,simulator.Time);

    if coder.target('MATLAB')

        showIfAutoShow(outputAc,source{1}.Scenario,viewer);
    end
end


