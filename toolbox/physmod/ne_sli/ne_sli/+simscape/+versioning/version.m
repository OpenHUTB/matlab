classdef version<matlab.mixin.CustomDisplay























    properties(SetAccess=private)
        major(1,1)uint32=0;
        minor(1,1)uint32=0;
    end

    properties
        type(1,1)simscape.versioning.VersionType='simscape';
    end

    methods
        function obj=version(varargin)
            narginchk(0,1);
            if nargin==0
                return;
            end
            ver=varargin{1};

            if isnumeric(ver)&&numel(ver)==2
                obj.major=ver(1);
                obj.minor=ver(2);
                return;
            end

            if~((ischar(ver)&&isrow(ver))||...
                (isstring(ver)&&isscalar(ver)))
                pm_error('physmod:ne_sli:versioning:InvalidVersionType');
            end

            vers=strsplit(ver,'.','CollapseDelimiters',false);

            if numel(vers)>2
                pm_error('physmod:ne_sli:versioning:InvalidVersionSyntax');
            end

            obj.major=lMakeVer(vers{1});
            if(numel(vers)>1)
                obj.minor=lMakeVer(vers{2});
            end
        end

        function out=char(obj)
            out=sprintf('%i.%i',obj.major,obj.minor);
        end

        function out=lt(a,b)
            a=lCastVer(a);
            b=lCastVer(b);

            if a.major==b.major
                out=a.minor<b.minor;
            else
                out=a.major<b.major;
            end
        end

        function out=gt(a,b)
            out=lt(b,a);
        end

        function out=eq(a,b)
            out=~lt(a,b)&&~lt(b,a);
        end

        function out=ne(a,b)
            out=~eq(a,b);
        end

        function out=le(a,b)
            out=lt(a,b)||eq(a,b);
        end

        function out=ge(a,b)
            out=le(b,a);
        end

        function[B,I]=sort(A)
            idx=bitshift(uint64([A.major]),32)+uint64([A.minor]);
            [~,I]=sort(idx);
            B=A(I);
        end
    end

    methods(Access=protected)
        function displayScalarObject(obj)
            fprintf('    %i.%i\n\n',obj.major,obj.minor);
        end
    end
end

function out=lMakeVer(ver)
    out=uint32(str2double(ver));
end

function obj=lCastVer(obj)
    if~isa(obj,'simscape.versioning.version')
        obj=simscape.versioning.version(obj);
    end
end