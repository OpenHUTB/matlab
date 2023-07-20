classdef Circuit<handle







    properties
        A1=[]
        A3=[]
        AA=[]
        AB=[]
        AI=[]
        AM=[]
        AP=[]
        AS=[]
        AT=[]
        AV=[]
        AX=[]
        C=[]
        E=[]
        Epoly=[]
        F=[]
        G=[]
        Gpoly=[]
        H=[]
        I=[]
        Ipwl=[]
        L=[]
        R=[]
        S=[]
        V=[]
        Vic=[]
        Iic=[]
        Vpwl=[]
        Vsin=[]
    end

    properties(Constant)
        ElementMap=containers.Map(...
        {'A1','A3','AA','AB','AI','AM','AP','AS','AT','AV','AX',...
        'C','E','Epoly','F','G','Gpoly','H','I','Iic','Ipwl','L',...
        'R','S','V','Vic','Vpwl','Vsin'},{...
        str2func('rf.internal.rfengine.elements.A1.add'),...
        str2func('rf.internal.rfengine.elements.A3.add'),...
        str2func('rf.internal.rfengine.elements.AA.add'),...
        str2func('rf.internal.rfengine.elements.AB.add'),...
        str2func('rf.internal.rfengine.elements.AI.add'),...
        str2func('rf.internal.rfengine.elements.AM.add'),...
        str2func('rf.internal.rfengine.elements.AP.add'),...
        str2func('rf.internal.rfengine.elements.AS.add'),...
        str2func('rf.internal.rfengine.elements.AT.add'),...
        str2func('rf.internal.rfengine.elements.AV.add'),...
        str2func('rf.internal.rfengine.elements.AX.add'),...
        str2func('rf.internal.rfengine.elements.C.add'),...
        str2func('rf.internal.rfengine.elements.E.add'),...
        str2func('rf.internal.rfengine.elements.Epoly.add'),...
        str2func('rf.internal.rfengine.elements.F.add'),...
        str2func('rf.internal.rfengine.elements.G.add'),...
        str2func('rf.internal.rfengine.elements.Gpoly.add'),...
        str2func('rf.internal.rfengine.elements.H.add'),...
        str2func('rf.internal.rfengine.elements.I.add'),...
        str2func('rf.internal.rfengine.elements.Iic.add'),...
        str2func('rf.internal.rfengine.elements.Ipwl.add'),...
        str2func('rf.internal.rfengine.elements.L.add'),...
        str2func('rf.internal.rfengine.elements.R.add'),...
        str2func('rf.internal.rfengine.elements.S.add'),...
        str2func('rf.internal.rfengine.elements.V.add'),...
        str2func('rf.internal.rfengine.elements.Vic.add'),...
        str2func('rf.internal.rfengine.elements.Vpwl.add'),...
        str2func('rf.internal.rfengine.elements.Vsin.add')
        })
        AnalysisMap=containers.Map(...
        {'HB','OP','TRAN'},{...
        str2func('rf.internal.rfengine.analyses.HB'),...
        str2func('rf.internal.rfengine.analyses.OP'),...
        str2func('rf.internal.rfengine.analyses.TRAN')
        })
    end

    properties
        Name=''
        Flattened={}

        Analyses={}
        OP=[]
        TRAN=[]
        HB=[]

        OPTIONS=[]

        Elements={}
        SourceElements={}


        NodeMap=[]
        NodeCountMap=[]
        GroundName='0'


        NodeNames={}

        BranchData=[]
        VariableNames={}

        NumBranches=0
        NumNodes=0


        Jk=[]
        Jkiv=[]
    end

    properties(SetAccess=private)
        Result=[]
        Success=false
    end

    methods

        function self=Circuit(filename,varargin)
            self.NodeCountMap=containers.Map('KeyType','char','ValueType','double');
            if nargin==0
                return
            end

            p=inputParser;
            p.CaseSensitive=false;
            p.addParameter('Display','off');
            p.addParameter('RelTol',1e-3);
            p.addParameter('AbsTol',1e-6);
            p.addParameter('OpJacobianUpdatePeriod',3);
            p.addParameter('HbJacobianUpdatePeriod',3);
            p.addParameter('OpConductanceToGround',1e-12);
            p.addParameter('HbConductanceToGround',1e-12);
            p.addParameter('Method','');
            p.parse(varargin{:});
            args=p.Results;

            if strcmpi(args.Display,'on')
                fprintf('Circuit(''%s'')\n\n',filename)
            end
            self.Name=filename;


            self.OPTIONS.Method=args.Method;
            read(self,filename)


            prepareForAnalysis(self)
            for i=1:length(self.Analyses)
                analysis=self.Analyses{i};
                verbose=strcmpi(args.Display,'on');
                params=rf.internal.rfengine.analyses.parameters('OpVerbose',verbose,'HbVerbose',verbose,...
                'OpVoltageLimit',0.6,...
                'OpJacobianUpdatePeriod',args.OpJacobianUpdatePeriod,...
                'HbJacobianUpdatePeriod',args.HbJacobianUpdatePeriod,...
                'OpConductanceToGround',args.OpConductanceToGround,...
                'HbConductanceToGround',args.HbConductanceToGround,...
                'RelTol',args.RelTol,'AbsTol',args.AbsTol);
                [self.Result,self.Success]=Execute(analysis,params);
            end
        end

        function names=variableNames(self)
            branchNames=cell(self.NumBranches,1);
            for i=1:self.NumBranches
                branchNames{i}=self.BranchData(i).Name;
            end
            nodeNames=self.NodeNames;
            nodeNames(1)='';
            names=[branchNames;nodeNames'];
        end

        function prepareForAnalysis(self)

            k=keys(self.NodeCountMap);
            self.NodeMap=containers.Map(k,1:length(k));
            self.NodeNames=k;

            if~any(strcmp(k,'0'))
                v=values(self.NodeCountMap);
                [~,i]=max([v{:}]);
                self.GroundName=k{i};
            end

            if self.NodeMap(self.GroundName)~=1
                self.NodeMap(k{1})=self.NodeMap(self.GroundName);
                self.NodeMap(self.GroundName)=1;
            end
            self.NumNodes=length(self.NodeMap);


            for k=1:length(self.Elements)
                ev=self.Elements{k};
                ev.Nodes=zeros(size(ev.NodeNames));
                for i=1:numel(ev.Nodes)
                    ev.Nodes(i)=self.NodeMap(ev.NodeNames{i});
                end
            end
        end

        function tallyNodes(self,nodeNames)

            for i=1:length(nodeNames)
                if~isKey(self.NodeCountMap,nodeNames{i})
                    self.NodeCountMap(nodeNames{i})=1;
                else
                    self.NodeCountMap(nodeNames{i})=...
                    self.NodeCountMap(nodeNames{i})+1;
                end
            end
        end



        function computeGlobalConnectivity(self,beta)

            branchIndex=1;
            for k=1:length(self.Elements)
                ev=self.Elements{k};
                nBranches=size(ev.BranchNodeIndices,2);
                nElements=size(ev.Nodes,2);
                if nBranches==1
                    ev.BranchNodes=ev.Nodes(ev.BranchNodeIndices,:);
                else
                    ev.BranchNodes=[];
                    for j=1:nElements
                        n=ev.Nodes(:,j);
                        ev.BranchNodes=[ev.BranchNodes,n(ev.BranchNodeIndices)];
                    end
                end
                ev.Branches=branchIndex+(0:nBranches*nElements-1);
                branchIndex=ev.Branches(end)+1;
            end
            self.NumBranches=branchIndex-1;


            self.Jk=spalloc(double(self.NumNodes),...
            double(self.NumBranches),2*double(self.NumBranches));
            for k=1:length(self.Elements)
                ev=self.Elements{k};
                initializeIndices(ev,self)



                evalConservationJ(ev,self)
            end
            N=self.NumNodes;
            self.Jkiv=[self.Jk(2:end,:),beta*speye(N-1,N-1)];



            self.BranchData=struct('Name',{},'Device',{},'BranchIndex',{});
            index=0;
            for k=1:length(self.Elements)
                ev=self.Elements{k};
                for j=1:size(ev.Nodes,2)
                    for i=1:size(ev.BranchNodeIndices,2)
                        index=index+1;
                        self.BranchData(index).Device=k;
                        self.BranchData(index).BranchIndex=i;
                        self.BranchData(index).Name=...
                        [ev.Label{j},'.',num2str(i)];
                    end
                end
            end

            self.VariableNames=variableNames(self);

            self.checkCircuit;
        end

        function checkCircuit(self)

            [m,~]=find(self.Jk);

            branch2nodes=reshape(m,2,length(m)/2)';


            floating=true(1,self.NumNodes);
            ground=1;
            floating(ground)=false;

            frontier=ground;
            while~isempty(frontier)
                node=frontier(1);
                adjacent_branches=(self.Jk(node,:)~=0);

                adjacent_nodes=unique(branch2nodes(adjacent_branches,:));
                not_yet_visited=...
                adjacent_nodes(floating(adjacent_nodes));
                floating(not_yet_visited)=false;
                frontier=[frontier(2:end);not_yet_visited(:)];
            end

            if any(floating)
                warning('The following nodes do not have paths to ground: ''%s'' ',...
                self.NodeNames{floating});
            end
        end

        function readFile(self,filename)
            [~,~,ext]=fileparts(filename);
            if strcmp(ext,'.m')
                feval(filename)
                return
            end


            fid=fopen(filename,'rt');
            cf=textscan(fid,'%s','Delimiter','\n');
            fclose(fid);
            lines=cf{1};


            row=find(strncmpi(lines,'.include',8),1);
            while~isempty(row)
                [~,remainder]=strtok(lines{row});
                token=strtok(remainder);

                fid2=fopen(token,'rt');
                cf2=textscan(fid2,'%s','Delimiter','\n');
                fclose(fid2);
                lines=[lines(1:row-1);cf2{1};lines(row+1:end)];

                row=find(strncmpi(lines,'.include',8),1);
            end


            idx=strncmp(lines,'+',1);
            for row=flip(find(idx'))
                lines{row-1}=[lines{row-1},lines{row}(2:end)];
            end
            lines=lines(~idx);


            idx=strcmpi('',lines);
            lines(idx)=[];


            start=find(strncmpi(lines,'.subckt',7));
            if~isempty(start)
                stop=find(strncmpi(lines,'.ends',5));

                subckts={};
                for k=length(start):-1:1
                    subckts=[subckts;lines(start(k):stop(k))];%#ok<AGROW>
                    lines(start(k):stop(k))=[];
                end


                rowMap=containers.Map('KeyType','char','ValueType','double');
                terminalMap=containers.Map('KeyType','char','ValueType','any');
                start=strncmpi(subckts,'.subckt',7);
                for k=find(start')
                    c=textscan(subckts{k},'%s');
                    tokens=c{1}';
                    rowMap(tokens{2})=k;
                    terminalMap(tokens{2})=tokens(3:end);
                end


                numNodesMap=containers.Map(...
                {'r','c','l','v','i','d','m','e','f','g','h'},...
                [2,2,2,2,2,2,4,4,2,4,2]);


                row=find(strncmpi(lines,'x',1),1);
                while~isempty(row)
                    c=textscan(lines{row},'%s');
                    tokens=c{1}';
                    instanceLabel=tokens{1};
                    subcktName=tokens{end};
                    terms=terminalMap(subcktName);
                    nodeMap=containers.Map(terms,tokens(2:2+length(terms)-1));
                    nodeMap('0')='0';

                    newLines={};
                    subcktRow=rowMap(subcktName)+1;
                    subcktLine=subckts{subcktRow};
                    while~strcmpi(subcktLine,'.ends')
                        if any(strcmpi(subcktLine(1),numNodesMap.keys))
                            c=textscan(subcktLine,'%s');
                            tokens=c{1}';


                            newLine=[tokens{1},'.',instanceLabel];


                            if strcmpi(tokens{1}(1),'f')||strcmpi(tokens{1}(1),'h')
                                tokens{4}=[tokens{4},'.',instanceLabel];
                            end


                            for k=2:numNodesMap(lower(subcktLine(1)))+1
                                if isKey(nodeMap,tokens{k})
                                    nodeName=nodeMap(tokens{k});
                                else
                                    nodeName=[instanceLabel,'.',tokens{k}];
                                end
                                newLine=[newLine,' ',nodeName];%#ok<AGROW>
                            end


                            for k=k+1:length(tokens)
                                newLine=[newLine,' ',tokens{k}];%#ok<AGROW>
                            end

                            newLines{end+1,1}=newLine;%#ok<AGROW>
                        end
                        subcktRow=subcktRow+1;
                        subcktLine=subckts{subcktRow};
                    end

                    lines=[lines(1:row-1);newLines;lines(row+1:end)];
                    row=find(strncmpi(lines,'x',1),1);
                end
            end

            self.Flattened=lines;
        end

        function read(self,filename)
            readFile(self,filename)
            lines=self.Flattened;

            numlines=length(lines);
            row=1;
            while row<=numlines
                c=textscan(lines{row},'%s');
                row=row+1;
                tokens=c{1};

                key=upper(tokens{1}(1));
                switch key
                case '*'
                    continue
                case '.'
                    key=upper(tokens{1}(2:end));
                    if strcmpi(key,'end')
                        return
                    elseif strncmpi(key,'opt',3)
                        for k=2:length(tokens)
                            opt=tokens{k};
                            i=strfind(opt,'=');
                            name=[upper(opt(1)),lower(opt(2:i-1))];
                            self.OPTIONS.(name)=opt(i+1:end);
                        end
                    else
                        self.Analyses{end+1}=...
                        feval(self.AnalysisMap(key),self,tokens{2:end});
                    end
                    continue
                case 'A'
                    key=upper(tokens{1}(1:2));
                case 'E'
                    if strncmpi(tokens{4},'poly',4)
                        key='Epoly';
                    end
                case 'G'
                    if strncmpi(tokens{4},'poly',4)
                        key='Gpoly';
                    end
                case 'I'
                    if strncmpi(tokens{4},'sin',3)
                        key='Isin';
                    elseif strncmpi(tokens{4},'pwl',3)
                        key='Ipwl';
                    end
                case 'S'
                    if strncmpi(tokens{1},'s',4)
                        key='S';
                    end
                case 'V'
                    if strncmpi(tokens{4},'sin',3)
                        key='Vsin';
                    elseif strncmpi(tokens{4},'pwl',3)
                        key='Vpwl';
                    end
                end
                feval(self.ElementMap(key),self,tokens{:})
            end
        end
    end

    methods(Static)
        function d=spice2double(str)

            str=regexprep(str,'V','','ignorecase');
            str=regexprep(str,'(\d*[\d\.]\d*)T(\S)*',' $1e12','ignorecase');
            str=regexprep(str,'(\d*[\d\.]\d*)G(\S)*',' $1e9','ignorecase');
            str=regexprep(str,'(\d*[\d\.]\d*)MEG(\S)*','$1e6','ignorecase');
            str=regexprep(str,'(\d*[\d\.]\d*)X(\S)*',' $1e6','ignorecase');
            str=regexprep(str,'(\d*[\d\.]\d*)K(\S)*',' $1e3','ignorecase');
            str=regexprep(str,'(\d*[\d\.]\d*)M(\S)*',' $1e-3','ignorecase');
            str=regexprep(str,'(\d*[\d\.]\d*)U(\S)*',' $1e-6','ignorecase');
            str=regexprep(str,'(\d*[\d\.]\d*)N(\S)*',' $1e-9','ignorecase');
            str=regexprep(str,'(\d*[\d\.]\d*)P(\S)*',' $1e-12','ignorecase');
            str=regexprep(str,'(\d*[\d\.]\d*)F(\S)*',' $1e-15','ignorecase');
            str=regexprep(str,'(\d*[\d\.]\d*)A(\S)*',' $1e-18','ignorecase');
            d=str2double(str);
        end
    end
end
