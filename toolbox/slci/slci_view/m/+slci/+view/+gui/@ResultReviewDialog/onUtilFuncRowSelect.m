


function onUtilFuncRowSelect(obj,data)


    if~isempty(data)&&~isempty(data.codelines)
        input=obj.prepareHiliteCodeData(data.codelines);

        title=data.name;
        src=slci.view.internal.getSource(obj.getStudio);
        modelName=src.modelName;


        slci.view.internal.hiliteCode(modelName,title,input);


        if isfield(data,'blocktrace')
            blockhandles=getBlockHandles(data.blocktrace);
            slci.view.internal.hiliteBlock(modelName,blockhandles);
        end
    end

end

function out=getBlockHandles(blockTrace)

    out=[];
    idx=1;
    for i=1:numel(blockTrace)
        sid=blockTrace{i};
        try
            h=Simulink.URL.getHandle(sid);
            if isa(h,'Stateflow.Object')
                out(idx)=h.ID;%#ok
            else
                type=get_param(h,'type');
                if strcmp(type,'port')
                    out(idx)=get_param(h,'Line');%#ok
                else
                    out(idx)=h;%#ok
                end
            end
            idx=idx+1;
        catch
        end
    end
    out=unique(out);
end

