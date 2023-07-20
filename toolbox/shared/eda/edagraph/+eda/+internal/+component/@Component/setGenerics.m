function setGenerics(this,varargin)





    arg='';
    len=length(varargin{:});












    incr=2;
    for i=1:incr:len
        if incr==3
            arg.(varargin{1}{i}).Type=varargin{1}{i+1};
            arg.(varargin{1}{i}).Value=varargin{1}{i+2};
        else
            arg.(varargin{1}{i})=varargin{1}{i+1};
        end
    end
    if~isempty(arg)
        if~isempty(this.findprop('generic'))
            argField=fieldnames(arg);
            for i=1:length(argField)
                if isfield(this.generic,argField(i))
                    if incr==3
                        this.generic.(argField{i}).instance_Value=arg.(argField{i}).Value;
                        this.generic.(argField{i}).Type=arg.(argField{i}).Type;
                    else
                        this.generic.(argField{i}).instance_Value=arg.(argField{i});

                    end
                else
                    warning(message('EDALink:Component:setGenerics:NoParameterSpecified'));
                end
            end
        else
            if~isempty(arg)
                error(message('EDALink:Component:setGenerics:NoSettableParameter'));
            end
        end

    end
end

