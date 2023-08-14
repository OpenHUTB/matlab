function callback(obj,src,evt)


    if~isa(evt,'simulinkcoder.internal.CodeViewEventData')
        return;
    end

    data=evt.data;


    if~isfield(data,'cid')||~strcmp(obj.cid,data.cid)
        return;
    end

    switch data.action
    case 'start'
        obj.sendData(data.uid);

    case 'openFiles'
        [files,folder]=uigetfile('*.*','MultiSelect','on');

        if~iscell(files)
            if files==0
                return;
            end
            files={files};
        end
        n=length(files);
        str=sprintf('Opening %d files ...',n);
        obj.publish('lock',str);

        list=cell(n,1);
        for i=1:n
            list{i}=fullfile(folder,files{i});
        end
        obj.files=list;
        d=obj.getCodeData();
        obj.publish('init',d);

    case 'openFolder'
        folder=uigetdir;
        if(folder==0)
            return;
        end

        str=sprintf('Opening files in folder: %s',folder);
        obj.publish('lock',str);

        obj.files={folder};
        d=obj.getCodeData();
        obj.publish('init',d);

    otherwise
        newEvt=simulinkcoder.internal.CodeViewEventData(data);
        obj.notify('CodeViewEvent',newEvt);

    end