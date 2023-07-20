classdef Title<Rptgen.TitlePage.HTML.TextElement




    methods

        function this=Title(side)
            this@Rptgen.TitlePage.HTML.TextElement('title',side);
            this.FontSize='24.8832pt';
            this.RowNum=1;
        end

        function xpath=getDefaultXPath(this)%#ok<MANU>
            xpath='bookinfo/title';
        end

        function xform=getDefaultXForm(this)%#ok<MANU>
            xform='<xsl:call-template name="division.title"/>';
        end


    end




end