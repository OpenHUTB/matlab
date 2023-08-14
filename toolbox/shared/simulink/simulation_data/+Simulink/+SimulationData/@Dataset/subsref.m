function varargout=subsref(obj,s)

    try
        switch s(1).type
        case '.'
            obj.utPrivateCheck(s(1).subs);
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
                [varargout{1:nargout}]=obj.get(idx);
            else
                if s(2).type=='.'
                    intermediate=obj.get(idx);
                    curIndex=2;
                    if strcmp(s(2).subs,'Name')&&...
                        obj.utNeedsTransparentElement(intermediate)
                        [~,intermediate]=obj.getElement(idx);
                        curIndex=3;
                    end
                else
                    intermediate=obj.get(idx);
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
    catch me
        throwAsCaller(me);
    end
end

