function dlgstruct=customizePropertyInspector(mdl,dlgstruct)





    cp=simulinkcoder.internal.CodePerspective.getInstance;
    on=cp.getStatus(mdl);
    if~on

        return;
    end

...
...
...
...
...
...
...
...
...
...
...
...
...
...

    try
        dlgstruct=loc_customize(dlgstruct);
    catch e
        disp(e);
    end


    function dlgstruct=loc_customize(dlgstruct)

        if isfield(dlgstruct,'Type')&&strcmp(dlgstruct.Type,'togglepanel')
            if strcmp(dlgstruct.Tag,'CodeGenTogglePanel')
                dlgstruct.Expand=true;
            else
                dlgstruct.Expand=false;
            end
        end

        if isfield(dlgstruct,'Items')
            for i=1:length(dlgstruct.Items)
                item=dlgstruct.Items{i};
                dlgstruct.Items{i}=loc_customize(item);
            end
        end
