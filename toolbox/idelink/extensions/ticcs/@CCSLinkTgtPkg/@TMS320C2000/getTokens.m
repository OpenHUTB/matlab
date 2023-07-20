function[tokenVal,status,msg]=getTokens(h,varargin)







    knownTokens={'BIOS_INSTALL_DIR','DSP2802x_INSTALLDIR','DSP2803x_INSTALLDIR','DSP2804x_INSTALLDIR','DSP2834x_INSTALLDIR'};
    token=varargin{1};
    str=varargin{2};
    j=find(strcmp(token,knownTokens),1);
    if~isempty(j)
        tokenVal=getenv(token);
        switch j
        case 1
            msg{1}='DSP/BIOS';
            msg{2}='C:\Applications\CCStudio_v3.3\bios_5_31_02';
            msg{3}='packages\ti\rtdx\lib\c2000\rtdxx.lib';
        case 2
            msg{1}='F2802x';
            msg{2}='C:\tidcs\c28\DSP2802x\v100';
            msg{3}='DSP2802x_common\source_include or DSP2802x_headers\source_include';
        case 3
            msg{1}='F2803x';
            msg{2}='C:\tidcs\c28\DSP2803x\v101';
            msg{3}='DSP2803x_common\source_include or DSP2803x_headers\source_include';
        case 4
            msg{1}='F2804x';
            msg{2}='C:\tidcs\c28\DSP2804x\v130';
            msg{3}='DSP2804x_common\source_include or DSP2804x_headers\source_include';
        case 5
            msg{1}='F2834x';
            msg{2}='C:\tidcs\c28\DSP2834x\v110';
            msg{3}='DSP2834x_common\source_include or DSP2834x_headers\source_include';
        end
        if isempty(tokenVal)
            status=-1;
        else
            tokenVal=strrep(tokenVal,'/','\');
            status=1;
        end
    else
        tokenVal='';
        status=0;
        msg='';
    end
