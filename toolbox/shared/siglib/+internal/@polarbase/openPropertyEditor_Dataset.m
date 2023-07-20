function openPropertyEditor_Dataset(p)






    c=p.ColorOrder;
    if iscell(c)

        str=sprintf('''%s'',',c{:});
        p1=['{',str(1:end-1),'}'];
    else
        p1=mat2str(c);
    end
    if isscalar(p.LineWidth)
        p2=sprintf('%d',p.LineWidth);
    else
        p2=mat2str(p.LineWidth);
    end
    p3=sprintf('%d',p.MarkerSize);



    prompt={...
    'Color order',...
    'Line Width:',...
    'Marker Size:'};
    name='Dataset Properties';
    numlines=1;
    defaults={p1,p2,p3};
    options.Resize='on';
    options.WindowStyle='modal';
    options.Interpreter='tex';
    a=inputdlg(prompt,name,numlines,defaults,options);




    if~isempty(a)

        try













            if~isequal(a{1},p1)
                p.ColorOrder=evalin('base',a{1});
            end
            if~isequal(a{2},p2)
                p.LineWidth=evalin('base',a{2});
            end
            if~isequal(a{3},p3)
                p.MarkerSize=str2num(a{3});
            end
        catch me
            warndlg(me.message,'Invalid Input','modal');
        end
    end
