classdef Copyright<Rptgen.TitlePage.HTML.TextElement




    methods

        function this=Copyright(side)
            this@Rptgen.TitlePage.HTML.TextElement('copyright',side);
            this.FontSize='8pt';
            this.RowNum=5;
        end

        function xpath=getDefaultXPath(this)%#ok<MANU>
            xpath='bookinfo/copyright';
        end

        function xform=getDefaultXForm(this)
            xform=sprintf('<xsl:text>Copyright &#169; </xsl:text><xsl:value-of select="%s/year"/><xsl:text>&#160;</xsl:text><xsl:value-of select="%s/holder"/>',...
            getXPath(this),getXPath(this));
        end



    end




end