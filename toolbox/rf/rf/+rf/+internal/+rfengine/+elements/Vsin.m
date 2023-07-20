classdef Vsin<rf.internal.rfengine.elements.SourceElements




    properties(Constant)
        BranchNodeIndices=[1;2]
    end

    properties
        Offset=[]
        Amplitude=[]
        Frequency=[]
        TimeDelay=[]
        DampingFactor=[]
        PhaseDelay=[]
    end

    properties(Access=private)
nP
nM
    end

    methods(Access=private)
        function self=Vsin(ckt,label,n1,n2)
            self@rf.internal.rfengine.elements.SourceElements(ckt,label,n1,n2);
        end
    end

    methods(Static)
        function add(ckt,label,n1,n2,varargin)
            if isempty(ckt.Vsin)
                ckt.Vsin=rf.internal.rfengine.elements.Vsin(ckt,label,n1,n2);
            else
                addElement(ckt.Vsin,ckt,label,n1,n2)
            end

            tokens=varargin;
            if strcmpi(varargin{1},'sin')||strcmpi(varargin{1},'sin(')
                tokens(1)=[];
            else
                tokens{1}=regexprep(tokens{1},'sin\(+','','ignorecase');
            end
            if strcmp(tokens{1},'(')
                tokens(1)=[];
            else
                tokens{1}=regexprep(tokens{1},'\(','');
            end
            if strcmpi(tokens{end},')')
                tokens(end)=[];
            else
                tokens{end}=regexprep(tokens{end},'\)','');
            end

            vals=zeros(1,6);
            for i=1:length(tokens)
                vals(i)=rf.internal.rfengine.Circuit.spice2double(tokens{i});
            end

            ckt.Vsin.Offset(end+1)=vals(1);
            ckt.Vsin.Amplitude(end+1)=vals(2);
            ckt.Vsin.Frequency(end+1)=vals(3);
            ckt.Vsin.TimeDelay(end+1)=vals(4);
            ckt.Vsin.DampingFactor(end+1)=vals(5);
            ckt.Vsin.PhaseDelay(end+1)=vals(6);
        end
    end

    methods
        function initializeIndices(self,ckt)
            initializeIndices@rf.internal.rfengine.elements.Elements(self,ckt)
            self.IndicesJi=[];

            self.nP=self.BranchNodes(1,:);
            self.nM=self.BranchNodes(2,:);
        end

        function evalConstitutiveJandF(self,analysis)
            analysis.Jv(self.IndicesJv(1,:))=1;
            analysis.Jv(self.IndicesJv(2,:))=-1;
            updateConstitutiveF(self,analysis)
        end

        function updateConstitutiveJandF(self,analysis)
            updateConstitutiveF(self,analysis)
        end

        function updateConstitutiveF(self,analysis)
            t=double(analysis.Time);
            v=self.Offset+(t>=self.TimeDelay).*self.Amplitude...
            .*exp((self.TimeDelay-t).*self.DampingFactor)...
            .*sin(2*pi.*(self.Frequency.*(t-self.TimeDelay)+self.PhaseDelay./360));
            analysis.Fiv(self.Branches)=...
            analysis.V(self.nP)-analysis.V(self.nM);
            analysis.Uiv(self.Branches)=v;
        end
    end
end
