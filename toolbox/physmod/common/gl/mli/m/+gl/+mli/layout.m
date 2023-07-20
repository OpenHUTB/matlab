function layoutStruct=layout(dotStr)





    layoutParams.fileNameRoot=tempname;
    layoutParams.dotFileName=[layoutParams.fileNameRoot,'.dot'];
    layoutParams.outFileName=[layoutParams.fileNameRoot,'.plain'];
    fid=fopen(layoutParams.dotFileName,'w');
    c=onCleanup(@()(fclose(fid)));
    fprintf(fid,dotStr);
    c=[];%#ok<NASGU>

    try

        callgraphviz('dot','-Tplain',layoutParams.dotFileName,...
        '-o',layoutParams.outFileName);


        layoutStruct=lReadLayout(layoutParams.outFileName);
    catch e
        if exist(layoutParams.dotFileName,'file')
            delete(layoutParams.dotFileName);
        end
        if exist(layoutParams.outFileName,'file')
            delete(layoutParams.outFileName);
        end
        rethrow(e);

    end

    if exist(layoutParams.dotFileName,'file')
        delete(layoutParams.dotFileName);
    end
    if exist(layoutParams.outFileName,'file')
        delete(layoutParams.outFileName);
    end

end

function layoutStruct=lReadLayout(fileName)


    fid=fopen(fileName,'r');
    c=onCleanup(@()(fclose(fid)));

    blocks=struct('id',{},'x1',{},'y1',{},'x2',{},'y2',{});

    while~feof(fid)
        str=fgetl(fid);
        while(str(end)=='\')
            str=[str(1:end-1),fgetl(fid)];
        end

        type=strread(str,'%s',1,'delimiter',' ');%#ok<FPARK>
        idx=numel(blocks)+1;
        switch type{1}
        case 'graph'
            result=textscan(str,'%s %f %f %f');
            layoutStruct.height=result{4};
            layoutStruct.width=result{3};
        case 'node'
            result=textscan(str,'%s %s %f %f %f %f %s %s %s %s %s');
            blocks(idx).id=result{2}{1};
            blocks(idx).x1=result{3};
            blocks(idx).y1=result{4};
            blocks(idx).x2=result{5};
            blocks(idx).y2=result{6};
        case 'edge'
        case 'stop'
            break;
        otherwise
            break;
        end
    end

    layoutStruct.blocks=blocks;

end
