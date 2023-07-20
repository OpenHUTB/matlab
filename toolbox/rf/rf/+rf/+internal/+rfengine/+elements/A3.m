classdef A3<handle




    properties
        Label={}
        NodeNames={}
        FileName={}
        Sparameters={}
        ATk=[]
    end

    methods(Access=private)
        function self=A3(label,varargin)
            addElement(self,label,varargin{:})
        end

        function addElement(self,label,varargin)
            self.Label{end+1}=label;
            self.NodeNames(:,end+1)=varargin';
        end
    end

    methods(Static)
        function add(ckt,label,varargin)
            if isempty(ckt.A3)
                ckt.A3=...
                rf.internal.rfengine.elements.A3(label,varargin{1:end-1});
            else
                addElement(ckt.A3,label,varargin{1:end-1})
            end
            if ischar(varargin{end})
                ckt.A3.FileName{end+1}=varargin{end};
                S=sparameters(varargin{end});
            else
                S=varargin{end};
            end
            ckt.A3.Sparameters{end+1}=S;
            generateSparams(ckt.A3,ckt,length(ckt.A3.Label))
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

            AB1=sprintf('AB1_%s',label);
            AT11=sprintf('AT11_%s',label);
            AT21=sprintf('AT21_%s',label);
            AT31=sprintf('AT31_%s',label);
            AB2=sprintf('AB2_%s',label);
            AT12=sprintf('AT12_%s',label);
            AT22=sprintf('AT22_%s',label);
            AT32=sprintf('AT32_%s',label);
            AB3=sprintf('AB3_%s',label);
            AT13=sprintf('AT13_%s',label);
            AT23=sprintf('AT23_%s',label);
            AT33=sprintf('AT33_%s',label);
            b1=sprintf('b1_%s',label);
            b2=sprintf('b2_%s',label);
            b3=sprintf('b3_%s',label);
            ai11=sprintf('ai11_%s',label);
            ai21=sprintf('ai21_%s',label);
            ai31=sprintf('ai31_%s',label);
            ai12=sprintf('ai12_%s',label);
            ai22=sprintf('ai22_%s',label);
            ai32=sprintf('ai32_%s',label);
            ai13=sprintf('ai13_%s',label);
            ai23=sprintf('ai23_%s',label);
            ai33=sprintf('ai33_%s',label);

            rf.internal.rfengine.elements.AB.add(ckt,AB1,nodeNames{1},nodeNames{2},b1,'0',Zref)
            rf.internal.rfengine.elements.AT.add(ckt,AT11,b1,'0',b1,ai11)
            rf.internal.rfengine.elements.AT.add(ckt,AT21,b1,'0',b2,ai21)
            rf.internal.rfengine.elements.AT.add(ckt,AT31,b1,'0',b3,ai31)

            rf.internal.rfengine.elements.AB.add(ckt,AB2,nodeNames{3},nodeNames{4},b2,'0',Zref)
            rf.internal.rfengine.elements.AT.add(ckt,AT12,b2,'0',b1,ai12)
            rf.internal.rfengine.elements.AT.add(ckt,AT22,b2,'0',b2,ai22)
            rf.internal.rfengine.elements.AT.add(ckt,AT32,b2,'0',b3,ai32)

            rf.internal.rfengine.elements.AB.add(ckt,AB3,nodeNames{5},nodeNames{6},b3,'0',Zref)
            rf.internal.rfengine.elements.AT.add(ckt,AT13,b3,'0',b1,ai13)
            rf.internal.rfengine.elements.AT.add(ckt,AT23,b3,'0',b2,ai23)
            rf.internal.rfengine.elements.AT.add(ckt,AT33,b3,'0',b3,ai33)

            i=length(ckt.AT.Label)-8:length(ckt.AT.Label);
            self.ATk(:,end+1)=i;
        end
    end
end
