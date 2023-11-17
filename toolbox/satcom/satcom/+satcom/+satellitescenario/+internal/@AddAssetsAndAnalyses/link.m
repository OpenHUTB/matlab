function outputLnk=link(source,varargin)

%#codegen

    coder.allowpcode('plain');

    narginchk(2,inf);

    if coder.target('MATLAB')
        validateattributes(source,...
        {'satcom.satellitescenario.Transmitter'},...
        {'nonempty','vector'},'link','ASSET1',1);
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
        {'satcom.satellitescenario.Transmitter'},...
        {'nonempty','scalar'},'link','ASSET1',1);
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



    numLnk=numel(source);


    simulator=source{1}.Simulator;


    coder.internal.errorIf(simulator.SimulationMode==1&&simulator.SimulationStatus~=0,...
    'shared_orbit:orbitPropagator:UnableAddAssetOrAnalysisIncorrectSimStatus',...
    'link');

    for idx1=1:numel(nodes)

        node=nodes{idx1};


        if idx1~=numel(nodes)
            expNodeType={'satcom.satellitescenario.Transmitter',...
            'satcom.satellitescenario.Receiver'};
        else
            expNodeType={'satcom.satellitescenario.Receiver'};
        end

        if coder.target('MATLAB')
            validateattributes(node,...
            expNodeType,...
            {'nonempty','vector'},'link',...
            ['ASSET',sprintf('%.0f',(idx1+1))],idx1+1);
        else
            validateattributes(node,...
            expNodeType,...
            {'nonempty','scalar'},'link',...
            ['ASSET',sprintf('%.0f',(idx1+1))],idx1+1);
        end






        if numLnk==1




            if~isscalar(node)
                numLnk=numel(node);
            end
        else


            numelNode=numel(node);
            nodePosition=idx1+1;
            msg='shared_orbit:orbitPropagator:LinkNodeSizeMismatch';
            coder.internal.errorIf(~isscalar(node)&&(numLnk~=numelNode),msg,nodePosition,numelNode,numLnk);
        end

        if simulator.NumLinks==0
            simulator.Links=repmat(simulator.LinkStruct,1,numLnk);
        else
            newLinkStruct=repmat(simulator.LinkStruct,1,numLnk);
            simulator.Links=[simulator.Links,newLinkStruct];
        end
        if coder.target('MATLAB')
            node=node.Handles;
            for idx2=1:numel(node)

                if~isvalid(node{idx2})
                    msg=message(...
                    'shared_orbit:orbitPropagator:SatelliteScenarioInvalidObject',...
                    "ASSET"+(idx2+1));
                    error(msg);
                end



                if~isequal(node{idx2}.Simulator,simulator)
                    msg='shared_orbit:orbitPropagator:SatelliteScenarioLinkDifferentScenario';
                    error(message(msg));
                end
            end
        end
    end

    if coder.target('MATLAB')

        outputLnk=satcom.satellitescenario.Link;
        handles=cell(1,numLnk);
        outputLnk.Handles=handles;


        for idx=1:numLnk

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


            lnk=satcom.satellitescenario.Link(formattedSource,formattedNodes{:});


            existingLinks=formattedSource.Links;


            if isempty(existingLinks)||~formattedSource.pLinksAddedBefore
                formattedSource.Links=lnk;
                formattedSource.pLinksAddedBefore=true;
            else
                formattedSource.Links=[existingLinks,lnk];
            end


            outputLnk.Handles{idx}=lnk.Handles{1};
        end
    else
        outputLnk=satcom.satellitescenario.Link(source,nodes{:});


        existingLnk=source.Links;


        if isempty(existingLnk)||~source.pLinksAddedBefore
            source.Links=existingLnk;
            source.pLinksAddedBefore=true;
        else
            source.Links=[existingLnk,outputLnk];
        end
    end



    simulator.NeedToSimulate=true;
    if coder.target('MATLAB')&&isa(source{1}.Scenario,'satelliteScenario')
        scenario=source{1}.Scenario;
        scenario.NeedToSimulate=true;


        scenario.addToScenarioGraphics(outputLnk);


        for idx=1:numLnk
            scenario.Links{end+1}=outputLnk(idx);
        end
    end



    advance(simulator,simulator.Time);

    if coder.target('MATLAB')

        showIfAutoShow(outputLnk,source{1}.Scenario,viewer);
    end
end


