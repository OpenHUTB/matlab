

function varargout=gpucGetGuiOptions(key,type,varargin)

    persistent hasGpuCoder;
    if isempty(hasGpuCoder)
        hasGpuCoder=~isempty(which('coder.gpu.getGUIOptions'));
    end

    if hasGpuCoder
        if(isempty(varargin)||(nargin~=4))
            [varargout{1:nargout}]=coder.gpu.getGUIOptions(key,type);
        else
            param=varargin{1};
            pval=varargin{2};
            [varargout{1:nargout}]=coder.gpu.getGUIOptions(key,type);

            if(strcmp(param,'Toolchain')&&~ispc)
                if(contains(pval,'NVIDIA CUDA for Jetson Tegra K1'))
                    varargout{1}={'3.2'};
                    varargout{2}='3.2';
                elseif(contains(pval,'NVIDIA CUDA for Jetson Tegra X1'))
                    varargout{1}={'5.3'};
                    varargout{2}='5.3';
                elseif(contains(pval,'NVIDIA CUDA for Jetson Tegra X2'))
                    varargout{1}={'6.2'};
                    varargout{2}='6.2';
                end
            end
        end
    elseif nargout==2
        varargout={{''},''};
    elseif strcmp(type,'logical')
        varargout={false};
    else
        varargout={''};
    end
end
