classdef AutoMNContainer<handle




    properties(Access=public)

        SourceImpedance double
        LoadImpedance double
        CenterFrequency double
        Q double
Topology

        CircuitNames(:,1)cell
        Circuits(:,1)circuit


        CircuitSParameters(:,1)cell


        PerformanceTestsFailed(:,1)cell

        Name(1,:)char='User-Created Circuits'
        MatchingNetworkObject(:,1)matchingnetwork
    end

    methods(Access=public)
        function this=AutoMNContainer(cktNames,ckts,sparams,failedtests,varargin)

            if(nargin==0)
                return;
            elseif(length(varargin)==1)
                this.Name=varargin{1};
            elseif(length(varargin)>=3)
                this.CenterFrequency=varargin{1};
                this.Q=varargin{2};
                this.Topology=varargin{3};
                this.Name=this.createNameFromMetadata();

                this.SourceImpedance=varargin{4};
                this.LoadImpedance=varargin{5};
                this.MatchingNetworkObject=copy(varargin{6});
            end


            this.CircuitNames=cktNames;
            this.Circuits=ckts;
            this.CircuitSParameters=sparams;
            this.PerformanceTestsFailed=failedtests;
        end


        function[names,sparams,circuits,failedtests,freq,loadedq,sourceZ,loadZ]=retrieveCircuits(this,circuitNames)
            temp=false(size(this.CircuitNames));
            for k=1:size(circuitNames,2)
                temp=temp|strcmpi(this.CircuitNames,circuitNames(k));
            end
            if any(temp)
                names=this.CircuitNames(temp);
                sparams=this.CircuitSParameters(temp);
                circuits=this.Circuits(temp);
                circuits=arrayfun(@(x)mat2cell(x,1),circuits);
                failedtests=this.PerformanceTestsFailed(temp);
                temp_size=[numel(contains(circuitNames,this.CircuitNames)),1];
                freq=repmat({this.CenterFrequency},temp_size);
                loadedq=repmat({this.Q},temp_size);
                sourceZ=repmat({this.SourceImpedance},temp_size);
                loadZ=repmat({this.LoadImpedance},temp_size);
            else
                names={};sparams={};circuits={};failedtests={};
                freq={};loadedq={};sourceZ={};loadZ={};
            end
        end

        function delete(this)

            this.CircuitSParameters={};
            delete(this.Circuits)
        end
    end

    methods(Access=protected)

        function name=createNameFromMetadata(this)
            [normFreq,~,prefix]=engunits(this.CenterFrequency);
            if(isnumeric(this.Topology)&&(this.Topology==3))
                name=['fc = ',num2str(normFreq),' ',prefix,'Hz; Q = ',num2str(this.Q),' ; Topology: ',num2str(this.Topology)];
            elseif strcmp(this.Topology,'L')||(isnumeric(this.Topology)&&(this.Topology==2))
                name=['fc = ',num2str(normFreq),' ',prefix,'Hz; Topology: L'];
            else
                name=['fc = ',num2str(normFreq),' ',prefix,'Hz; Q = ',num2str(this.Q),' ; Topology: ',this.Topology];
            end
        end
    end
end
