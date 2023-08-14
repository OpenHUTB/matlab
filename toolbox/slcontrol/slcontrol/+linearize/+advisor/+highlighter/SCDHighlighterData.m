classdef SCDHighlighterData

























    properties
        Description=''
HLOptions
    end

    properties(SetAccess=?linearize.advisor.highlighter.SCDHighlighter)
ModelNames
BlockPaths
Lines



    end

    properties(Access=private)
style
    end

    methods








        function this=SCDHighlighterData(varargin)
            import linearize.advisor.highlighter.*

            Blocks=[];
            Lines=[];
            if isstruct(varargin{1})
                HLElement=varargin{1};

                if isfield(HLElement,'Description')
                    this.Description=HLElement.Description;
                end

                if isfield(HLElement,'Blocks')
                    Blocks=HLElement.Blocks;
                end

                if isfield(HLElement,'Lines')
                    Lines=HLElement.Lines;
                end

                if isfield(HLElement,'Options')&&~isempty(HLElement.Options)
                    this.HLOptions=HLElement.Options;
                else
                    this.HLOptions=SCDHighlighter.getDefaultHLOptions;
                end
            else

                Blocks=varargin{1};
                if ischar(Blocks)
                    Blocks={Blocks};
                end
                if~isempty(varargin{2})
                    Lines=struct('Block',varargin{2},'PortNumber',num2cell(varargin{3}));
                end
                if nargin>=4
                    this.Description=varargin{4};
                    if nargin==5&&isstruct(varargin{5})
                        this.HLOptions=varargin{5};
                    else
                        this.HLOptions=SCDHighlighter.getDefaultHLOptions;
                    end
                else
                    this.HLOptions=SCDHighlighter.getDefaultHLOptions;
                end
            end


            this.BlockPaths=Blocks;
            if~isempty(Lines)
                this.Lines=Lines;
                blocksFromLines={Lines.Block};
                allBlockPaths=[Blocks(:);blocksFromLines(:)];
            else
                allBlockPaths=Blocks;
            end
            allBlockHandles=get_param(allBlockPaths,'handle');
            if iscell(allBlockHandles)
                allBlockHandles=cell2mat(allBlockHandles);
            end

            this.ModelNames=get(unique(bdroot(allBlockHandles)),'Name');
            if~iscell(this.ModelNames)
                this.ModelNames={this.ModelNames};
            end
        end





























        function this=reassignHLColor(this)

            idx=true(size(this));
            for ct=1:numel(this)
                idx(ct)=isempty(this(ct).BlockPaths)&&isempty(this(ct).Lines);
            end
            idx=find(~idx);
            numNonEmptyObjs=numel(idx);


            for ct=1:numNonEmptyObjs
                this(idx(ct)).HLOptions.highlightcolor=LocalGetColorFromColorMap(ct,numNonEmptyObjs);
                this(idx(ct)).HLOptions.blockfillcolor=[this(idx(ct)).HLOptions.highlightcolor(1:3),0.5];
            end
        end


        function validateDescription(this)
            for ct=1:numel(this)
                if isempty(this(ct).Description)
                    this(ct).Description=['Category #',num2str(ct)];
                end
            end
        end

        function allsegs=getallsegments(this)
            allsegs=[];
            for ctl=1:numel(this.Lines)

                ph=get_param(this.Lines(ctl).Block,'portHandles');
                allInports=Simulink.Structure.Utils.getAllInportHandles(ph);

                allsegs=[allsegs;LocalGetAllLinesFromDst(allInports(this.Lines(ctl).PortNumber))];
            end
        end

        function decorator=createHighlighter(this)
            import linearize.advisor.highlighter.*
            decorator=SCDHighlighter(this);
        end
    end
end






function lines=LocalGetAllLinesFromDst(dstPort)

    lines=get(dstPort,'line');
    if lines==-1
        lines=[];
        return
    end
    pl=get(lines,'LineParent');
    while pl~=-1
        lines=[lines;pl];
        pl=get(pl,'LineParent');
    end
end


function color=LocalGetColorFromColorMap(value,max)
    cmap=get(groot,'defaultfigurecolormap');
    [m,~]=size(cmap);
    row=round((value/max)*(m-1))+1;
    color=cmap(row,:);
    color=[color,1];
end
