classdef TextElement<Rptgen.TitlePage.Element&Rptgen.TitlePage.HTML.ElementLayout&Rptgen.TitlePage.HTML.ElementFormat



    methods

        function this=TextElement(name,side)
            this=this@Rptgen.TitlePage.Element(name,side);
            this=this@Rptgen.TitlePage.HTML.ElementLayout();
            this=this@Rptgen.TitlePage.HTML.ElementFormat();
        end

        function appendFormat(this,cell,jDoc)
            appendFormat@Rptgen.TitlePage.HTML.ElementLayout(this,cell,jDoc);
            choose=jDoc.createElement('xsl:choose');
            cell.appendChild(choose);
            when=jDoc.createElement('xsl:when');
            when.setAttribute('test',getXPath(this));
            choose.appendChild(when);
            block=applyFormat(this,jDoc);
            when.appendChild(block);
            block.appendChild(getParsedXForm(this,jDoc));
        end


        function save(this,elCE)
            save@Rptgen.TitlePage.Element(this,elCE);
            save@Rptgen.TitlePage.HTML.ElementLayout(this,elCE);
            save@Rptgen.TitlePage.HTML.ElementFormat(this,elCE);
        end

        function loadSelf(this,elCE)
            loadSelf@Rptgen.TitlePage.Element(this,elCE);
            loadSelf@Rptgen.TitlePage.HTML.ElementLayout(this,elCE);
            loadSelf@Rptgen.TitlePage.HTML.ElementFormat(this,elCE);
        end

    end


end