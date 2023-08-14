function progressbar(command,model,title,message,percentage)





    persistent dispatcher;

    persistent map;

    if isempty(dispatcher)
        dispatcher.create=@lCreate;
        dispatcher.update=@lUpdate;
        dispatcher.delete=@lDelete;
    end

    if isempty(map)
        map=containers.Map;
    end

    dispatcher.(command)(model,title,message,percentage);

    function lCreate(model,title,message,percentage)

        lDelete(model,title,message,percentage);
        h=waitbar(percentage,'','Name',title);
        h.CurrentAxes.Title.Interpreter='none';
        h.CurrentAxes.Title.String=message;
        map(model)=h;

    end

    function lUpdate(model,~,message,percentage)

        if map.isKey(model)
            waitbar(percentage,map(model),message);
        end

    end

    function lDelete(model,~,~,~)

        if map.isKey(model)
            delete(map(model));
            remove(map,model);
        end

    end
end
