classdef LegalNotice<Rptgen.TitlePage.HTML.TextElement




    methods

        function this=LegalNotice(side)
            this@Rptgen.TitlePage.HTML.TextElement('legalnotice',side);
            this.FontSize='24.8832pt';
            this.RowNum=1;
        end

        function xpath=getDefaultXPath(this)%#ok<MANU>
            xpath='bookinfo/legalnotice';
        end

        function xform=getDefaultXForm(this)
            xform=['<xsl:apply-templates mode="book.titlepage.'...
            ,this.Side,'.auto.mode" select="',getXPath(this),'"/>'];
        end


    end




end