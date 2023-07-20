classdef circuitAdapter<handle





    properties
Circuit
Analysis
        Jpattern=[]
        NumStates=[]
        NumInputs=[]
        JRows=[]
        JCols=[]
        JQpattern=[]
        JUpattern=[]

        IsDae=true
        IsYLinear=true
        InputOrder=1
        IsDyAnalytic=true
EquationData
VariableData
    end

    methods
        function self=circuitAdapter(ckt,analysis)
            self.Circuit=ckt;
            self.Analysis=analysis;

            N=ckt.NumNodes;
            B=ckt.NumBranches;
            self.NumStates=B+N-1;
            eqOut=cell(1,self.NumStates);
            varOut=zeros(1,self.NumStates);
            if~isempty(ckt.AT)
                arNodes=ckt.AT.Nodes(1,:);
                aiNodes=ckt.AT.Nodes(4,:);
                brBranches=ckt.AT.Branches(1:2:end);
                biBranches=ckt.AT.Branches(2:2:end);
                for k=1:B
                    if ismember(k,brBranches)
                        eqOut{k}='FREQUENCY_REAL';
                        varOut(k)=1;
                    elseif ismember(k,biBranches)
                        eqOut{k}='FREQUENCY_IMAG';
                    else
                        eqOut{k}='TIME';
                        varOut(k)=1;
                    end
                end
                for k=2:N
                    [isMemb,membInd]=ismember(k,aiNodes);
                    if isMemb
                        eqOut{k-1+B}='COMPLEX';
                        complexEq=zeros(1,self.NumStates);
                        complexEq(arNodes(membInd)-1+B)=1;
                        complexEq(aiNodes(membInd)-1+B)=2;
                        complexEq(brBranches(membInd))=3;
                        complexEq(biBranches(membInd))=4;
                        self.Circuit.Jkiv(k-1,:)=complexEq;
                    else
                        eqOut{k-1+B}='TIME';
                        varOut(k-1+B)=1;
                    end
                end
            else
                for k=1:numel(eqOut)
                    eqOut{k}='TIME';
                    varOut(k)=1;
                end
            end

            self.EquationData.domain=eqOut;
            self.VariableData.time=varOut;



            Ji=logical(sparse(B,B));
            Jv=logical(sparse(B,N));
            Jqi=Ji;
            Jqv=Jv;
            for k=1:length(ckt.Elements)
                ev=ckt.Elements{k};

                for i=1:size(ev.Nodes,2)
                    Ji(ev.IndicesJi)=true;
                    Jv(ev.IndicesJv)=true;
                    Jqi(ev.IndicesJqi)=true;
                    Jqv(ev.IndicesJqv)=true;
                end
            end
            G=[Ji,Jv(:,2:end);logical(ckt.Jkiv~=0)];
            C=[Jqi,Jqv(:,2:end);logical(sparse(N-1,self.NumStates))];
            self.Jpattern=G;
            [self.JRows,self.JCols]=find(G);
            self.JQpattern=C;


            n=0;
            i=[];
            for k=1:length(ckt.SourceElements)
                ev=ckt.SourceElements{k};
                nev=size(ev.Nodes,2);
                n=n+nev;
                i=[i;ev.Branches'];%#ok<AGROW>
            end
            self.NumInputs=n;
            s=true(self.NumInputs,1);
            j=(1:self.NumInputs).';
            self.JUpattern=sparse(i,j,s,self.NumStates,self.NumInputs);
        end
    end

    methods(Access=private)
        function timeDomainEvaluateU(self,x,time,u,evaluateJacobian)
            timeDomainEvaluate(self.Analysis.Evaluator,x,time,evaluateJacobian)
            self.Analysis.Evaluator.Uiv(:)=0;
            idx=0;
            for k=1:length(self.Circuit.SourceElements)
                ev=self.Circuit.SourceElements{k};
                for i=1:size(ev.Nodes,2)
                    idx=idx+1;
                    self.Analysis.Evaluator.Uiv(ev.Branches(i))=u(idx);
                end
            end
        end
    end

    methods
        function[tones,branches,amplitudes,phases]=sourceData(self)


            tones=[];
            branches=[];
            amplitudes=[];
            phases=[];
            for k=1:length(self.Circuit.SourceElements)
                ev=self.Circuit.SourceElements{k};

                tones=[tones,ev.Frequency];%#ok<AGROW>

                branches=[branches,ev.Branches];%#ok<AGROW>
                amplitudes=[amplitudes,ev.Amplitude];%#ok<AGROW>
                phases=[phases,ev.PhaseDelay];%#ok<AGROW>
            end
            tones=tones.';
            branches=branches.';
            amplitudes=amplitudes.';
            phases=phases.';

        end

        function n=NumOutputs(self)
            n=self.NumStates;

        end

        function n=NumModes(self)%#ok<MANU>
            n=0;

        end



        function flag=IsMConstant(self)%#ok<MANU>
            flag=true;

        end


        function in=inputs(self)
            in.T=0;

            in.X=zeros(self.Circuit.NumNodes+self.Circuit.NumBranches-1,1);
            in.U=zeros(self.NumInputs,1);


            in.Q=[];
            in.E=[];
            in.CR=[];
            in.CI=[];
            in.D=[];

        end

        function values=Y(self,inputs)%#ok<INUSL>
            values=inputs.X;

        end

        function values=MODE(self,inputs)%#ok<INUSD>
            values=[];

        end

        function values=DTF(self,inputs)%#ok<INUSD>
            n=self.NumStates;
            values=false(n,1);

        end

        function pattern=DTF_P(self,inputs)%#ok<INUSD>
            n=self.NumStates;
            pattern=ones(n,1);

        end

        function values=DXF(self,inputs)

            pattern=DXF_P(self,inputs);
            timeDomainEvaluateU(self,inputs.X,inputs.T,inputs.U,true);
            values=-self.Analysis.Evaluator.G(pattern);

        end

        function pattern=DXF_P(self,~)
            pattern=self.Jpattern;

        end

        function[Jvalues,Fvalues]=DXFandF(self,inputs)
            timeDomainEvaluateU(self,inputs.X,inputs.T,inputs.U,true);
            Jvalues=self.Analysis.Evaluator.G(self.Jpattern);
            Fvalues=[...
            self.Analysis.Evaluator.Fiv-self.Analysis.Evaluator.Uiv;...
            self.Analysis.Evaluator.Fk];
        end

        function values=DUF(self,inputs)%#ok<INUSD>
            values=ones(self.NumInputs,1);

        end

        function pattern=DUF_P(self,inputs)%#ok<INUSD>
            pattern=self.JUpattern;

        end

        function values=F(self,inputs)

            timeDomainEvaluateU(self,inputs.X,inputs.T,inputs.U,false);
            values=[...
            -self.Analysis.Evaluator.Fiv+self.Analysis.Evaluator.Uiv;...
            -self.Analysis.Evaluator.Fk];

        end

        function pattern=M_P(self,~)

            pattern=self.JQpattern;

        end

        function values=DXF_V_X(self,inputs)%#ok<INUSD>
            values=true(self.NumStates,1);

        end

        function values=DUF_V_X(self,inputs)%#ok<INUSD>
            values=true(self.NumStates,1);

        end

        function values=M(self,inputs)

            pattern=M_P(self);

            timeDomainEvaluateU(self,inputs.X,inputs.T,inputs.U,true);
            values=self.Analysis.Evaluator.C(pattern);

        end

        function values=DXY(self,inputs)%#ok<INUSD>
            values=nonzeros(self.VariableData.time).';

        end

        function pattern=DXY_P(self,inputs)%#ok<INUSD>
            pattern=logical(spdiags(self.VariableData.time.',...
            0,self.NumStates,self.NumStates));

        end

        function values=DUY(self,inputs)%#ok<INUSD>
            values=[];

        end

        function pattern=DUY_P(self,inputs)%#ok<INUSD>
            pattern=[];

        end
    end
end
