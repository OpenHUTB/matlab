classdef ElementLayout<Rptgen.TitlePage.ElementLayout




    methods

        function appendFormat(this,cell,~)
            if this.ColSpan>1
                cell.setAttribute('colspan',num2str(this.ColSpan));
            end
            if this.RowSpan>1
                cell.setAttribute('rowspan',num2str(this.RowSpan));
            end
        end

    end


end