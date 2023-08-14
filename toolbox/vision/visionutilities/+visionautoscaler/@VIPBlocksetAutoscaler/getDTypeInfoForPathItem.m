function[wlValueStr,flValueStr,specifiedDTStr,flDlgStr,modeDlgStr,wlDlgStr]=...
    getDTypeInfoForPathItem(~,blkObj,paramPrefixStr,fixdtSignValStr)



    flDlgStr=strcat(paramPrefixStr,'FracLength');
    wlDlgStr=strcat(paramPrefixStr,'WordLength');
    modeDlgStr=strcat(paramPrefixStr,'Mode');
    wlValueStr='';
    flValueStr='';
    mdValueStr=blkObj.(modeDlgStr);

    if~strncmp(mdValueStr,'Same as',7)

        blkPath=regexprep(blkObj.getFullName,'\n',' ');
        wlValueStr=blkObj.(wlDlgStr);
        [isWLValid,wlVal]=evalBlockDT(blkPath,wlValueStr);

        if isWLValid
            if~strcmp(mdValueStr,'Specify word length')

                flDlgStr=strcat(paramPrefixStr,'FracLength');
                flValueStr=blkObj.(flDlgStr);
                [isFLValid,flVal]=evalBlockDT(blkPath,flValueStr);

                if isFLValid
                    specifiedDTStr=sprintf('fixdt(%s,%d,%d)',...
                    fixdtSignValStr,wlVal,flVal);
                else

                    specifiedDTStr='';
                end
            else

                specifiedDTStr=sprintf('fixdt(%s,%d)',fixdtSignValStr,wlVal);
            end
        else

            specifiedDTStr='';
        end
    else

        specifiedDTStr=mdValueStr;
    end


    function[isValid,val]=evalBlockDT(blockPath,unevaledParamStr)
        isValid=false;
        val=[];
        try
            val=slResolve(unevaledParamStr,blockPath);
            isValid=true;

        catch e %#ok<NASGU>

        end
