function varargout=transform_sensor(varargin)



    persistent BlockInfoCache
    mlock;

    if isempty(BlockInfoCache)
        BlockInfoCache=simmechanics.sli.internal.BlockInfo;
        mfname=mfilename('fullpath');
        BlockInfoCache.SourceFile=which(mfname);

        BlockInfoCache.SLBlockProperties.Name=...
        pm_message('sm:library:framesAndTransforms:sensor:Name');
        className=...
        pm_message('mech2:transformSensor:parameters:className:Value');

        [b,mp,p]=sm_get_block_info(className);

        BlockInfoCache.InitialVersion=b.VersionIntroduced;
        BlockInfoCache.IconFile=b.Icon;
        BlockInfoCache.SLBlockProperties.Position=str2num(b.Position);
        BlockInfoCache.SLBlockProperties.MaskIconUnits=b.IconUnits;
        BlockInfoCache.SLBlockProperties.Orientation=b.Orientation;






        BlockInfoCache.setForwardingTableEntries('R2013b',...
        sprintf('sm_lib/Frames and\n Transforms/Transform \nSensor'),...
        'simmechanics.library.frames_transforms.sl_postprocess');

        BlockInfoCache.setTransformationFunction(...
        'simmechanics.library.frames_transforms.sl_postprocess',0,4.30);



        BlockInfoCache.setTransformationFunction(...
        'simmechanics.library.sl_postprocess',4.30,4.72);


        BlockInfoCache.setTransformationFunction(...
        'simmechanics.library.helper.translate_hertz_units',4.72,4.82);

        BlockInfoCache.SLBlockProperties.OpenFcn=...
        'simmechanics.sli.internal.pi_block_dialog(gcbh,''open'')';
        BlockInfoCache.SLBlockProperties.CloseFcn='';
        BlockInfoCache.SLBlockProperties.DeleteFcn='';
        BlockInfoCache.SLBlockProperties.CopyFcn='';


        for idx=1:numel(p)
            pi=p(idx);

            if~strcmp(pi.Type,"output")
                port=simmechanics.sli.internal.PortInfo(pi.Type,pi.Label,...
                pi.Side,pi.Id);
                BlockInfoCache.addPorts(port);
            end
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

    if nargin==1
        varargout={simmechanics.library.helper.generate_outputs(BlockInfoCache,...
        varargin{1})};
    else
        varargout{1}=BlockInfoCache.copy;
    end

end