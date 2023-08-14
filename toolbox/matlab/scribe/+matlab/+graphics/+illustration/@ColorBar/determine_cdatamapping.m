function mapping=determine_cdatamapping(ax)















    h=findobj(ax,'-property','CData');
    if isempty(h)
        mapping='none';
    else
        found_scaled=false;
        found_float=false;
        found_uint=false;
        for idx=1:numel(h)

            if uses_colormap(h(idx))
                if isprop(h(idx),'CDataMapping')
                    this_mapping=get(h(idx),'CDataMapping');
                    if strcmp('scaled',this_mapping)
                        found_scaled=true;
                    elseif strcmp('direct',this_mapping)
                        isuint=false;


                        if is_imagelike(h(idx))&&is_zerobased(get(h(idx),'CData'))
                            isuint=true;
                        end
                        if isuint
                            found_uint=true;
                        else
                            found_float=true;
                        end
                    end
                else


                    found_scaled=true;
                end
            end
        end

        if sum([found_scaled,found_float,found_uint])>1
            mapping='mixed';
        elseif found_scaled
            mapping='scaled';
        elseif found_float
            mapping='direct';
        elseif found_uint
            mapping='direct0based';
        else
            mapping='none';
        end
    end

    function r=uses_colormap(obj)




        r=true;
        if isprop(obj,'CData_I')
            [~,n,p]=size(obj.CData_I);


            if(p==3)||(strcmp(obj.Type,'scatter')&&(n==3))
                r=false;
            end
        end

        function r=is_imagelike(obj)









            r=false;
            if ishghandle(obj,'image')
                r=true;
            elseif ishghandle(obj,'surface')
                fc=get(obj,'FaceColor');
                if ischar(fc)&&strcmp('texturemap',fc)
                    r=true;
                end
            end

            function r=is_zerobased(c)


                if isa(c,'uint8')||isa(c,'uint16')||isa(c,'logical')
                    r=true;
                else
                    r=false;
                end
