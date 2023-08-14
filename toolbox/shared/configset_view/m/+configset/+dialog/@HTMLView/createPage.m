function createPage(obj,~)





    persistent first;
    first=isempty(first);


    obj.isWebPageReady=false;

    try

        info=obj.Source.modelInfo;
        obj.publish('info',info);
        if~info.resolved
            obj.isWebPageReady=true;
            return;
        end


        if first||obj.uptMode
            obj.prepareData(false);
            obj.publish('init',obj.data);
        end

        if obj.uptMode
            obj.isWebPageReady=true;
        else
            obj.prepareData(true);
            obj.publish('init',obj.data);
        end
    catch e


        obj.error=e;
        dlg=obj.Dlg;
        if isa(dlg,'DAStudio.Dialog')
            dlg.refresh;
        end


        obj.isWebPageReady=true;
    end



