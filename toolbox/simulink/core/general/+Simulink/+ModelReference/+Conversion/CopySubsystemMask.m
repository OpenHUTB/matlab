classdef CopySubsystemMask<handle
    properties(SetAccess=private,GetAccess=private)
Systems
MaskObjects
ConversionData
        ParameterArgumentValues={}
    end

    methods(Access=public)
        function this=CopySubsystemMask(subsys,params)
            this.Systems=subsys;
            this.MaskObjects=arrayfun(@(ss)Simulink.Mask.get(ss),subsys,'UniformOutput',false);
            this.ParameterArgumentValues=cellfun(@(aMask)this.getParameterArgumentValues(aMask),...
            this.MaskObjects,'UniformOutput',false);
            this.ConversionData=params;
        end

        function copy(this,subsys,aModel)
            subsysMaskObj=this.MaskObjects{this.Systems==subsys};
            if~isempty(subsysMaskObj)



                aParamNames=strjoin(get_param(subsys,'MaskNames'),',');
                set_param(aModel,'ParameterArgumentNames',aParamNames);
                aModelMaskObj=Simulink.Mask.get(aModel);
                if isempty(aModelMaskObj)
                    aModelMaskObj=Simulink.Mask.create(aModel);
                end
                aModelMaskObj.copy(subsysMaskObj);


                modelWorkspace=get_param(aModel,'ModelWorkspace');
                arrayfun(@(aParam)Simulink.ModelReference.Conversion.CopySubsystemMask.copyMaskParameter(aParam,modelWorkspace),...
                aModelMaskObj.Parameters);


                this.ConversionData.Logger.addInfo(...
                message('Simulink:modelReferenceAdvisor:CopySubsystemMaskToNewModel',...
                this.ConversionData.beautifySubsystemName(subsys),...
                Simulink.ModelReference.Conversion.MessageBeautifier.beautifyModelName(aModel)));
            end
        end

        function updateModelBlock(this,subsys,modelBlock)
            paramArgValues=this.ParameterArgumentValues{this.Systems==subsys};
            if~isempty(paramArgValues)
                set_param(modelBlock,'ParameterArgumentValues',paramArgValues);
            end
        end
    end

    methods(Static,Access=private)
        function copyMaskParameter(param,modelWorkspace)
            if~modelWorkspace.evalin(sprintf('exist(''%s'')',param.Name))
                modelWorkspace.assignin(param.Name,str2double(param.Value));
            end
        end

        function val=getParameterArgumentValues(aMask)
            if~isempty(aMask)&&~isempty(aMask.Parameters)
                params=aMask.Parameters;
                N=length(params);
                val=params(1).Name;
                for idx=2:N
                    val=sprintf('%s,%s',val,params(idx).Name);
                end
            else
                val='';
            end
        end
    end
end
