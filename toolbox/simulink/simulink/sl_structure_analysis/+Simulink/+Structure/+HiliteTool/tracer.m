classdef tracer<handle



















    properties(Access=public,Hidden=true)
hiliteObj
    end

    methods(Access=public)



        function obj=tracer(varargin)




            obj.hiliteObj=Simulink.Structure.HiliteTool.HiliteTree(varargin{:});
        end



        function traceToSource(this)



            if(isvalid(this.hiliteObj))
                this.hiliteObj.hiliteToSrc;
            end
        end



        function this=traceToAllSources(this,varargin)
            if(isvalid(this.hiliteObj))
                if isempty(varargin)
                    this.hiliteObj.traceToAllSrcsOrDsts(true);
                else
                    this.hiliteObj.traceToAllSrcsOrDsts(true,varargin{1});
                end
            end
        end



        function traceToDestination(this)




            if(isvalid(this.hiliteObj))
                this.hiliteObj.hiliteToDest;
            end
        end



        function this=traceToAllDestinations(this,varargin)
            if(isvalid(this.hiliteObj))
                if isempty(varargin)
                    this.hiliteObj.traceToAllSrcsOrDsts(false);
                else
                    this.hiliteObj.traceToAllSrcsOrDsts(false,varargin{1});
                end
            end
        end



        function removeHighlighting(this)



            if(isvalid(this.hiliteObj))
                this.hiliteObj.clearStylingAndResetTree;
            end
        end



        function togglePortDisplay(this,togglePortsOnTraceAllPath)




            if isvalid(this.hiliteObj)
                this.hiliteObj.togglePortDisplay(togglePortsOnTraceAllPath);
            end
        end



        function undoTrace(this)

            if(isvalid(this.hiliteObj))
                this.hiliteObj.undoPreviousTrace;
            end
        end



        function delete(obj)



            delete(obj.hiliteObj);
        end



        function toggleUp(this)
            if(isvalid(this.hiliteObj))
                this.hiliteObj.toggleUp;
            end
        end



        function toggleDown(this)
            if(isvalid(this.hiliteObj))
                this.hiliteObj.toggleDown;
            end
        end



        function undoTraceAllStyling(this)
            if(isvalid(this.hiliteObj))
                removeTraceAllStyling(this.hiliteObj);
            end
        end
    end

end

