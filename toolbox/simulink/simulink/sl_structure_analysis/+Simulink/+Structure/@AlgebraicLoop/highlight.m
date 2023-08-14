

function algLoop=highlight(algLoop,index,totalLoops)

    import Simulink.SLHighlight.*;
    import Simulink.Structure.Utils.*

    if algLoop.nCycles<1
        return;
    end

    f=figure('visible','off');
    cmap=colormap(f);
    close(f);

    if nargin<2
        index=algLoop.Id(2);
        totalLoops=index+1;
    end


    if isempty(algLoop.hSegments)

        for i=1:algLoop.nCycles

            opC=algLoop.hloopOutports(i);
            ipC=algLoop.hloopInports(i);


            while~isempty(find(cellfun(@iscell,opC),1))
                opC=horzcat(opC{:});
                ipC=horzcat(ipC{:});
            end

            segments={};
            blocksInLoop={};

            for j=1:length(opC)
                op=opC{j};
                ip=ipC{j};

                [hSegs,hBlks]=Simulink.SLHighlight.find_path(op,ip,[]);
                segments{j}=hSegs;
                blocksInLoop{j}=hBlks;
            end

            algLoop.hSegments{i}=segments;
            algLoop.hAllBlocks{i}=blocksInLoop;

        end
    end

    lcolor=[1,0,0,1];
    tag=[];

    for i=1:algLoop.nCycles
        lcolor=getColorFromColorMap(cmap,index,0,totalLoops);


        tag=strcat(int2str(algLoop.Id(1)),'#',int2str(algLoop.Id(2)));


        options=[];
        if algLoop.isArtificialCycle(i)
            options={'HighLightColor',lcolor,'HighlightStyle','DotLine'};
        else
            options={'HighlightColor',lcolor};
        end
        options=[options,'tag',tag];

        segments=algLoop.hSegments{i};
        objs=algLoop.hAllBlocks{i};

        for j=1:length(segments)
            style=highlightObjs(segments{j},objs{j},options{:});
            algLoop.hstyle=[algLoop.hstyle;style];
        end
    end


    options={'blockFillColor',lcolor,'tag',tag};
    style=highlightObjs([],algLoop.VariableBlockHandles',options{:});
    algLoop.hstyle=[algLoop.hstyle;style];

end