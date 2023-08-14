function[num,biggest,smallest]=regionProperties(info)




    props=table2array(regionprops3(info.Mask,'Volume'));

    if~isempty(props)
        num=numel(props);
        biggest=max(props);
        smallest=min(props);
    else
        num=0;
        biggest=0;
        smallest=0;
    end

end