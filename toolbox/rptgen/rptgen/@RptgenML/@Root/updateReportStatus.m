function updateReportStatus(this,obj,evt)





    editor=this.Editor;

    if isa(editor,'DAStudio.Explorer')
        if strncmp(evt,'s',1)

            ime=DAStudio.imExplorer(editor);
            highlightColor=[1,1,0.2];


            nodes=ime.getVisibleTreeNodes;
            nodes=[nodes{:}]';
            if(sum(nodes==obj)>0)


                parentObj=obj.getParent();
                if isa(parentObj,'rptgen.DAObject')
                    editor.unhighlight(parentObj);
                end


                editor.highlight(obj,highlightColor);
            end


        elseif strncmp(evt,'e',1)

            editor.unhighlight(obj);

        end
    end