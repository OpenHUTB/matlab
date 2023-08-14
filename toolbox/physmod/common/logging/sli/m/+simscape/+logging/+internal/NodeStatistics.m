



classdef NodeStatistics<handle

    properties(Access=private)
RootNode
SelectedNodes
RootStats
    end

    properties(Access=private)
        StatusTitle(1,1)string
        StatusDesc(1,1)string
        StatusUnit(1,1)string
        StatusStats(1,1)string

        SourceStr(1,1)string
    end

    methods

        function this=NodeStatistics(rootNode,selectedNodes,rootStats)
            this.RootNode=rootNode;
            this.SelectedNodes=selectedNodes;
            this.RootStats=rootStats;



            this.populateNodeStatistics;
        end

        function nodeStatsValues=getNodeStatisticsValues(this,~,~)


            nodeStatsValues.StatusTitle=this.StatusTitle;
            nodeStatsValues.StatusDesc=this.StatusDesc;
            nodeStatsValues.StatusUnit=this.StatusUnit;
            nodeStatsValues.StatusStats=this.StatusStats;
            nodeStatsValues.SourceStr=this.SourceStr;
        end
    end

    methods(Access=private)
        function populateNodeStatistics(this,~,~)
            assert(numel(this.RootNode)==1,...
            'The root node should be scalar');

            if isempty(this.SelectedNodes)
                this.StatusTitle=getMessageFromCatalog('NoNodeSelected');
            elseif numel(this.SelectedNodes)==1
                node=this.SelectedNodes{1};
                if numel(node)>1
                    node=node(1);
                end
                if isempty(node)||builtin('isequal',node,this.RootNode)
                    [this.StatusTitle,this.StatusDesc,this.StatusUnit,...
                    this.StatusStats]=lPrintStatus(this.SelectedNodes,...
                    this.RootNode,this.RootStats);
                else
                    printStatusFcn=simscape.logging.internal.getNodeDisplayOption(...
                    node,'PrintStatusFcn',@lPrintStatus);
                    [this.StatusTitle,this.StatusDesc,this.StatusUnit,...
                    this.StatusStats]=printStatusFcn(this.SelectedNodes);
                end
                printLocationFcn=simscape.logging.internal.getNodeDisplayOption(...
                node,'PrintLocationFcn',@lPrintLocation);
                [this.SourceStr]=printLocationFcn(node);

            else
                [this.StatusTitle,this.StatusDesc,this.StatusUnit,...
                this.StatusStats]=lPrintStatus(this.SelectedNodes,...
                this.RootNode,this.RootStats);
            end
        end
    end


    methods(Static,Access=?NodeStatisticsTester)
        function out=getNodeStatistics(node)
            out=getNodeStatistics(node);
        end
    end
end


function[statusTitle,statusDesc,statusUnit,statusStats]=...
    lPrintStatus(selectedNodes,rootNode,rootStats)


    assert((numel(selectedNodes)==1)||(nargin>1));

    isMultiSelected=(numel(selectedNodes)>1);
    isRootNode=(nargin>1)&&(selectedNodes{1}==rootNode);

    if isMultiSelected||isRootNode
        assert(numel(rootNode)==1);
        node=rootNode;
        baseFreq=node.series.baseFrequency();
        statusTitle=getMessageFromCatalog('RootNodeStats');
        if nargin==3
            stats=rootStats;
        else
            stats=getNodeStatistics(node);
        end

        [statusDesc,statusUnit]=lGetNodeDescription(node);
    else
        node=selectedNodes{1};
        baseFreq=node(1).series.baseFrequency();
        statusTitle=getMessageFromCatalog('SelectedNodeStats');
        stats=getNodeStatistics(node);
        [statusDesc,statusUnit]=lPrintNodeId(node);
    end




    if isMultiSelected
        if any(cellfun(@(z)z.isFrequency(),selectedNodes,'UniformOutput',true))
            baseFreq='--';
        else


            baseFreq=rootNode.series.baseFrequency();
        end
        for idx=1:numel(selectedNodes)
            series=selectedNodes{idx}(1).series;
            if stats.nPoints~=numel(series.time)
                stats.nPoints='--';
                break;
            end
        end
    end

    statusStats=lGetStatusStatsText(stats,baseFreq);
end

function[nodeDesc,nodeUnit]=lGetNodeDescription(node)

    dimension=mat2str(size(node));

    if numel(node)>1
        nodeDescription=node.id;
        node=node(1);
    else
        nodeDescription=node.getDescription;
    end

    if isempty(nodeDescription)
        nodeDescription=node.getName;
        nodeTruncatedDesc=node.getName;
    else




        maxSize=35;
        if numel(nodeDescription)>maxSize
            nodeTruncatedDesc=[nodeDescription(1:maxSize),' '...
            ,getMessageFromCatalog('VariableDescriptionEllipsis')];
        else
            nodeTruncatedDesc=nodeDescription;
        end
    end

    conversion=node.series.conversion;

    descriptionMsg=getMessageFromCatalog('VariableDescription');
    conversionMsg=getMessageFromCatalog('UnitConversion',conversion);

    if~isempty(node.getDescription)
        nodeDesc=sprintf('\n%s %s\n',descriptionMsg,nodeTruncatedDesc);
        nodeUnit=sprintf('%s\n',conversionMsg);
    else

        dimensionMsg=getMessageFromCatalog('NodeDimension');
        dimensionMsg=[dimensionMsg,dimension];
        nodeDesc=sprintf('\n%s %s \n',descriptionMsg,nodeTruncatedDesc);
        nodeUnit=sprintf('%s \n',dimensionMsg);
    end
end

function[str,nodeUnit]=lPrintNodeId(node)


    str='';
    nodeUnit='';

    if(node(1).hasSource())
        [str,nodeUnit]=lGetNodeDescription(node);
    end
end

function model=lGetModelFromSource(source)
    strs=strsplit(source,':');
    model=strs{1};
end

function statusStatsText=lGetStatusStatsText(stats,baseFrequency)

    baseFrequencyMsg='';







    if ischar(baseFrequency)||baseFrequency>0
        baseFrequencyMsg=[getMessageFromCatalog('BaseFrequency',...
        num2str(baseFrequency)),newline];
    end

    statusStatsText=sprintf(['%s%s\n'...
    ,'%s\n'...
    ,'%s\n'],...
    baseFrequencyMsg,...
    getMessageFromCatalog('NumTimeSteps',num2str(stats.nPoints)),...
    getMessageFromCatalog('NumLoggedVariables',num2str(stats.nVariables)),...
    getMessageFromCatalog('NumLoggedZeroCrossings',num2str(stats.nZCs)));

end

function[str]=lPrintLocation(node)

    str='';

    assert(numel(node)==1);

    if(node.hasSource())
        source=node.getSource();
        model=lGetModelFromSource(source);
        srcLabel=getMessageFromCatalog('Source');
        if exist('is_simulink_loaded','file')&&is_simulink_loaded()&&bdIsLoaded(model)
            if Simulink.ID.isValid(source)
                blockName=pmsl_sanitizename(...
                get_param(Simulink.ID.getHandle(source),'Name'));
                str=sprintf('%s %s',srcLabel,blockName);
            else
                str=sprintf(getMessageFromCatalog('NoBlock'));
            end
        else
            noModelStatus=['(',getMessageFromCatalog('NoModel'),')'];
            str=sprintf('%s %s',srcLabel,noModelStatus);
        end
    end
end