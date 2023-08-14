classdef Frame<Advisor.Element

    properties(Access='public')
    end


    methods(Access='public')


        function this=Frame()
            this.setTag('frame');
        end


        function setSrc(this,src)
            this.setAttribute('src',src);
        end


        function setFrameBorder(this,value)
            if value
                this.setAttribute('frameborder','1');
            else
                this.setAttribute('frameborder','0');
            end
        end

    end
end

