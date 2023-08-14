classdef Vpwl<rf.internal.rfengine.elements.Elements




    properties(Constant)
        BranchNodeIndices=[1;2]
    end

    properties
        Structure=[]
    end

    properties(Access=private)
nP
nM
    end

    methods(Access=private)
        function self=Vpwl(ckt,label,n1,n2)
            self@rf.internal.rfengine.elements.Elements(ckt,label,n1,n2);
        end
    end

    methods(Static)
        function add(ckt,label,n1,n2,varargin)
            if isempty(ckt.Vpwl)
                ckt.Vpwl=rf.internal.rfengine.elements.Vpwl(ckt,label,n1,n2);
            else
                addElement(ckt.Vpwl,ckt,label,n1,n2)
            end

            tokens=varargin;
            if strcmpi(varargin{1},'pwl')||strcmpi(varargin{1},'pwl(')
                tokens(1)=[];
            else
                tokens{1}=regexprep(tokens{1},'pwl\(+','','ignorecase');
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

            vals=zeros(1,length(tokens));
            for i=1:length(tokens)
                vals(i)=rf.internal.rfengine.Circuit.spice2double(tokens{i});
            end
            s.time=vals(1:2:end);
            s.values=vals(2:2:end);

            if isempty(ckt.Vpwl.Structure)
                ckt.Vpwl.Structure=s;
            else
                ckt.Vpwl.Structure(end+1)=s;
            end
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
            if t>self.Structure.time(end)
                v=self.Structure.values(end);
            else
                v=interp1(self.Structure.time,self.Structure.values,t);
            end
            analysis.Fiv(self.Branches)=...
            analysis.V(self.nP)-analysis.V(self.nM);
            analysis.Uiv(self.Branches)=v;
        end
    end
end
