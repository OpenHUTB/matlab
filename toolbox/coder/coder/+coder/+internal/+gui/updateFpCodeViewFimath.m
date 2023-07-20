function updateFpCodeViewFimath(chartObj)


    try
        if~coder.internal.gui.isFixedPointCodeViewOpen()
            return;
        end

        effectiveFimath=[];

        if strcmp(chartObj.EmlDefaultFimath,'Other:UserSpecified')
            try
                effectiveFimath=eval(chartObj.InputFimath);
                if~isa(effectiveFimath,'embedded.fimath')
                    effectiveFimath=[];
                end
            catch
            end
        end

        if isempty(effectiveFimath)
            effectiveFimath=fimath();
        end

        effectiveFimath=regexprep(tostring(effectiveFimath),'\.\.\.\n','');

        emlcprivate('mlfbPublishJavaMessage',...
        Simulink.ID.getSID(chartObj.Path),...
        com.mathworks.toolbox.coder.mlfb.FunctionBlockConstants.STATEFLOW_UI_UPDATE_TOPIC,...
        'stateflowUiUpdate',...
        blockSid,...
        effectiveFimath,...
        ~strcmp(event,'idle'));
    catch me
        if coder.internal.gui.debugmode
            rethrow(me);
        end
    end
end