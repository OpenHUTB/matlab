classdef Format<Rptgen.TitlePage.Format




    methods

        function this=Format(side)
            this@Rptgen.TitlePage.Format(side);
            this.IncludeElements=...
            {
            Rptgen.TitlePage.PDF.Title(side),...
            Rptgen.TitlePage.PDF.Subtitle(side),...
            Rptgen.TitlePage.PDF.Author(side),...
            Rptgen.TitlePage.PDF.Image(side),...
            Rptgen.TitlePage.PDF.Copyright(side),...
            Rptgen.TitlePage.PDF.PubDate(side),...
            Rptgen.TitlePage.PDF.LegalNotice(side),...
            Rptgen.TitlePage.PDF.Abstract(side)
            };
        end

        function generateTemplateContent(this,jTemplate)
            import com.mathworks.toolbox.rptgencore.tools.RgXmlUtils;
            occupiedCells={};
            RgXmlUtils.removeAllChildren(jTemplate);
            doc=jTemplate.getOwnerDocument();
            node=doc.createComment(Rptgen.TitlePage.saveFormat(this));
            jTemplate.appendChild(node);
            node=doc.createElement('fo:block');
            node.setAttribute('block-progression-dimension','auto');
            jTemplate.appendChild(node);


            table=doc.createElement('fo:table');
            node.appendChild(table);
            table.setAttribute('inline-progression-dimension','100%');
            table.setAttribute('table-layout','fixed');
            table.setAttribute('block-progression-dimension','auto');
            if this.LayoutGrid.Show
                table.setAttribute('border-top-style','dotted');
                table.setAttribute('border-bottom-style','dotted');
                table.setAttribute('border-left-style','dotted');
                table.setAttribute('border-right-style','dotted');
            end

            if~isempty(this.LayoutGrid.Width)
                table.setAttribute('width',[this.LayoutGrid.Width,this.LayoutGrid.WidthUnit]);
            end

            if~isempty(this.LayoutGrid.Height)
                table.setAttribute('height',[this.LayoutGrid.Height,this.LayoutGrid.HeightUnit]);
            end



            colwidth=[num2str(100/this.LayoutGrid.NumberOfColumns),'%'];
            for i=1:this.LayoutGrid.NumberOfColumns
                node=doc.createElement('fo:table-column');
                node.setAttribute('column-number',num2str(i));
                node.setAttribute('column-width',colwidth);
                table.appendChild(node);
            end


            tableBody=doc.createElement('fo:table-body');
            table.appendChild(tableBody);





            rowHeight=[num2str(str2double(this.LayoutGrid.Height)/this.LayoutGrid.NumberOfRows),'in'];
            for r=1:this.LayoutGrid.NumberOfRows
                row=doc.createElement('fo:table-row');
                row.setAttribute('height',rowHeight);
                if this.LayoutGrid.Show
                    row.setAttribute('border-top-style','dotted');
                end


                for c=1:this.LayoutGrid.NumberOfColumns
                    cellPreoccupied=occupiedCells(cellfun(@(x)x{1}==r&&x{2}==c,occupiedCells));
                    if isempty(cellPreoccupied)
                        cell=doc.createElement('fo:table-cell');
                        if this.LayoutGrid.Show
                            cell.setAttribute('border-right-style','dotted');
                        end
                        this.appendCellContent(r,c,cell,doc);
                        row.appendChild(cell);


                        colspan=char(cell.getAttribute('number-columns-spanned'));
                        if~isempty(colspan)
                            colspan=str2double(colspan);
                        else
                            colspan=1;
                        end

                        rowspan=char(cell.getAttribute('number-rows-spanned'));
                        if~isempty(rowspan)
                            rowspan=str2double(rowspan);
                        else
                            rowspan=1;
                        end

                        if rowspan>1||colspan>1
                            for i=r:r+rowspan-1
                                for j=c:c+colspan-1
                                    occupiedCells=[occupiedCells,{{i,j}}];%#ok<AGROW>
                                end
                            end
                        end

                    end
                end




                if~isempty(row.getFirstChild)
                    tableBody.appendChild(row);
                end
            end

        end

        function appendCellContent(this,row,column,cell,jDoc)
            ce=this.IncludeElements(...
            cellfun(@(a)(a.RowNum==row)&&(a.ColNum==column),...
            this.IncludeElements));
            if isempty(ce)
                block=jDoc.createElement('fo:block');
                cell.appendChild(block);
            else
                ce{1}.appendFormat(cell,jDoc);
            end
        end

    end

end