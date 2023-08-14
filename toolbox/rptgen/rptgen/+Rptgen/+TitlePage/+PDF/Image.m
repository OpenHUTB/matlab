classdef Image<Rptgen.TitlePage.Element&Rptgen.TitlePage.PDF.ElementLayout




    methods

        function this=Image(side)
            this=this@Rptgen.TitlePage.Element('image',side);
            this=this@Rptgen.TitlePage.PDF.ElementLayout();
            this.RowNum=3;
        end

        function xpath=getDefaultXPath(this)%#ok<MANU>
            xpath='bookinfo/mediaobject';
        end

        function xform=getDefaultXForm(this)
            xform=['<xsl:apply-templates mode="book.titlepage.'...
            ,this.Side,'.auto.mode" select="',getXPath(this),'"/>'];
        end

        function appendFormat(this,cell,jDoc)
            appendFormat@Rptgen.TitlePage.PDF.ElementLayout(this,cell,jDoc);
            block=jDoc.createElement('fo:block');
            cell.appendChild(block);
            choose=jDoc.createElement('xsl:choose');
            block.appendChild(choose);
            when=jDoc.createElement('xsl:when');
            when.setAttribute('test',getXPath(this));
            choose.appendChild(when);
            apply=getParsedXForm(this,jDoc);
            when.appendChild(apply);
        end

        function save(this,elCE)
            save@Rptgen.TitlePage.Element(this,elCE);
            save@Rptgen.TitlePage.PDF.ElementLayout(this,elCE);
        end

        function loadSelf(this,elCE)
            loadSelf@Rptgen.TitlePage.Element(this,elCE);
            loadSelf@Rptgen.TitlePage.PDF.ElementLayout(this,elCE);
        end



    end




end