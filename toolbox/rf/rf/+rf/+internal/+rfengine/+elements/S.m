classdef S<handle




    properties
        Label={}
        NodeNames={}
        FileName={}
        Sparameters={}
        Fit={}
        Pfit={}
    end

    methods(Access=private)
        function self=S(label,varargin)
            addElement(self,label,varargin{:})
        end

        function addElement(self,label,varargin)
            self.Label{end+1}=label;
            self.NodeNames{end+1}=varargin';
        end
    end

    methods(Static)
        function add(ckt,label,varargin)
            if isempty(ckt.S)
                ckt.S=...
                rf.internal.rfengine.elements.S(label,varargin{1:end-1});
            else
                addElement(ckt.S,label,varargin{1:end-1})
            end
            if ischar(varargin{end})
                ckt.S.FileName{end+1}=varargin{end};
                ckt.S.Sparameters{end+1}=sparameters(varargin{end});
            else
                ckt.S.Sparameters{end+1}=varargin{end};
            end
            ckt.S.Fit{end+1}=...
            rationalfit(ckt.S.Sparameters{end});
            ckt.S.Pfit{end+1}=...
            makepassive(ckt.S.Fit{end},ckt.S.Sparameters{end});
            generateSparams(ckt.S,ckt,length(ckt.S.Label))
        end
    end

    methods
        function generateSparams(self,ckt,k)
            Zref=50;

            if isempty(self.Pfit{k})
                [A,B,C,D]=abcd(self.Fit{k});
            else
                [A,B,C,D]=abcd(self.Pfit{k});
            end
            ns=size(A,1);

            np=size(D,1);






            Tdiag=sum(abs(C),1)./sum(C~=0,1);
            T=diag(Tdiag);
            Ti=diag(1./Tdiag);

            TiA=T/A;
            Ais=TiA*Ti;
            Bs=TiA*B;
            Cs=C*Ti;

            label=self.Label{k};
            nodeNames=self.NodeNames{:,k};


            for i=1:np





                Vspi=sprintf('Vsp%d_%s',i,label);
                Eui=sprintf('Eu%d_%s',i,label);
                Hui=sprintf('Hu%d_%s',i,label);
                Rui=sprintf('Ru%d_%s',i,label);

                pi=sprintf('%s_p%d',label,i);
                ui=sprintf('%s_u%d',label,i);
                umi=sprintf('%s_um%d',label,i);
                gain=sprintf('%.15g',Zref);

                rf.internal.rfengine.elements.V.add(ckt,Vspi,nodeNames{i},pi,'0')
                rf.internal.rfengine.elements.E.add(ckt,Eui,ui,umi,pi,'0','1')
                rf.internal.rfengine.elements.H.add(ckt,Hui,umi,'0',Vspi,gain)
                rf.internal.rfengine.elements.R.add(ckt,Rui,ui,'0','1')
            end


            for i=1:ns




                Rxi=sprintf('Rx%d_%s',i,label);
                Cxi=sprintf('Cx%d_%s',i,label);
                Vxi=sprintf('Vx%d_%s',i,label);

                xi=sprintf('%s_x%d',label,i);
                xmi=sprintf('%s_xm%d',label,i);
                val=sprintf('%.15g',-Ais(i,i));

                rf.internal.rfengine.elements.R.add(ckt,Rxi,xi,'0','1')
                rf.internal.rfengine.elements.C.add(ckt,Cxi,xi,xmi,val)
                rf.internal.rfengine.elements.V.add(ckt,Vxi,xmi,'0','0')

                for j=1:ns
                    if j~=i&&Ais(i,j)~=0

                        Fxcij=sprintf('Fxc%d_%d_%s',i,j,label);
                        Vxj=sprintf('Vx%d_%s',j,label);
                        gain=sprintf('%.15g',Ais(i,j)/Ais(j,j));
                        rf.internal.rfengine.elements.F.add(ckt,Fxcij,xi,'0',Vxj,gain)
                    end
                end
                for j=1:np
                    if Bs(i,j)~=0

                        Gxij=sprintf('Gx%d_%d_%s',i,j,label);
                        uj=sprintf('%s_u%d',label,j);
                        gain=sprintf('%.15g',Bs(i,j));
                        rf.internal.rfengine.elements.G.add(ckt,Gxij,xi,'0',uj,'0',gain)
                    end
                end
            end


            for i=1:np

                Ryi=sprintf('Ry%d_%s',i,label);
                yi=sprintf('%s_y%d',label,i);
                rf.internal.rfengine.elements.R.add(ckt,Ryi,yi,'0','1')

                for j=1:ns
                    if Cs(i,j)~=0

                        Gycij=sprintf('Gyc%d_%d_%s',i,j,label);
                        xj=sprintf('%s_x%d',label,j);
                        gain=sprintf('%.15g',-Cs(i,j));
                        rf.internal.rfengine.elements.G.add(ckt,Gycij,yi,'0',xj,'0',gain)
                    end
                end
                for j=1:np
                    if D(i,j)~=0

                        Gydij=sprintf('Gyd%d_%d_%s',i,j,label);
                        uj=sprintf('%s_u%d',label,j);
                        gain=sprintf('%.15g',-D(i,j));
                        rf.internal.rfengine.elements.G.add(ckt,Gydij,yi,'0',uj,'0',gain)
                    end
                end
            end


            for i=1:np



                Eyi=sprintf('Ey%d_%s',i,label);
                Hyi=sprintf('Hy%d_%s',i,label);

                pi=sprintf('%s_p%d',label,i);
                yi=sprintf('%s_y%d',label,i);
                ymi=sprintf('%s_ym%d',label,i);
                Vspi=sprintf('Vsp%d_%s',i,label);
                gain=sprintf('%.15g',-Zref);

                rf.internal.rfengine.elements.E.add(ckt,Eyi,pi,'0',yi,ymi,'1')
                rf.internal.rfengine.elements.H.add(ckt,Hyi,ymi,'0',Vspi,gain)
            end
        end
    end
end
