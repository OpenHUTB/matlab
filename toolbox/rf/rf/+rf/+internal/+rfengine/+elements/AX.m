classdef AX<rf.internal.rfengine.elements.Elements





    properties(Constant)
        BranchNodeIndices=[6;7];
        ControlNodeIndices=[1,2,3,4;5,5,5,5]
    end

    properties
        ControlNodes=[]
    end

    properties
coeff
out
inI
inQ
loI
loQ
inloM
outP
outM
dOutdOutP
dOutdOutM
dOutdInI
dOutdInQ
dOutdLoI
dOutdLoQ
dOutdInLoM
    end

    methods(Access=private)
        function self=AX(ckt,label,n1,n2,n3,n4,n5,n6,n7)
            self@rf.internal.rfengine.elements.Elements(ckt,label,n1,n2,n3,n4,n5,n6,n7);
        end
    end

    methods(Static)
        function add(ckt,label,n1,n2,n3,n4,n5,n6,n7,imt)
            if isempty(ckt.AX)
                ckt.AX=rf.internal.rfengine.elements.AX(ckt,label,n1,n2,n3,n4,n5,n6,n7);
            else
                addElement(ckt.AX,ckt,label,n1,n2,n3,n4,n5,n6,n7)
            end
            ckt.AX.coeff{end+1}=imt;
        end
    end

    methods
        function initializeIndices(self,ckt)
            self.IndicesJk=...
            self.BranchNodes+(self.Branches-1)*ckt.NumNodes;

            self.IndicesJi=[];

            self.ControlNodes=self.Nodes(self.ControlNodeIndices,:);

            self.out=self.Branches;
            self.inI=self.ControlNodes(1,:);
            self.inQ=self.ControlNodes(3,:);
            self.loI=self.ControlNodes(5,:);
            self.loQ=self.ControlNodes(7,:);
            self.inloM=self.ControlNodes(2,:);
            self.outP=self.BranchNodes(1,:);
            self.outM=self.BranchNodes(2,:);

            self.dOutdOutP=self.out+(self.outP-1)*ckt.NumBranches;
            self.dOutdOutM=self.out+(self.outM-1)*ckt.NumBranches;
            self.dOutdInI=self.out+(self.inI-1)*ckt.NumBranches;
            self.dOutdInQ=self.out+(self.inQ-1)*ckt.NumBranches;
            self.dOutdLoI=self.out+(self.loI-1)*ckt.NumBranches;
            self.dOutdLoQ=self.out+(self.loQ-1)*ckt.NumBranches;
            self.dOutdInLoM=self.out+(self.inloM-1)*ckt.NumBranches;

            self.IndicesJv=[...
            self.dOutdOutP
            self.dOutdOutM
            self.dOutdInI
            self.dOutdInQ
            self.dOutdLoI
            self.dOutdLoQ
            self.dOutdInLoM
            ];
        end

        function evalConstitutiveJandF(self,evaluator)
            updateConstitutiveJandF(self,evaluator)
            evaluator.Jv(self.dOutdOutP)=1;
            evaluator.Jv(self.dOutdOutM)=-1;
        end

        function updateConstitutiveJandF(self,evaluator)
            allVinI=evaluator.V(self.inI)-evaluator.V(self.inloM);
            allVinQ=evaluator.V(self.inQ)-evaluator.V(self.inloM);
            allVloI=evaluator.V(self.loI)-evaluator.V(self.inloM);
            allVloQ=evaluator.V(self.loQ)-evaluator.V(self.inloM);

            for k=1:size(self.Nodes,2)
                VinI=allVinI(k);
                VinQ=allVinQ(k);
                VloI=allVloI(k);
                VloQ=allVloQ(k);

                m=size(self.coeff{k},1);
                n=size(self.coeff{k},2);

                s1=zeros(m,1);
                dS1dInI=zeros(m,1);
                dS1dInQ=zeros(m,1);
                s1(1)=1;
                s1(2)=VinI;
                dS1dInI(2)=1;
                nck=[1,1];
                for i=2:m-1
                    nck=[1,nck(1:end-1)+nck(2:end),1];
                    r=0:i;
                    s1(i+1)=sum(nck.*cosd((i-r)*90).*VinI.^r.*VinQ.^(i-r));
                    t=r(2:end);
                    dS1dInI(i+1)=sum(nck(2:end).*cosd((i-t)*90).*t.*VinI.^(t-1).*VinQ.^(i-t));
                    t=r(1:end-1);
                    dS1dInQ(i+1)=sum(nck(1:end-1).*cosd((i-t)*90).*VinI.^t.*(i-t).*VinQ.^(i-t-1));
                end
                s1=s1./sqrt(2).^r';
                dS1dInI=dS1dInI./sqrt(2).^r';
                dS1dInQ=dS1dInQ./sqrt(2).^r';

                s2=zeros(1,n);
                dS2dLoI=zeros(1,n);
                dS2dLoQ=zeros(1,n);
                s2(1)=1;
                s2(2)=VloI;
                dS2dLoI(2)=1;
                nck=[1,1];
                for j=2:n-1
                    nck=[1,nck(1:end-1)+nck(2:end),1];
                    r=0:j;
                    s2(j+1)=sum(nck.*cosd((j-r)*90).*VloI.^r.*VloQ.^(j-r));
                    t=r(2:end);
                    dS2dLoI(j+1)=sum(nck(2:end).*cosd((j-t)*90).*t.*VloI.^(t-1).*VloQ.^(j-t));
                    t=r(1:end-1);
                    dS2dLoQ(i+1)=sum(nck(1:end-1).*cosd((j-t)*90).*VloI.^t.*(j-t).*VloQ.^(j-t-1));
                end
                s2=s2./sqrt(2).^r;
                dS2dLoI=dS2dLoI./sqrt(2).^r;
                dS2dLoQ=dS2dLoQ./sqrt(2).^r;

                tmp=sqrt(2)^3*self.coeff{k}.*(s1.*s2);
                dTmpdInI=sqrt(2)^3*self.coeff{k}.*(dS1dInI.*s2);
                dTmpdInQ=sqrt(2)^3*self.coeff{k}.*(dS1dInQ.*s2);
                dTmpdLoI=sqrt(2)^3*self.coeff{k}.*(s1.*dS2dLoI);
                dTmpdLoQ=sqrt(2)^3*self.coeff{k}.*(s1.*dS2dLoQ);

                Vout=sum(tmp(:));
                evaluator.Fiv(self.Branches(k))=...
                evaluator.V(self.outP(k))-evaluator.V(self.outM(k))-Vout;

                evaluator.Jv(self.dOutdInI(k))=-sum(dTmpdInI(:));
                evaluator.Jv(self.dOutdInQ(k))=-sum(dTmpdInQ(:));
                evaluator.Jv(self.dOutdLoI(k))=-sum(dTmpdLoI(:));
                evaluator.Jv(self.dOutdLoQ(k))=-sum(dTmpdLoQ(:));

                s=evaluator.Jv(self.dOutdInI(k))+evaluator.Jv(self.dOutdInQ(k))+...
                evaluator.Jv(self.dOutdLoI(k))+evaluator.Jv(self.dOutdLoQ(k));
                evaluator.Jv(self.dOutdInLoM)=-s;
            end
        end

        function updateConstitutiveF(self,evaluator)


            allVinI=evaluator.V(self.inI)-evaluator.V(self.inloM);
            allVinQ=evaluator.V(self.inQ)-evaluator.V(self.inloM);
            allVloI=evaluator.V(self.loI)-evaluator.V(self.inloM);
            allVloQ=evaluator.V(self.loQ)-evaluator.V(self.inloM);

            for k=1:size(self.Nodes,2)
                VinI=allVinI(k);
                VinQ=allVinQ(k);
                VloI=allVloI(k);
                VloQ=allVloQ(k);

                m=size(self.coeff{k},1);
                n=size(self.coeff{k},2);

                s1=zeros(m,1);
                s1(1)=1;
                s1(2)=VinI;
                nck=[1,1];
                for i=2:m-1
                    nck=[1,nck(1:end-1)+nck(2:end),1];
                    r=0:i;
                    s1(i+1)=sum(nck.*cosd((i-r)*90).*VinI.^r.*VinQ.^(i-r));
                end
                s1=s1./sqrt(2).^r';

                s2=zeros(1,n);
                s2(1)=1;
                s2(2)=VloI;
                nck=[1,1];
                for j=2:n-1
                    nck=[1,nck(1:end-1)+nck(2:end),1];
                    r=0:j;
                    s2(j+1)=sum(nck.*cosd((j-r)*90).*VloI.^r.*VloQ.^(j-r));
                end
                s2=s2./sqrt(2).^r;

                tmp=sqrt(2)^3*self.coeff{k}.*(s1.*s2);
                Vout=sum(tmp(:));
                evaluator.Fiv(self.Branches(k))=...
                evaluator.V(self.outP(k))-evaluator.V(self.outM(k))-Vout;
            end
        end
    end
end
