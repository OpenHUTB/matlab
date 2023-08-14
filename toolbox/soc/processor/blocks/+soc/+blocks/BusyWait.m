classdef BusyWait<matlab.System&coder.ExternalDependency






%#codegen


    properties(Nontunable)

        what=uint16(0);

        durpercent=double([100,0.0,0.0,0.0,0.0]);

        durmin=double([0.055,0.0,0.0,0.0,0.0]);

        durmean=double([0.055,0.0,0.0,0.0,0.0]);

        durmax=double([0.055,0.0,0.0,0.0,0.0]);

        durstd=double([0,0.0,0.0,0.0,0.0]);
    end


    properties(Access=private)
        tnow;
    end

    methods

        function obj=BusyWait(varargin)
            coder.allowpcode('plain');

            setProperties(obj,nargin,varargin{:})
        end
    end

    methods(Access=protected)

        function setupImpl(obj)

            if~isequal(sum(obj.what),0)&&~isequal(sum(obj.what),1)
                error('Measuring point must be 0 or 1');
            end
            if obj.what==1
                if~isequal(sum(obj.durpercent),100)
                    error('All duration percents must add up to 100');
                end
                if~isequal(sort(obj.durpercent,'descend'),obj.durpercent)
                    error('All duration percents must be given in descending order');
                end
                if any(obj.durpercent<0)
                    error('All duration percents must be positive');
                end

                if any(obj.durmean<0)
                    error('All duration means must be positive');
                end

                if any(obj.durmin<0)
                    error('All duration lower limits means must be positive');
                end

                if any(obj.durmax<0)
                    error('All duration upper limits means must be positive');
                end

                if any(obj.durstd<0)
                    error('All duration standard deviations must be positive');
                end

                for i=1:5
                    if~isequal(obj.durpercent(i),0)
                        if(obj.durmean(i)<obj.durmin(i))
                            error('Duration mean must be greater than duration lower limit');
                        end
                        if(obj.durmean(i)>obj.durmax(i))
                            error('Duration mean must not be greater than duration lower limit');
                        end
                        if(obj.durmean(i)<=obj.durstd(i))
                            error('Duration standard deviation must be smaller than duration mean');
                        end
                    end
                end
            end
        end

        function y=stepImpl(obj,u)
            if coder.target('rtw')
                coder.ceval('mw_busywait',...
                uint16(obj.what),...
                obj.durpercent,...
                obj.durmean,...
                obj.durmin,...
                obj.durmax,...
                obj.durstd);
            end
            y=u;
        end

        function resetImpl(~)

        end

        function validateInputsImpl(~,varargin)
            if coder.target('MATLAB')
                mdlName=bdroot(gcb);
                if codertarget.utils.isBaremetal(mdlName)||...
                    ~(isequal(codertarget.data.getParameterValue(mdlName,'RTOS'),'Linux')||...
                    isequal(codertarget.data.getParameterValue(mdlName,'RTOS'),'Generic RTOS'))
                    error('soc:blocks:BusyWait_NonLinuxRTOS','Block is expected to run on hardware board with Linux as platform. Selected hardware board for the model is selected to run either with no RTOS or non-Linux RTOS. Please select valid hardware board running with Linux as RTOS.');
                end
            end
        end


        function s=saveObjectImpl(obj)



            s=saveObjectImpl@matlab.System(obj);



        end

        function loadObjectImpl(obj,s,wasLocked)






            loadObjectImpl@matlab.System(obj,s,wasLocked);
        end



        function flag=isInputSizeMutableImpl(~,~)


            flag=false;
        end

        function out=getOutputSizeImpl(obj)

            out=propagatedInputSize(obj,1);
        end

        function icon=getIconImpl(~)

            icon=mfilename("class");



        end
    end

    methods(Static,Access=protected)

        function header=getHeaderImpl

            header=matlab.system.display.Header(mfilename("class"));
        end

        function group=getPropertyGroupsImpl

            group=matlab.system.display.Section(mfilename("class"));
        end
    end

    methods(Static)s
        function name=getDescriptiveName()
            name='SOC Busy Wait';
        end

        function b=isSupportedContext(context)
            b=context.isCodeGenTarget('rtw');
        end

        function updateBuildInfo(buildInfo,context)
            if context.isCodeGenTarget('rtw')
                srcRoot=fullfile(matlabroot,'toolbox','target','codertarget','rtos');
                addIncludePaths(buildInfo,fullfile(srcRoot,'inc'));
                addIncludeFiles(buildInfo,'mw_busywait.h');
                systemTargetFile=get_param(buildInfo.ModelName,'SystemTargetFile');
                if isequal(systemTargetFile,'ert.tlc')
                    addSourcePaths(buildInfo,fullfile(srcRoot,'src'));
                    addSourceFiles(buildInfo,'mw_busywait.c',fullfile(srcRoot,'src'),'BlockModules');
                end
            end
        end
    end

end


