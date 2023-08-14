classdef Abstract<Rptgen.TitlePage.PDF.TextElement




    methods

        function this=Abstract(side)
            this@Rptgen.TitlePage.PDF.TextElement('abstract',side);
            this.FontSize='12pt';
            this.RowNum=8;
        end

        function xpath=getDefaultXPath(this)%#ok<MANU>
            xpath='bookinfo/abstract';
        end

        function xform=getDefaultXForm(this)
            xform=['<xsl:value-of select="',getXPath(this),'"/>'];
        end


    end


end