function opVar=deepCopy(var,varargin)
















    persistent p
    if isempty(p)
        p=inputParser;
        p.FunctionName='Simulink.variant.utils.deepCopy';
        p.StructExpand=false;
        p.PartialMatching=false;
        addParameter(p,'ErrorForNonCopyableHandles',...
        true,@(x)validateattributes(x,{'logical'},{}));
    end

    if isa(var,'struct')
        opVar=repmat(struct(),size(var));
        fieldNames=fieldnames(var);
        for f=1:numel(fieldNames)
            for s=1:numel(var)
                opVar(s).(fieldNames{f})=Simulink.variant.utils.deepCopy(var(s).(fieldNames{f}),varargin{:});
            end
        end
    elseif isa(var,'cell')
        opVar=cell(size(var));
        for i=1:numel(var)
            opVar{i}=Simulink.variant.utils.deepCopy(var{i},varargin{:});
        end
    elseif isa(var,'Simulink.VariantControl')

        opVar=slvariants.internal.config.utils.deepCopyVariantControl(var);
    elseif isa(var,'handle')
        try
            parse(p,varargin{:});
            errorForNonCopyableHandles=p.Results.ErrorForNonCopyableHandles;
        catch ME
            throwAsCaller(ME);
        end
        if isa(var,'matlab.mixin.Copyable')||errorForNonCopyableHandles

            opVar=copy(var);
        else
            opVar=var;
        end
    else
        opVar=var;
    end
end
