classdef ElementFormat<Rptgen.TitlePage.ElementFormat



    methods


        function block=applyFormat(this,jDoc)
            block=jDoc.createElement('div');
            block.setAttribute('class','titlepage')

            style=['font-size:',this.FontSize];
            if(this.IsBold)
                style=[style,';font-weight:bold'];
            end
            if(this.IsItalic)
                style=[style,';font-style:italic'];
            end
            style=[style,';color:',this.Color];
            style=[style,';text-align:',this.HAlign];
            block.setAttribute('style',style);
        end


    end

end