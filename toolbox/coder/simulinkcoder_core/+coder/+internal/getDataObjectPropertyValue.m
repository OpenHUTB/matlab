function retVal=getDataObjectPropertyValue(modelName,objectName,param,varargin)













    retVal={false,[]};

    try
        [varExists,object]=coder.internal.evalObject(modelName,objectName);
        if varExists

            if isa(object,'Simulink.Breakpoint')
                switch param
                case 'Max'
                    value=object.Breakpoints.Max;
                case 'Min'
                    value=object.Breakpoints.Min;
                case 'Unit'
                    value=object.Breakpoints.Unit;
                case 'Description'
                    value=object.Breakpoints.Description;
                case 'NumValues'
                    value=num2str(numel(object.Breakpoints.Value));
                case{'Values','BreakpointValues'}
                    value=object.Breakpoints.Value;
                otherwise
                    value=[];
                end
            elseif isa(object,'Simulink.LookupTable')
                switch param
                case 'Max'
                    value=object.Table.Max;
                case 'Min'
                    value=object.Table.Min;
                case 'Unit'
                    value=object.Table.Unit;
                case 'Description'
                    value=object.Table.Description;
                case 'NumValues'
                    value=num2str(numel(object.Table.Value));
                case 'Values'
                    value=object.Table.Value;
                case 'BreakpointValues'
                    if(size(varargin)>0)
                        idx=varargin{1};
                        value=object.Breakpoints(idx).Value;
                    end
                case 'BreakpointUnit'
                    if size(varargin)>0
                        idx=varargin{1};
                        value=object.Breakpoints(idx).Unit;
                    end
                case 'BreakpointsSpecification'
                    value=object.BreakpointsSpecification;
                otherwise
                    value=[];
                end
            elseif isa(object,'Simulink.Signal')
                switch param
                case 'Max'
                    value=object.Max;
                case 'Min'
                    value=object.Min;
                case 'Unit'
                    value=object.Unit;
                case 'Description'
                    value=object.Description;
                case 'NumValues'
                    value=num2str(numel(eval(object.InitialValue)));
                case 'Values'
                    value=eval(object.InitialValue);
                otherwise
                    value=[];
                end
            elseif isa(object,'Simulink.Parameter')
                switch param
                case 'Max'
                    value=object.Max;
                case 'Min'
                    value=object.Min;
                case 'Unit'
                    value=object.Unit;
                case 'Description'
                    value=object.Description;
                case 'NumValues'
                    value=num2str(numel(object.Value));
                case{'Values','BreakpointValues'}
                    value=object.Value;
                otherwise
                    value=[];
                end
            else
                switch param
                case 'Unit'
                    value='';
                case 'Values'
                    value=object;
                otherwise
                    value=[];
                end
            end
            retVal{1}=true;
            if isa(value,'Simulink.data.Expression')
                try
                    value=eval(value.ExpressionString);
                catch
                    retVal{1}=false;
                    value=[];
                end
            end
            retVal{2}=value;
        end
    catch
        retVal{1}=false;
        retVal{2}=[];
    end
end