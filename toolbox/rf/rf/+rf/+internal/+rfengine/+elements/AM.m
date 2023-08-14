classdef AM<rf.internal.rfengine.elements.Elements




    properties(Constant)
        BranchNodeIndices=[5;6]
        ControlNodeIndices=[1,3;2,4]
    end

    properties
        GAIN=[]
        NF=[]
        OIP2=[]
        OIP3=[]
        ZIN=[]
        ZLO=[]
        ZOUT=[]
        ControlNodes=[]
    end



    properties(Hidden,Constant)
        DefaultGAIN=modulator.DefaultGain
        DefaultNF=modulator.DefaultNF
        DefaultOIP2=modulator.DefaultOIP2
        DefaultOIP3=modulator.DefaultOIP3
        DefaultZIN=modulator.DefaultZin
        DefaultZLO=Inf
        DefaultZOUT=modulator.DefaultZout
    end

    properties(Access=private)
outB
inP
inM
loP
loM
outP
outM
dOutBdOutP
dOutBdOutM
dOutBdInP
dOutBdInM
dOutBdLoP
dOutBdLoM

invZout
c1
c2
c3
vvMin
vvMax
i
isat
    end

    methods(Access=private)
        function self=AM(ckt,label,n1,n2,n3,n4,n5,n6)
            self@rf.internal.rfengine.elements.Elements(ckt,label,n1,n2,n3,n4,n5,n6);
        end
    end

    methods(Static)
        function add(ckt,label,n1,n2,n3,n4,n5,n6,varargin)
            if isempty(ckt.AM)
                ckt.AM=rf.internal.rfengine.elements.AM(ckt,label,n1,n2,n3,n4,n5,n6);
            else
                addElement(ckt.AM,ckt,label,n1,n2,n3,n4,n5,n6)
            end
            ckt.AM.GAIN(end+1)=ckt.AM.DefaultGAIN;
            ckt.AM.NF(end+1)=ckt.AM.DefaultNF;
            ckt.AM.OIP2(end+1)=ckt.AM.DefaultOIP2;
            ckt.AM.OIP3(end+1)=ckt.AM.DefaultOIP3;
            ckt.AM.ZIN(end+1)=ckt.AM.DefaultZIN;
            ckt.AM.ZLO(end+1)=ckt.AM.DefaultZLO;
            ckt.AM.ZOUT(end+1)=ckt.AM.DefaultZOUT;
            for k=1:length(varargin)
                i=strfind(varargin{k},'=');
                ckt.AM.(upper(varargin{k}(1:i-1)))(end)=...
                rf.internal.rfengine.Circuit.spice2double(varargin{k}(i+1:end));
            end
        end
    end

    methods
        function initializeIndices(self,ckt)
            self.IndicesJk=...
            self.BranchNodes+(self.Branches-1)*ckt.NumNodes;

            self.IndicesJi=...
            self.Branches+(self.Branches-1)*ckt.NumBranches;


            self.ControlNodes=self.Nodes(self.ControlNodeIndices,:);

            self.outB=self.Branches;
            self.inP=self.ControlNodes(1,:);
            self.inM=self.ControlNodes(2,:);
            self.loP=self.ControlNodes(3,:);
            self.loM=self.ControlNodes(4,:);
            self.outP=self.BranchNodes(1,:);
            self.outM=self.BranchNodes(2,:);

            self.dOutBdOutP=self.outB+(self.outP-1)*ckt.NumBranches;
            self.dOutBdOutM=self.outB+(self.outM-1)*ckt.NumBranches;
            self.dOutBdInP=self.outB+(self.inP-1)*ckt.NumBranches;
            self.dOutBdInM=self.outB+(self.inM-1)*ckt.NumBranches;
            self.dOutBdLoP=self.outB+(self.loP-1)*ckt.NumBranches;
            self.dOutBdLoM=self.outB+(self.loM-1)*ckt.NumBranches;

            self.IndicesJv=[...
            self.dOutBdOutP
            self.dOutBdOutM
            self.dOutBdInP
            self.dOutBdInM
            self.dOutBdLoP
            self.dOutBdLoM
            ];
        end

        function evalConstitutiveJandF(self,evaluator)
            self.invZout=1./self.ZOUT.';


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
            self.vvMin=min(x1,x2);
            self.vvMax=max(x1,x2);
            self.i=(d>0)&(abs(c3tilde)>eps);

            updateConstitutiveJandF(self,evaluator)

            evaluator.Ji(self.IndicesJi)=1;
            evaluator.Jv(self.dOutBdOutP)=-self.invZout;
            evaluator.Jv(self.dOutBdOutM)=self.invZout;
        end

        function updateConstitutiveJandF(self,evaluator)
            updateConstitutiveF(self,evaluator);

            vIn=evaluator.V(self.inP)-evaluator.V(self.inM);
            vLo=evaluator.V(self.loP)-evaluator.V(self.loM);
            dFdIn=self.invZout.*...
            (vLo.*self.c1+2*vLo.^2.*self.c2.*vIn+3*vLo.^3.*self.c3.*vIn.^2);
            dFdLo=self.invZout.*...
            (vIn.*self.c1+2*vIn.^2.*self.c2.*vLo+3*vIn.^3.*self.c3.*vLo.^2);
            dFdIn(self.isat)=0;
            dFdLo(self.isat)=0;

            evaluator.Jv(self.dOutBdInP)=dFdIn;
            evaluator.Jv(self.dOutBdInM)=-dFdIn;
            evaluator.Jv(self.dOutBdLoP)=dFdLo;
            evaluator.Jv(self.dOutBdLoM)=-dFdLo;
        end

        function updateConstitutiveF(self,evaluator)



            vIn=evaluator.V(self.inP)-evaluator.V(self.inM);
            vLo=evaluator.V(self.loP)-evaluator.V(self.loM);

            vv=vIn.*vLo;
            j=self.i&(vv<self.vvMin);
            k=self.i&(self.vvMax<vv);
            vv(j)=self.vvMin(j);
            vv(k)=self.vvMax(k);
            self.isat=j|k;

            v=self.c1.*vv+self.c2.*vv.^2+self.c3.*vv.^3;
            evaluator.Fiv(self.outB)=...
            evaluator.I(self.outB)+self.invZout.*...
            (v-(evaluator.V(self.outP)-evaluator.V(self.outM)));
        end
    end
end
