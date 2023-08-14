function fxptToolShowResultInCodeView()



    codeView=coder.internal.mlfb.gui.CodeViewManager.getActiveCodeView();
    if isempty(codeView)
        codeView=coder.internal.mlfb.gui.fxptToolOpenCodeView();
    end

    if~isempty(codeView)
        assert(isa(codeView,'coder.internal.mlfb.gui.CodeViewManager'));
        [matlabResult,mlfbSid]=coder.internal.mlfb.gui.MlfbUtils.getSelectedListViewResult();

        if~isempty(matlabResult)
            assert(~isempty(mlfbSid)&&ischar(mlfbSid));
            identifier=matlabResult.getUniqueIdentifier();




            if isa(identifier,'fxptds.MATLABExpressionIdentifier')&&...
                ~isempty(identifier.MATLABFunctionIdentifier)

                import coder.internal.mlfb.gui.MessageTopics;
                fcnIdentifier=identifier.MATLABFunctionIdentifier;
                if fcnIdentifier.NumberOfInstances>1
                    fcnSpec=fcnIdentifier.InstanceCount;
                else
                    fcnSpec=0;
                end
                blockId=coder.internal.mlfb.idForBlock(mlfbSid);

                if isa(identifier,'fxptds.MATLABVariableIdentifier')&&~isempty(identifier.VariableName)
                    if identifier.NumberOfInstances>1
                        varSpec=identifier.InstanceCount;
                    else
                        varSpec=0;
                    end
                    codeView.publishToCodeView(MessageTopics.CodeViewManipulation,...
                    'selectVariable',...
                    blockId,...
                    identifier.VariableName,...
                    varSpec,...
                    fcnIdentifier.ScriptPath,...
                    fcnIdentifier.FunctionName,...
                    fcnSpec,...
                    matlabResult.getRunName());
                    codeView.show();
                else

                    codeView.publishToCodeView(MessageTopics.CodeViewManipulation,...
                    'selectFunction',...
                    blockId,...
                    fcnIdentifier.ScriptPath,...
                    fcnIdentifier.FunctionName,...
                    fcnSpec,...
                    matlabResult.getRunName());
                    codeView.publishToCodeView(MessageTopics.CodeViewManipulation,...
                    'highlightText',identifier.TextStart(1),identifier.TextLength(1));
                    codeView.show();
                end
            end
        end
    end
end