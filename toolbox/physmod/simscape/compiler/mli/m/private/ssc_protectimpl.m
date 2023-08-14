function[varargout]=ssc_protectimpl(varargin)






    warning off backtrace;
    clean=onCleanup(@()warning('on','backtrace'));


    inplace=false;


    ispath=false;


    isrecursive=false;


    isdeploy=false;


    num_protected_files=0;
    sscp_file_list=[];


    num_other_files=0;
    other_file_list=[];


    flagList={};
    varargin=cellfun(@pm_charvector,varargin,'UniformOutput',false);
    for i=nargin:-1:1


        if isempty(varargin{i})
            pm_error('physmod:simscape:compiler:mli:ssc_protect:ArgMustBeString');
        end


        if strncmp(varargin{i},'-',1)
            if strcmpi(varargin{i},'-inplace')
                inplace=true;
                flagList=[flagList,{'-inplace'}];
            else
                pm_error('physmod:simscape:compiler:mli:ssc_protect:UnknownFlag',varargin{i});
            end
            varargin(i)=[];
        end
    end


    if numel(varargin)==0
        pm_warning('physmod:simscape:compiler:mli:ssc_protect:ZeroNonFlagParameter');
    end


    for i=1:numel(varargin)


        arg=varargin{i};


        baddots=strfind(arg,'..');
        badqmark=strfind(arg,'?');
        if~isempty(baddots)||~isempty(badqmark)
            pm_warning('physmod:simscape:compiler:mli:ssc_protect:BadPath',...
            arg);
            continue;
        end


        if exist(arg,'dir')
            if exist([arg,'.ssc'],'file')...
                ||exist([arg,'.SSC'],'file')
                pm_warning('physmod:simscape:compiler:mli:ssc_protect:Ambiguous',...
                arg);
            end
            arg=fullfile(arg,'*.*');
            ispath=true;
        end


        [pn,fn,en]=fileparts(arg);
        if~isempty(fn)

            if isempty(en)||strcmpi(en,'.sscp')
                mName=which(fullfile(pn,[fn,'.ssc']));
                if~isempty(mName)
                    arg=mName;
                else
                    arg=fullfile(pn,[fn,'.???']);
                end
            else
                fullarg=which(arg);
                if~isempty(fullarg)
                    arg=fullarg;
                end
            end
        end


        pn=fileparts(arg);
        if isempty(pn)
            arg=fullfile('.',arg);
        end


        [pn]=fileparts(arg);
        if~exist(pn,'dir')
            pm_warning('physmod:simscape:compiler:mli:ssc_protect:NotPath',...
            varargin{i});
            continue
        end


        [pn,fn,en]=fileparts(arg);
        ap=fullfile(pwd,pn,'');
        if exist(ap,'dir')
            arg=fullfile(ap,[fn,en]);
        end


        [pn,fn,en]=fileparts(arg);
        if isempty(fn)
            pm_warning('physmod:simscape:compiler:mli:ssc_protect:NotFileName',...
            varargin{i},[fn,en]);
            continue;
        end


        if strcmpi(en,'.sscp')||strcmp(en,'.*')
            en='.???';
        elseif~strcmpi(en,'.ssc')&&~strcmp(en,'.???')&&~strcmp(en,'.*')
            pm_warning('physmod:simscape:compiler:mli:ssc_protect:FileUnsupported',...
            varargin{i});
            continue;
        end
        arg=fullfile(pn,[fn,en]);


        [pn,fn,en]=fileparts(arg);
        if ispath
            arg=fullfile(pn,fn);
            files=dir(arg);
        else
            if strcmp(en,'.???')
                fm=dir(fullfile(pn,[fn,'.ssc']));
                fM=dir(fullfile(pn,[fn,'.SSC']));
                files=[fm;fM];
            else
                files=dir(arg);
            end
        end

        if isempty(files)
            pm_warning('physmod:simscape:compiler:mli:ssc_protect:FileNotFound',...
            varargin{i});
            continue;
        end

        for j=1:numel(files)
            fname=files(j).name;
            [x,fn,en]=fileparts(fname);
            if files(j).isdir
                if~strcmpi(fname,'.')&&~strcmpi(fname,'..')&&isrecursive&&~strcmp(fname,'sscprj')
                    if~issymboliclink(fullfile(pn,fname))
                        dname=fullfile(pn,fname);
                        [tmp_sscp_list,tmp_other_list]=ssc_protect_mcode(flagList{:},dname);
                        sscp_file_list=[sscp_file_list,tmp_sscp_list];
                        num_protected_files=num_protected_files+numel(tmp_sscp_list);
                        other_file_list=[other_file_list,tmp_other_list];
                        num_other_files=num_other_files+numel(tmp_other_list);
                    else
                        pm_warning('physmod:simscape:compiler:mli:ssc_protect:NoSymbolicLink',...
                        fname);
                    end
                end
            elseif strcmpi(en,'.ssc')
                ssc_protectfile(pn,fname,inplace);

                num_protected_files=num_protected_files+1;
                sscname=fullfile(pn,fn);
                sscpname=[sscname,'.sscp'];
                sscp_file_list{num_protected_files}=sscpname;
            else
                if~strcmpi(fn,'sscprj')
                    otherfilename=fullfile(pn,[fn,en]);
                    num_other_files=num_other_files+1;
                    other_file_list{num_other_files}=otherfilename;

                    if isdeploy
                        npth=sscpcodedirs(pn);
                        if~strcmp(otherfilename,fullfile(npth,[fn,en]))
                            copyfile(otherfilename,fullfile(npth,[fn,en]),'f');
                        end
                    end
                end
            end
        end
    end

    if nargout==0
    else
        if nargout==1
            varargout{1}=sscp_file_list;
        else
            if nargout==2
                varargout{1}=sscp_file_list;
                varargout{2}=other_file_list;
            else
                pm_error('physmod:simscape:compiler:mli:ssc_protect:TooManyOutputParameters');
            end
        end
    end

end



function ssc_protectfile(pth,fn,inplace)
    sscname=fullfile(pth,fn);
    sscpname=[sscname(1:end-4),'.sscp'];
    if inplace
        protectwithexceptionhandling(sscname,sscpname);
    else
        npth=sscpcodedirs(pth);
        pf=fullfile(npth,[fn(1:end-4),'.sscp']);

        protectwithexceptionhandling(sscname,pf);
    end
end


function[]=protectwithexceptionhandling(sscname,pf)

    try

        builtin('ssc_protect_internal',sscname,pf);

    catch e



        newException=pm_exception('physmod:simscape:compiler:mli:prot:FailToProtectFile',sscname);
        newException=addCause(newException,MException(e.identifier,'%s',e.message));
        throwAsCaller(newException);

    end

end



...
...
...
...
...
...
...




function destinationDir=sscpcodedirs(sourceDir)
    destinationDir=pwd;


    destinationDir=matlab.internal.language.introspective.separateImplicitDirs(destinationDir);


    [unused,sourceImplicitDirs]=matlab.internal.language.introspective.separateImplicitDirs(sourceDir);

    if~isempty(sourceImplicitDirs)


        destinationDir=fullfile(destinationDir,sourceImplicitDirs);
        cmkdir(destinationDir);
    end
end


function cmkdir(pth)
    if~exist(pth,'dir')
        mkdir(pth);
    end
end


function islink=issymboliclink(fname)

    islink=false;


    [pn,fn]=fileparts(fname);


    lsinfo=ls(pn,'-l');


    fpos=strfind(lsinfo,fn);


    if fpos+size(fn,2)+2<=size(lsinfo,2)
        if lsinfo(fpos+size(fn,2)+1)=='-'&&lsinfo(fpos+size(fn,2)+2)=='>'
            islink=true;
        end
    end

end

