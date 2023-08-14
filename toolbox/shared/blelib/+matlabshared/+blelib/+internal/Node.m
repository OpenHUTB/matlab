classdef Node<matlab.mixin.internal.TreeNode&matlab.mixin.Heterogeneous




    properties(Access=private)

HasSaveWarningBeenIssued
    end


    methods(Hidden)
        function obj=Node()
        end

        function addChildren(obj,varargin)
            obj.addChildren@matlab.mixin.internal.TreeNode(varargin{:});
        end

        function insertAfter(obj,varargin)
            obj.insertAfter@matlab.mixin.internal.TreeNode(varargin{:});
        end

        function insertBefore(obj,varargin)
            obj.insertBefore@matlab.mixin.internal.TreeNode(varargin{:});
        end

        function output=getParent(obj,varargin)
            output=obj.getParent@matlab.mixin.internal.TreeNode(varargin{:});
        end

        function output=getChildren(obj,varargin)
            output=obj.getChildren@matlab.mixin.internal.TreeNode(varargin{:});
        end

        function output=getPrevious(obj,varargin)
            output=obj.getPrevious@matlab.mixin.internal.TreeNode(varargin{:});
        end

        function output=getNext(obj,varargin)
            output=obj.getNext@matlab.mixin.internal.TreeNode(varargin{:});
        end

        function output=getLastChild(obj,varargin)
            output=obj.getLastChild@matlab.mixin.internal.TreeNode(varargin{:});
        end

        function output=getFirstChild(obj,varargin)
            output=obj.getFirstChild@matlab.mixin.internal.TreeNode(varargin{:});
        end

        function disconnect(obj,varargin)
            obj.disconnect@matlab.mixin.internal.TreeNode(varargin{:});
        end
    end

    methods(Access=protected)
        function delete(~)
        end
    end


    methods(Sealed,Hidden)
        function saveInfo=saveobj(obj)
            saveInfo=[];
            if obj.HasSaveWarningBeenIssued
                return
            end
            obj.HasSaveWarningBeenIssued=true;

            sWarningBacktrace=warning('off','backtrace');
            className=class(obj);
            n=strfind(className,'.');
            if~isempty(n)

                className=className(n(end)+1:end);
            end
            warning(message('MATLAB:ble:ble:nosave',className));
            warning(sWarningBacktrace.state,'backtrace');
        end
    end
end

