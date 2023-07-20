classdef subcheck_jc_0281<slcheck.subcheck
    properties(Access=private)
        Mode=1;
        SupportStateflow=false;
    end

    properties(Access=private,Constant)



    end

    methods
        function obj=subcheck_jc_0281(InitParams)
            obj.CompileMode='None';
            obj.Licenses={''};
            obj.ID=InitParams.Name;
            obj.Mode=InitParams.Mode;
            obj.SupportStateflow=InitParams.Stateflow;
        end

        function result=run(this)
            result=false;

            blockHandle=this.getEntity();
            if isempty(blockHandle)
                return;
            end

            triggerPortBlock=get(blockHandle);

            if~strcmp('TriggerPort',triggerPortBlock.BlockType)
                return;
            end

            subsystem=get_param(triggerPortBlock.Parent,'Object');

            if~isprop(subsystem,'PortHandles')
                return;
            end





            if(Stateflow.SLUtils.isStateflowBlock(...
                get_param(triggerPortBlock.Parent,'handle')))
                if~this.SupportStateflow
                    return;
                end
            else
                if this.SupportStateflow
                    return;
                end
            end

            [mOrigin,mTrigger,mSignal,mSubsystem]=deal(false);
            switch(this.Mode)
            case 1
                [mOrigin,mTrigger]=deal(true);
            case 2
                [mOrigin,mSubsystem]=deal(true);
            case 3
                [mSignal,mTrigger]=deal(true);
            case 4
                [mSignal,mSubsystem]=deal(true);
            otherwise
            end

            signal=get_param(subsystem.PortHandles.Trigger,'Line');

            if mOrigin

                if isempty(signal)||-1==signal
                    return;
                end

                srcBlkHndl=get_param(signal,'SrcBlockHandle');

                if isempty(srcBlkHndl)
                    return;
                end

                if-1==srcBlkHndl
                    return;
                end

                sourceName=get_param(srcBlkHndl,'Name');
                sourceNameToCompare=lower(regexprep(sourceName,...
                '[^a-zA-Z0-9\s]',''));
            end

            if mTrigger
                destinationName=get_param(blockHandle,'Name');
                destinationNameToCompare=lower(regexprep(destinationName,...
                '[^a-zA-Z0-9\s]',''));
            end

            if mSignal

                if isempty(signal)||-1==signal
                    return;
                end

                sourceName=get_param(signal,'Name');
                if isempty(sourceName)

                    sigObj=get_param(signal,'object');
                    if sigObj.ShowPropagatedSignals
                        sourceName=get_param(sigObj.SrcPortHandle,'PropagatedSignals');
                    end
                end
                sourceNameToCompare=lower(regexprep(sourceName,...
                '[^a-zA-Z0-9\s]',''));
            end

            if mSubsystem
                destinationName=subsystem.Name;
                destinationNameToCompare=lower(regexprep(destinationName,...
                '[^a-zA-Z0-9\s]',''));
            end

            minimumLength=3;

            editDistance=ModelAdvisor.internal.getEditDistanceStrings(...
            sourceNameToCompare,destinationNameToCompare);

            sLen=length(sourceNameToCompare);
            dLen=length(destinationNameToCompare);

            if sLen>dLen
                checkLen=sLen;
            else
                checkLen=dLen;
            end

            if checkLen<minimumLength
                status=editDistance>0;
            else
                status=(checkLen-editDistance)<minimumLength;
            end

            if status
                vObj=slcheck.setResultDefaults(this,ModelAdvisor.ResultDetail);
                ModelAdvisor.ResultDetail.setData(vObj,'SID',blockHandle);
                result=this.setResult(vObj);
            end

        end
    end
end