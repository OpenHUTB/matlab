classdef Title<Rptgen.TitlePage.PDF.TextElement




    methods

        function this=Title(side)
            this=this@Rptgen.TitlePage.PDF.TextElement('title',side);
            this.FontSize='24.8832pt';
            this.RowNum=1;
        end

        function xpath=getDefaultXPath(this)%#ok<MANU>
            xpath='bookinfo/title';
        end

        function xform=getDefaultXForm(this)
            xform=sprintf('<xsl:value-of select="%s"/>',...
            getXPath(this));
        end



    end




end