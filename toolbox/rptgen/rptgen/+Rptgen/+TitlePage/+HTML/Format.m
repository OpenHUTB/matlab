classdef Format<Rptgen.TitlePage.Format




    methods

        function this=Format(side)
            this@Rptgen.TitlePage.Format(side);
            this.IncludeElements=...
            {
            Rptgen.TitlePage.HTML.Title(side),...
            Rptgen.TitlePage.HTML.Subtitle(side),...
            Rptgen.TitlePage.HTML.Author(side),...
            Rptgen.TitlePage.HTML.Image(side),...
            Rptgen.TitlePage.HTML.Copyright(side),...
            Rptgen.TitlePage.HTML.PubDate(side),...
            Rptgen.TitlePage.HTML.LegalNotice(side),...
            Rptgen.TitlePage.HTML.Abstract(side)
            };
        end

        function generateTemplateContent(this,jTemplate)
            import com.mathworks.toolbox.rptgencore.tools.RgXmlUtils;
            occupiedCells={};
            RgXmlUtils.removeAllChildren(jTemplate);
            doc=jTemplate.getOwnerDocument();
            node=doc.createComment(Rptgen.TitlePage.saveFormat(this));
            jTemplate.appendChild(node);
            node=doc.createElement('div');
            jTemplate.appendChild(node);


            table=doc.createElement('table');
            node.appendChild(table);
            if this.LayoutGrid.Show
                table.setAttribute('border','1');
            end

            if~isempty(this.LayoutGrid.Width)
                table.setAttribute('width',[this.LayoutGrid.Width,this.LayoutGrid.WidthUnit]);
            end

            if~isempty(this.LayoutGrid.Height)
                table.setAttribute('height',[this.LayoutGrid.Height,this.LayoutGrid.HeightUnit]);
            end



            colwidth=[num2str(100/this.LayoutGrid.NumberOfColumns),'%'];
            for i=1:this.LayoutGrid.NumberOfColumns
                node=doc.createElement('colgroup');
                node.setAttribute('width',colwidth);
                table.appendChild(node);
            end





            rowHeight=[num2str(str2double(this.LayoutGrid.Height)/this.LayoutGrid.NumberOfRows),'in'];
            for r=1:this.LayoutGrid.NumberOfRows
                row=doc.createElement('tr');
                row.setAttribute('height',rowHeight);


                for c=1:this.LayoutGrid.NumberOfColumns
                    cellPreoccupied=occupiedCells(cellfun(@(x)x{1}==r&&x{2}==c,occupiedCells));
                    if isempty(cellPreoccupied)
                        cell=doc.createElement('td');
                        this.appendCellContent(r,c,cell,doc);
                        row.appendChild(cell);


                        colspan=char(cell.getAttribute('colspan'));
                        if~isempty(colspan)
                            colspan=str2double(colspan);
                        else
                            colspan=1;
                        end

                        rowspan=char(cell.getAttribute('rowspan'));
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
                    table.appendChild(row);
                end
            end

        end

        function appendCellContent(this,row,column,cell,jDoc)
            ce=this.IncludeElements(...
            cellfun(@(a)(a.RowNum==row)&&(a.ColNum==column),...
            this.IncludeElements));
            if isempty(ce)
                block=jDoc.createElement('div');
                cell.appendChild(block);
            else
                ce{1}.appendFormat(cell,jDoc);
            end
        end

    end

end