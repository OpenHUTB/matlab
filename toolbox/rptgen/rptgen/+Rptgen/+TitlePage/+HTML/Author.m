classdef Author<Rptgen.TitlePage.HTML.TextElement




    methods

        function this=Author(side)
            this@Rptgen.TitlePage.HTML.TextElement('author',side);
            this.RowNum=4;
        end

        function xpath=getDefaultXPath(this)%#ok<MANU>
            xpath='bookinfo/author/firstname';
        end

        function xform=getDefaultXForm(this)
            xform=['<xsl:value-of select="',getXPath(this),'"/>'];
        end



    end




end