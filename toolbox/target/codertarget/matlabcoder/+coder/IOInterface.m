classdef IOInterface<hgsetget












    properties(Access='public')


        Name='';
    end
    properties(Access='public',Hidden)
        Target=[];
    end
    methods
        function obj=set.Name(obj,name)
            if~ischar(name)||isempty(name)
                error(message('codertarget:targetapi:IOInterfaceNameInvalidType'));
            end
            obj.Name=name;
        end
    end
end
