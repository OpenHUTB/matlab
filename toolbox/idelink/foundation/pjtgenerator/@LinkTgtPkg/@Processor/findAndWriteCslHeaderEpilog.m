function findAndWriteCslHeaderEpilog(h,cslFile,epilog,epilogDelim)












    narginchk(3,4);

    if exist(cslFile,'file')==2,


        cslContents=getContents(cslFile);
        epilogToken=regexptranslate('escape',epilog);
        noEpilogue=isempty(regexp(cslContents,epilogToken,'once'));


        if noEpilogue
            if nargin==3
                epilogDelim='\n';
            end
            fid=fopen(cslFile,'a');
            if fid==-1
                error(message('ERRORHANDLER:pjtgenerator:CannotWriteToCslHeader',...
                cslFile));
            end
            fprintf(fid,['\n',epilog,epilogDelim]);
            fclose(fid);
        end

    end



    function cslcontents=getContents(cslFile)
        fid=fopen(cslFile,'rt');
        if fid==-1
            error(message('ERRORHANDLER:pjtgenerator:CannotReadCslHeader',cslFile));
        end
        cslcontents=fread(fid,[1,inf],'*char');
        fclose(fid);
