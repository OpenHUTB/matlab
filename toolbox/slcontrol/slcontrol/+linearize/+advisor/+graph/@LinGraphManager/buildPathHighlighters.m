function this=buildPathHighlighters(this)


    import linearize.advisor.highlighter.*

    if isempty(this.NumericalHighlighter)
        updatedNumEdges=getPortConnectivity(this.RedChannelGraph);
        if isempty(updatedNumEdges)
            this.NumericalHighlighter=SCDHighlighter(...
            {},[],[],...
            ctrlMsgUtils.message('Slcontrol:linadvisor:HighlightNumericallyOnPath'),...
            LocalGetNumericalHighlightingOptions());
        else
            compiledNumPortEdges=vertcat(this.NumPortData(:).Edge);
            numIdx2Keep=ismember(compiledNumPortEdges,updatedNumEdges,'rows');
            updatedNumPortData=this.NumPortData(numIdx2Keep);

            [nPortBlks,nPortNum]=LocalExtractInportInfoFromSegs(updatedNumPortData);

            blks=getfullname(nPortBlks);
            if ischar(blks)
                ublks=blks;
            else
                ublks=unique(blks);
            end
            this.NumericalHighlighter=SCDHighlighter(...
            ublks,blks,nPortNum,...
            ctrlMsgUtils.message('Slcontrol:linadvisor:HighlightNumericallyOnPath'),...
            LocalGetNumericalHighlightingOptions());
        end
    end

    if isempty(this.StructuralHighlighter)&&this.GenerateStructuralHLData
        updatedStructEdges=getPortConnectivity(this.MinimalChannelGraph);
        if isempty(updatedStructEdges)
            this.StructuralHighlighter=SCDHighlighter(...
            {},[],[],...
            ctrlMsgUtils.message('Slcontrol:linadvisor:HighlightStructurallyOnPath'),...
            LocalGetStructuralHighlightingOptions());
        else
            compiledStructPortEdges=vertcat(this.StructPortData(:).Edge);
            structIdx2Keep=ismember(compiledStructPortEdges,updatedStructEdges,'rows');
            updatedStructPortData=this.StructPortData(structIdx2Keep);

            [sPortBlks,sPortNum]=LocalExtractInportInfoFromSegs(updatedStructPortData);

            blks=getfullname(sPortBlks);
            if ischar(blks)
                ublks=blks;
            else
                ublks=unique(blks);
            end
            this.StructuralHighlighter=SCDHighlighter(...
            ublks,blks,sPortNum,...
            ctrlMsgUtils.message('Slcontrol:linadvisor:HighlightStructurallyOnPath'),...
            LocalGetStructuralHighlightingOptions());
        end
    end

    function opts=LocalGetStructuralHighlightingOptions()
        opts=LocalGetHighlightingOptions(2);

        function opts=LocalGetNumericalHighlightingOptions()
            opts=LocalGetHighlightingOptions(1);

            function opts=LocalGetHighlightingOptions(idx)
                opts=linearize.advisor.highlighter.SCDHighlighter.getDefaultHLOptions;
                co=get(groot,'defaultAxesColorOrder');
                clr=[co(idx,:),1];
                opts.highlightcolor=clr;
                opts.highlightwidth=0.5;
                opts.blockedgecolor=clr;
                opts.blockedgewidth=0.5;

                function[blks,portNum]=LocalExtractInportInfoFromSegs(portData)
                    blks=[];portNum=[];
                    for pd=portData
                        segs=pd.Segments(:)';
                        for s=segs
                            if isempty(get_param(s,'lineChildren'))
                                portHandles=get_param(s,'DstPortHandle');
                                for ph=portHandles(:)'
                                    portNum(end+1)=get_param(ph,'PortNumber');%#ok<AGROW>
                                    blks(end+1)=get_param(get_param(ph,'Parent'),'Handle');%#ok<AGROW>
                                end
                            end
                        end
                    end
