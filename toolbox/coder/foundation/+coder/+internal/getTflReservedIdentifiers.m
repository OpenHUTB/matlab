function reservedIds=getTflReservedIdentifiers(lTargetRegistry,varargin)








    refreshCRL(lTargetRegistry);

    reservedIds=[];
    if nargin==1
        numCrl=length(lTargetRegistry.TargetFunctionLibraries);
        for idx=1:numCrl
            crl=lTargetRegistry.TargetFunctionLibraries(idx);
            try
                theseIds=locGetReservedIdsForCrl(lTargetRegistry,crl);

                if isempty(reservedIds)
                    reservedIds=theseIds;
                else
                    reservedIds=[reservedIds;theseIds];%#ok<AGROW>
                end
            catch me
                rethrow(me);
            end

        end
    else
        Crl_QueryString=varargin{1};
        crl=coder.internal.getTfl(lTargetRegistry,Crl_QueryString);
        reservedIds=locGetReservedIdsForCrl(lTargetRegistry,crl);


        langStdCrls=lTargetRegistry.TargetFunctionLibraries([lTargetRegistry.TargetFunctionLibraries.IsLangStdTfl]);
        for i_crl=1:numel(langStdCrls)
            alangcrl=langStdCrls(i_crl);
            if~strcmpi(crl.Name,alangcrl.Name)
                reservedIds=[reservedIds;locGetReservedIdsForCrl(lTargetRegistry,alangcrl)];%#ok<AGROW>
            end
        end
    end


    reservedIds=unique(reservedIds);



    function ids=locGetReservedIdsForCrl(h,crl)
        try
            ids=[];
            tables=coder.internal.getTflTableList(h,crl.Name);
            numTable=length(tables);
            for idy=1:numTable
                [pathstr,name,ext]=fileparts(tables{idy});
                currentDir=pwd;
                if~isempty(pathstr)
                    try
                        cd(pathstr);
                    catch err
                        DAStudio.error('RTW:tfl:invalidTflTable',fullfile(pathstr,name,ext));
                    end
                end

                switch ext
                case{'','.m','.p'}
                    try
                        table.hTflTable=feval(name);
                    catch %#ok<CTCH>
                        cd(currentDir);
                        DAStudio.error('RTW:tfl:invalidTflTable',[name,ext]);
                    end

                case '.mat'
                    try
                        table=load(name);
                    catch %#ok<CTCH>
                        cd(currentDir);
                        DAStudio.error('RTW:tfl:invalidTflTable',[name,ext]);
                    end

                otherwise
                    cd(currentDir);
                    DAStudio.error('RTW:tfl:invalidTflTable',[name,ext]);
                end
                if~isempty(pathstr)
                    cd(currentDir);
                end
                allEnts=table.hTflTable.AllEntries;
                numEnts=length(allEnts);
                theseIds={};
                index=1;
                for idz=1:numEnts
                    thisEnt=allEnts(idz);
                    if isprop(thisEnt,'Implementation')
                        if~isempty(thisEnt.Implementation)
                            theseIds{index,1}=thisEnt.Implementation.Name;%#ok<AGROW>
                            index=index+1;
                        end
                    elseif isprop(thisEnt,'ImplementationVector')
                        implVector=thisEnt.ImplementationVector;
                        if~isempty(implVector)
                            [nrow,ncol]=size(implVector);
                            idx=(nrow*ncol)/2;
                            for i=1:nrow
                                implSet=implVector{idx+i};
                                for j=1:length(implSet)
                                    impl=implSet(j);
                                    theseIds{index,1}=impl.Name;%#ok<AGROW>
                                    index=index+1;
                                end
                            end
                        end
                    end
                end
                if~isempty(theseIds)
                    theseIds=unique(theseIds);
                    if isempty(ids)
                        ids=theseIds;
                    else
                        ids=[ids;theseIds];%#ok<AGROW>
                    end
                end
            end
        catch me
            rethrow(me);
        end




