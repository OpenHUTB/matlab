function populate(h,root,varargin)









    if isempty(varargin)

        h.Name='';

        if isempty(h.Name)
            h.Name=strcat(root.defaulttypeprefix,num2str(root.tablecount));
            root.tablecount=root.tablecount+1;
        end
        h.Type='TflTable';

        h.children=[];
        h.object=RTW.TflTable;
        h.parentroot=root;

    else
        input=varargin{1};

        if length(varargin)==2
            nm=varargin{2};
        else
            nm=input.Name;
        end
        if isempty(nm)
            [~,nm,~]=fileparts(nm);
        end
        h.Name=nm;

        if isa(input,'RTW.TflRegistry')
            h.Type='TflRegistry';

            h.children=[];
            h.object=input.copy;
            h.parentroot=root;
            h.path=h.Name;
            h.Description=input.Description;

        elseif isa(input,'RTW.TflTable')
            if isempty(h.Name)
                h.Name=strcat(root.defaulttypeprefix,num2str(root.tablecount));
                root.tablecount=root.tablecount+1;
            end

            h.Type='TflTable';
            h.object=input.getCopy;
            h.parentroot=root;

            entries=h.object.AllEntries;
            numEntries=length(entries);
            if(numEntries>0)
                child=handle([]);
                for idx=1:numEntries
                    if allowedEntryType(entries(idx))
                        child(end+1)=TflDesigner.elements(h,entries(idx));
                    end
                end
                if~isempty(child)
                    h.children=child(:);
                end
            else
                h.children=[];
            end;

        elseif isa(input,'RTW.TflEntry')
            h.Type='TflTable';
            h.object=[];
            h.parentroot=root;
            h.path=h.Name;
            child=handle([]);

            for id=1:length(input)
                if allowedEntryType(input(id))
                    child(end+1)=TflDesigner.elements(h,input(id));
                end
            end
            if~isempty(child)
                h.children=child(:);
            end
        else
            DAStudio.error('RTW:tfl:invalidObjError');
        end
    end




    function isOkay=allowedEntryType(hEntry)

        isOkay=true;
        if isa(hEntry,'RTW.TflBlockEntry')
            isOkay=false;
        end
