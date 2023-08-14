function varargout=subsref(h,S)




    if strcmp(S(1).type,'()')
        if~isempty(h.TsValue)
            if length(S)==1
                tsObj=h.copy;
                tsObj.TsValue=subsref(h.TsValue,S);
                varargout{1}=tsObj;
            elseif strcmp(S(2).type,'.')&&...
                any(strcmp(S(2).subs,{'BlockPath','PortIndex','SignalName','ParentName','RegionInfo'}))
                varargout{1}=get(h,S(2).subs);
            else
                varargout{1}=subsref(h.TsValue,S);
            end
        else
            varargout{1}=[];
        end
    else
        if nargout>0
            varargout=cell(1,nargout);
            [varargout{:}]=builtin('subsref',h,S);
        else
            ans=[];
            builtin('subsref',h,S);
            if~isempty(ans)
                varargout{1}=ans;
            end
        end
    end
