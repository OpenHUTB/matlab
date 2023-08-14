function viewTfl(varargin)



















    persistent listener;%#ok<PUSE>
    persistent hWaitBar;
    if~isa(hWaitBar,'DAStudio.WaitBar')
        hWaitBar=DAStudio.WaitBar;cleanupObj=onCleanup(@()delete(hWaitBar));
        hWaitBar.setWindowTitle('Code replacement viewer');
        hWaitBar.setLabelText('Initializing viewer...');
    end



    hWaitBar.setValue(0);
    hWaitBar.show;
    if nargin==0
        hWaitBar.setValue(20);
        hRoot=RTW.TargetRegistry.get;
        hWaitBar.setValue(60);
    elseif nargin==1
        hWaitBar.setValue(40);
        hRoot=varargin{1};
    else
        DAStudio.error('RTW:tfl:invalidNumOfInput');
    end



    try
        aObj=DAStudio.Object;
        me=DAStudio.Explorer(aObj,'Code Replacement Viewer',false);
        me.UserData=struct('IsMatlabCoder',false);
        hWaitBar.setValue(80);
        me.showStatusBar(false);

        am=DAStudio.ActionManager;
        am.initializeClient(me);


        listener=handle.listener(me,'ObjectBeingDestroyed',{@MECallback});
        listener(end+1)=handle.listener(me,'MEPostClosed',{@MECallback});
        listener(end+1)=handle.listener(me,'METreeSelectionChanged',{@MECallback});

        screenSize=get(groot,'ScreenSize');
        width=screenSize(3);
        height=screenSize(4);
        x=floor(width/6);
        y=floor(height/6);
        height=floor(height/1.5);
        width=floor(width/1.5);
        me.position=[x,y,width,height];


        me.icon=fullfile(matlabroot,'toolbox','shared','dastudio','resources','SimulinkModelIcon.png');

        me.Title='Code Replacement Viewer';
        me.showContentsOf(false);
        hWaitBar.setValue(98);
    catch m_exception

        hWaitBar.imCancel;
        clear hWaitBar;
        rethrow(m_exception);
    end
    hWaitBar.hide;


    p1=locCreateTree(hRoot,me);


    me.setRoot(p1);
    switch me.getRoot.Type
    case 'TargetRegistry'
        me.setTreeTitle('All Libraries');
        me.setListProperties({'Name'});
    case 'TflRegistry'
        me.setTreeTitle('Code Replacement Library');
        me.setListProperties({'Name'});
    case 'TflControl'
        me.setTreeTitle('Code Replacement Controller');
        me.setListProperties({'Name'});
    case 'TflTable'
        me.setTreeTitle('Code Replacement Table');
        me.setListProperties({'Name','Implementation',...
        'NumIn','In1Type','In2Type','OutType','Priority','UsageCount'});
    case 'TflEntry'
        me.setTreeTitle('Code Replacement Entry');
        me.setListProperties({'Name','Implementation',...
        'NumIn','In1Type','In2Type','OutType','Priority','UsageCount'});
    case 'other'
        me.setTreeTitle('Code Replacement Library');
        me.setListProperties({'Name'});
    otherwise
        DAStudio.error('RTW:tfl:invalidObjError');
    end






    me.enableContextMenu('TreeView',false);
    me.enableContextMenu('ListView',false);
    me.enableContextMenu('Header',false);

    me.show;







    function p1=locCreateTree(hRoot,hme,varargin)

        persistent hWaitBarReg closeBar;
        if~isa(hWaitBarReg,'DAStudio.WaitBar')
            hWaitBarReg=DAStudio.WaitBar;cleanupObj=onCleanup(@()delete(hWaitBarReg));
            hWaitBarReg.setWindowTitle('Loading library');
            closeBar=true;
        end
        if isa(hRoot,'coder.targetreg.internal.TargetRegistry')
            p1=TflDesigner.TflViewer(hRoot,hme);

            tr=RTW.TargetRegistry.get;
            tr.refreshCRL;
            numTfl=length(tr.TargetFunctionLibraries);
            nonSimIdx=[];
            for idx=1:numTfl
                closeBar=false;%#ok
                tfl=tr.TargetFunctionLibraries(idx);
                if tfl.IsVisible
                    try
                        child(idx)=locCreateTree(tfl,hme);%#ok<AGROW>
                    catch me
                        tfl_warn=RTW.TflRegistry;
                        tfl_warn.Name=tfl.Name;
                        tfl_warn.Description='!!! Fail to load !!!';
                        child(idx)=TflDesigner.TflViewer(tfl_warn,hme);%#ok<AGROW>
                        MSLDiagnostic('RTW:tfl:FailedToLoad',me.message).reportAsWarning;
                    end
                    nonSimIdx=[nonSimIdx;idx];%#ok<AGROW>
                end
            end
            closeBar=true;
            hWaitBarReg.setValue(100);
            if hWaitBarReg.wasCanceled
                delete(hWaitBarReg);
                hWaitBarReg=[];
            end
            p1.Children=child(nonSimIdx);
            return;

        elseif isa(hRoot,'RTW.TflRegistry')
            p1=TflDesigner.TflViewer(hRoot,hme);
            hWaitBarReg.setValue(0);
            hWaitBarReg.setLabelText(hRoot.Name);
            if~hWaitBarReg.wasCanceled
                hWaitBarReg.show;
            end
            try
                tr=RTW.TargetRegistry.get;
                tables=coder.internal.getTflTableList(tr,hRoot.Name);

                [dummyList,Ia]=setdiff(tables,{'private_ansi_tfl_table_tmw.mat','private_iso_tfl_table_tmw.mat',...
                'private_intrinsic_tfl_table_tmw.mat','private_akima_lookup_tfl_table_tmw.mat'});
                if~isempty(dummyList)
                    tables=tables(sort(Ia));
                end
                numTable=length(tables);
                if numTable==0
                    child=[];
                end

                for idy=1:numTable
                    hWaitBarReg.setValue(idy/numTable*98);
                    if hWaitBarReg.wasCanceled
                        hWaitBarReg.hide;
                    end
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
                        catch
                            cd(currentDir);
                            DAStudio.error('RTW:tfl:invalidTflTable',[name,ext]);
                        end

                    case '.mat'
                        try
                            table=load(name);
                        catch
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

                    table.hTflTable.Name=[name,ext];
                    child(idy)=locCreateTree(table.hTflTable,hme);%#ok<AGROW>



                    cacheLoadedTable(table.hTflTable.Name,child(idy));
                end
            catch me
                hWaitBarReg.hide;
                closeBar=true;
                rethrow(me);
            end
            p1.Children=child(:);
            if closeBar
                hWaitBarReg.setValue(100);
            end
            return;

        elseif isa(hRoot,'RTW.TflControl')
            p1=TflDesigner.TflViewer(hRoot,hme);
            tables=hRoot.TflTables;
            numTable=length(tables);

            if numTable==0
                child=[];
            end
            for idy=1:numTable
                child(idy)=locCreateTree(tables(idy),hme);%#ok<AGROW>



                cacheLoadedTable(tables(idy).Name,child(idy));
            end
            if~isempty(hRoot.HitCache)
                cHitTable=locCreateTree(hRoot.HitCache,hme,'HitCache',true);
            else
                cHitTable=[];
            end
            if~isempty(hRoot.MissCache)
                cMisTable=locCreateTree(hRoot.MissCache,hme,'MissCache');
            else
                cMisTable=[];
            end
            if~isempty(hRoot.TLCCallList)
                cTlcTable=locCreateTree(hRoot.TLCCallList,hme,'TLCCallList');
            else
                cTlcTable=[];
            end
            p1.Children=[cHitTable;cMisTable;cTlcTable;child(:)];
            return;

        elseif isa(hRoot,'RTW.TflTable')
            if isempty(hRoot.Name)
                hRoot.Name='Table';
            end
            p1=TflDesigner.TflViewer(hRoot,hme);
            entries=hRoot.AllEntries;
            numEntries=length(entries);
            if(numEntries>0)
                for idx=1:numEntries
                    child(idx)=TflDesigner.TflViewer(entries(idx),hme);%#ok<AGROW>
                end
                p1.Children=child(:);
            else
                p1.Children=[];
            end
            return;

        elseif isa(hRoot,'RTW.TflEntry')
            entries=hRoot;
            noexcludeBuildEntries=false;
            if nargin==2
                dummyTop.Name=hRoot(1).Key;
            elseif nargin>2
                dummyTop.Name=varargin{1};
                if nargin>3
                    noexcludeBuildEntries=varargin{2};
                end
            end
            dummyTop.Version='0.0';
            dummyTop.AllEntries=[];

            for idx=1:length(entries)
                if noexcludeBuildEntries&&entries(idx).getExcludeFromBuild
                    continue;
                end
                if isempty(dummyTop.AllEntries)
                    dummyTop.AllEntries=entries(idx);
                else
                    dummyTop.AllEntries(end+1)=entries(idx);
                end
            end
            p1=TflDesigner.TflViewer(dummyTop,hme);

            child=[];
            for idx=1:length(entries)
                if noexcludeBuildEntries&&entries(idx).getExcludeFromBuild
                    continue;
                end
                if isempty(child)
                    child=TflDesigner.TflViewer(entries(idx),hme);
                else
                    child(end+1)=TflDesigner.TflViewer(entries(idx),hme);%#ok<AGROW>
                end
            end
            p1.Children=child(:);
            return;

        elseif isa(hRoot,'char')
            tr=RTW.TargetRegistry.get;
            try
                tfl=coder.internal.getTfl(tr,hRoot);
            catch ME
                DAStudio.error('RTW:tfl:inValidTfl',hRoot);
            end
            p1=locCreateTree(tfl,hme,varargin);
        else
            DAStudio.error('RTW:tfl:invalidObjError');
        end




        function MECallback(this,event)
            switch(event.type)
            case 'METreeSelectionChanged'
                switch event.EventData.Type
                case{'TargetRegistry','TflRegistry','TflControl','other'}
                    this.setListProperties({'Name'});
                case 'TflTable'
                    this.setListProperties({'Name','Implementation',...
                    'NumIn','In1Type','In2Type','OutType','Priority','UsageCount'});
                otherwise
                    DAStudio.error('RTW:tfl:invalidObjError');
                end
            case 'ObjectBeingDestroyed'




                clear global loadedTbl;
            case 'MEPostClosed'

                delete(this);
            otherwise
                DAStudio.error('RTW:tfl:unknownEventError');
            end


            function cacheLoadedTable(TflTableName,hTblTree)



                global loadedTbl;
                loadedTbl(end+1).Name=TflTableName;
                loadedTbl(end).hTblTree=hTblTree.handle;




