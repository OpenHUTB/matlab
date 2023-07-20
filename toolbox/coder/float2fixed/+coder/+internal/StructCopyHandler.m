


classdef StructCopyHandler<handle
    properties(Access=private)


copyStructMap
    end

    methods(Access=public)
        function this=StructCopyHandler()
            this.copyStructMap=coder.internal.lib.Map();
        end


        function addCopyStruct(this,key,value)
            this.copyStructMap(key)=value;
        end



        function[code,me]=getCode(this)
            code='';
            me=[];
            keys=this.copyStructMap.keys;
            for ii=1:length(keys)
                key=keys{ii};
                code=[code,char(10),this.copyStructMap(key)];%#ok<AGROW>
            end
        end
    end
end