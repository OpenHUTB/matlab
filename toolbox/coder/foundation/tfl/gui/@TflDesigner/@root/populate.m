function populate(handle,varargin)







    if length(varargin)>1
        DAStudio.error('RTW:tfl:invalidNumOfInput');
    end

    handle.iseditorbusy=true;
    if~isempty(varargin)&&~ischar(varargin{1})
        in=varargin{1};

        if isa(in,'RTW.TflControl')
            tables=in.TflTables;
            numTable=length(tables);
            if numTable==0
                child=[];
            end
            for idy=1:numTable
                t=TflDesigner.node(handle,tables(idy),tables(idy).Name);
                t.isDirty=false;
                child(idy)=t;%#ok<AGROW>
            end
            if~isempty(in.HitCache)
                cHitTable=TflDesigner.node(handle,in.HitCache,'HitCache');
                cHitTable.isDirty=false;
            else
                cHitTable=[];
            end
            if~isempty(in.MissCache)
                cMisTable=TflDesigner.node(handle,in.MissCache,'MissCache');
                cMisTable.isDirty=false;
            else
                cMisTable=[];
            end
            if~isempty(in.TLCCallList)
                cTlcTable=TflDesigner.node(handle,in.TLCCallList,'TLCCallList');
                cTlcTable.isDirty=false;
            else
                cTlcTable=[];
            end

            if isempty(handle.children)
                handle.children=[cHitTable;cMisTable;cTlcTable;child(:)];
            else
                if~isempty(cHitTable)
                    handle.children(end+1)=cHitTable;
                end
                if~isempty(cMisTable)
                    handle.children(end+1)=cMisTable;
                end
                if~isempty(cTlcTable)
                    handle.children(end+1)=cTlcTable;
                end
                if~isempty(child)
                    handle.children=[handle.children;child(:)];
                end
            end

        elseif isa(in,'coder.targetreg.internal.TargetRegistry')

            tr=RTW.TargetRegistry.get;






            refreshCRL(tr);

            numTfl=length(tr.TargetFunctionLibraries);
            nonSimIdx=[];
            for idx=1:numTfl
                tfl=tr.TargetFunctionLibraries(idx);
                if tfl.IsVisible
                    try
                        parent(idx)=createnodetree(handle,tfl);%#ok<AGROW>
                        nonSimIdx=[nonSimIdx;idx];%#ok<AGROW>
                    catch me
                        disp(DAStudio.message('RTW:tfldesigner:DisplayWarning',me.message));
                    end

                end
            end

            if isempty(handle.children)
                handle.children=parent(nonSimIdx);
            else
                copy=handle.children;
                handle.children=parent(nonSimIdx);
                for i=1:length(copy)
                    handle.children(end+1)=copy(i);
                end
            end

        elseif isa(in,'RTW.TflRegistry')

            parent=createnodetree(handle,in);

            if isempty(handle.children)
                handle.children=parent;
            else
                copy=handle.children;
                handle.children=parent;
                for i=1:length(copy)
                    handle.children(end+1)=copy(i);
                end
            end

        elseif isa(in,'RTW.TflTable')
            child=TflDesigner.node(handle,in);
            if isempty(handle.children)
                handle.children=child;
            else
                handle.children=[handle.children;child];
            end
        else
            DAStudio.error('RTW:tfl:invalidObjError');
        end
    end

    handle.firehierarchychanged;
    handle.refreshchildrencache(true);
    handle.iseditorbusy=false;





    function parent=createnodetree(handle,in)

        parent=TflDesigner.node(handle,in,in.Name);
        tr=RTW.TargetRegistry.get;
        hWaitBar=DAStudio.WaitBar;
        hWaitBar.setWindowTitle('Code replacement tool');
        hWaitBar.setLabelText(['Loading TFL: ',in.Name]);
        hWaitBar.show;
        hWaitBar.setValue(0);
        tables=coder.internal.getTflTableList(tr,in.Name);

        privateTablesList=regexp(tables,'^private.*$','match');
        privateTablesList=privateTablesList(locCellfind(privateTablesList));
        pTablesList=[privateTablesList{:}];
        [dummyList,Ia]=setdiff(tables,pTablesList);
        if~isempty(dummyList)
            tables=tables(sort(Ia));
        end
        numTable=length(tables);

        for idy=1:numTable
            hWaitBar.setValue((idy/numTable)*98);
            [pathstr,name,ext]=fileparts(tables{idy});
            currentDir=pwd;
            if~isempty(pathstr)
                try
                    cd(pathstr);
                catch err
                    delete(hWaitBar);
                    DAStudio.error('RTW:tfl:invalidTflTable',fullfile(pathstr,name,ext));
                end
            end
            switch ext
            case{'','.m','.p'}
                try
                    table.hTflTable=feval(name);
                catch ME
                    delete(hWaitBar);
                    cd(currentDir);
                    DAStudio.error('RTW:tfl:invalidTflTable',[name,ext]);
                end

            case '.mat'
                try
                    table=load(name);
                catch ME
                    delete(hWaitBar);
                    cd(currentDir);
                    DAStudio.error('RTW:tfl:invalidTflTable',[name,ext]);
                end

            otherwise
                delete(hWaitBar);
                cd(currentDir);
                DAStudio.error('RTW:tfl:invalidTflTable',[name,ext]);
            end
            if~isempty(pathstr)
                cd(currentDir);
            end

            table.hTflTable.Name=[name,ext];
            t=TflDesigner.node(parent.handle,table.hTflTable,table.hTflTable.Name);
            t.isDirty=false;
            child(idy)=t;%#ok<AGROW>
        end
        hWaitBar.setValue(100);

        parent.children=child(:);


        function idx=locCellfind(c)



            idx=[];
            for i=1:length(c)
                if~isempty(c{i})
                    idx=[idx;i];%#ok<AGROW>
                end
            end


