
classdef CircuitElement<handle&matlab.mixin.CustomDisplay






    properties(Hidden)
Name
    end
    properties(Hidden,SetAccess=protected)
        Ports={}
Terminals
    end
    properties(Hidden,Dependent,SetAccess=protected)
NumPorts
    end


    properties(Hidden,SetAccess=protected)
Parent
    end
    properties(Abstract,Constant,Access=protected)
HeaderDescription
    end
    properties(Abstract,Constant,Hidden)
DefaultName
    end


    methods
        function obj=CircuitElement(varargin)
            narginchk(0,1)

            [varargin{:}]=convertStringsToChars(varargin{:});

            if nargin
                obj.Name=varargin{1};
            else
                obj.Name=obj.DefaultName;
            end


            obj.Parent=[];
            initializeTerminalsAndPorts(obj)
        end
    end


    methods
        function outobj=serdesClone(inobj)


            outobj=localClone(inobj);


            outobj.Name=inobj.Name;
        end
    end


    methods
        function numports=get.NumPorts(obj)
            numports=numel(obj.Ports);
        end
    end


    methods
        function set.Name(obj,newName)
            serdes.internal.apps.serdesdesigner.validateMLname(newName,'Name')

            ckt=obj.Parent;%#ok<MCSUP>
            if~isempty(ckt)
                replaceName(ckt,obj.Name,newName)
            end

            obj.Name=newName;
        end
    end


    methods(Hidden,Access=protected,Sealed=true)

        function footer=getFooter(obj)
            footer=getFooter@matlab.mixin.CustomDisplay(obj);
        end
        function displayNonScalarObject(obj)
            displayNonScalarObject@matlab.mixin.CustomDisplay(obj);
        end
    end


    methods(Abstract,Hidden,Access=protected)
        initializeTerminalsAndPorts(obj)
        plist1=getLocalPropertyList(obj)
        outobj=localClone(inobj)
    end


    methods(Sealed)
        function varargout=ne(varargin)
            varargout{:}=ne@handle(varargin{:});
        end
        function varargout=eq(varargin)
            varargout{:}=eq@handle(varargin{:});
        end
    end

end