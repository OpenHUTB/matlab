classdef(CaseInsensitiveProperties=true,TruncatedProperties=true)Table<Advisor.Table

    methods(Access='public')

        function this=Table(row,column)


            this=this@Advisor.Table(row,column);
            this.CollapsibleMode='systemdefined';
            this.setAttribute('class','AdvTable');
        end

        function setBorder(this,size)


            if isnumeric(size)&&size>=0






                if size==0
                    this.setAttribute('class','AdvTableNoBorder');
                    this.Border=0;
                else
                    this.setAttribute('class','AdvTable');
                    this.Border=size;
                end
            else
                DAStudio.error('Advisor:engine:MATableBorderNeedInteger');
            end
        end

    end
end

