classdef AA<rf.internal.rfengine.elements.Elements





    properties(Constant)
        BranchNodeIndices=[3;4]
        ControlNodeIndices=[1;2]
    end

    properties
        GAIN=[]
        OIP2=[]
        OIP3=[]
        ZIN=[]
        ZOUT=[]
        ControlNodes=[]
    end



    properties(Hidden,Constant)
        DefaultGAIN=amplifier.DefaultGain
        DefaultOIP2=amplifier.DefaultOIP2
        DefaultOIP3=amplifier.DefaultOIP3
        DefaultZIN=amplifier.DefaultZin
        DefaultZOUT=amplifier.DefaultZout
    end

    properties(Access=private)
outB
inP
inM
outP
outM
dOutBdOutP
dOutBdOutM
dOutBdInP
dOutBdInM

c1
c2
c3
vInMin
vInMax
idx
idxSat
    end

    methods(Access=private)
        function self=AA(ckt,label,n1,n2,n3,n4)
            self@rf.internal.rfengine.elements.Elements(ckt,label,n1,n2,n3,n4);
        end
    end

    methods(Static)
        function add(ckt,label,n1,n2,n3,n4,varargin)
            if isempty(ckt.AA)
                ckt.AA=rf.internal.rfengine.elements.AA(ckt,label,n1,n2,n3,n4);
            else
                addElement(ckt.AA,ckt,label,n1,n2,n3,n4)
            end
            ckt.AA.GAIN(end+1)=ckt.AA.DefaultGAIN;
            ckt.AA.OIP2(end+1)=ckt.AA.DefaultOIP2;
            ckt.AA.OIP3(end+1)=ckt.AA.DefaultOIP3;
            ckt.AA.ZIN(end+1)=ckt.AA.DefaultZIN;
            ckt.AA.ZOUT(end+1)=ckt.AA.DefaultZOUT;
            for k=1:length(varargin)
                i=strfind(varargin{k},'=');
                ckt.AA.(upper(varargin{k}(1:i-1)))(end)=...
                rf.internal.rfengine.Circuit.spice2double(varargin{k}(i+1:end));
            end
        end
    end

    methods
        function initializeIndices(self,ckt)
            self.IndicesJk=...
            self.BranchNodes+(self.Branches-1)*ckt.NumNodes;

            self.IndicesJi=[];

            self.ControlNodes=self.Nodes(self.ControlNodeIndices,:);

            self.outB=self.Branches;
            self.inP=self.ControlNodes(1,:);
            self.inM=self.ControlNodes(2,:);
            self.outP=self.BranchNodes(1,:);
            self.outM=self.BranchNodes(2,:);

            self.dOutBdOutP=self.outB+(self.outP-1)*ckt.NumBranches;
            self.dOutBdOutM=self.outB+(self.outM-1)*ckt.NumBranches;
            self.dOutBdInP=self.outB+(self.inP-1)*ckt.NumBranches;
            self.dOutBdInM=self.outB+(self.inM-1)*ckt.NumBranches;

            self.IndicesJv=[...
            self.dOutBdOutP
            self.dOutBdOutM
            self.dOutBdInP
            self.dOutBdInM
            ];
        end

        function evalConstitutiveJandF(self,evaluator)

            self.c1=2*10.^(self.GAIN.'/20).*...
            sqrt(real(self.ZOUT.').*real(self.ZIN.'))./abs(self.ZIN.');
            self.c2=self.c1.^2./...
            sqrt(4*real(self.ZOUT.').*10.^((self.OIP2.'-30)/10));
            self.c3=-(1/3)*self.c1.^3./...
            (real(self.ZOUT.').*10.^((self.OIP3.'-30)/10));

            c3tilde=3/4*self.c3;
            d=self.c2.^2-3*self.c1.*c3tilde;
            x1=(-self.c2+sqrt(d))./(3*c3tilde);
            x2=(-self.c2-sqrt(d))./(3*c3tilde);
            self.vInMin=min(x1,x2);
            self.vInMax=max(x1,x2);
            self.idx=(d>0)&(abs(c3tilde)>eps);

            updateConstitutiveJandF(self,evaluator)

            evaluator.Jv(self.dOutBdOutP)=-1;
            evaluator.Jv(self.dOutBdOutM)=1;
        end

        function updateConstitutiveJandF(self,evaluator)
            updateConstitutiveF(self,evaluator);

            vIn=evaluator.V(self.inP)-evaluator.V(self.inM);
            dFdIn=self.c1+2*self.c2.*vIn+3*self.c3.*vIn.^2;
            dFdIn(self.idxSat)=0;

            evaluator.Jv(self.dOutBdInP)=dFdIn;
            evaluator.Jv(self.dOutBdInM)=-dFdIn;
        end

        function updateConstitutiveF(self,evaluator)


            vIn=evaluator.V(self.inP)-evaluator.V(self.inM);

            j=self.idx&(vIn<self.vInMin);
            k=self.idx&(self.vInMax<vIn);
            vIn(j)=self.vInMin(j);
            vIn(k)=self.vInMax(k);
            self.idxSat=j|k;

            v=self.c1.*vIn+self.c2.*vIn.^2+self.c3.*vIn.^3;
            evaluator.Fiv(self.outB)=...
            v-(evaluator.V(self.outP)-evaluator.V(self.outM));
        end
    end
end
