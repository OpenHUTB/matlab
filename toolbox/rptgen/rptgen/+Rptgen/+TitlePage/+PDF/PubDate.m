classdef PubDate<Rptgen.TitlePage.PDF.TextElement




    methods

        function this=PubDate(side)
            this@Rptgen.TitlePage.PDF.TextElement('pubdate',side);
            this.FontSize='8pt';
            this.RowNum=6;
        end

        function xpath=getDefaultXPath(this)%#ok<MANU>
            xpath='bookinfo/pubdate';
        end

        function xform=getDefaultXForm(this)
            xform=sprintf('<xsl:text>Publication date </xsl:text><xsl:value-of select="%s"/>',...
            getXPath(this));
        end


    end




end