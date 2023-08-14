function varargout=subsref(obj,s)
    try
        switch s(1).type
        case '.'
            obj.utPrivateCheck(s(1).subs,true);
            [varargout{1:nargout}]=builtin('subsref',obj,s);
        case '()'
            s(1).subs=obj.utReplacePDatasetEndIndex(s(1).subs);

            if length(s)==1
                [varargout{1:nargout}]=builtin('subsref',obj,s);
            else


                intermediate=builtin('subsref',obj,s(1));
                [varargout{1:nargout}]=Simulink.SimulationData.utSubsrefRecurser(...
                intermediate,s(2:end));
            end
        case '{}'
            idx=obj.utGetIndexFromSubs(s,true);
            if length(s)==1
                [varargout{1:nargout}]=obj.getAsDatastore(idx);
            else
                if s(2).type=='.'
                    if strcmp(s(2).subs,'Name')
                        [~,intermediate]=obj.getAsDatastore(idx);
                        curIndex=3;
                    else
                        intermediate=obj.getAsDatastore(idx);
                        curIndex=2;
                    end
                else
                    intermediate=obj.getAsDatastore(idx);
                    curIndex=2;
                end

                if(curIndex<=numel(s))


                    [varargout{1:nargout}]=...
                    Simulink.SimulationData.utSubsrefRecurser(intermediate,s(curIndex:end));
                else
                    varargout{1}=intermediate;
                end
            end
        end
    catch ME
        throwAsCaller(ME);
    end
end

