classdef A1<handle




    properties
        Label={}
        NodeNames={}
        FileName={}
        Sparameters={}
        ATk=[]
    end

    methods(Access=private)
        function self=A1(label,varargin)
            addElement(self,label,varargin{:})
        end

        function addElement(self,label,varargin)
            self.Label{end+1}=label;
            self.NodeNames(:,end+1)=varargin';
        end
    end

    methods(Static)
        function add(ckt,label,varargin)
            if isempty(ckt.A1)
                ckt.A1=...
                rf.internal.rfengine.elements.A1(label,varargin{1:2});
            else
                addElement(ckt.A1,label,varargin{1:2})
            end
            if ischar(varargin{end})
                ckt.A1.FileName{end+1}=varargin{end};
                S=sparameters(varargin{end});
            else
                S=varargin{end};
            end
            ckt.A1.Sparameters{end+1}=S;
            generateSparams(ckt.A1,ckt,length(ckt.A1.Label))
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
            b1=sprintf('b1_%s',label);
            ai11=sprintf('ai11_%s',label);

            rf.internal.rfengine.elements.AB.add(ckt,ABin,nodeNames{1},nodeNames{2},b1,'0',Zref)
            rf.internal.rfengine.elements.AT.add(ckt,AT11,b1,'0',b1,ai11)

            self.ATk(:,end+1)=length(ckt.AT.Label);
        end
    end
end
