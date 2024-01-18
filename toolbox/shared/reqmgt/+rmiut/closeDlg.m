function closeDlg(title)

    figs=findall(0,'Type','figure');
    for i=1:length(figs)
        if strcmp(get(figs(i),'Name'),title)
            delete(figs(i));
            break;
        end
    end
end