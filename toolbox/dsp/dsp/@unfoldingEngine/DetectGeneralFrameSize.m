function frames_length=DetectGeneralFrameSize(obj)



    frames_length=1;


    if any(obj.data.FrameInputs)
        sz=[];
        for i=1:numel(obj.data.TopFunctionInputs)
            if obj.data.TopFunctionInputs{i}.VarFrame
                if isempty(sz)
                    sz=obj.data.TopFunctionInputs{i};
                    szidx=i;
                else
                    coder.internal.errorIf(any(sz.VarType.LogInfo.Size~=obj.data.TopFunctionInputs{i}.VarType.LogInfo.Size),...
                    'dsp:dspunfold:InputFramesNotSameSize',num2str(szidx),num2str(i),obj.data.TopFunctionName);
                end
            end
        end
        if~isempty(sz)
            frames_length=double(sz.VarType.LogInfo.Size(1));
        end
    end




