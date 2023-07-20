function cba_import(varargin)





    persistent lastImportLocation;
    if isempty(lastImportLocation)
        lastImportLocation=pwd;
    end

    me=TflDesigner.getexplorer;
    rt=me.getRoot;

    if~isempty(me)&&~me.getRoot.iseditorbusy&&...
        strcmpi(me.getaction('FILE_IMPORT').Enabled,'on')==1

        me.getaction('FILE_IMPORT').Enabled='off';

        if nargin==0
            [filename,pathname]=uigetfile(...
            {'*.m;*.p;*.mat;','MATLAB Files (*.m,*.p,*.mat)';
            '*.m',DAStudio.message('RTW:tfldesigner:ImportMATLABFiles');...
            '*.p','p-files (*.p)';...
            '*.mat','MAT-files (*.mat)'},...
            DAStudio.message('RTW:tfldesigner:OpenDialogTitle'),...
            lastImportLocation);
            if filename==0
                me.getaction('FILE_IMPORT').Enabled='on';
                return;
            end
            [pathstr,name,ext]=fileparts([pathname,filename]);
        else

            [pathstr,name,ext]=fileparts(varargin{1});
            if isempty(pathstr)||isempty(ext)

                flag=exist(varargin{1});%#ok
                if flag==2||flag==6
                    search=which([name,ext]);
                    [pathstr,name,ext]=fileparts(search);
                end
                if flag==5
                    name=varargin{1};
                    pathstr=pwd;
                end
            end
            if(~strcmp(ext,'.m')&&~strcmp(ext,'.mat')&&~strcmp(ext,'.p'))...
                ||isempty(name)
                me.getaction('FILE_IMPORT').Enabled='on';
                me.setStatusMessage('Invalid TFL table');
                DAStudio.error('RTW:tfl:invalidTflTable',varargin{1});
            end
        end

        rt.iseditorbusy=true;
        me.setStatusMessage(DAStudio.message('RTW:tfldesigner:ImportInProgressStatusMsg'));
        lastImportLocation=pathstr;
        currentDir=pwd;
        if~isempty(pathstr)
            try
                cd(pathstr);
            catch err
                rt.iseditorbusy=false;
                me.getaction('FILE_IMPORT').Enabled='on';
                me.setStatusMessage('Invalid TFL table');
                DAStudio.error('RTW:tfl:invalidTflTable',fullfile(pathstr,name,ext));
            end
        end

        switch ext
        case{'','.m','.p'}
            try
                table.hTflTable=feval(name);
                if~isa(table.hTflTable,'RTW.TflTable')
                    DAStudio.error('RTW:tfl:invalidTflTable',[name,ext]);
                end
                table.hTflTable.Name=getNameStr(rt,name,0);
            catch ME
                rt.iseditorbusy=false;
                me.getaction('FILE_IMPORT').Enabled='on';
                cd(currentDir);
                me.setStatusMessage('Invalid TFL table');
                DAStudio.error('RTW:tfl:invalidTflTable',[name,ext]);
            end

        case '.mat'
            try
                table=load(name);
                if~isa(table.hTflTable,'RTW.TflTable')
                    me.setStatusMessage('Invalid TFL table');
                    DAStudio.error('RTW:tfl:invalidTflTable',[name,ext]);
                end
                table.hTflTable.Name=name;
            catch ME
                rt.iseditorbusy=false;
                me.getaction('FILE_IMPORT').Enabled='on';
                cd(currentDir);
                me.setStatusMessage('Invalid TFL table');
                DAStudio.error('RTW:tfl:invalidTflTable',[name,ext]);
            end

        otherwise
            rt.iseditorbusy=false;
            me.getaction('FILE_IMPORT').Enabled='on';
            cd(currentDir);
            me.setStatusMessage('Invalid TFL table');
            DAStudio.error('RTW:tfl:invalidTflTable',[name,ext]);
        end
        if~isempty(pathstr)
            cd(currentDir);
        end

        child=TflDesigner.node(rt,table.hTflTable,table.hTflTable.Name);
        child.isDirty=false;
        child.path=pathstr;
        if isempty(rt.children)
            rt.children=child;
        else
            rt.children=[rt.children;child];
        end

        rt.firehierarchychanged;
        rt.refreshchildrencache(true);
        TflDesigner.setcurrenttreenode(child);
        child.firelistchanged;
        me.setStatusMessage(DAStudio.message('RTW:tfldesigner:ReadyStatus'));
        rt.iseditorbusy=false;
        me.getaction('FILE_IMPORT').Enabled='on';
    end


    function nameStr=getNameStr(rt,str,index)

        nameStr=str;
        matchfound=false;

        if index~=0
            nameStr=[str,'_',num2str(index)];
        end

        childNodes=rt.getChildren;
        if~isempty(childNodes)
            for i=1:length(childNodes)
                name=childNodes(i).Name;
                if strcmp(name,nameStr)
                    matchfound=true;
                    break;
                end
            end
        end

        if matchfound
            nameStr=getNameStr(rt,str,index+1);
        end


















