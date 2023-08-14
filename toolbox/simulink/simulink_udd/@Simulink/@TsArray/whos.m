function varargout=whos(h)








    nameStruct=get(h,'Members');
    blkPath=get(h,'BlockPath');
    portIdx=get(h,'PortIndex');

    num=length(nameStruct);

    if nargout>0,
        for(i=1:num),
            name=nameStruct(i).name;


            if~isvarname(name)
                name=['(''',name,''')'];
            end

            out(i).name=name;
            out(i).elements=nameStruct(i).elems;
            out(i).simulinkClass=nameStruct(i).class;

            varargout{1}=out;
        end
    else

        if(portIdx>1),
            disp(['Simulink.TsArray (',blkPath,', port ',num2str(portIdx),'):']);
        else
            disp(['Simulink.TsArray (',blkPath,'):']);
        end


        s=['  Name                   Elements   Simulink Class',sprintf('\n')];
        disp(s);

        for(i=1:num),
            name=nameStruct(i).name;


            if~isvarname(name)
                names{i}=['(''',name,''')'];
            end

            [s,err]=sprintf('  %-25s %-5d   %s',name,...
            nameStruct(i).elems,nameStruct(i).class);
            disp(s);
        end


        disp(sprintf('\n'));
    end
