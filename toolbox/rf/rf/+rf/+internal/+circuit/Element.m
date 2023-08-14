classdef Element<handle&matlab.mixin.Heterogeneous&...
    matlab.mixin.CustomDisplay







    properties
Name
    end
    properties(SetAccess=protected)
        Ports={}
Terminals
        ParentNodes=[]
    end
    properties(Dependent,SetAccess=protected)
ParentPath
NumPorts
    end


    properties(Hidden,SetAccess=protected)
Parent
    end
    properties(Hidden,Dependent,SetAccess=protected)
FullPath
    end
    properties(Abstract,Constant,Access=protected)
HeaderDescription
DefaultName
    end


    methods
        function obj=Element(varargin)
            narginchk(0,1)

            [varargin{:}]=convertStringsToChars(varargin{:});

            if nargin
                obj.Name=varargin{1};
            else
                obj.Name=obj.DefaultName;
            end

            obj.Parent=circuit.empty;
            initializeTerminalsAndPorts(obj)
        end
    end


    methods
        function outobj=clone(inobj)


            outobj=localClone(inobj);


            outobj.Name=inobj.Name;
        end
    end


    methods
        function parentpath=get.ParentPath(obj)
            if isempty(obj.Parent)
                parentpath='';
            else
                parentpath=obj.Parent.FullPath;
            end
        end

        function fullpath=get.FullPath(obj)
            fullpath=obj.Name;
            if~isempty(obj.Parent)
                fullpath=[obj.ParentPath,'/',fullpath];
            end
        end

        function numports=get.NumPorts(obj)
            numports=numel(obj.Ports);
        end
    end


    methods
        function set.Name(obj,newName)
            newName=convertStringsToChars(newName);
            rf.internal.validateMLname(newName,'Name')

            ckt=obj.Parent;%#ok<MCSUP>
            if~isempty(ckt)
                replaceName(ckt,obj.Name,newName)
            end

            obj.Name=newName;
        end
    end

    properties(Access=protected)
        ShowCircuitProperties=false
    end


    methods(Access=protected,Sealed=true)
        function str=getHeader(obj)
            if~isscalar(obj)
                str=getHeader@matlab.mixin.CustomDisplay(obj);
            else
                link=matlab.mixin.CustomDisplay.getClassNameForHeader(obj);
                desc=obj.HeaderDescription;
                str=sprintf('  %s: %s element\n',link,desc);
            end
        end

        function group=getPropertyGroups(obj)
            if~isscalar(obj)
                plist={'Name','Terminals','ParentNodes','ParentPath'};
                group=matlab.mixin.util.PropertyGroup(plist);
            else
                plist=getLocalPropertyList(obj);
                plist.Name=obj.Name;
                numports=obj.NumPorts;
                if numports
                    plist.NumPorts=numports;
                end
                if~isempty(obj.Terminals)
                    plist.Terminals=obj.Terminals;
                end
                if~isempty(obj.Parent)
                    plist.ParentNodes=obj.ParentNodes;
                    plist.ParentPath=obj.ParentPath;
                end
                group=matlab.mixin.util.PropertyGroup(plist);
            end
        end


        function footer=getFooter(obj)
            footer=getFooter@matlab.mixin.CustomDisplay(obj);
        end
        function displayNonScalarObject(obj)
            displayNonScalarObject@matlab.mixin.CustomDisplay(obj);
        end
    end


    methods(Hidden)
        function numreqterms=getNumRequiredTerminals(obj)


            numreqterms=numel(obj.Terminals)-obj.NumPorts;
        end

        function updateParentInfo(elem,newName,ckt,pnodes)

            elem.Name=newName;
            elem.Parent=ckt;
            elem.ParentNodes=pnodes;
        end
    end
    methods(Static,Hidden)
        function validateCellNameList(namelist,nametype)
            validateattributes(namelist,{'cell'},{'row'},'',sprintf('the %s List',nametype))
            nlist=numel(namelist);
            for n=1:nlist
                namelist{n}=convertStringsToChars(namelist{n});
                rf.internal.validateMLname(namelist{n},sprintf('%s Name',nametype))
            end
            if numel(unique(namelist))~=nlist

                error(message('rf:rfcircuit:element:validateCellNameList:NamesNotUnique',nametype))
            end
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
