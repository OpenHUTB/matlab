

classdef ResultsMF0Util
    methods(Static)

        function destBlks=getDestBlks(transObj)
            assert(isa(transObj,'slci.stateflow.Transition'));
            sess=Simulink.CMI.EIAdapter(Simulink.EngineInterfaceVal.byFiat);%#ok<NASGU>
            sfBlock=transObj.ParentChart().ParentBlock().getSID();
            actionAST=transObj.getConditionActionAST();
            if~isempty(actionAST)
                destBlks={};
                destBlks=slci.results.getDestsForEvent(sfBlock,...
                actionAST,...
                destBlks);
            end
        end


        function metaData=getMetaData(configObj)
            assert(isa(configObj,'slci.Configuration'));


            modelName=configObj.getModelName();


            info=Simulink.MDLInfo(modelName);


            modelFileName=info.FileName;


            simulinkVersion=info.SimulinkVersion;


            if~isempty(info.ReleaseName)
                simulinkVersion=[simulinkVersion,' (',info.ReleaseName,')'];
            end


            v=ver('SLCI');
            slciVersion=[v.Version,' (',v.Release,')'];


            modelVersion=info.ModelVersion;



            mStamp=get_param(configObj.getModelName(),'LastModifiedDate');
            mdateformat=get_param(configObj.getModelName(),'ModifiedDateFormat');
            if strcmpi(mdateformat,'%<Auto>')

                dn=datenum(mStamp,'ddd mmm dd HH:MM:SS yyyy');
                modelTimeStamp=slci.internal.ReportUtil.setToDefaultFormat(dn);
            else

                modelTimeStamp=mStamp;
            end


            inspectionRunDate=slci.internal.ReportUtil.setToDefaultFormat(now);


            metaData={modelName,modelFileName,simulinkVersion,...
            slciVersion,modelVersion,modelTimeStamp,inspectionRunDate};



            if~configObj.getTopModel()&&...
                configObj.getIncludeTopModelChecksumForRefModels()
                isTopModel=true;
                metaData{end+1}=slci.internal.getModelChecksum(...
                configObj.getModelName(),isTopModel);
            end
        end



        function metaData=getCompiledMetaData(configObj)
            assert(isa(configObj,'slci.Configuration'));

            suffix=configObj.getTargetLangSuffix();
            mainFile=fullfile(configObj.getDerivedCodeFolder(),...
            [configObj.getModelName(),suffix]);
            try

                mainFile=slci.internal.normalizeFilePath(mainFile,pwd);
            catch


            end
            modelCheckSum=...
            slci.internal.getModelChecksum(...
            configObj.getModelName(),configObj.getTopModel());
            metaData={mainFile,modelCheckSum};
        end

    end
end