classdef Abstract<Rptgen.TitlePage.HTML.TextElement




    methods

        function this=Abstract(side)
            this@Rptgen.TitlePage.HTML.TextElement('abstract',side);
            this.FontSize='24.8832pt';
            this.RowNum=1;
        end

        function xpath=getDefaultXPath(this)%#ok<MANU>
            xpath='bookinfo/abstract';
        end

        function xform=getDefaultXForm(this)
            xform=['<xsl:value-of select="',getXPath(this),'"/>'];
        end



    end




end