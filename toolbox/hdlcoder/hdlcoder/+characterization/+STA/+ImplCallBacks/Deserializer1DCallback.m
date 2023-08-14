
classdef Deserializer1DCallback<characterization.STA.ImplementationCallback





    methods
        function self=Deserializer1DCallback()
            self@characterization.STA.ImplementationCallback();
        end

        function preprocessWidthSettings(~,modelInfo)

            validInIndex=2;
            x=modelInfo.modelDependantParams('startIn');
            isOn=strfind(x{1},'on');
            if~isempty(isOn)
                value={2,'boolean'};
                modelInfo.wmap(2)=value;
                validInIndex=3;
            end


            x=modelInfo.modelDependantParams('validIn');
            isOn=strfind(x{1},'on');
            if isempty(isOn)
                return;
            end
            value={validInIndex,'boolean'};
            modelInfo.wmap(validInIndex)=value;
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
