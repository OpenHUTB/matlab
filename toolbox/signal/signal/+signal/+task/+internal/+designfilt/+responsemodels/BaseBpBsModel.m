classdef(Abstract)BaseBpBsModel<signal.task.internal.designfilt.responsemodels.BaseConstrainedResponseModel




    properties(Access=protected,Transient)
        StateFreqMagProps={'Fpass','F3dB','F6dB','Fstop','Apass','Astop',...
        'Fpass1','F3dB1','F6dB1','Fstop1','Apass1','Astop1',...
        'Fpass2','F3dB2','F6dB2','Fstop2','Apass2','Astop2'};
    end

    methods
        function modelState=getState(this)

            fdesObj=this.pFilterDesignerObj;
            modelState=getState@signal.task.internal.designfilt.responsemodels.BaseConstrainedResponseModel(this);
            propNames=this.StateFreqMagProps;
            for idx=1:numel(propNames)
                if isprop(fdesObj,propNames{idx})
                    modelState.(propNames{idx})=fdesObj.(propNames{idx});
                end
            end
        end

        function setState(this,modelState)

            fdesObj=this.pFilterDesignerObj;
            setState@signal.task.internal.designfilt.responsemodels.BaseConstrainedResponseModel(this,modelState);
            propNames=this.StateFreqMagProps;
            for idx=1:numel(propNames)
                if isprop(fdesObj,propNames{idx})
                    fdesObj.(propNames{idx})=modelState.(propNames{idx});
                end
            end
        end
    end
end

