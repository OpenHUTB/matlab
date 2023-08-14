function[handles,objs]=find_path(srcP,dstP,blks)





    import Simulink.SLHighlight.*;


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

end

