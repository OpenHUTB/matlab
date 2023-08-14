
classdef Serializer1DCallback<characterization.STA.ImplementationCallback





    methods
        function self=Serializer1DCallback()
            self@characterization.STA.ImplementationCallback();
        end

        function preprocessWidthSettings(~,modelInfo)


            ratioValue=modelInfo.modelIndependantParams('ratio');
            y=modelInfo.wmap(1);
            modelInfo.wmap(1)=[y(:)',{ratioValue}];


            validInValue=modelInfo.modelDependantParams('validIn');
            isOn=strfind(validInValue{1},'on');
            if isempty(isOn)
                return;
            end
            value={2,'boolean'};
            modelInfo.wmap(2)=value;

        end

        function modelInfo=processConfig(~,modelInfo)

            if~modelInfo.modelIndependantParams.isKey('ratio')
                error('Incorrect setting for ratio');
            end
            x=modelInfo.modelIndependantParams('ratio');
            width=str2double(x{1});
            modelInfo.currentWidthSettings={1,width};

        end

    end

end
