function[envVal,suffixOut,otherOpts]=parse_mexopts_for_envval(desiredSuffix,varargin)







    envVal='';
    otherOpts.msvcdir='';
    otherOpts.msvcver='';
    otherOpts.platformSDKdir='';

    if nargin==1
        mexopts=fullfile(prefdir,'mexopts.bat');
    elseif nargin==2
        mexopts=varargin{1};
    else
        return;
    end


    r=loc_scan_mexopts_for_env(mexopts);
    envVal=r.envVal;

    if~isempty(desiredSuffix)
        if~strcmp(desiredSuffix,r.tmfSuffix)

            envVal='';
        end
    end

    if nargout>=2
        suffixOut=r.tmfSuffix;
        if nargout==3
            otherOpts.msvcdir=r.msvcdir;
            otherOpts.msvcver=r.msvcver;
            otherOpts.platformSDKdir=r.platformSDKdir;
        end
    end

end




function r=loc_scan_mexopts_for_env(mexoptsfile)




    if nargin==0
        mexoptsfile='';
    end

    r.msvcdir='';
    r.msvcver='';
    r.platformSDKdir='';


    [original_mexoptname,mexopts_content]=locGetOriginalMexFileName(mexoptsfile);

    switch lower(original_mexoptname)

    case{'msvc60opts'}
        r.tmfSuffix='_vc.tmf';
        r.msvcver='600';
        msvsdir=locGetVSDirFromMexOpts(mexopts_content);
        r.envVal=fullfile(msvsdir,'Common','msdev98');
        r.msvcdir=fullfile(msvsdir,'VC98');

    case{'msvc80opts'}
        r.tmfSuffix='_vc.tmf';
        r.msvcver='800';
        msvsdir=locGetVSDirFromMexOpts(mexopts_content);
        r.envVal=fullfile(msvsdir,'Common7','IDE');
        r.msvcdir=fullfile(msvsdir,'VC');

    case{'msvc90opts'}
        r.tmfSuffix='_vc.tmf';
        r.msvcver='900';
        msvsdir=locGetVSDirFromMexOpts(mexopts_content);
        r.envVal=fullfile(msvsdir,'Common7','IDE');
        r.msvcdir=fullfile(msvsdir,'VC');

    case{'openwatcopts'}
        r.tmfSuffix='_watc.tmf';
        r.envVal=locGetWatCDirFromMexOpts(mexopts_content);

    case{'lccopts'}
        r.tmfSuffix='_lcc.tmf';
        r.envVal='lcc';
    otherwise
        r.tmfSuffix='';
        r.envVal='';
    end

    r.envVal=RTW.reduceRelativePath(r.envVal);
    r.msvcdir=RTW.reduceRelativePath(r.msvcdir);
    r.platformSDKdir=RTW.reduceRelativePath(r.platformSDKdir);

end

function[original_mexoptname,mexopts_content]=locGetOriginalMexFileName(mexoptsfile)
    fid=fopen(mexoptsfile,'rt');
    if fid==-1

        mexopts_content='';
        original_mexoptname='';
    else
        mexopts_content=fread(fid,[1,inf],'*char');
        fclose(fid);
        try
            pat='\n\s*rem\s+(?<filename>[^\s\.]+)\.bat';
            f=regexpi(mexopts_content,pat,'names','once');
            original_mexoptname=f.filename;
        catch e %#ok<NASGU>
            mexopts_content='';
            original_mexoptname='';
        end
    end

end

function[mexoptsvsdir,mexoptslinkerdir]=locGetVSDirFromMexOpts(mexopts_content)


    vsinstall_pat='VSINSTALLDIR=(?<vsdir>[^\r\n]*)';
    tmp=regexpi(mexopts_content,vsinstall_pat,'names','once');
    if isempty(tmp)

        old_pat1='MSVCDir=(?<vsdir>.*)[\\/]VC.*[\r\n]';
        tmp=regexpi(mexopts_content,old_pat1,'names','once');
        if isempty(tmp)

            old_pat2='MSDevDir=(?<vsdevdir>[^\r\n]*)';
            tmp=regexpi(mexopts_content,old_pat2,'names','once');
            if isempty(tmp)
                mexoptsvsdir='';
            else
                mexoptsvsdir=RTW.reduceRelativePath(fullfile(tmp.vsdevdir,'..','..'));
            end
        else
            mexoptsvsdir=tmp.vsdir;
        end
    else
        mexoptsvsdir=tmp.vsdir;
    end


    linker_pat='LINKERDIR=(?<linkerdir>[^\r\n]*)';
    tmp=regexpi(mexopts_content,linker_pat,'names','once');
    if isempty(tmp)
        mexoptslinkerdir='';
    else
        mexoptslinkerdir=tmp.linkerdir;
    end

end


function mexoptswatcdir=locGetWatCDirFromMexOpts(mexopts_content)

    pat='WATCOM=(?<watcdir>[^\r\n]*)';
    tmp=regexpi(mexopts_content,pat,'names','once');
    if isempty(tmp)
        mexoptswatcdir='';
    else
        mexoptswatcdir=tmp.watcdir;
    end
end


