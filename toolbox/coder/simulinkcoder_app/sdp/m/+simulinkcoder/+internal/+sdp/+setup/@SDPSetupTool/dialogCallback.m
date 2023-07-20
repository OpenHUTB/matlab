function dialogCallback(obj,widget,event)
    switch widget.tag
    case 'multiPlatform'
        if event.state
            obj.dataModel.columnChanged(4,{});
        else
            obj.dataModel.columnChanged(3,{});
        end
    end
