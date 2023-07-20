function tf=canAcceptDrop(this,dropObjects)







    tf=true;
    for i=1:length(dropObjects)
        if(isa(dropObjects(i),'RptgenML.StylesheetEditor')||...
            isa(dropObjects(i),'rptgen.coutline')||...
            isa(dropObjects(i),'rpt_xml.db_output'))

        else
            tf=false;
            return;
        end
    end


