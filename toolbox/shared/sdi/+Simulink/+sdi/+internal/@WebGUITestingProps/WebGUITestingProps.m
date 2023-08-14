



classdef WebGUITestingProps<handle


    methods


        function val=get(this,prop)
            assert(strcmpi(prop,'Visible'));
            val=this.Visible;
        end

    end


    properties(Hidden)
        Visible='off';
    end

end

