classdef SCDHighlighter<linearize.advisor.highlighter.AbstractHighlighter




























    methods

        function this=SCDHighlighter(varargin)
            if nargin~=0
                import linearize.advisor.highlighter.*
                if isa(varargin{1},'linearize.advisor.highlighter.SCDHighlighterData')
                    HLData=varargin{1};
                else
                    HLData=SCDHighlighterData(varargin{:});
                end

                numData=numel(HLData);
                this(numData)=SCDHighlighter;
                for ct=1:numData
                    this(ct).Data=HLData(ct);
                    this(ct).HLOptions=HLData(ct).HLOptions;
                    this(ct).Description=HLData(ct).Description;
                    this(ct).IsDataEmpty=isempty(HLData(ct).BlockPaths)&&isempty(HLData(ct).Lines);
                end
            end
        end












        function highlightBlock(HLInfo)
            block=HLInfo(1).Data.BlockPaths;
            block=block{1};
            LocalHLBlock(block);
        end

        function removeHighlightBlock(HLInfo)
            block=HLInfo(1).Data.BlockPaths;
            blockOwner=get_param(block,'parent');
            hblock=get_param(block,'handle');
            root=bdroot(hblock);
            open_system(blockOwner);


            SLStudio.EmphasisStyleSheet.removeStyler(root);
        end



        function highlight(HLInfos)
            removehighlight(HLInfos);

            for ctInfo=1:numel(HLInfos)
                this=HLInfos(ctInfo);

                if(isempty(this.Data.BlockPaths)&&isempty(this.Data.Lines))||isempty(this.Data.ModelNames)
                    continue
                end


                for ctm=1:numel(this.Data.ModelNames)
                    if iscell(this.Data.ModelNames)
                        mdl=this.Data.ModelNames{ctm};
                    else
                        mdl=this.Data.ModelNames;
                    end
                    if~bdIsLoaded(mdl)
                        open_system(mdl);
                    end
                end


                allBlocks=get_param(this.Data.BlockPaths,'handle');
                if iscell(allBlocks)
                    allBlocks=cell2mat(allBlocks);
                end




                bdhandles=bdroot(allBlocks);




                [unibd,~,ic]=unique(bdhandles);




                for ct=1:numel(unibd)

                    hBlocks=allBlocks(ic==ct);
                    this.style=[this.style;
                    Simulink.Structure.Utils.highlightObjs([],...
                    hBlocks,...
                    'blockfillcolor',this.HLOptions.blockfillcolor,...
                    'blockedgecolor',this.HLOptions.blockedgecolor,...
                    'blocklinestyle',this.HLOptions.blocklinestyle,...
                    'blocklinewidth',this.HLOptions.blocklinewidth,...
                    'highlightcolor',this.HLOptions.highlightcolor,...
                    'highlightwidth',this.HLOptions.highlightwidth,...
                    'highlightstyle',this.HLOptions.highlightstyle)];

                    hOwners=[];
                    new_owners=get_param(get(hBlocks,'parent'),'handle');
                    if iscell(new_owners)
                        new_owners=cell2mat(new_owners);
                    end
                    new_owners=setdiff(new_owners,[hOwners;hBlocks;unibd(ct)]);
                    while~isempty(new_owners)
                        hOwners=[new_owners;hOwners];
                        new_owners=get_param(get(new_owners,'parent'),'handle');
                        if iscell(new_owners);new_owners=cell2mat(new_owners);end
                        new_owners=setdiff(new_owners,[hOwners;hBlocks;unibd(ct)]);
                    end



                    this.style=[this.style;
                    Simulink.Structure.Utils.highlightObjs([],...
                    hOwners,...
                    'blockfillcolor',[1,1,1,1],...
                    'blockedgecolor',this.HLOptions.blockedgecolor,...
                    'blocklinestyle','DashLine',...
                    'blocklinewidth',this.HLOptions.blocklinewidth,...
                    'highlightcolor',this.HLOptions.highlightcolor,...
                    'highlightwidth',3,...
                    'highlightstyle',this.HLOptions.highlightstyle)];
                end


                if~isempty(this.Data.Lines)
                    allsegs=getallsegments(this);
                    bdhandles=bdroot(allsegs);

                    [unibd,~,ic]=unique(bdhandles);
                    for ct=1:numel(unibd)
                        open_system(unibd(ct));
                        segs=allsegs(ic==ct);
                        this.style=[this.style;
                        Simulink.Structure.Utils.highlightObjs(segs,...
                        [],...
                        'blockfillcolor',this.HLOptions.blockfillcolor,...
                        'blockedgecolor',this.HLOptions.blockedgecolor,...
                        'blocklinestyle',this.HLOptions.blocklinestyle,...
                        'blocklinewidth',this.HLOptions.blocklinewidth,...
                        'highlightcolor',this.HLOptions.highlightcolor,...
                        'highlightwidth',this.HLOptions.highlightwidth,...
                        'highlightstyle',this.HLOptions.highlightstyle,...
                        'segmentcolor',this.HLOptions.segmentcolor,...
                        'segmentlinestyle',this.HLOptions.segmentlinestyle,...
                        'segmentlinewidth',this.HLOptions.segmentlinewidth)];
                    end
                end
            end
        end


        function removehighlight(HLInfos)
            for ctInfo=1:numel(HLInfos)
                this=HLInfos(ctInfo);
                if~isempty(this.style)
                    for ct=1:numel(this.style)
                        Simulink.SLHighlight.removeHighlight(this.style(ct));
                    end
                end
                this.style=[];
            end
        end


        function delete(this)
            removehighlight(this);
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
            for ctl=1:numel(this.Data.Lines)

                ph=get_param(this.Data.Lines(ctl).Block,'portHandles');
                allInports=Simulink.Structure.Utils.getAllInportHandles(ph);

                allsegs=[allsegs;LocalGetAllLinesFromDst(allInports(this.Data.Lines(ctl).PortNumber))];
            end
        end
    end

    methods(Static)
        function opt=getDefaultHLOptions(value,Max)
            opt=struct('blockfillcolor',[1,1,1,1],...
            'blockedgecolor',[0,0,0,1],...
            'blocklinestyle','SolidLine',...
            'blocklinewidth',1.5,...
            'highlightcolor',[0.98,0.92,0.2,1],...
            'highlightwidth',2.75,...
            'highlightstyle','SolidLine',...
            'segmentcolor',[0,0,0,1],...
            'segmentlinestyle','SolidLine',...
            'segmentlinewidth',1);
            if nargin==2
                opt.highlightcolor=LocalGetColorFromColorMap(value,Max);
                opt.blockfillcolor=opt.highlightcolor;
            end
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


function LocalCloseFigureCallBack(hFig,~,data)
    delete(hFig);
    removehighlight(data);
end

function LocalOKButtonCallBack(~,~,data)
    delete(gcbf);
    removehighlight(data);
end

function LocalHLBlock(block)
    blkparent=get_param(block,'parent');
    hblock=get_param(block,'handle');
    root=bdroot(hblock);


    s=warning('error','Simulink:blocks:HideContents');%#ok<CTPCT>
    try
        open_system(blkparent,'force');

        warning(s);

        SLStudio.EmphasisStyleSheet.removeStyler(root);
        SLStudio.EmphasisStyleSheet.applyStyler(root,hblock);
    catch ex

        warning(s);
        if strcmp(ex.identifier,'Simulink:blocks:HideContents')

            LocalHLBlock(blkparent);
        else
            rethrow(ex);
        end
    end
end

