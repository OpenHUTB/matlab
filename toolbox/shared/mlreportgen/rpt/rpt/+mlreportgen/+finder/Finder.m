classdef(Abstract,Hidden)Finder<matlab.mixin.SetGet






    properties


Container




























        Properties cell;
    end

    properties(Abstract,Constant,Hidden)
        InvalidPropertyNames;
    end

    methods
        function h=Finder(varargin)
            n=numel(varargin);
            if(n==0)
                error(message("mlreportgen:finder:error:containerNotSpecified"));
            elseif(n==1)
                h.Container=varargin{1};
            elseif(mod(n,2)==0)
                for i=1:2:n

                    name=char(varargin{i});
                    value=varargin{i+1};
                    h.(name)=value;
                end
            else
                error(message("mlreportgen:finder:error:mustBePropertyPairs"))
            end

            if isempty(h.Container)
                error(message("mlreportgen:finder:error:containerNotSpecified"));
            end
        end

        function set.Container(h,val)
            mustNotBeIterating(h,"Container");
            h.Container=val;
            reset(h);
        end

        function set.Properties(h,properties)
            mustNotBeIterating(h,"Properties");
            n=numel(properties);
            if(mod(n,2)>0)
                error(message("mlreportgen:finder:error:mustBePropertyPairs"));
            end

            invalidPropNames=lower(h.InvalidPropertyNames);
            for i=1:2:n
                pName=properties{i};
                if(~ischar(pName)&&~isstring(pName))
                    error(message("mlreportgen:finder:error:invalidPropertyNameMustBeString",i));
                end

                pName=string(pName);
                if(startsWith(pName,"-"))
                    error(message("mlreportgen:finder:error:invalidPropertyNameMustNotStartsWithDash",...
                    pName));
                end

                if(~isempty(invalidPropNames)&&ismember(lower(pName),invalidPropNames))
                    error(message("mlreportgen:finder:error:invalidPropertyNameMustNotBeMemberOf",...
                    pName,...
                    prettyPrintInvalidPropertyNames(h)));
                end
            end
            h.Properties=properties(:)';
            reset(h);
        end
    end

    methods(Abstract)
        result=next(h);

        tf=hasNext(h);

        results=find(h);
    end

    methods(Access=protected,Abstract)
        tf=isIterating(h);

        reset(h);
    end

    methods(Access=protected)
        function tf=satisfyObjectPropertiesConstraint(h,obj)
            tf=true;
            if~isempty(obj)
                nProps=numel(h.Properties);
                for j=1:2:nProps
                    propName=h.Properties{j};
                    propValue=h.Properties{j+1};

                    try
                        objValue=get(obj,propName);
                        if ischar(objValue)
                            tf=strcmp(objValue,propValue);
                        else
                            tf=all(objValue==propValue);
                        end
                    catch
                        tf=false;
                    end

                    if~tf
                        break;
                    end
                end
            end
        end

        function mustNotBeIterating(h,varargin)
            if isIterating(h)
                if isempty(varargin)
                    error(message("mlreportgen:finder:error:mustNotModifyPropertiesWhileIterating"));
                else
                    error(message("mlreportgen:finder:error:mustNotModifyPropertyNameWhileIterating",...
                    varargin{1}));
                end
            end
        end
    end

    methods(Access=private)
        function str=prettyPrintInvalidPropertyNames(h)
            str=string(newline)...
            +string(newline)...
            +join(strcat("     ",h.InvalidPropertyNames),newline);
        end
    end
end

