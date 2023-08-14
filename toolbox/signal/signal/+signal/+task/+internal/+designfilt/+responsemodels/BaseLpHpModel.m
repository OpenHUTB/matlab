classdef(Abstract)BaseLpHpModel<signal.task.internal.designfilt.responsemodels.BaseConstrainedResponseModel





    methods
        function modelState=getState(this)

            fdesObj=this.pFilterDesignerObj;
            modelState=getState@signal.task.internal.designfilt.responsemodels.BaseConstrainedResponseModel(this);
            propNames={'Fpass','F3dB','F6dB','Fstop','Apass','Astop'};
            for idx=1:numel(propNames)
                modelState.(propNames{idx})=fdesObj.(propNames{idx});
            end
        end

        function setState(this,modelState)

            fdesObj=this.pFilterDesignerObj;
            setState@signal.task.internal.designfilt.responsemodels.BaseConstrainedResponseModel(this,modelState);
            propNames={'Fpass','F3dB','F6dB','Fstop','Apass','Astop'};
            for idx=1:numel(propNames)
                fdesObj.(propNames{idx})=modelState.(propNames{idx});
            end
        end
    end

    methods(Access=protected)
        function s=getActiveFrequencyConstraints(this)
            fdesObj=this.pFilterDesignerObj;
            constraints=lower(fdesObj.FrequencyConstraints);
            s=struct;
            s.hasFpass=contains(constraints,'passband edge');
            s.hasFstop=contains(constraints,'stopband edge');
            s.hasF3db=contains(constraints,'3db point');
            s.hasF6db=contains(constraints,'6db point');
        end
    end
end

