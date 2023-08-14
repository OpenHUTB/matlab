classdef ElementFormat<handle



    properties

        FontSize='24.8832pt'
        IsBold=true
        IsItalic=false
        Color='black'
        HAlign='center'

    end

    methods


        function save(this,elCE)
            elCE.setAttribute('font-size',this.FontSize);
            if this.IsBold
                elCE.setAttribute('font-weight','bold');
            else
                elCE.setAttribute('font-weight','normal');
            end
            if this.IsItalic
                elCE.setAttribute('font-style','italic');
            else
                elCE.setAttribute('font-style','normal');
            end
            elCE.setAttribute('color',this.Color);
            elCE.setAttribute('halign',this.HAlign);
        end

        function loadSelf(this,elCE)
            this.FontSize=char(elCE.getAttribute('font-size'));
            if strcmp(char(elCE.getAttribute('font-weight')),'bold')
                this.IsBold=true;
            end
            if strcmp(char(elCE.getAttribute('font-style')),'italic')
                this.IsItalic=true;
            end
            this.Color=char(elCE.getAttribute('color'));
            this.HAlign=char(elCE.getAttribute('halign'));
        end


    end

end