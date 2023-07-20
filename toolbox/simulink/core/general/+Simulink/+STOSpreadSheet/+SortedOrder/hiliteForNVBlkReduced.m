classdef hiliteForNVBlkReduced<handle













    properties(Access=private)
        BD,
currentBD
    end

    methods


        function obj=hiliteForNVBlkReduced(bd,currentBD)
            obj.BD=bd;
            obj.currentBD=currentBD;
        end

        function setCurrentBD(obj,bd)
            obj.currentBD=bd;
        end




        function delete(obj)
            set_param(obj.BD,'NVBlockReducedDisplay','off');
            Simulink.STOSpreadSheet.SortedOrder.NVBlockReducedDisplaySource.removeStyler(obj.BD);
            Simulink.STOSpreadSheet.SortedOrder.NVBlockReducedDisplaySource.removeStyler(obj.currentBD);
        end
    end

    methods




        function highlightingElements(obj,BD,currentBD,varargin)
            import Simulink.STOSpreadSheet.SortedOrder.*
            elements=varargin{:};
            obj.validateElementsForHighlighting(currentBD,elements');
            Simulink.STOSpreadSheet.SortedOrder.NVBlockReducedDisplaySource.applyStyler(currentBD,elements');
        end
    end

    methods(Access=private)





        function validateElementsForHighlighting(~,BD,elements)
            import Simulink.STOSpreadSheet.SortedOrder.*
            if~all(ishandle(elements))||any(elements==0)||~isValidObject(elements)
                ME=sltrace.utils.createMException('Simulink:HiliteTool:InvalidHandleForHighlighting');
                throw(ME);
            end

            for i=1:length(elements)
                element=elements(i);
                try
                    mdl=getBaseGraph(element);
                    mdlH=get_param(mdl,'handle');
                catch
                    ME=sltrace.utils.createMException('Simulink:HiliteTool:InvalidHandleForHighlighting');
                    throw(ME);
                end
                if mdlH~=BD
                    ME=sltrace.utils.createMException('Simulink:HiliteTool:ElementNotInBD',element,mdl,getfullname(BD));
                    throw(ME);
                end
            end
        end

    end
end


function value=isValidObject(elements)
    value=true;
    for i=1:length(elements)
        element=elements(i);
        try
            get_param(element,'Object');
        catch
            value=false;
            return;
        end
    end
end

function baseGraph=getBaseGraph(block)
    baseGraph=block;
    if isa(block,'Simulink.BlockPath')
        blockParent=block.getParent;
    else
        blockParent=get_param(block,'Parent');
    end
    if isempty(blockParent)
        return;
    end
    baseGraph=sltrace.utils.getBaseGraph(blockParent);
end