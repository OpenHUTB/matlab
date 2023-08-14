classdef AS<handle




    properties
        Label={}
        NodeNames={}
        FileName={}
        Sparameters={}
        ATk=[]
    end

    methods(Access=private)
        function self=AS(label,varargin)
            addElement(self,label,varargin{:})
        end

        function addElement(self,label,varargin)
            self.Label{end+1}=label;
            self.NodeNames(:,end+1)=varargin';
        end
    end

    methods(Static)
        function add(ckt,label,varargin)
            if isempty(ckt.AS)
                ckt.AS=...
                rf.internal.rfengine.elements.AS(label,varargin{1:end-1});
            else
                addElement(ckt.AS,label,varargin{1:end-1})
            end
            if ischar(varargin{end})
                ckt.AS.FileName{end+1}=varargin{end};
                S=sparameters(varargin{end});
            else
                S=varargin{end};
            end
            ckt.AS.Sparameters{end+1}=S;
            generateSparams(ckt.AS,ckt,length(ckt.AS.Label))
        end
    end

    methods
        function resampleSParameters(self,analysis)

            for k=1:length(self.Label)

                S=rfinterp1(self.Sparameters{k},analysis.UniqueFreqs,'extrap');
                self.Sparameters{k}=S;
                np=S.NumPorts;
                i=self.ATk(:,k);
                p=reshape(S.Parameters,np*np,[]);
                analysis.Circuit.AT.SR(i,:)=real(p);
                analysis.Circuit.AT.SI(i,:)=imag(p);
            end
        end

        function generateSparams(self,ckt,k)
            S=self.Sparameters{k};
            Zref=sprintf('Z0=%.15g',S.Impedance);




            label=self.Label{k};
            nodeNames=self.NodeNames(:,k);

            ABin=sprintf('ABin_%s',label);
            AT11=sprintf('AT11_%s',label);
            AT21=sprintf('AT21_%s',label);
            AT12=sprintf('AT12_%s',label);
            AT22=sprintf('AT22_%s',label);
            ABout=sprintf('ABout_%s',label);
            b1=sprintf('b1_%s',label);
            b2=sprintf('b2_%s',label);
            ai11=sprintf('ai11_%s',label);
            ai21=sprintf('ai21_%s',label);
            ai12=sprintf('ai12_%s',label);
            ai22=sprintf('ai22_%s',label);

            rf.internal.rfengine.elements.AB.add(ckt,ABin,nodeNames{1},nodeNames{2},b1,'0',Zref)
            rf.internal.rfengine.elements.AT.add(ckt,AT11,b1,'0',b1,ai11)
            rf.internal.rfengine.elements.AT.add(ckt,AT21,b1,'0',b2,ai21)
            rf.internal.rfengine.elements.AT.add(ckt,AT12,b2,'0',b1,ai12)
            rf.internal.rfengine.elements.AT.add(ckt,AT22,b2,'0',b2,ai22)
            rf.internal.rfengine.elements.AB.add(ckt,ABout,nodeNames{3},nodeNames{4},b2,'0',Zref)

            i=length(ckt.AT.Label)-3:length(ckt.AT.Label);
            self.ATk(:,end+1)=i;
        end
    end
end
