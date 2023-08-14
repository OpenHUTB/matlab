classdef ModelCompInfo<handle




    properties(GetAccess=public,SetAccess=private)
ModelMexCompInfo
ToolchainInfo
ModelMexCompilerKey
    end

    methods(Access=private,Static=true)

        function lCompInfo=createModelCompInfoPrivate...
            (ignoreError,mdl,lDefaultMexCompInfo,allowLcc)

            cs=getActiveConfigSet(mdl);
            [lMexCompilerKey,lToolchainInfo,lToolchainInfoError]=...
            coder.internal.getMexCompilerForModel...
            (cs,lDefaultMexCompInfo);
            if~allowLcc&&strcmp(lMexCompilerKey,'LCC-x')
                lMexCompilerKey='';
            end
            lModelMexCompInfo=coder.make.internal.getMexCompInfoFromKey...
            (lMexCompilerKey);

            if~ignoreError&&isempty(lMexCompilerKey)
                if~isempty(lToolchainInfoError)



                    exc=MException('coder_compile:toolchain:SelectedToolchainNotInRegistry',...
                    lToolchainInfoError);
                    exc.throw;
                end
                if~isempty(lToolchainInfo)&&...
                    isa(lToolchainInfo,'coder.make.internal.adapter.targetframework.CMakeToolchain')




                    filter=configset.internal.util.ToolchainListFilter(cs);
                    origTc=lToolchainInfo.getWrappedObject;
                    registryAdapter=coder.make.internal.targetframework.ToolchainRegistryAdapter(origTc);
                    tcGroup=coder.make.internal.groupToolchainsByConfig(registryAdapter,filter);
                    if tcGroup==coder.make.enum.ToolchainGroup.BOARD_NOT_COMPATIBLE
                        compatibleBoards=strjoin(registryAdapter.Board,newline);
                        error(message('coder_compile:toolchain:SelectedToolchainNotCompatibleWithBoard',...
                        lToolchainInfo.Name,...
                        get_param(cs,'HardwareBoard'),...
                        compatibleBoards));
                    elseif tcGroup==coder.make.enum.ToolchainGroup.PROCESSOR_NOT_COMPATIBLE
                        compatibleProcessors=strjoin(registryAdapter.TargetHWDeviceType,newline);
                        error(message('coder_compile:toolchain:SelectedToolchainNotCompatibleWithHW',...
                        lToolchainInfo.Name,...
                        get_param(cs,'TargetHWDeviceType'),...
                        compatibleProcessors));
                    end
                end
            end

            lCompInfo=coder.internal.ModelCompInfo...
            (lModelMexCompInfo,lToolchainInfo,lMexCompilerKey);
        end

    end

    methods(Access=public,Static=true)

        function varargout=createModelCompInfoIgnoreError(varargin)

            ignoreError=true;
            [varargout{1:nargout}]=...
            coder.internal.ModelCompInfo.createModelCompInfoPrivate...
            (ignoreError,varargin{:});
        end

        function varargout=createModelCompInfo(varargin)

            ignoreError=false;
            [varargout{1:nargout}]=...
            coder.internal.ModelCompInfo.createModelCompInfoPrivate...
            (ignoreError,varargin{:});
        end
    end

    methods(Access=private)

        function this=ModelCompInfo(lModelMexCompInfo,lToolchainInfo,...
            lMexCompilerKey)
            this.ModelMexCompInfo=lModelMexCompInfo;
            this.ToolchainInfo=lToolchainInfo;
            this.ModelMexCompilerKey=lMexCompilerKey;
        end

    end
end
