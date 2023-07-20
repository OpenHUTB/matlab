classdef ElementLayout<handle



    properties

        RowNum=1
        ColNum=1
        ColSpan=1
        RowSpan=1

    end

    methods


        function save(this,elCE)
            elCE.setAttribute('rownum',num2str(this.RowNum));
            elCE.setAttribute('colnum',num2str(this.ColNum));
            elCE.setAttribute('colspan',num2str(this.ColSpan));
            elCE.setAttribute('rowspan',num2str(this.RowSpan));
        end

        function loadSelf(this,elCE)
            this.RowNum=str2double(char(elCE.getAttribute('rownum')));
            this.ColNum=str2double(char(elCE.getAttribute('colnum')));
            this.ColSpan=str2double(char(elCE.getAttribute('colspan')));
            this.RowSpan=str2double(char(elCE.getAttribute('rowspan')));
        end


    end


end