function archDir=archiveSnapshot(archMode,archDir,logFile,guidanceFile,lastGuidanceFile,cpAnnotationFile)
















    files2copy={...
    logFile,...
    guidanceFile,...
    lastGuidanceFile,...
    cpAnnotationFile,...
    };

    if(archMode==hdlcoder.OptimizationConfig.Archive.Verbose)
        files2copy=[files2copy,...
        'hdlsrc',...
        'hdl_prj',...
        '*.dot',...
        ];
    end

    for j=1:length(files2copy)
        s=copyfile(files2copy{j},fullfile(archDir,files2copy{j}),'f');%#ok<NASGU>
    end
end

