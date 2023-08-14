



function blockSupportCB(userdata,cbinfo)


    if cbinfo.EventData

        slprivate('remove_hilite',cbinfo.editorModel.handle);


        children=cbinfo.editorModel.getHierarchicalChildren;
        for index=1:length(children)
            graph_children=children(index).getChildren;
            for c=1:length(graph_children)
                obj=graph_children(c);
                if isa(obj,'Simulink.Reference')
                    h=obj.handle;
                    obj=get_param(h,'object');
                end
                if isa(obj,'Simulink.Block')&&SLStudio.Utils.BlockSupportsCap(obj,userdata)
                    set_param(obj.handle,'HiliteAncestors','orangeWhite');
                end
            end
        end


        slprivate('hilite_option',userdata);


    elseif strcmpi(slprivate('hilite_option'),userdata)
        SLStudio.Utils.RemoveHighlighting(cbinfo.editorModel.handle);
        slprivate('hilite_option','none');
    end
end
