function summary=prepareSummary(data)







    [analyzedSystem,analysisInformation]=prepareAnalysisInformation(data);

    summary.analysisInformation=analysisInformation;
    summary.analyzedSystem=analyzedSystem;

end

function[analyzedSystem,analysisInformation]=prepareAnalysisInformation(data)






    analysisInformation=cell(0,2);

    analysisInformation(end+1,1)={getString(message('Sldv:ReportUtils:prepareSummary:Model'))};
    analysisInformation(end,2)={data.ModelInformation.Name};


    analyzedSystem=data.ModelInformation.Name;

    if isfield(data.AnalysisInformation,'Release')




        analysisInformation(end+1,1)={getString(message('Sldv:ReportUtils:prepareSummary:Release'))};
        analysisInformation(end,2)={data.AnalysisInformation.Release};
    end
    if isfield(data.ModelInformation,'SubsystemPath')
        subsystemH=get_param(data.ModelInformation.SubsystemPath,'Handle');
        if Sldv.utils.isAtomicSubchartSubsystem(subsystemH)
            analysisInformation(end+1,1)={getString(message('Sldv:ReportUtils:prepareSummary:AnalyzedAtomic'))};
        else
            analysisInformation(end+1,1)={getString(message('Sldv:ReportUtils:prepareSummary:AnalyzedSubsystem'))};
        end
        analysisInformation(end,2)={data.ModelInformation.SubsystemPath};


        analyzedSystem=data.ModelInformation.SubsystemPath;
    end
    if isfield(data.ModelInformation,'ReplacementModel')
        analysisInformation(end+1,1)={getString(message('Sldv:ReportUtils:prepareSummary:ReplacementModel'))};
        analysisInformation(end,2)={data.ModelInformation.ReplacementModel};
    end


    if isfield(data.ModelInformation,'Checksum')




        analysisInformation(end+1,1)={getString(message('Sldv:RptGen:ModelChecksum'))};
        analysisInformation(end,2)={data.ModelInformation.Checksum};
    end

    analysisInformation(end+1,1)={getString(message('Sldv:ReportUtils:prepareSummary:Mode'))};
    analysisInformation(end,2)={sldvprivate('util_translate_analysismode',data.AnalysisInformation.Options.Mode)};

    if sldvprivate('isReuseTranslationON',data.AnalysisInformation.Options)&&isfield(data.AnalysisInformation,'ModelRepresentationInfo')
        analysisInformation(end+1,1)={getString(message('Sldv:RptGen:RebuildModelRepresentationInfo'))};
        analysisInformation(end,2)={data.AnalysisInformation.ModelRepresentationInfo};
    end

    if slavteng('feature','GeneratedCodeTestGen')&&data.AnalysisInformation.Options.Mode=="TestGeneration"
        analysisInformation(end+1,1)={getString(message('Sldv:RptGen:TestgenTarget'))};
        analysisInformation(end,2)={data.AnalysisInformation.Options.TestgenTarget};
    end


    analStatus=data.AnalysisInformation.Status;
    analysisInformation(end+1,1)={getString(message('Sldv:ReportUtils:prepareSummary:Status'))};
    analysisInformation(end,2)={sldvprivate('util_translate_analysisstatus',analStatus,'Upper')};



    if strcmpi(analStatus,'In progress')
        if isfield(data.AnalysisInformation,'ElapsedTime')
            analysisInformation(end+1,1)={getString(message('Sldv:ReportUtils:prepareSummary:ElapsedTime'))};
            analysisInformation(end,2)={[num2str(data.AnalysisInformation.ElapsedTime)...
            ,getString(message('Sldv:RptGen:Sec'))]};
        end
    else
        if(isfield(data.AnalysisInformation,'PreProcessingTime'))
            analysisInformation(end+1,1)={getString(message('Sldv:ReportUtils:prepareSummary:PreprocessingTime'))};
            analysisInformation(end,2)={[num2str(data.AnalysisInformation.PreProcessingTime)...
            ,getString(message('Sldv:RptGen:Sec'))]};
        end

        if(isfield(data.AnalysisInformation,'AnalysisTime'))
            analysisInformation(end+1,1)={getString(message('Sldv:ReportUtils:prepareSummary:AnalysisTime'))};
            analysisInformation(end,2)={[num2str(data.AnalysisInformation.AnalysisTime)...
            ,getString(message('Sldv:RptGen:Sec'))]};
        end




    end
end
