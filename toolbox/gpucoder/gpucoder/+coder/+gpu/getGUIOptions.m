function varargout=getGUIOptions(param,type)



    persistent GPU_CODER_DEFAULTS;
    if isempty(GPU_CODER_DEFAULTS)
        GPU_CODER_DEFAULTS=coder.GpuCodeConfig;
    end

    if isprop(GPU_CODER_DEFAULTS,param)
        value=GPU_CODER_DEFAULTS.(param);
        if strcmp(type,'logical')&&isa(value,'logical')
            resp=value;
            varargout={resp};
        elseif strcmp(type,'char')&&isa(value,'char')
            default=value;
            if(nargout>1)
                entries=coder.GpuCodeConfig.getOptions(param);
                varargout={entries;default};
            else
                varargout={default};
            end
        else
            varargout={};
        end
    else
        if strcmp(type,'logical')
            resp=false;
            varargout={resp};
        elseif strcmp(type,'char')
            default='No options available';
            entries={default};
            varargout={entries;default};
        else
            varargout={};
        end
    end
end
