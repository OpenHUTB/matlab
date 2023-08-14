classdef LegalNotice<Rptgen.TitlePage.PDF.TextElement




    methods

        function this=LegalNotice(side)
            this@Rptgen.TitlePage.PDF.TextElement('legalnotice',side);
            this.FontSize='12';
            this.RowNum=7;
        end

        function xpath=getDefaultXPath(this)%#ok<MANU>
            xpath='bookinfo/legalnotice';
        end

        function xform=getDefaultXForm(this)
            xform=['<xsl:value-of select="',getXPath(this),'"/>'];
        end



    end




end