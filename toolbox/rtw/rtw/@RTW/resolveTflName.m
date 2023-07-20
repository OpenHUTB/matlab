function result=resolveTflName(alias,varargin)






















    argParser=inputParser;
    argParser.addRequired('alias',@(x)ischar(x)...
    ||evalc('DAStudio.error(''RTW:targetRegistry:badInputType'', ''char array (string)'')'));
    argParser.addParameter('ForMakeFile',false,@(x)islogical(x));
    argParser.addParameter('TargetLangStdTfl','',@(x)ischar(x));
    argParser.parse(alias,varargin{:});


    if isempty(alias)
        result='';
    elseif~contains(alias,coder.internal.getCrlLibraryDelimiter)
        tr=RTW.TargetRegistry.get;
        tfl=coder.internal.getTfl(tr,alias);
        if(isempty(tfl))
            result=alias;
        else
            result=tfl.Name;
        end
        if argParser.Results.ForMakeFile

            tblist=coder.internal.getTflTableList(tr,{result,argParser.Results.TargetLangStdTfl});
            if ismember('gnu_tfl_table_tmw.mat',tblist)
                result='GNU';
            else


                requiredLangStdTfl=loc_getHighestTgtFcnLib(argParser.Results.TargetLangStdTfl,tblist);
                if~strcmpi(requiredLangStdTfl,'ANSI_C')
                    result=requiredLangStdTfl;
                end
            end
        end
    else

        result=alias;
        if argParser.Results.ForMakeFile
            tr=RTW.TargetRegistry.get;
            crls=coder.internal.getCRLs(tr,result);
            n=length(crls);
            tblist=[];
            for i=1:n
                Crl=crls(i);
                tblist=[tblist;coder.internal.getTflTableList(tr,{Crl.Name,argParser.Results.TargetLangStdTfl})];%#ok<AGROW>
            end
            if ismember('gnu_tfl_table_tmw.mat',tblist)
                result='GNU';
            else


                requiredLangStdTfl=loc_getHighestTgtFcnLib(argParser.Results.TargetLangStdTfl,tblist);
                if~strcmpi(requiredLangStdTfl,'ANSI_C')
                    result=requiredLangStdTfl;
                end
            end
        end
    end

    function result=loc_getHighestTgtFcnLib(targetLangStdTfl,tblList)

        if ismember('iso_cpp11_tfl_table_tmw.mat',tblList)...
            ||strcmp(targetLangStdTfl,'C++11 (ISO)')...
            ||strcmp(targetLangStdTfl,'ISO_C++11')
            result='ISO_C++11';
        elseif ismember('iso_cpp_tfl_table_tmw.mat',tblList)...
            ||strcmp(targetLangStdTfl,'C++03 (ISO)')...
            ||strcmp(targetLangStdTfl,'ISO_C++')
            result='ISO_C++';
        elseif ismember('iso_tfl_table_tmw.mat',tblList)...
            ||strcmp(targetLangStdTfl,'C99 (ISO)')...
            ||strcmp(targetLangStdTfl,'ISO_C')
            result='ISO_C';
        else
            result='ANSI_C';
        end



