...
...
...
function ft=createFormalTable(header,body,tableColSpecGroups)
    import mlreportgen.dom.*;

    if nargin<3
        tableColSpecGroups={};
    else
        if~isa(tableColSpecGroups,'mlreportgen.dom.TableColSpecGroup')
            error('tableColSpecGroup must be of type mlreportgen.dom.TableColSpecGroup');
        end
    end

    if nargin<2||isempty(body)

        body=header;
        ft=FormalTable(body);


        if~isempty(ft.Body)&&~isempty(ft.Body.Children)&&~isempty(ft.Body.Children(1))
            ft.Body.Children(1).Style={Bold(1)};
        end
    else
        ft=FormalTable(header,body);
        ft.Header.Style=dashboard.internal.report.Styles.tableHeaderStyle;
    end

    ft.Style=dashboard.internal.report.Styles.tableStyle;
    ft.TableEntriesInnerMargin=dashboard.internal.report.Styles.tableEntriesInnerMargin;

    if~isempty(tableColSpecGroups)
        ft.ColSpecGroups=tableColSpecGroups;
    end
end
