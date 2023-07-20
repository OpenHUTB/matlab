function buildLibrary(this,cm,options)



















    debug=false;


    wstate=warning('off','dsp:hdlshared:DeprecateHDLStreamingFFTSupport');

    if nargin==3&&strcmp(options,'html')
        htmlreport=true;
    else
        htmlreport=false;
    end

    getCatMap('init');
    blklist=getSupportedBlocks(this);
    nblks=numel(blklist);



    if~isStateflowAvailable

        sfblkid=strncmpi('sflib/',blklist,6);
        blklist=blklist(~sfblkid);

        sfblkid=strncmpi('hdlsllib/HDL Operations/Bit ',blklist,21);
        blklist=blklist(~sfblkid);
        nblks=numel(blklist);
    end


    iblt=strncmpi('built-in/',blklist,9);
    bltins=blklist(iblt);
    isl=strncmpi('simulink/',blklist,9);
    slblks=blklist(isl);
    otblks=blklist(logical(1-(iblt+isl)));
    blklist={bltins{:},slblks{:},otblks{:}};%#ok<CCAT>

    if numel(blklist)~=nblks
        error(message('hdlcoder:engine:badblockpartition'));
    end

    libraries=getSupportedLibraries(this);


    if~isStateflowAvailable
        sflibidx=strcmpi('sflib',libraries);
        bitopslibidx=strcmpi('hdldemolib_bitops',libraries);
        libraries=libraries(~(sflibidx+bitopslibidx));
    end

    libraries=openalllibraries(libraries);
    hdllibpos=emitblockpreamble(htmlreport);

    blknamelist={};
    for n=1:nblks
        if htmlreport
            fprintf(htmlfile,'<TR>\n');
        end
        foundone=false;
        foundblks={};
        blk=blklist{n};

        if~publishBlock(this,blk)
            continue;
        end

        if strcmpi(blk,'built-in/SubSystem')
            foundone=true;
            foundblks={foundblks{:},'built-in/SubSystem'};%#ok<CCAT>
        elseif strcmpi(blk,'built-in/MATLABSystem')
            foundone=true;
            foundblks={foundblks{:},'simulink/User-Defined Functions/MATLAB System'};%#ok<CCAT>
        elseif strncmpi(blk,'built-in',8)
            for libn=1:numel(libraries)


                fblks=find_system(libraries{libn},'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'BlockType',strrep(blk,'built-in/',''));
                if~isempty(fblks)
                    foundone=true;
                    foundblks={foundblks{:},fblks{:}};%#ok<CCAT>
                end
            end
        else
            for libn=1:numel(libraries)


                libblks=find_system(libraries{libn},'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices);
                libblkssp=strrep(libblks,newline,' ');
                fblks=strcmp(libblkssp,blk);
                if any(fblks)
                    foundone=true;
                    foundblks={foundblks{:},libblks{fblks}};%#ok<CCAT>
                end
            end
        end

        if foundone

            newfoundblks={};
            newcount=1;
            foundblks=filterDuplicates(foundblks);
            blkcategory=cell(numel(foundblks));
            for q=1:numel(foundblks)
                if~isProblemBlock(foundblks{q})
                    newfoundblks{newcount}=foundblks{q};%#ok<AGROW>

                    blkcategory{newcount}=...
                    getblkcategory(newfoundblks{newcount},cm);
                    newcount=newcount+1;
                end
            end
            foundblks=newfoundblks;
            [hdllibpos,blknamelist]=emitblocknames(this,foundblks,blkcategory,...
            htmlreport,hdllibpos,blknamelist,cm,debug);
            if htmlreport
                fprintf(htmlfile,'</TR>\n');
            end
        end
    end

    if htmlreport
        printCategoryList;
    end

    emitblockpostamble(htmlreport,cm);

    if htmlreport
        link=sprintf('<a href="matlab:web %s">%s</a>',htmlblklistfilename,htmlblklistfilename);
        hdldisp(message('hdlcoder:hdldisp:SupportedList',link));
        link=sprintf('<a href="matlab:web %s">%s</a>',htmlfilename,htmlfilename);
        hdldisp(message('hdlcoder:hdldisp:ImplementationList',link));
    end




    q=find_system(hdllibraryname,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'BlockType','SubSystem');
    for itr=length(q):-1:1

        set_param(q{itr},'ZoomFactor','100');
    end


    warning(wstate);





    open_system(hdllibraryname);
end






























function outblks=filterDuplicates(blks)


    outblks={};


    blks=blks(~endsWith(blks,'dsphdlfiltering/Discrete FIR Filter'));

    if length(blks)>1
        matchblks=strfind(blks,'hdlsllib');
        if~isempty(matchblks)
            for ii=1:length(matchblks)
                if isempty(matchblks{ii})
                    outblks{end+1}=blks{ii};%#ok<AGROW>
                end
            end
        else
            outblks=blks;
        end
    else
        outblks=blks;
    end

end


function blkPublish=publishBlock(this,blk)



    blkImpls=this.getImplementationsFromBlock(blk);
    blkPublish=false;
    for ii=1:length(blkImpls)
        impl=eval(blkImpls{ii});
        if impl.getPublish
            blkPublish=true;
            break;
        end
    end
end


function libNames=rearrangeLibNames(libNames)

    libName='Simulink';
    idx=find(ismember(libNames,libName));
    if~isempty(idx)
        libNames(idx)=[];%#ok<*FNDSB>
        libNames=[{libName},libNames];
    end

    libName='HDL Demo Library';
    idx=find(ismember(libNames,libName));
    if~isempty(idx)
        libNames(idx)=[];%#ok<*FNDSB>
        libNames=[libNames,{libName}];
    end
end


function printCategoryList
    catMap=getCatMap('');
    keys=catMap.keys;

    keys=rearrangeLibNames(keys);

    for ii=1:length(keys)
        k=keys{ii};
        vals=catMap(k);
        fprintf(htmlblklistfile,'<TR>\n');

        if~isempty(vals)
            vals=sort(unique(vals));
        end

        empLen=length(vals)-1;
        str=[k,repmat('<BR>',1,empLen)];
        fprintf(htmlblklistfile,'<TD WIDTH=300>%s<BR></TD>\n',str);

        list='';
        for jj=1:length(vals)
            v=vals{jj};
            list=[list,sprintf('%s<BR>',v)];%#ok<AGROW>
        end

        fprintf(htmlblklistfile,'<TD WIDTH=300>%s</TD></TR>\n',list);
    end
end


function prob=isProblemBlock(blk)
    blkname=get_param(blk,'Name');




    blacklist={...
    ['Signed',char(10),'Sqrt'],...
    'Variable Integer Delay',...
    };

    prob=any(strcmp(blkname,blacklist));
end


function hdllibpos=emitblockpreamble(htmlreport)
    hdllibpos=openhdllibrary;
    if htmlreport
        htmlfile('open');
        htmlblklistfile('open');
    end
end


function[hdllibpos,blknamelist]=emitblocknames(this,foundblks,...
    blkcategory,htmlreport,hdllibpos,blknamelist,cm,debug)
    for p=1:numel(foundblks)
        [hdllibpos,blknamelist]=addtohdllibrary(foundblks{p},...
        blkcategory{p},hdllibpos,blknamelist);
    end

    if htmlreport
        blknamehtml(this,foundblks,cm,debug);
    end
end


function emitblockpostamble(htmlreport,cm)
    closehdllibrary(cm);
    if htmlreport
        htmlfile('close');
        htmlblklistfile('close');
    end
end


function openlibraries=openalllibraries(libraries)
    openlibraries={};
    for libn=1:numel(libraries)
        lib=libraries{libn};
        try
            load_system(lib);
            openlibraries{end+1}=lib;%#ok<AGROW>
        catch me

        end
    end
end


function libname=hdllibraryname
    libname='hdlsupported';
end


function hdllibpos=openhdllibrary
    libname=hdllibraryname;
    try
        new_system(libname,'Library')
    catch me
        error(message('hdlcoder:engine:newlibfailed',libname));
    end




    hdlsetup(libname);


    hdllibpos=containers.Map;
    pos=startpos;
    hdllibpos('default')=pos;
    hdllibpos('')=pos;


    tempsubsys=gettempnames;
    add_block('built-in/SubSystem',[libname,'/',tempsubsys],'Position',[100,100,110,110]);
end


function pos=startpos
    pos.x=2;
    pos.y=2;
    pos.count=0;
    pos.yrow=0;
end



function[hdllibpos,blknamelist]=addtohdllibrary(blk,category,hdllibpos,blknamelist)
    libname=hdllibraryname;
    blkname=get_param(blk,'Name');

    switch get_param(blk,'BlockType')
    case{'S-Function','SubSystem','M-S-Function'}
        obj=get_param(blk,'Object');
        src=[get(obj,'Path'),'/',get_param(blk,'Name')];
        if~isempty(get(obj,'Path'))
            pos=get_param(src,'Position');
            xsize=pos(3)-pos(1);
            ysize=pos(4)-pos(2);
        else
            src=blk;
            xsize=80;
            ysize=50;
        end
    otherwise
        src=blk;
        pos=get_param(src,'Position');
        xsize=pos(3)-pos(1);
        ysize=pos(4)-pos(2);
    end


    if(xsize<30&&ysize<30)
        xsize=30;ysize=30;
    end


    if isempty(category)
        category_str='';
    else
        category_str=['/',category];
    end



    hdllibpos=add_subsys(category,libname,hdllibpos);


    catpos=hdllibpos(fixname(category));

    addToCategoryMap(category_str,blkname);


    blkh=add_block(src,[libname,category_str,'/',blkname],...
    'MakeNameUnique','on',...
    'Position',[catpos.x,catpos.y,catpos.x+xsize,catpos.y+ysize]);
    set_param(blkh,'ShowName','on');


    setupBlock(getfullname(blkh))

    if strcmpi(category_str,['/Simulink/Math',char(10),'Operations'])&&strcmpi(blkname,'Divide')
        set_param(blkh,'Inputs','/');
    end



    if isempty(strfind(category_str,['Commonly',char(10),'Used Blocks']))
        blknamelist{end+1}=blkname;
    end


    catpos=getnewposXY(catpos,xsize,ysize);

    hdllibpos(fixname(category))=catpos;

end


function setupBlock(blk)

    if strcmpi(blk,'hdlsupported/Simulink/Continuous/PID Controller')
        set_param(blk,'TimeDomain','Discrete-time');
    end

    if strcmpi(blk,'hdlsupported/Simulink/Discrete/Resettable Delay')
        set_param(blk,'ExternalReset','Level');
        set_param(blk,'InitialConditionSource','Dialog');
    end
end


function closehdllibrary(cm)
    libname=hdllibraryname;


    tempsubsys=gettempnames;
    if~isempty(find_system(libname,'SearchDepth',1,...
        'BlockType','SubSystem','Name',tempsubsys))
        delete_block([libname,'/',tempsubsys]);
    end



    set_param(libname,'ModelBrowserVisibility','on');
    set_subsys_params(libname);


    rearrangeblocks(libname,cm);

    if isStateflowAvailable
        rt=slroot;
        machine=rt.find('-isa','Stateflow.Machine','Name',libname);
        if~isempty(machine)
            machine.tag=sfprivate('get_sf_library_tag');
        end
    end
end








function result=htmlfile(cmd)
    persistent fid;

    if nargin==1
        switch(cmd)
        case 'open'
            validateblock;
            fid=fopen(htmlfilename,'w','n','utf-8');

            if fid<0
                error(message('hdlcoder:engine:cannotopenhtmlfile'));
            end

            toolVersion=ver('hdlcoder');
            desc=['<p>The following table describes the blocks that are supported for\n'...
            ,'HDL code generation and their respective implementation architectures in ',...
            toolVersion.Name,' ',toolVersion.Version,'.\n</p>\n'];
            printPreamble(fid,desc);
            fprintf(fid,'<TR><TH>Simulink Block</TH><TH>Configuration Blockscope</TH>');
            fprintf(fid,'<TH>Configuration Implementation Architecture</TH></TR>');
        case 'close'
            printPostamble(fid);

        otherwise
        end
    end
    result=fid;
end

function result=htmlblklistfile(cmd)
    persistent fid2;
    if nargin<1
        cmd='';
    end

    switch(cmd)
    case 'open'
        fid2=fopen(htmlblklistfilename,'w','n','utf-8');
        if fid2<0
            error(message('hdlcoder:engine:cannotopenblocklistfile'));
        end

        desc='<p>The following table shows the summary of blocks that are supported for HDL Code generation\n</p>\n';
        printPreamble(fid2,desc);
        fprintf(fid2,'<TR><TH>Simulink Library</TH><TH>Block Name</TH></TR>');

    case 'close'
        printPostamble(fid2);
    otherwise
    end
    result=fid2;
end

function printPostamble(fid)
    if~isempty(fid)
        fprintf(fid,'</TABLE>\n');
        fprintf(fid,'</body>\n');
        fprintf(fid,'</html>\n');
        fclose(fid);
    end
end


function printPreamble(fid,desc)
    fprintf(fid,'<html>\n');
    fprintf(fid,'<head>\n');
    fprintf(fid,'<title>HDL Block Support</title>\n');
    fprintf(fid,'<meta http-equiv="Content-Type" content="text/html; charset=utf-8">\n');
    fprintf(fid,'</head>\n');
    fprintf(fid,'<body bgcolor="#FFFFFF" text="#000000">\n');
    fprintf(fid,'<font face="Arial, Helvetica, sans-serif"> \n');
    fprintf(fid,'<h2><font face="Arial, Helvetica, sans-serif" color="#990000">HDL Block\n');
    fprintf(fid,' Support</font></h2>\n');
    fprintf(fid,desc);
    fprintf(fid,'<TABLE border=1>\n');
end


function filename=htmlfilename()
    filename=[hdllibraryname,'.html'];
end


function filename=htmlblklistfilename()
    filename='hdlblklist.html';
end


function result=validateblock(blkname)
    persistent blocks;
    result=false;
    if nargin<1
        blocks={};
    else
        slashpos=find(blkname=='/');
        if~isempty(slashpos)
            blkname=blkname(slashpos(end)+1:end);
        end
        if isempty(find(strcmp(blocks,blkname),1))
            blocks{end+1}=blkname;
            result=true;
        end
    end
end



function catMap=getCatMap(cmd)
    persistent myCatMap;
    if isempty(myCatMap)||strcmpi(cmd,'init')
        myCatMap=containers.Map;
    end
    catMap=myCatMap;
end


function addToCategoryMap(category,name)
    myCatMap=getCatMap('');
    category=strrep(category,char(10),' ');
    name=strrep(name,char(10),' ');

    if(category(1)=='/')
        category=category(2:end);
        category=strtok(category,'/');
    end

    if~isempty(category)||~isempty(name)
        if isKey(myCatMap,category)
            values=myCatMap(category);
            values{end+1}=name;
            myCatMap(category)=values;%#ok<*NASGU>
        else
            myCatMap(category)={name};
        end
    end
end


function blknamehtml(this,foundblks,cm,debug)
    for p=1:numel(foundblks)
        pname=foundblks{p};
        pname(pname==char(10))=' ';
        blk=pname;
        if validateblock(blk)
            fprintf(htmlfile,'<TR>\n');
            fprintf(htmlfile,'<TD>%s<BR></TD>\n',blk);

            switch get_param(blk,'BlockType')
            case{'S-Function','SubSystem','M-S-Function'}
                obj=get_param(blk,'Object');
                if isempty(get(obj,'Path'))
                    tag=['built-in/',get_param(blk,'Name')];
                else
                    tag=[get(obj,'Path'),'/',get_param(blk,'Name')];
                end
            otherwise
                tag=['built-in/',get_param(blk,'BlockType')];
            end
            fprintf(htmlfile,'<TD>%s<BR></TD>\n',tag);
            impls=this.getImplementationsFromBlock(tag);
            topSet=cm.DefaultTable.getImplementationSet(cm.ModelName);
            implInfo=topSet.getImplInfoForBlockLibPath(tag);
            if~isempty(implInfo)
                defimpl=implInfo.ArchitectureName;
            else
                defimpl='';
            end

            fprintf(htmlfile,'<TD>');
            for nn=1:numel(impls)
                impl=eval(impls{nn});

                implarch=impl.ArchitectureNames;
                if isempty(implarch)
                    implarch={'default'};
                end
                defMatch=strfind(implarch,'default');

                if strcmpi(defimpl,impls{nn})&&...
                    isempty([defMatch{:}])
                    implarch={'default',implarch{:}};%#ok<CCAT>
                end
                implarch_str='';
                for ii=1:length(implarch)
                    implarch_str=[implarch_str,implarch{ii},', '];%#ok<AGROW>
                end

                if strcmp(implarch_str(end-1:end),', ')
                    implarch_str=implarch_str(1:end-2);
                end

                if debug

                    [~,clsname]=strtok(impls{nn},'.');
                    if~isempty(clsname)

                        clsname=clsname(2:end);
                    end
                    implarch_str=[implarch_str,' (',clsname,')'];%#ok<AGROW>
                end

                fprintf(htmlfile,'%s<BR>\n',implarch_str);

                newPVPairs=impl.implParamNames;
                if~isempty(newPVPairs)
                    fprintf(htmlfile,'<UL>');
                    for kk=1:length(newPVPairs)
                        fprintf(htmlfile,'<LI> %s\n',newPVPairs{kk});
                    end
                    fprintf(htmlfile,'</UL>');
                end
            end
            fprintf(htmlfile,'</TD>');

            fprintf(htmlfile,'</TR>\n');
        end
    end
end


function hdllibpos=add_subsys(category,libname,hdllibpos)


    cat_idx=strfind(category,'/');
    if isempty(cat_idx)
        cat_idx=length(category)+1;
    else
        cat_idx=[cat_idx,length(category)+1];
    end

    sys_name='';
    find_sys_name=libname;
    start_idx=1;
    for ii=1:numel(cat_idx)

        subsys_name=category(start_idx:cat_idx(ii)-1);


        subsys_list=find_system(find_sys_name,'regexp','on',...
        'SearchDepth',1,'Name',subsys_name);


        find_sys_name=[find_sys_name,'/',subsys_name];%#ok<AGROW>


        if isempty(sys_name)
            new_sys_name=subsys_name;
        else
            new_sys_name=[sys_name,'/',subsys_name];
        end


        if isempty(subsys_list)
            xsize=60;
            ysize=40;
            pos=hdllibpos(fixname(sys_name));
            add_block('built-in/Subsystem',find_sys_name,'Position',...
            [pos.x,pos.y,pos.x+xsize,pos.y+ysize]);
            set_subsys_params(find_sys_name);
            pos=getnewposXY(pos,xsize,ysize);
            hdllibpos(fixname(sys_name))=pos;


            hdllibpos(fixname(new_sys_name))=hdllibpos('default');
        end


        start_idx=cat_idx(ii)+1;
        sys_name=new_sys_name;
    end
end


function pos=getnewposXY(pos,xsize,ysize)

    maxcount=4;
    pos.yrow=max(pos.yrow,ysize);
    pos.count=pos.count+1;
    pos.x=pos.x+xsize+20;
    if(pos.count==1)
        pos.x=pos.x+30;
    end
    if(pos.count>=maxcount)
        pos.yrow=max(pos.yrow+45,120);
        pos.y=pos.y+pos.yrow;
        pos.x=20;
        pos.yrow=0;
        pos.count=0;
    end
end


function name=fixname(name)


    replacewithspace_list={char(9),char(10),char(12),char(13)};
    for i=1:numel(replacewithspace_list)
        name=strrep(name,replacewithspace_list{i},' ');
    end
end


function blkcategory=getblkcategory(blk,cm)


    defimpl=getdefimpl(blk,cm);

    if isempty(defimpl)

        blkcategory=gethdllibcategory(blk);
    else

        blkcategory=defimpl.libcategory(blk);
    end
end


function defimpl=getdefimpl(blk,cm)

    [tempsubsys,tempblk]=gettempnames;
    libname=hdllibraryname;

    blkname=[libname,'/',tempsubsys,'/',tempblk];
    add_block(blk,blkname);
    blkpath=hdlgetblocklibpath(blkname);

    delete_block(blkname);


    defimpl=cm.getDefaultImplementation(blkpath);
end


function[tempsubsys,tempblk]=gettempnames

    tempsubsys='Temp';
    tempblk='TempBlk';
end


function set_subsys_params(subsysname)
    pos=get_param(subsysname,'Location');
    set_param(subsysname,'Location',[pos(1),pos(2),pos(1)+600,pos(2)+400]);
    set_param(subsysname,'ZoomFactor','100');
end


function goforit=isStateflowAvailable
    q=ver;
    goforit=any(strcmp('Stateflow',{q.Name}))&&license('test','Stateflow');
end


function rearrangeblocks(name,cm)

    subsys=find_system(name,'SearchDepth',1,...
    'BlockType','SubSystem','ReferenceBlock','');

    subsys=setdiff(subsys,{name});

    for ii=1:numel(subsys)
        if strcmpi(get_param(subsys{ii},'SFBlockType'),'NONE')
            rearrangeblocks(subsys{ii},cm);
        end
    end


    if strcmpi(name,hdllibraryname)
        return;
    end



    blks=get_param(name,'Blocks');
    pos=startpos;
    blks=sort(blks);
    for jj=1:numel(blks)

        blkpos=get_param([name,'/',blks{jj}],'Position');
        xsize=blkpos(3)-blkpos(1);
        ysize=blkpos(4)-blkpos(2);

        blkname=[name,'/',blks{jj}];
        set_param(blkname,...
        'Position',[pos.x,pos.y,pos.x+xsize,pos.y+ysize]);


        blkpath=hdlgetblocklibpath(blkname);
        defimpl=cm.getDefaultImplementation(blkpath);

        blkh=get_param(blkname,'Handle');

        fixblk(defimpl,blkh);


        pos=getnewposXY(pos,xsize,ysize);
    end
end


function fixblk(defimpl,blkh)


    if~isempty(defimpl)

        defimpl.fixblkinhdllib(blkh);
    end
end



