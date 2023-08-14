function obj=subsasgn(obj,s,varargin)



    switch s(1).type
    case '.'


        obj.utPrivateCheck(s(1).subs);
        obj=builtin('subsasgn',obj,s,varargin{:});
    case '()'

        if isempty(obj)&&isnumeric(obj)&&length(s)==1
            obj=Simulink.SimulationData.Dataset.empty(0);
        end

        s(1).subs=obj.utReplacePDatasetEndIndex(s(1).subs);
        if length(s)==1||s(2).type~='.'
            obj=builtin('subsasgn',obj,s,varargin{:});
        else


            obj.utPrivateCheck(s(2).subs);
            obj=builtin('subsasgn',obj,s,varargin{:});
        end

    case '{}'
        idx=obj.utGetIndexFromSubs(s,false);

        if length(s)==1
            if~obj.utNeedsTransparentElement(varargin{:})
                obj=obj.setElement(idx,varargin{:});
            else
                obj=obj.setElement(idx,varargin{:},'');
            end
        elseif strcmp(s(2).type,'.')
            val=obj.getElement(idx);
            if obj.utNeedsTransparentElement(val)

                [~,name]=obj.getElement(idx);
                if~strcmp(s(2).subs,'Name')


                    obj=obj.setElement(idx,...
                    Simulink.SimulationData.utSubsasgnRecurser(val,s(2:end),...
                    varargin{:}),name);
                else
                    obj=obj.setElement(idx,val,varargin{:});
                end
            else


                obj=obj.setElement(idx,...
                Simulink.SimulationData.utSubsasgnRecurser(val,s(2:end),...
                varargin{:}));
            end
        else
            val=obj.getElement(idx);
            if obj.utNeedsTransparentElement(val)

                [~,name]=obj.getElement(idx);


                obj=obj.setElement(idx,...
                Simulink.SimulationData.utSubsasgnRecurser(val,s(2:end),...
                varargin{:}),name);
            else


                obj=obj.setElement(idx,...
                Simulink.SimulationData.utSubsasgnRecurser(val,s(2:end),...
                varargin{:}));
            end
        end
    otherwise
        error('Not a valid indexing expression')
    end
end

