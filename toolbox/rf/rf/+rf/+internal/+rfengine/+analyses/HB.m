

classdef HB<handle





    properties
        Circuit=[]
        Solution=[]
        Evaluator=[]
        DAE=[]
        Tones=[]
        NumHarmonics=[]

        Parameters=[]
        Transform=[]
        AllFreqs=[]
        UniqueFreqs=[]
    end

    methods
        function self=HB(ckt,varargin)
            if nargin>0
                self.Circuit=ckt;
                self.Circuit.HB=self;

                for k=1:2:length(varargin)
                    self.Tones(end+1)=...
                    rf.internal.rfengine.Circuit.spice2double(varargin{k});
                    self.NumHarmonics(end+1)=...
                    rf.internal.rfengine.Circuit.spice2double(varargin{k+1});
                end

                self.Transform=...
                rf.internal.rfengine.rfsolver.MappedFFT(self.NumHarmonics);
                self.AllFreqs=freqs(self.Transform,self.Tones);
                tol=1e-12;
                self.UniqueFreqs=uniquetol(abs(self.AllFreqs),tol);
            end
        end

        function[result,data,success]=...
            Execute(self,params,sp,additionalLocalSolverParams)
            self.Parameters=params;

            fprintf(self,'Harmonic Balance begins...\n');

            ckt=self.Circuit;
            if isa(ckt,'rf.internal.rfengine.Circuit')
                beta=params.HbConductanceToGround;
                computeGlobalConnectivity(ckt,beta);
                self.DAE=...
                rf.internal.rfengine.analyses.circuitAdapter(ckt,self);
                self.Evaluator=...
                rf.internal.rfengine.analyses.circuitEvaluator(ckt,self);
            elseif isa(ckt,'NetworkEngine.SolverSystem')
                self.DAE=ckt;
            else
                error('unknown type')
            end

            if~isempty(ckt.AS)
                resampleSParameters(ckt.AS,self)
            end
            if~isempty(ckt.A1)
                resampleSParameters(ckt.A1,self)
            end
            if~isempty(ckt.A3)
                resampleSParameters(ckt.A3,self)
            end

            N=ckt.NumNodes;
            B=ckt.NumBranches;
            self.Evaluator.I=zeros(B,1);
            self.Evaluator.V=zeros(N,1);

            if nargin<3
                sp=[];
                sp.UseLocalSolver=false;
                sp.LocalSolverChoice='NE_NDF2_ADVANCER';
                sp.DoFixedCost=false;
                sp.LocalSolverSampleTime=1e-6;


                RelTol=double(params.RelTol);
                AbsTol=double(params.AbsTol);
                MaxIter=int32(10);






                ErrorEstimationType=int32(2);
                SmallSignalApprox=logical(false);
                AllSimFreqs=logical(true);
                SimFreqsInternal=double([]);
                additionalLocalSolverParams=struct(...
                'RelTol',RelTol,...
                'AbsTol',AbsTol,...
                'MaxIter',MaxIter,...
                'ErrorEstimationType',ErrorEstimationType,...
                'SmallSignalApprox',SmallSignalApprox,...
                'AllSimFreqs',AllSimFreqs,...
                'SimFreqs',SimFreqsInternal);
            end


            id=struct(...
            'PseudoPeriodic',false,...
            'Frequencies',[],...
            'NoiseDistribution',int32(1),...
            'NoiseParameters',[]);
            od=struct('PseudoPeriodic',false,'Frequencies',[]);
            inputData=repmat({id},self.DAE.NumInputs,1);

            numOutputs=1;
            outputData=repmat({od},numOutputs,1);

            nU=0;
            for k=1:length(ckt.SourceElements)
                ev=ckt.SourceElements{k};
                if isa(ev,'rf.internal.rfengine.elements.Vsin')
                    for i=1:size(ev.Nodes,2)
                        nU=nU+1;
                        inputData{nU}.PseudoPeriodic=true;
                        inputData{nU}.NoiseDistribution=int32(1);
                        inputData{nU}.Frequencies=double(ev.Frequency(i));
                    end
                elseif isa(ev,'rf.internal.rfengine.elements.AV')||...
                    isa(ev,'rf.internal.rfengine.elements.AI')
                    for i=1:size(ev.Nodes,2)
                        nU=nU+1;
                        inputData{nU}.PseudoPeriodic=false;
                        inputData{nU}.Frequencies=[];
                        if isscalar(ev.Variance{i})
                            inputData{nU}.NoiseDistribution=int32(2);
                            inputData{nU}.NoiseParameters=ev.Variance{i};
                        else
                            inputData{nU}.NoiseDistribution=int32(3);



                            v=ev.Variance{i};
                            freqs=v(1:length(v)/2);
                            vals=v(length(v)/2+1:end);
                            [freqs,idx]=sort(freqs);
                            vals=vals(idx);
                            if freqs(1)~=0
                                freqs=[0,freqs];%#ok<AGROW>
                                vals=[vals(1),vals];%#ok<AGROW>
                            end
                            inputData{nU}.NoiseParameters=[freqs,vals];
                        end
                    end
                end
            end

            for k=1:numOutputs
                outputData{k}.PseudoPeriodic=true;
                outputData{k}.Frequencies=self.UniqueFreqs;
            end

            sepStream=false;
            noiseSeed=0;
            data=rf.internal.rfengine.rfsolver.MainDae(...
            'DATA',self.DAE,sp,[],self.Tones,...
            self.NumHarmonics,additionalLocalSolverParams,...
            ~isempty(ckt.AI),sepStream,noiseSeed,inputData,outputData);
            numOutputs=NumOutputs(self.DAE);
            data.OutputMap.daeUYindex=...
            reshape(data.OutputMap.daeUYindex.*(1:numOutputs),[],1);
            data.OutputMap.isReal=...
            reshape(data.OutputMap.isReal.*ones(1,numOutputs),[],1);
            data.OutputMap.isTimeDomain=...
            reshape(data.OutputMap.isTimeDomain.*ones(1,numOutputs),[],1);
            data.OutputMap.freqIndex=...
            reshape(repmat(data.OutputMap.freqIndex,1,numOutputs),[],1);
            data.OutputMap.isSameSign=...
            reshape(repmat(data.OutputMap.isSameSign,1,numOutputs),[],1);
            data.nY=data.nY*numOutputs;
            data.D=zeros(numOutputs,nU);




            per_state=2*data.nFreqs-1;
            num_history_states=2;
            res=data.solver.nSavedStates+...
            (data.dae.NumInputs+data.solver.NumStates)*...
            per_state+num_history_states;
            in=inputs(self.DAE);

            iqs=[];
            for k=1:length(ckt.SourceElements)
                ev=ckt.SourceElements{k};
                switch class(ev)
                case 'rf.internal.rfengine.elements.Vsin'
                    temp=[ev.Amplitude.*sin((pi/180).*ev.PhaseDelay);
                    -ev.Amplitude.*cos((pi/180).*ev.PhaseDelay)];
                    iqs=[iqs;temp(:)];%#ok<AGROW>
                case 'rf.internal.rfengine.elements.AV'
                    iqs=[iqs;ones(size(ev.Nodes,2),1)];%#ok<AGROW>
                case 'rf.internal.rfengine.elements.AI'
                    iqs=[iqs;ones(size(ev.Nodes,2),1)];%#ok<AGROW>
                otherwise
                    error('how did I get here?')
                end
            end

            in.U=iqs;
            in.D=zeros(res,1);


            result=...
            rf.internal.rfengine.rfsolver.MainDae('SOLVE',data,'IC_MODE',in);

            data.D=zeros(numOutputs,nU);
            y=rf.internal.rfengine.rfsolver.MainDae('METHOD',data,'Y',result);


            Ytri=reshape(y,[],numOutputs);
            Y=(Ytri(1:end/2,:)+1j*Ytri(end/2+1:end,:)).';

            self.Solution=...
            rf.internal.rfengine.analyses.solution(ckt,Y,self.UniqueFreqs);
            success=true;
            fprintf(self,'Harmonic Balance converged\n\n');
        end

        function fprintf(self,varargin)
            if self.Parameters.HbVerbose
                fprintf(varargin{:});
            end
        end
    end
end
