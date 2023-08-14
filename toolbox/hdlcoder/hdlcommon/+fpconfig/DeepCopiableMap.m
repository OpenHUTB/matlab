


classdef DeepCopiableMap<handle&fpconfig.DeepCopiable

    properties(Access=public,Hidden=true)
m_map
    end

    methods(Access=public,Hidden=true)

        function obj=DeepCopiableMap(varargin)
            obj.m_map=containers.Map(varargin{:});
        end
    end

    methods(Access=protected)
        function obj=deepCopy(this)
            obj=fpconfig.DeepCopiableMap('KeyType',this.m_map.KeyType,'ValueType',this.m_map.ValueType);
            keys=this.m_map.keys;
            for i=1:length(keys)
                key=keys{i};
                obj.m_map(key)=fpconfig.DeepCopiable.assign(this.m_map(key));
            end
        end
    end

    methods(Access=public)
        function mcode=serializeToMCode(this)
            keyStr='';
            valStr='';
            keys=this.m_map.keys;
            for i=1:length(keys)
                key=keys{i};
                if(i==1)
                    patten='%s%s';
                else
                    patten='%s, %s';
                end
                keyStr=sprintf(patten,keyStr,fpconfig.DeepCopiable.getString(key));
                valStr=sprintf(patten,valStr,fpconfig.DeepCopiable.getString(this.m_map(key)));
            end
            keyStr=sprintf('{%s}',keyStr);
            valStr=sprintf('{%s}',valStr);

            mcode=sprintf('%s(%s, %s)',class(this),keyStr,valStr);
        end
    end
end
