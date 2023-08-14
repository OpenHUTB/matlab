function cleanupFcn = make_ecoder_hook(hook, lBuildDirectory, lGeneratedTLCSubDir, lModelName, cs, ...
                          lAnchorFolder, lModelReferenceTargetType)
% MAKE_ECODER_HOOK: Embedded Coder has additional hooks
% (callbacks) to the normal Simulink Coder build process.

% Copyright 1994-2021 The MathWorks, Inc.

cleanupFcn = @()[];

if LocalIsSimulinkTargetWithoutCoders(cs)
    % Must avoid calling ec_mpt_enabled which is not shipped w/o coders
    mptEnabled = false;
else
    mptEnabled = ec_mpt_enabled(lModelName);
end

switch hook
    case {'entry', 'after_tlc', 'exit', 'error'}
        if mptEnabled
            cleanupFcn = mpt_ecoder_hook(hook,lModelName, lAnchorFolder, lModelReferenceTargetType);
        end
    case 'before_tlc'
        LocalExpandCodeTemplates(lBuildDirectory, lGeneratedTLCSubDir, cs);
        LocalCopyCustomTemplates(lBuildDirectory, lGeneratedTLCSubDir, cs);
        if mptEnabled
            mpt_ecoder_hook(hook,lModelName, lAnchorFolder, lModelReferenceTargetType);
        end
end
end

% -------------------------------------------------------------------------
% Expand ERT code templates if they exist
function LocalExpandCodeTemplates(lBuildDirectory, lGeneratedTLCSubDir, cs)
ert_src_template = get_param(cs,'ERTSrcFileBannerTemplate');
usList = {get_param(cs,'ERTDataHdrFileTemplate')...
    get_param(cs,'ERTDataSrcFileTemplate')...
    get_param(cs,'ERTHdrFileBannerTemplate')...
    ert_src_template};

% Sort list and remove duplicates
list = unique(usList);

for i = 1: length(list)
    cgtName = list{i};
    
    % if the path is not empty, then we need to strip out just the filename
    % portion for the tlc name.
    [fpath,fname,fext] = fileparts(cgtName);
    if ~isempty(fpath)
        tlcName = [fname fext];
    else
        tlcName = cgtName;
    end
    tlcName = rtw_cgt_name_conv(tlcName,'cgt2tlc');
    
    fullPathName = which(cgtName);
    
    if isempty(fullPathName)
        if exist(cgtName,'file')
            fullPathName = cgtName;
        end
    end
    
    outfile = fullfile(lBuildDirectory,lGeneratedTLCSubDir,tlcName);
    if ~isempty(fullPathName)
        if isequal(fext,'.cgt')
            cgtfile = fullfile(lBuildDirectory,lGeneratedTLCSubDir,[fname '_ct.cgt']);
            % Generate function banners from ERTSrcFileBannerTemplate only
            if strcmp(cgtName, ert_src_template)
                bGenFcnBannerFile = true;
            else
                bGenFcnBannerFile = false;
            end
            
            isCPPClassGenMode = strcmpi(get_param(cs, 'IsCPPClassGenMode'),'on');
            isC = strcmpi(get_param(cs, 'TargetLang'),'C');
            isSLC = coder.internal.isSingleLineComments(cs);
            
            % Cut regions out from original cgt file and save to a temp cgt file
            % Save regions into tlc files in the same directory as cgtfile, which is the tlc subdirectory
            rtwprivate('rtw_get_region_from_template', fullPathName, cgtfile, isC, isCPPClassGenMode, isSLC, bGenFcnBannerFile);
            
            % Expand temporary cgt file for code template. As rtw_expand_template doesn't recognize region,
            % rtw_get_region_from_template shall be called first.
            % Delete the file in the tlc directory to ensure the latest template.
            if exist(outfile,'file')
                rtw_delete_file(outfile);
            end
            rtw_expand_template(cgtfile,outfile, isCPPClassGenMode);
            rtw_delete_file(cgtfile);
        else
            rtw_copy_file(fullPathName,outfile);
        end
    else
        if isempty(cgtName)
            % cgt file is not specified in the config set
            doclink = rtwprivate('rtw_template_helper', 'get_doc_link');
            DAStudio.error('RTW:targetSpecific:cgtFileNotSet', doclink);
        else
            % cgt file is not in Matlab path.
            DAStudio.error('RTW:targetSpecific:cgtFileNotFound', cgtName);
        end
    end
end
end

% -------------------------------------------------------------------------
% Copy ERT custom template if it exist
function LocalCopyCustomTemplates(lBuildDirectory, lGeneratedTLCSubDir, cs)
templateFile = strtok(get_param(cs,'ERTCustomFileTemplate'));
% Delete the file in the tlc directory if it exists (to ensure
% we get the latest template).
[dirstr,fname,ext] = fileparts(templateFile); %#ok<ASGLU>
outfile = fullfile(lBuildDirectory,lGeneratedTLCSubDir,[fname,ext]);
if exist(outfile,'file')
    rtw_delete_file(outfile);
end
templateFile = which(templateFile);
% Copy it to the tlc directory if found
if ~isempty(templateFile)
    rtw_copy_file(templateFile,outfile);
end
end

% -------------------------------------------------------------------------
function ret = LocalIsSimulinkTargetWithoutCoders(cs)
stf = get_param(cs, 'SystemTargetFile');
isSimulinkTarget = isequal(stf, 'realtime.tlc') || ...
    (isequal(stf,'ert.tlc') && (codertarget.target.isCoderTarget(cs)));
codersInstalledAndLicensed = ...
    dig.isProductInstalled('Embedded Coder') && ...
    dig.isProductInstalled('Simulink Coder') && ...
    dig.isProductInstalled('MATLAB Coder');
ret = isSimulinkTarget && ~codersInstalledAndLicensed;
end

% LocalWords:  rtwattic sil pil Hdr cgt cgtfile
