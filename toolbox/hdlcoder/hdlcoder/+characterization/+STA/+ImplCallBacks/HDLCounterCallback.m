
classdef HDLCounterCallback<characterization.STA.ImplementationCallback





    methods
        function self=HDLCounterCallback()
            self@characterization.STA.ImplementationCallback();
        end

        function preprocessModelDependentParams(~,modelInfo)

        end

        function preprocessModelIndependentParams(~,modelInfo)
            ctype=modelInfo.modelDependantParams('CountType');
            isLimited=strfind(ctype{1},'Count limited');
            if isempty(isLimited)
                return;
            end



            x=modelInfo.modelIndependantParams('CountWordLen');
            wlen=str2double(x{1});
            countMax=pow2(wlen)-1;
            load_system([modelInfo.modelName]);
            currentCountMax=get_param(modelInfo.blockPath,'CountMax');



            if(str2double(currentCountMax)<countMax)
                set_param(modelInfo.blockPath,'CountWordLen',num2str(wlen));
            end
            set_param(modelInfo.blockPath,'CountMax',num2str(countMax));
            save_system([modelInfo.modelName]);
        end

        function preprocessWidthSettings(~,modelInfo)
            portid=2;
            if~modelInfo.modelDependantParams.isKey('CountLoadPort')
                return;
            end
            x=modelInfo.modelDependantParams('CountLoadPort');
            isOn=strfind(x{1},'on');
            if isempty(isOn)
                return;
            end
            x=modelInfo.modelDependantParams('CountResetPort');
            isOn=strfind(x{1},'on');
            if~isempty(isOn)
                portid=portid+1;
            end
            value=modelInfo.wmap(portid);
            x=modelInfo.modelIndependantParams('CountWordLen');
            value{2}=sprintf('fixdt(0, %s, 0)',x{1});
            modelInfo.wmap(portid)=value;
        end

        function modelInfo=processConfig(~,modelInfo)

            if~modelInfo.modelIndependantParams.isKey('CountWordLen')
                error('Incorrect setting for CountWordLen for HDLCounter');
            end
            x=modelInfo.modelIndependantParams('CountWordLen');
            width=str2double(x{1});
            modelInfo.currentWidthSettings={1,width};
        end

    end

end
