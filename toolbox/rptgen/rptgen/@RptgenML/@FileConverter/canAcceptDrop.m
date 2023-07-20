function tf=canAcceptDrop(this,dropObjects)







    tf=true;
    for i=1:length(dropObjects)
        if isa(dropObjects(i),'RptgenML.StylesheetEditor')&&...
            ~isempty(dropObjects(i).ID)

        elseif isa(dropObjects(i),'rptgen.coutline')||...
            isa(dropObjects(i),'rpt_xml.db_output')

        elseif isa(dropObjects(i),'RptgenML.LibraryFile')
            tf=true;
        else
            tf=false;
            return;
        end
    end


