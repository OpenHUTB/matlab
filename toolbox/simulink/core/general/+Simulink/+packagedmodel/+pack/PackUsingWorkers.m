classdef PackUsingWorkers<Simulink.packagedmodel.pack.PackHandler




    methods(Access=protected)
        function process(this)
            for i=1:length(this.SlxcMasterData)
                data=this.prepareData(i);
                f(i)=parfeval(@Simulink.packagedmodel.pack.PackHandler.loc_parPackSLCache,1,data);%#ok<AGROW>
            end

            for i=1:length(this.SlxcMasterData)
                [idx,value]=fetchNext(f);
                this.Results{idx}=value;
                this.loc_displayBuildLog(f(idx).Diary);
            end
        end
    end

    methods(Access=private)
        function loc_displayBuildLog(~,log)
            if~isempty(log)
                Simulink.output.info(strtrim(log));
            end
        end
    end
end
