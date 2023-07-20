classdef Copyright<Rptgen.TitlePage.PDF.TextElement




    methods

        function this=Copyright(side)
            this@Rptgen.TitlePage.PDF.TextElement('copyright',side);
            this.FontSize='8pt';
            this.RowNum=5;
        end

        function xpath=getDefaultXPath(this)%#ok<MANU>
            xpath='bookinfo/copyright';
        end

        function xform=getDefaultXForm(this)
            xform=['<xsl:text>Copyright &#169; </xsl:text><xsl:value-of select="'...
            ,getXPath(this),'/year"/><xsl:text>&#160;</xsl:text><xsl:value-of select="'...
            ,getXPath(this),'/holder"/>'];
        end


    end




end