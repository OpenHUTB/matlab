function updateMaxMinHoldLineProperties(this,lineType)




    defaultLineProperties=this.LinePropertyDefaults;
    defaultColorOrder=this.ColorOrder;
    cachedProps=this.([lineType,'HoldLinePropertiesCache']);
    numCachedLines=length(cachedProps);
    lineNumberForColor=0;
    hLines=this.([lineType,'HoldTraceLines']);
    nLines=length(hLines);
    if strcmp(lineType,'Min')&&strcmpi(this.PlotType,'stem')

        defaultLineProperties.LineWidth=1.5;
    end
    for lineNum=1:nLines

        props=defaultLineProperties;
        if(lineNum<=numCachedLines)&&~isempty(cachedProps{lineNum})
            props=dsp.scopes.SpectrumPlotter.mergeStructs(props,cachedProps{lineNum});
        end

        lineNumberForColor=lineNumberForColor+1;
        if~isfield(props,'Color')||isempty(props.Color)
            ac=get(this.Axes,'Color');
            if numel(this.Lines)>=lineNum

                lc=get(this.Lines(lineNum),'Color');
                if isequal(lc,ac)
                    lc=defaultColorOrder(rem(lineNumberForColor-1,size(defaultColorOrder,1))+1,:);
                end
            else


                lc=defaultColorOrder(rem(lineNumberForColor-1,size(defaultColorOrder,1))+1,:);
            end
            if strcmp(lineType,'Max')
                nc=this.MaxLineColorMultiplier*lc;
            else
                nc=this.MinLineColorMultiplier*lc;
            end
            props.Color=nc;
        end
        setMaxMinHoldLineProperties(this,lineNum,props,lineType)
    end
end
