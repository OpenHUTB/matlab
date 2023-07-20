function disp(h)




    scalarflag=isscalar(h);

    if~scalarflag||isvalid(h)
        s='  ';
        if~scalarflag
            sz=size(h);
            s=sprintf('%s%d',s,sz(1));
            for n=2:numel(sz)
                s=sprintf('%sx%d',s,sz(n));
            end
        end
        s=sprintf('%s %s ',s,rf.internal.makehelplinkstr(class(h)));
        if~scalarflag
            s=sprintf('%sarray ',s);
        end
        s=sprintf('%swith properties:\n',s);

        disp(s);

        if scalarflag
            getdisp(h);
        else
            props=properties(h);
            for p=1:numel(props)
                disp(horzcat('    ',props{p}));
            end
        end
    else
        str1=rf.internal.makehelplinkstr('handle','handle to deleted');
        str2=rf.internal.makehelplinkstr(class(h));
        disp(sprintf('  %s %s',str1,str2))
    end
