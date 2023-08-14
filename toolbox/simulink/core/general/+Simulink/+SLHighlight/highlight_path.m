function[srcP,dstP,objs,style]=highlight_path(srcP,dstP,blks,varargin)


    import Simulink.SLHighlight.*;

    style=[];







    index1=find(ishandle(srcP));
    index2=find(ishandle(dstP));

    index=intersect(index1,index2);

    dstP=dstP(index);
    srcP=srcP(index);



    indexToRemove=[];
    for i=1:length(dstP)
        try
            get_param(dstP(i),'parent');
        catch
            indexToRemove=[indexToRemove;i];
        end
    end
    dstP(indexToRemove)=[];
    srcP(indexToRemove)=[];

    indexToRemove=[];
    for i=1:length(srcP)
        try
            get_param(srcP(i),'parent');
        catch
            indexToRemove=[indexToRemove;i];
        end
    end

    dstP(indexToRemove)=[];
    srcP(indexToRemove)=[];



    vh1=[];
    handles=[];

    blockOnly=true;

    if~(isempty(dstP)||isempty(srcP))

        blockOnly=false;

        handles=private_sl_path_segments(dstP,srcP);

        hSrcBlks=get_param(handles,'SrcBlockHandle');

        if length(hSrcBlks)==1
            hSrcBlks=num2cell(hSrcBlks);
        end
        vh1=vertcat(hSrcBlks{:});
    end

    vh2=[];
    n=length(handles);



    for i=1:n
        hDstPort=get_param(handles(i),'DstPortHandle');
        k=length(hDstPort);
        for j=1:k

            try
                lines=get_param(hDstPort(j),'Line');
            catch
                continue;
            end

            if any(handles==lines)
                dsb=get_param(hDstPort(j),'Parent');
                vh2=[vh2;get_param(dsb,'handle')];
            end
        end
    end

    vBlks=unique([vh1;vh2]);

    b=unique([blks;vBlks]);





    if~blockOnly
        objs=unique([b;getAllSystems(b)]);
    else
        objs=b;
    end

    if isempty(handles)&&isempty(objs)
        return;
    end

    style=highlightSegments(handles,objs,varargin{:});

end

