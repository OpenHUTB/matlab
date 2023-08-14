


classdef ElementCSS<handle
    properties
        selector='';
        id=''
        elementName='';
        className='';
        pv={};
        definition='';
        href='';
    end
    methods
        function obj=ElementCSS(varargin)
            obj.setProperties(nargin,varargin{:});
        end

        function emitStr=emitCss(obj)
            obj.setDefinition;
            emitStr=obj.definition;
        end
    end


    methods(Access=protected)
        function setDefinition(obj)
            isExternal=false;

            switch obj.selector

            case 'type'
                obj.definition=sprintf('%s {\n',obj.elementName);



            case 'class'
                obj.definition=sprintf('%s.%s {\n',obj.elementName,obj.className);
            case 'id'
                obj.definition=sprintf('#%s %s {\n',obj.id,obj.elementName);
            case 'external'
                isExternal=true;
                obj.definition=sprintf('<link href="%s" type="text\\css" rel="stylesheet"/>\n',obj.href);
            otherwise
                obj.definition='';
            end

            if~isExternal

                obj.definition=[obj.definition,obj.emitProperties];


                obj.definition=[obj.definition,sprintf('}\n\n')];
            end
        end
        function emitStr=emitProperties(obj)
            emitStr='';
            for ii=1:length(obj.pv)
                pvpair=obj.pv{ii};
                prop=pvpair{1};
                val=pvpair{2};
                emitStr=[emitStr,sprintf('\t%s: %s;\n',prop,val)];
            end
        end
        function setProperties(obj,narg,varargin)

            for ii=1:2:narg
                assert(mod(narg,2)==0);
                if isprop(obj,varargin{ii})
                    obj.(varargin{ii})=varargin{ii+1};
                else
                    obj.pv{end+1}={varargin{ii},varargin{ii+1}};
                end
            end
        end
    end


end
