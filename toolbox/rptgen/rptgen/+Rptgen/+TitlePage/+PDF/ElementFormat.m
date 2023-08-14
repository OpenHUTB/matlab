classdef ElementFormat<Rptgen.TitlePage.ElementFormat



    methods


        function block=applyFormat(this,jDoc)
            block=jDoc.createElement('fo:block');
            block.setAttribute('xsl:use-attribute-sets','set.titlepage.recto.style');
            block.setAttribute('linefeed-treatment','preserve');
            block.setAttribute('font-family','{$title.fontset}');
            block.setAttribute('font-size',this.FontSize);
            if(this.IsBold)
                block.setAttribute('font-weight','bold');
            end
            if(this.IsItalic)
                block.setAttribute('font-style','italic');
            end
            block.setAttribute('color',this.Color);
            block.setAttribute('text-align',this.HAlign);
        end


    end

end