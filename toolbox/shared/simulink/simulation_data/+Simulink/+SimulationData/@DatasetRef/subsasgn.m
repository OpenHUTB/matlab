function obj=subsasgn(obj,s,varargin)




    try
        switch s(1).type
        case '.'


            obj.utPrivateCheck(s(1).subs,false);


            if numel(s)>2&&ischar(s(end).subs)
                switch s(1).subs
                case 'getAsDatastore'
                    switch s(end).subs
                    case 'ReadSize'


                        if ischar(s(2).subs)
                            intermediate=obj.getAsDatastore(s(2).subs);
                        else
                            intermediate=obj.getAsDatastore(s(2).subs{:});
                        end
                        isReadSize=locRecurser(intermediate,s(3:end));
                        if isReadSize
                            intermediate=builtin('subsasgn',intermediate,s(3:end),varargin{:});
                            return;
                        else
                            obj=builtin('subsasgn',obj,s,varargin{:});
                        end
                    otherwise
                        obj=builtin('subsasgn',obj,s,varargin{:});
                    end
                otherwise
                    obj=builtin('subsasgn',obj,s,varargin{:});
                end
            else
                obj=builtin('subsasgn',obj,s,varargin{:});
            end

            obj=builtin('subsasgn',obj,s,varargin{:});
        case '()'

            if isempty(obj)&&isnumeric(obj)&&length(s)==1
                obj=Simulink.SimulationData.DatasetRef.empty(0);
            end

            s(1).subs=obj.utReplacePDatasetEndIndex(s(1).subs);
            if length(s)==1||s(2).type~='.'
                obj=builtin('subsasgn',obj,s,varargin{:});
            else


                obj.utPrivateCheck(s(2).subs,false);
                obj=builtin('subsasgn',obj,s,varargin{:});
            end
        case '{}'
            if numel(s)>1&&ischar(s(end).subs)
                switch s(end).subs
                case 'ReadSize'
                    s(1).subs=obj.utReplaceBDatasetEndIndex(s(1).subs);



                    intermediate=obj.getAsDatastore(s(1).subs{:});
                    isReadSize=locRecurser(intermediate,s(2:end));
                    if isReadSize
                        intermediate=builtin('subsasgn',intermediate,s(2:end),varargin{:});
                        return;
                    else
                        locThrowReadOnlyException();
                    end
                otherwise
                    locThrowReadOnlyException();
                end
            else
                locThrowReadOnlyException();
            end
        otherwise
            error('Not a valid indexing expression')
        end
    catch ME
        throwAsCaller(ME);
    end

end

function isReadSize=locRecurser(obj,s)


    curIndex=1;
    switch s(1).type
    case '.'
        if numel(s)==1
            isReadSize=locCheckType(obj,s(curIndex:end));
            return;
        elseif~strcmp(s(2).type,'()')
            intermediate=builtin('subsref',obj,s(1));
            curIndex=2;
        else

            intermediate=builtin('subsref',obj,s(1:2));
            curIndex=3;
        end

        if curIndex<=numel(s)
            isReadSize=locRecurser(intermediate,s(curIndex:end));
            return;
        else
            isReadSize=false;
            return;
        end

    case '()'
        if numel(s)==1
            isReadSize=false;
            return;
        else
            intermediate=builtin('subsref',obj,s(1));
            isReadSize=locRecurser(intermediate,s(2:end));
            return;
        end

    case '{}'
        if numel(s)==1
            isReadSize=false;
            return;
        else
            intermediate=builtin('subsref',obj,s(1));
            isReadSize=locRecurser(intermediate,s(2:end));
            return;
        end
    end

end


function isReadSize=locCheckType(obj,s)
    switch s(1).type
    case '.'
        switch s(1).subs
        case 'ReadSize'
            switch class(obj)
            case 'matlab.io.datastore.SimulationDatastore'
                isReadSize=true;
            otherwise
                isReadSize=false;
            end
        otherwise
            isReadSize=false;
        end
    otherwise
        isReadSize=false
    end
end

function locThrowReadOnlyException
    id='SimulationData:Objects:DatasetRefElementsAreReadOnly';
    ME=MException(id,message(id).getString());
    throwAsCaller(ME);
end
