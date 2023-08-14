function[clientFullName,err]=findFileNameOnClient(fullName)





    ;%#ok undocumented



    err='';
    clientFullName='';

    if isempty(fullName)
        err=getString(message('parallel:lang:mpi:FindFileOnClientPathEmpty'));
        return;
    end

    try


        a=textscan(fullName,'%s','Delimiter','/\\','MultipleDelimsAsOne',true);

        clientFullName=iWhichOnClient(a{1});
        if isempty(clientFullName)
            err=getString(message('parallel:lang:mpi:FindFileOnClientNotExist'));
        end

    catch err

        err=getString(message('parallel:lang:mpi:FindFileOnClientErrorOccurred',err.getReport()));
    end

    function out=iWhichOnClient(filePath)








        if numel(filePath)==1


            out=which(filePath{1});
            return
        end



        if ispc
            strcmpFcn=@strcmpi;
        else
            strcmpFcn=@strcmp;
        end
        isPrivate=strcmpFcn(filePath{end-1},'private');
        if isPrivate
            partialPath=filePath(1:end-2);
            requiredPath=filePath(end-1:end);
        else
            partialPath=filePath(1:end-1);
            requiredPath=filePath(end);
        end



        classPattern='^@[A-Za-z_]\w*$';
        isUDD=numel(partialPath)>1&&...
        ~isempty(regexp(partialPath{end},classPattern,'once'))&&...
        ~isempty(regexp(partialPath{end-1},classPattern,'once'))&&...
        ~(numel(partialPath)>2&&~isempty(regexp(partialPath{end-2},classPattern,'once')));
        if isUDD
            try
                uddPath=partialPath(end-1:end);
                out=iWhichUDD(requiredPath,uddPath);
            catch err %#ok<NASGU>


                out='';
            end
        else


            if~isempty(partialPath)&&~isempty(regexp(partialPath{end},classPattern,'once'))
                requiredPath=[partialPath(end);requiredPath];
                partialPath=partialPath(1:end-1);
            end
            mcosPackagePattern='^\+[A-Za-z_]\w*$';

            while~isempty(partialPath)&&~isempty(regexp(partialPath{end},mcosPackagePattern,'once'))
                requiredPath=[partialPath(end);requiredPath];%#ok<AGROW>
                partialPath=partialPath(1:end-1);
            end
            out=iWhichPartial(requiredPath,partialPath);
        end

        function out=iWhichPartial(required,partial)


            if nargin<2
                partial={};
            end
            required=fullfile(required{:});
            for i=1:numel(partial)
                out=which(fullfile(partial{i:end},required));
                if~isempty(out)
                    return
                end
            end
            out=which(required);

            function out=iWhichUDD(parts,uddParts)


                packagePath=iGetUDDClassPath(uddParts{:});

                filename=fullfile(packagePath,uddParts{2},parts{:});
                if exist(filename,'file')
                    out=filename;
                else
                    out='';
                end

                function packagePath=iGetUDDClassPath(uddPackageFilename,uddClassFilename)


                    allWhats=what(uddPackageFilename);

                    for i=1:numel(allWhats)

                        if any(strcmp(allWhats(i).classes,uddClassFilename(2:end)))

                            packagePath=allWhats(i).path;
                            return
                        end
                    end

                    error(message('parallel:lang:mpi:ProfUnknownUDDpackage'));
