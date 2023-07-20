
function prevVal=feature(name,varargin)



    prevVal=true;
    if strcmpi(name,'JIT Coverage')
        prevVal=sf('feature','JIT Coverage');
        if(numel(varargin)<1)
            return
        end
        val=varargin{1};

        if val
            sf('feature','JIT Coverage',1);
        else
            sf('feature','JIT Coverage',0);
        end
    elseif strcmpi(name,'sldvfilter')
        prevVal=strcmp(cv('Feature','enable sldv filter'),'on');
        if(numel(varargin)<1)
            return
        end
        val=varargin{1};
        if val
            cv('Feature','enable sldv filter','on');
        else
            cv('Feature','enable sldv filter','off');
        end
    elseif strcmpi(name,'justification')
        prevVal=strcmp(cv('Feature','enable justification'),'on');
        if(numel(varargin)<1)
            return
        end
        val=varargin{1};
        if val
            cv('Feature','enable justification','on');
        else
            cv('Feature','enable justification','off');
        end
    elseif strcmpi(name,'autosave')
        prevVal=strcmp(cv('Feature','enable auto save'),'on');
        if(numel(varargin)<1)
            return
        end
        val=varargin{1};
        if val
            cv('Feature','enable auto save','on');
        else
            cv('Feature','enable auto save','off');
        end
    elseif strcmpi(name,'results')
        prevVal=strcmp(cv('Feature','enable results ui'),'on');
        if(numel(varargin)<1)
            return
        end
        val=varargin{1};
        if val
            cv('Feature','enable results ui','on');
        else
            cv('Feature','enable results ui','off');
        end
    end
end
