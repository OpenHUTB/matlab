function varargout=general_flexible_plate(varargin)



    persistent BlockInfoCache
    mlock;

    if isempty(BlockInfoCache)
        BlockInfoCache=simmechanics.sli.internal.BlockInfo;
        mfname=mfilename('fullpath');
        BlockInfoCache.SourceFile=which(mfname);
        BlockInfoCache.SLBlockProperties.Name=...
        pm_message('sm:library:bodyElements:flexibleBodies:platesShells:generalFlexiblePlate:Name');

        className=pm_message('mech2:generalFlexiblePlate:parameters:className:Value');

        [b,mp,p]=sm_get_block_info(className);

        BlockInfoCache.InitialVersion=b.VersionIntroduced;
        BlockInfoCache.IconFile=b.Icon;
        BlockInfoCache.SLBlockProperties.Position=str2num(b.Position);
        BlockInfoCache.SLBlockProperties.MaskIconUnits=b.IconUnits;
        BlockInfoCache.SLBlockProperties.Orientation=b.Orientation;


        for idx=1:numel(p)
            pi=p(idx);
            port=simmechanics.sli.internal.PortInfo(pi.Type,pi.Label,...
            pi.Side,pi.Id);
            BlockInfoCache.addPorts(port);
        end


        make_params=@simmechanics.library.helper.make_params;

        maskParams=[];
        for idx=1:numel(mp)
            mpi=mp(idx);
            pIdx=numel(maskParams)+1;
            if strcmp(mpi.DefaultUnits,'1')||isempty(mpi.UnitsParamName)
                maskParams=[maskParams,make_params(mpi.ParamName,...
                mpi.DefaultValue,mpi.Runtime)];
            else
                maskParams=[maskParams,make_params(mpi.ParamName,...
                mpi.DefaultValue,mpi.UnitsParamName,mpi.DefaultUnits,...
                mpi.Runtime)];
            end
            maskParams(pIdx).Hidden=mpi.Hidden;
            maskParams(pIdx).Evaluate=mpi.Evaluate;
            if strcmp(mpi.ParamName,'ClassName')
                maskParams(pIdx).ReadOnly=true;
            end
        end

        BlockInfoCache.addMaskParameters(maskParams);
    end
    BlockInfoCache.HasDialogGraphics=true;

    if nargin==1
        varargout={simmechanics.library.helper.generate_outputs(BlockInfoCache,varargin{1})};
    else
        varargout{1}=BlockInfoCache.copy;
    end

end


