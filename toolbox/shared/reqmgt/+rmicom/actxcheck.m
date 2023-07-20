function result=actxcheck(filenames,name)



    if~ispc
        disp('This is a Windows-only utility. Exit.');
        return;
    end

    if nargin==0

        fprintf(1,'\nChecking registration for RMI ActiveX controls\n\n');


        buttons.SLRefButton={'mwSimulink1','mwSimulink'};
        buttons.SLRefButtonA={'mwSimulink2'};


        controls=fieldnames(buttons);
        for i=1:length(controls)
            filenames=buttons.(controls{i});
            for j=1:length(filenames)
                progId=[filenames{j},'.',controls{i}];
                result=checkProdId(progId);
                if~result
                    return;
                end
            end
        end
        fprintf('All good.\n\n');

    else

        for j=1:length(filenames)
            progId=[filenames{j},'.',name];
            result=checkProdId(progId);
            if~result
                return;
            end
        end
    end
end


function ok=checkProdId(progId)
    fprintf(1,'ProgId: %s ...\n',progId);
    try
        winqueryreg('HKEY_CLASSES_ROOT',progId);
        clsid=winqueryreg('HKEY_CLASSES_ROOT',[progId,'\Clsid']);
        ok=checkClsid(clsid);
    catch Mex
        warning('SLVnV:reqmgt:checkrmiactx',Mex.message);
        ok=false;
    end
    if~ok
        fprintf(1,'Missing or invalid registration for %s\n%s\n\n',...
        progId,...
        'You may need Administrative privileges to rerun rmi(''setup'').');
        beep;
    end
end

function ok=checkClsid(clsid)
    fprintf(1,'\tclsid:\t%s ... ',clsid);
    try
        if strcmp(computer,'PCWIN64')
            location=winqueryreg('HKEY_CLASSES_ROOT',['Wow6432Node\CLSID\',clsid,'\InprocServer32']);
        else
            location=winqueryreg('HKEY_CLASSES_ROOT',['CLSID\',clsid,'\InprocServer32']);
        end
        fprintf(1,'OK\n');
        ok=checkLocation(location);
    catch Mex
        fprintf(1,'MISSING\n\n');
        warning('SLVnV:reqmgt:checkrmiactx',Mex.message);
        ok=false;
    end
end

function ok=checkLocation(location)
    fprintf(1,'\tlocation:\t%s ... ',location);
    if exist(location,'file')
        fprintf(1,'OK\n\n');
        ok=true;
    else
        fprintf(1,'MISSING\n\n');
        ok=false;
    end
end

