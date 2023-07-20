classdef CustomSliceFunction<images.automation.volume.Algorithm



    properties(Constant)

        Name=getString(message('images:segmenter:defaultName'));

        Description=getString(message('images:segmenter:defaultDescription'));

        Icon=matlab.ui.internal.toolstrip.Icon(fullfile(matlabroot,'toolbox','images','imuitools','+images','+internal','+app','+segmenter','+volume','+icons','Volume_CustomSlice_24.png'));

        ExecutionMode='slice';

        UseScaledVolume=false;

    end

    properties


FunctionHandle


FunctionHandleWithNoMask

    end

    methods




        function labels=run(obj,I,labels)


            mask=labels==obj.SelectedLabel;


            try
                mask=obj.FunctionHandle(I,mask);
            catch ME

                if strcmp(ME.identifier,'MATLAB:TooManyInputs')&&numel(ME.stack)>1&&strcmp(ME.stack(2).name,'CustomSliceFunction.run')
                    mask=obj.FunctionHandleWithNoMask(I);
                else
                    throw(ME);
                end

            end


            labels(labels==obj.SelectedLabel)=missing;


            labels(logical(mask))=obj.SelectedLabel;

        end

    end

end

