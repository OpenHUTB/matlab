classdef highlight<handle













    properties(Access=private)
Stylers
    end

    methods


        function obj=highlight()
            obj.Stylers={};
        end




        function delete(obj)
            for i=1:numel(obj.Stylers)
                Simulink.SLHighlight.removeHighlight(obj.Stylers{i});
            end
            obj.Stylers={};
        end
    end

    methods




        function highlighting(obj,BD,traceMap,originBlock,varargin)
            if isempty(varargin)
                options={'HighlightColor',[1,1,0]};
            end
            keys=traceMap.keys;
            stylers=cell(1,length(keys));
            for i=1:length(keys)
                key=keys{i};
                elements=traceMap(key);
                stylers{i}=Simulink.SLHighlight.highlightSegments(elements,BD,options{:});
            end

            if~isempty(obj.Stylers)
                obj.Stylers=[obj.Stylers,stylers];
            else
                obj.Stylers=stylers;
            end

            try
                open_system(get(originBlock,'Parent'),'tab');
            catch
                open_system(BD,'tab');
            end
        end


        function highlightingElements(obj,BD,varargin)
            import sltrace.utils.*
            options={'HighlightColor',[1,0,0]};
            elements=varargin{:};

            obj.validateElementsForHighlighting(BD,elements);

            styler=Simulink.SLHighlight.highlightSegments(elements,BD,options{:});

            if~isempty(obj.Stylers)
                obj.Stylers=[obj.Stylers,styler];
            else
                obj.Stylers={styler};
            end


            try
                open_system(get(elements(1),'Parent'),'tab');
            catch
                open_system(BD,'tab');
            end

        end
    end

    methods(Access=private)





        function validateElementsForHighlighting(~,BD,elements)
            import sltrace.utils.*
            if~all(ishandle(elements))||any(elements==0)||~isValidObject(elements)
                ME=createMException('Simulink:HiliteTool:InvalidHandleForHighlighting');
                throw(ME);
            end

            for i=1:length(elements)
                element=elements(i);
                try
                    mdl=getBaseGraph(element);
                    mdlH=get_param(mdl,'handle');
                catch
                    ME=createMException('Simulink:HiliteTool:InvalidHandleForHighlighting');
                    throw(ME);
                end
                if mdlH~=BD
                    ME=createMException('Simulink:HiliteTool:ElementNotInBD',element,mdl,getfullname(BD));
                    throw(ME);
                end
            end
        end
    end
end