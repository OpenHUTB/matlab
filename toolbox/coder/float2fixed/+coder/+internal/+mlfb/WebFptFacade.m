classdef(Sealed)WebFptFacade<coder.internal.mlfb.FptFacade






    methods
        function propose(this)




            fpt=this.getFPTInstance();
            if~isempty(fpt)
                fpt.show;
                fpt.triggerProposalFromCodeView;
            end
        end

        function apply(this)




            fpt=this.getFPTInstance();
            if~isempty(fpt)
                fpt.show;
                fpt.triggerApplyFromCodeView;
            end
        end

        function blockObj=getSelectedTreeNode(this)
            fpt=this.getFPTInstance();
            if~isempty(fpt)
                blockObj=fpt.getSelectedTreeNode();
            end
        end

        function resultObj=getSelectedResult(this)
            fpt=this.getFPTInstance();
            if~isempty(fpt)
                resultObj=fpt.getSelectedResult();
            end
        end

        function isSet=isSudSet(this)
            isSet=~isempty(this.getSud());
        end

        function sudObj=getSud(this)
            fpt=this.getFPTInstance();
            if~isempty(fpt)
                sud=fpt.getSystemForConversion();
                sudObj=[];
                if~isempty(sud)
                    sudObj=get_param(sud,'Object');
                end
            end
        end

        function setSystemForConversion(this,blockObject,temporary)
            validateattributes(blockObject,{'DAStudio.Object','Simulink.DABaseObject'},{'scalar'});



            if~temporary
                fpt=this.getFPTInstance();
                if~isempty(fpt)
                    fpt.setSystemForConversion(blockObject.getFullName(),class(blockObject));
                end
            end
        end

        function goToTreeNode(this,qualifiedName)
            validateattributes(qualifiedName,{'char'},{'nonempty'});
            fpt=this.getFPTInstance();
            if~isempty(fpt)
                treeObj=get_param(qualifiedName,'Object');
                fpt.selectTreeNodeInUI(treeObj);
                fpt.show();
            end
        end

        function live=isLive(this)
            live=~isempty(this.getFPTInstance());
        end

        function modelName=getCurrentModelName(this)
            fpt=this.getFPTInstance();
            if~isempty(fpt)
                modelName=fpt.getModel();
            end
        end

        function setAutoscalerWordLength(this,wordLength)
            validateattributes(wordLength,{'numeric'},{'scalar'});
            this.updateFptSetting(coder.internal.mlfb.FptSetting.WordLength,wordLength);
        end

        function setAutoscalerFractionLength(this,fractionLength)
            validateattributes(fractionLength,{'numeric'},{'scalar'});
            this.updateFptSetting(coder.internal.mlfb.FptSetting.FractionLength,fractionLength);
        end

        function setAutoscalerSafetyMargin(this,safetyMargin)
            validateattributes(safetyMargin,{'numeric'},{'scalar'});
            this.updateFptSetting(coder.internal.mlfb.FptSetting.SafetyMargin,safetyMargin);
        end

        function setAutoscalerProposeSignedness(this,proposeSignedness)
            validateattributes(proposeSignedness,{'logical'},{'scalar'});
            this.updateFptSetting(coder.internal.mlfb.FptSetting.ProposeSignedness,proposeSignedness);
        end

        function setAutoscalerProposeWordLength(this,proposeWordLength)
            validateattributes(proposeWordLength,{'logical'},{'scalar'});
            this.updateFptSetting(coder.internal.mlfb.FptSetting.ProposeWordLength,proposeWordLength);
        end

        function cleanupObj=onSudChanged(this,sudChangeCallback)
            fpt=this.getFPTInstance();
            if~isempty(fpt)
                cleanupObj=addlistener(fpt,'UpdateSUDEvent',@(~,~)sudChangeCallback());
            end
        end

        function cleanupObj=onDisposed(this,disposeCallback)
            fpt=this.getFPTInstance();
            if~isempty(fpt)
                cleanupObj=addlistener(fpt,'FPTCloseEvent',@(~,~)disposeCallback());
            end
        end
    end

    methods(Static,Access=private)
        function fpt=getFPTInstance()
            fpt=fxptui.FixedPointTool.getExistingInstance();
        end
    end

    methods(Access=private)
        function updateFptSetting(this,setting,settingValue)
            assert(isa(setting,'coder.internal.mlfb.FptSetting')&&~isjava(settingValue));
            fpt=this.getFPTInstance();
            if~isempty(fpt)




                data=struct(setting.ModelProperty,settingValue);
                fpt.getWorkflowController().updateProposalOptions(data);
            end
        end
    end

end


