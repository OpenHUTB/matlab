function out=getParam(obj,name,varargin)




    if nargin>2
        testParamName=varargin{1};
    else
        testParamName=true;
    end

    if testParamName&&~obj.ParamMap.isKey(name)
        error(['Parameter ''',name,''' is not defined']);
    end

    out=obj.ParamMap(name);

    if iscell(out)

        list=out;
        out={};
        for i=1:length(list)
            if list{i}.isFeatureActive
                if isempty(out)
                    out=list{i};
                else
                    if iscell(out)
                        out{end+1}=list{i};
                    else
                        out={out,list{i}};
                    end
                end
            end
        end
        if isempty(out)
            error(['Parameter ''',name,''' is not defined']);
        end
    end

