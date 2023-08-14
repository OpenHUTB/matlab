classdef SampleTime



























    properties
Value
Description
ColorRGBValue
Annotation
OwnerBlock
        ComponentSampleTimes=Simulink.SampleTime.empty(0,0);
    end

    methods
        function tsObj=SampleTime(tsStructIn)
            if(isfield(tsStructIn,'Value'))
                if(isempty(tsStructIn.Value)||...
                    (tsStructIn.Value(1)>=0))
                    tsObj.Value=tsStructIn.Value;
                else
                    tsObj.Value=[];
                end
            end
            if(isfield(tsStructIn,'Description'))
                tsObj.Description=tsStructIn.Description;
            end
            if(isfield(tsStructIn,'ColorRGBValue'))
                tsObj.ColorRGBValue=tsStructIn.ColorRGBValue;
            end
            if(isfield(tsStructIn,'Annotation'))
                tsObj.Annotation=tsStructIn.Annotation;
            end




            if(isfield(tsStructIn,'Owner'))
                tsObj.OwnerBlock=tsStructIn.Owner;
            end
            if(isfield(tsStructIn,'ComponentSampleTimes'))
                for idx=1:length(tsStructIn.ComponentSampleTimes)
                    tmpObj=Simulink.SampleTime(tsStructIn.ComponentSampleTimes(idx));
                    tsObj.ComponentSampleTimes(idx)=tmpObj;

                end
            end
        end
    end
end

