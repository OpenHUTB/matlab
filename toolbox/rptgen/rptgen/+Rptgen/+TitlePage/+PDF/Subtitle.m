classdef Subtitle<Rptgen.TitlePage.PDF.TextElement




    methods

        function this=Subtitle(side)
            this=this@Rptgen.TitlePage.PDF.TextElement('subtitle',side);
            this.RowNum=2;
        end

        function xpath=getDefaultXPath(this)%#ok<MANU>
            xpath='bookinfo/subtitle';
        end

        function xform=getDefaultXForm(this)
            xform=['<xsl:value-of select="',getXPath(this),'"/>'];
        end


    end




end