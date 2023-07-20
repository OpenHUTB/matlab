function varargout=subsref(h,S)







    members=get(h,'Members');
    if strcmp(S(1).type,'()')


        if length(S(1).subs)>1
            error(message('Simulink:Timeseries:onedsubsref'))
        end

        if ischar(S(1).subs{1})
            I=1:length(members);
        elseif~isempty(S(1).subs{1})
            I=S(1).subs{1};
            if isnumeric(I)&&(any(I<1)||any(I>length(members))||~isequal(round(I),I))
                error(message('Simulink:Timeseries:invind'))
            elseif islogical(I)
                I=find(I);
            end
        else
            tsout=[];
            return
        end


        tsvec=cell(length(I),1);
        for k=1:length(I)
            tsvec{k}=get(h,members(k).name);
        end


        if length(I)>0
            tsout=Simulink.TsArray;
            initialize(tsout,'Subsref',tsvec{:});
            varargout{1}=localBuiltinSubsref(tsout,S);
        else
            tsout=[];
            return
        end

    elseif strcmp(S(1).type,'{}')


        if length(S(1).subs)>1
            error(message('Simulink:Timeseries:onedsubsref'))
        end
        if~isempty(S(1).subs{1})
            I=S(1).subs{1};
            if~isnumeric(I)||length(I)~=1||I>length(members)||I<1||~isequal(round(I),I)
                error(message('Simulink:Timeseries:scalar'))
            end
            tsout=get(h,members(I).name);
            varargout{1}=localBuiltinSubsref(tsout,S);
        else
            tsout=[];
            return
        end
    elseif strcmp(S(1).subs,'unpack')







        for k=1:length(members)
            elementName=members(k).name;
            assignin('caller',elementName,get(h,elementName));
        end

    else



        isproperty=~isempty(h.findprop(S(1).subs));
        if isproperty,
            obj=get(h,S(1).subs);
        else
            obj=h;
        end

        if nargout==0
            if isproperty
                ans=[];
                if length(S)>1
                    ans=subsref(obj,S(2:end));
                else
                    ans=obj;
                end
                if~isempty(ans)
                    varargout{1}=ans;
                end
            else
                builtin('subsref',h,S)
            end
        else
            varargout=cell(1,nargout);
            if isproperty
                if length(S)>1
                    varargout{:}=subsref(obj,S(2:end));
                else
                    varargout{:}=obj;
                end
            else
                varargout{:}=builtin('subsref',h,S);
            end
        end
    end


    function varargout=localBuiltinSubsref(ts,S)


        if length(S)>1
            varargout{1}=subsref(ts,S(2:end));
        else
            varargout{1}=ts;
        end


