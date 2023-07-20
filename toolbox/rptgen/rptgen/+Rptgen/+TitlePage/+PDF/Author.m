classdef Author<Rptgen.TitlePage.PDF.TextElement




    methods

        function this=Author(side)
            this@Rptgen.TitlePage.PDF.TextElement('author',side);
            this.RowNum=4;
            this.FontSize='17.28pt';
        end

        function xpath=getDefaultXPath(this)%#ok<MANU>
            xpath='bookinfo/author/firstname';
        end

        function xform=getDefaultXForm(this)
            xform=['<xsl:value-of select="',getXPath(this),'"/>'];
        end

    end




end