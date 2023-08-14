function oldbuildLibrary(this)





    blklist=getSupportedBlocks(this);

    nblks=numel(blklist);

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
    libraries=openalllibraries(libraries);
    hdllibpos=openhdllibrary;

    for n=1:nblks
        foundone=false;
        foundblks={};
        blk=blklist{n};


        blkImpls=this.getPublishedImplementations(blk);
        if isempty(blkImpls)
            continue;
        end

        if strcmpi(blk,'built-in/SubSystem')
            foundone=true;
            foundblks={foundblks{:},'built-in/SubSystem'};%#ok<CCAT>
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
                libblkssp=strrep(libblks,char(10),' ');
                fblks=strmatch(blk,libblkssp,'exact');
                if~isempty(fblks)
                    foundone=true;
                    foundblks={foundblks{:},libblks{fblks}};%#ok<CCAT>
                end
            end
        end

        if foundone

            newfoundblks={};
            newcount=1;
            for q=1:numel(foundblks)
                if~isProblemBlock(foundblks{q})
                    newfoundblks{newcount}=foundblks{q};%#ok<AGROW>
                    newcount=newcount+1;
                end
            end
            foundblks=newfoundblks;
            hdllibpos=emitblocknames(foundblks,hdllibpos);
        end
    end
end


function prob=isProblemBlock(blk)
    blkname=get_param(blk,'Name');
    blacklist={
    'Enable',...
    'StateEnable',...
    'Trigger',...
    ['Signed',char(10),'Sqrt'],...
    'Resettable Delay',...
    'Variable Integer Delay',...
    };
    prob=any(strcmp(blkname,blacklist));
end


function blks=duplicateNameBlocks
    blks={'HDL Cosimulation',['Math',char(10),'Function']};
end


function hdllibpos=emitblocknames(foundblks,hdllibpos)
    for p=1:numel(foundblks)
        hdllibpos=addtohdllibrary(foundblks{p},hdllibpos);
    end
end


function openlibraries=openalllibraries(libraries)
    openlibraries={};
    for libn=1:numel(libraries)
        lib=libraries{libn};
        try
            load_system(lib);
            openlibraries{end+1}=lib;%#ok<AGROW>
        catch me %#ok<NASGU>

        end
    end
end


function libname=hdlibraryname
    libname='hdlsupported';
end


function hdllibpos=openhdllibrary
    libname=hdlibraryname;
    try
        new_system(libname,'Library')
        open_system(libname);
    catch me
        error(message('hdlcoder:engine:newlibfailed',libname));
    end


    hdllibpos.x=10;
    hdllibpos.y=10;
    hdllibpos.count=0;
    hdllibpos.yrow=0;
end


function hdllibpos=addtohdllibrary(blk,hdllibpos)
    libname=hdlibraryname;
    blkname=get_param(blk,'Name');
    blocks=get_param(libname,'Blocks');

    samenameblks=strmatch(blkname,blocks,'exact');
    duplicatedOK=strmatch(blkname,duplicateNameBlocks,'exact');

    if isempty(samenameblks)||~isempty(duplicatedOK)
        origname=blkname;
        n=1;
        while~isempty(samenameblks)&&n<1000
            blkname=[origname,num2str(n)];
            n=n+1;
            samenameblks=strmatch(blkname,blocks,'exact');
        end
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
        add_block(src,[libname,'/',blkname],...
        'Position',[hdllibpos.x,hdllibpos.y...
        ,hdllibpos.x+xsize,hdllibpos.y+ysize]);
        hdllibpos.yrow=max(hdllibpos.yrow,ysize);
        hdllibpos.count=hdllibpos.count+1;
        hdllibpos.x=hdllibpos.x+150;
        if(hdllibpos.count>=10)
            hdllibpos.yrow=max(hdllibpos.yrow+45,120);
            hdllibpos.y=hdllibpos.y+hdllibpos.yrow;
            hdllibpos.x=10;
            hdllibpos.yrow=0;
            hdllibpos.count=0;
        end
    end
end
