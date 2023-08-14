classdef NDInterp<controldesign.blockconfig.NDLookUp






    methods(Access=public)

        function this=NDInterp(BlockPath)

            if~(strcmp(get_param(BlockPath,'TableSource'),'Dialog')&&...
                strcmp(get_param(BlockPath,'NumSelectionDims'),'0'))


                error(message('Slcontrol:controldesign:NDInterp1',BlockPath))
            end
            this.BlockPath=BlockPath;

            [precompiled,ModelParameterMgr]=this.preprocessModel(getModelName(this));
            try
                feature('EngineInterface',Simulink.EngineInterfaceVal.byFiat)
                r=get_param(BlockPath,'RunTimeObject');

                ndim=r.NumInputPorts/2;
                this.NDIM_=ndim;

                p=RuntimePrm(r,1);
                this.SLMaskParameters_=struct('Name',p.Name,'Value',p.Data,'Tunable','on');

                initialize(this)

                ph=get_param(BlockPath,'PortHandles');
                BreakPointData=cell(1,ndim);
                for ct=1:ndim
                    p=get(ph.Inport(2*ct),'Object');
                    GainSrc=p.getActualSrc;GainSrc=GainSrc(1);
                    PLU=get_param(GainSrc,'Parent');
                    if~(strcmp(get_param(PLU,'BlockType'),'PreLookup')&&...
                        strcmp(get_param(PLU,'BreakpointsDataSource'),'Dialog'))
                        error(message('Slcontrol:controldesign:NDInterp2',BlockPath))
                    end
                    r=get_param(PLU,'RunTimeObject');
                    p=RuntimePrm(r,1);
                    BreakPointData{ct}=p.Data;
                end
                this.BreakPoints_=BreakPointData;

                this.postprocessModel(precompiled,ModelParameterMgr)
            catch ME
                this.postprocessModel(precompiled,ModelParameterMgr)
                throw(ME)
            end
        end

    end

end
