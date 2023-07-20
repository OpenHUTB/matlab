function asset=horzcat(asset,varargin)





    if isa(asset,'matlabshared.satellitescenario.internal.ObjectArray')

        handles=asset.Handles;
        assetClass=class(asset);
    elseif isa(asset,'double')&&isempty(asset)

        handles=cell(1,0);
        assetClass='';
    else

        msg=message('shared_orbit:orbitPropagator:CatArraysMustBeSame');
        error(msg);
    end

    for idx=1:numel(varargin)
        if isempty(assetClass)&&isa(varargin{idx},'matlabshared.satellitescenario.internal.ObjectArray')


            assetClass=class(varargin{idx});
            asset=varargin{idx};
        elseif~isempty(varargin{idx})&&~strcmpi(assetClass,class(varargin{idx}))

            msg=message('shared_orbit:orbitPropagator:CatArraysDifferent',class(asset));
            error(msg);
        end


        if~isempty(varargin{idx})
            handles=horzcat(handles,varargin{idx}.Handles);
        end
    end


    asset.Handles=handles;
end