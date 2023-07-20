function[cgInfo,rtlInfo]=getCodeGenInfo(this)


    rtlInfo=[];
    cgInfo=this.cgInfo;
    if isempty(cgInfo)
        return;
    end

    if isfield(cgInfo,'hdlFiles')
        hdlFileNames=cgInfo.hdlFiles;
        if~iscell(hdlFileNames)
            hdlFileNames={hdlFileNames};
        end

        tbFiles={};
        if isfield(cgInfo,'hdlTbFiles')
            tbFiles=cgInfo.hdlTbFiles;
            if~iscell(tbFiles)
                tbFiles={tbFiles};
            end
        end

        for ii=1:length(tbFiles)
            hdlFileNames{end+1}=tbFiles{ii};%#ok<AGROW>
        end

        cgDir=this.hdlGetCodegendir;

        hdlFileNamesWithPaths={};
        for i=1:length(hdlFileNames)
            hdlFileNamesWithPaths{i}=fullfile(cgDir,hdlFileNames{i});%#ok<AGROW>
        end

        rtlInfo.hdlFileNames=hdlFileNames;
        rtlInfo.hdlFileNamesWithPaths=hdlFileNamesWithPaths;
    end
