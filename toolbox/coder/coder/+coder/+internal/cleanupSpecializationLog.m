function cleanupSpecializationLog(filename,outputfile)


















    if nargin<1
        filename='specializationLog.txt';
    end

    if nargin<2
        [pathstr,name,ext]=fileparts(filename);
        outputfile=fullfile(pathstr,[name,'_clean',ext]);
    end

    s=fileread(filename);

    fid=fopen(outputfile,'wb');

    if fid<0
        disp('Failed to open output file.');
        return;
    end
    a=onCleanup(@()fclose(fid));

    pat='\# Specialization Logger';
    regions=regexp(s,pat,'start');

    if isempty(regions)
        disp('Invalid specialization log file.');
        return;
    end

    regions=[regions,numel(s)+1];

    for i=1:(numel(regions)-1)
        processRegion(fid,s(regions(i):(regions(i+1)-1)));
    end

end

function processRegion(fid,s)

    function pp(varargin)
        fprintf(fid,varargin{:});
    end

    function printDivider
        pp('\n%s\n',repmat('*',1,80));
    end

    pat='^\#.*$';
    markers=regexp(s,pat,'lineanchors','dotexceptnewline','match');

    pat='^\s*def\s+(?<kind>.)(?<index>\d+)\s*=\s*(?<def>.*)$';
    defs=regexp(s,pat,'lineanchors','dotexceptnewline','names');
    for i=1:numel(defs)
        defs(i).index=str2double(defs(i).index);
    end

    if isempty(defs)
        disp('No definitions found.');
    end

    pat='^\s*add\s+(?<kind>.)(?<index>\d+)\s*\+=\s*(?<def>.*)$';
    adds=regexp(s,pat,'lineanchors','dotexceptnewline','names');
    for i=1:numel(adds)
        adds(i).index=str2double(adds(i).index);
    end

    if isempty(adds)
        defKeys=[{defs.kind};{defs.index}]';
        [~,defIdx]=sortrows(defKeys,[1,2]);
        defs=defs(defIdx);
    else

        [defs.isAdd]=deal(0);
        [adds.isAdd]=deal(1);

        defs=[defs,adds];
        defKeys=[{defs.kind};{defs.index};{defs.isAdd}]';
        [~,defIdx]=sortrows(defKeys,[1,2,3]);
        defs=defs(defIdx);
        [defs.add]=deal([]);

        anchor=1;
        for i=2:numel(defs)
            if defs(i).isAdd~=0
                defs(anchor).add=defs(i).def;
            else
                anchor=i;
            end
        end
        defs([defs.isAdd]==1)=[];
        defs=rmfield(defs,'isAdd');
    end



    for i=1:numel(markers)
        pp('%s\n',markers{i});
    end

    currentKind='';
    for i=1:numel(defs)
        d=defs(i);
        if~isequal(d.kind,currentKind)
            currentKind=d.kind;
            pp('\n\n');
            switch d.kind
            case 'M',pp('MClasses');
            case 'S',pp('Specialization Contexts');
            case 'L',pp('Locations');
            case 'C',pp('Constants');
            end
            printDivider();
        end
        pp('%s%-5d = %s\n',d.kind,d.index,d.def);
        if isfield(d,'add')&&~isempty(d.add)
            pp('    ++ %s\n',d.add);
        end
    end


    pat='^\*(?<specializationTree>.*)$';
    specTree=regexp(s,pat,'lineanchors','dotexceptnewline','tokens');
    specTree=[specTree{:}];

    pp('\n\nSpecialization Tree');
    printDivider();
    for i=1:numel(specTree)
        pp('%s\n',specTree{i});
    end

    pp('\n');
    pp('\n');

end

