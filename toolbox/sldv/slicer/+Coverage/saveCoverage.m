function cvtFile=saveCoverage(scfg,packageName)




    assert(isa(scfg,'SlicerConfiguration'));

    if nargin<2
        packageName=[];
    end

    sc=scfg.CurrentCriteria;

    try
        if isfield(scfg.options,'ResultOptions')
            settings.OutputDir=scfg.options.ResultOptions.OutputDir;
            MakeOutputFilesUnique=scfg.options.ResultOptions.MakeOutputFilesUnique;
        else

            hiddenOpt=SlicerConfiguration.getAllOpts;
            settings.OutputDir=hiddenOpt.ResultOptions.OutputDir;
            MakeOutputFilesUnique=hiddenOpt.ResultOptions.MakeOutputFilesUnique;
        end

        if MakeOutputFilesUnique
            MakeOutputFilesUniqueStr='on';
        else
            MakeOutputFilesUniqueStr='off';
        end

        if~slavteng('feature','EnhancedCoverageSlicer')


            cvtFile=Sldv.utils.settingsFilename('$ModelName$',MakeOutputFilesUniqueStr,...
            '.cvt',scfg.modelH,false,true,settings,'Model Slicer');
            SlCov.CoverageAPI.saveCoverage(cvtFile,sc.cvd.data);
            if contains(cvtFile,[pwd,filesep])

                cvtFile=strrep(cvtFile,[pwd,filesep],'');
            end
            sc.cvFileName=cvtFile;
        else
            sc.cvFileName=slcrxPackager.write(sc.cvd,scfg.modelH,settings,packageName);
            cvtFile=sc.cvFileName;
        end
        sc.useCvd=true;

    catch Mex
        sc.cvFileName='';
        sc.cvd=[];
        sc.useCvd=false;
        rethrow(Mex);
    end
end
