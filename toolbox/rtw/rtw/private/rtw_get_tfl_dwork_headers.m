function typeHeaders=rtw_get_tfl_dwork_headers(model)







    crlControl=get_param(model,'TargetFcnLibHandle');
    if isempty(crlControl)
        DAStudio.error('RTW:buildProcess:loadObjectHandleError',...
        'TargetFcnLibhandle');
    end


    typeHeaders=[];


    hitCache=crlControl.HitCache;



    for i=1:length(hitCache)
        currEntry=hitCache(i);
        if isprop(currEntry,'DWorkArgs')&&~isempty(currEntry.DWorkArgs)
            if isprop(currEntry,'ImplementationVector')
                typeHeaders=[typeHeaders,loc_parseImplVector(currEntry)];%#ok
            elseif isprop(currEntry,'Implementation')
                typeHeaders=[typeHeaders,{currEntry.Implementation.HeaderFile}];%#ok
            end
        end
    end
    typeHeaders=unique(typeHeaders);




    function hdrFiles=loc_parseImplVector(entry)
        hdrFiles=[];
        dw={entry.DWorkArgs(:).Name};
        implVector=entry.ImplementationVector;
        if~isempty(implVector)
            [nrow,ncol]=size(implVector);
            index=(nrow*ncol)/2;
            for ii=1:nrow
                implSet=implVector{index+ii};
                for jj=1:length(implSet)
                    impl=implSet(jj);
                    argNames={impl.Arguments(:).Name};
                    if~isempty(find(ismember(dw,argNames),1))
                        hdrFiles=[hdrFiles,{impl.HeaderFile}];%#ok
                    end
                end
            end
        end



