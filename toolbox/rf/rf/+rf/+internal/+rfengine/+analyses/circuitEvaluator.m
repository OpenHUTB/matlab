classdef circuitEvaluator<handle




    properties
        Circuit=[]
        Analysis=[]

        V=[]
        I=[]

        Time=[]
        Frequency=[]


        Fk=[]
        Fiv=[]
        Qiv=[]
        Uiv=[]


        Ji=[]
        Jv=[]
        Jqi=[]
        Jqv=[]

        G=[]
        C=[]

        Fiv_freq=[]
        Ji_freq=[]
        Jv_freq=[]
        G_freq=[]

        EvaluateCharge=true
        UseFullMatrices=false

        ConductanceToGround=[]
    end

    methods
        function self=circuitEvaluator(ckt,analysis)
            self.Circuit=ckt;
            self.Analysis=analysis;

            if isa(analysis,'rf.internal.rfengine.analyses.HB')
                self.ConductanceToGround=...
                analysis.Parameters.HbConductanceToGround;
            end


        end

        function timeDomainEvaluate(self,x,time,evaluateJacobian,beta)
            N=self.Circuit.NumNodes;
            B=self.Circuit.NumBranches;

            self.Time=time;
            self.I=x(1:B);
            if length(x)==N+B
                self.V=x(B+1:end);
            else
                self.V=[0;x(B+1:end)];
            end


            if isempty(self.Fiv)
                self.Fiv=zeros(B,1);
                self.Qiv=zeros(B,1);
                self.Uiv=zeros(B,1);
            end



            timeDomain=(1:length(self.Circuit.Elements));
            if evaluateJacobian
                if isempty(self.Jv)
                    if self.UseFullMatrices
                        self.Ji=zeros(B,B);
                        self.Jv=zeros(B,N);
                        self.Jqi=zeros(B,B);
                        self.Jqv=zeros(B,N);
                    else
                        self.Ji=spalloc(B,B,B);
                        self.Jv=spalloc(B,N,2*B);
                        self.Jqi=spalloc(B,B,B);
                        self.Jqv=spalloc(B,N,2*B);
                    end
                    for i=timeDomain
                        evalConstitutiveJandF(self.Circuit.Elements{i},self)
                    end
                else
                    for i=timeDomain
                        updateConstitutiveJandF(self.Circuit.Elements{i},self)
                    end
                end

...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...

                self.G=[self.Ji,self.Jv(:,2:end);self.Circuit.Jkiv];
                self.C=[self.Jqi,self.Jqv(:,2:end);sparse(N-1,N+B-1)];
            else
                for i=timeDomain
                    updateConstitutiveF(self.Circuit.Elements{i},self)
                end
            end


            if nargin<5
                beta=self.ConductanceToGround;
            end

            self.Fk=self.Circuit.Jk(2:end,:)*self.I+beta*self.V(2:end);

        end

        function freqDomainEvaluate(self,x,freq,evaluateJacobian)
            N=self.Circuit.NumNodes;
            B=self.Circuit.NumBranches;

            FreqDomain=[];

            self.I=x(1:B);
            self.Frequency=freq;




            self.V=[0;x(B+1:end)];




            if isempty(self.Fiv_freq)
                self.Fiv_freq=zeros(B,1);
            end

            if evaluateJacobian

                if isempty(self.Jv_freq)
                    if self.UseFullMatrices
                        self.Ji_freq=zeros(B,B);
                        self.Jv_freq=zeros(B,N);
                    else
                        self.Ji_freq=spalloc(B,B,B);
                        self.Jv_freq=spalloc(B,N,2*B);
                    end
                    for i=FreqDomain
                        evalConstitutiveJandF(self,self.Circuit.Elements(i));
                    end
                else
                    for i=FreqDomain
                        updateConstitutiveJandF(self,self.Circuit.Elements(i));
                    end
                end

                self.G_freq=[self.Ji_freq,self.Jv_freq(:,2:end);sparse(N-1,B+N-1)];
            else
                for i=FreqDomain
                    updateConstitutiveF(self,self.Circuit.Elements(i));
                end
            end

        end
    end
end
