function readXml(blockInfo,className)

    [b,mp,p]=sm_get_block_info(className);

    blockInfo.InitialVersion=b.VersionIntroduced;
    blockInfo.IconFile=b.Icon;
    blockInfo.SLBlockProperties.Position=str2num(b.Position);
    blockInfo.SLBlockProperties.MaskIconUnits=b.IconUnits;
    blockInfo.SLBlockProperties.Orientation=b.Orientation;
    blockInfo.HasDialogGraphics=getBool(b.HasDialogGraphics);

    blockInfo.SLBlockProperties.OpenFcn=...
    'simmechanics.sli.internal.block_dialog(gcbh,''open'')';
    blockInfo.SLBlockProperties.CloseFcn='';
    blockInfo.SLBlockProperties.DeleteFcn='';
    blockInfo.SLBlockProperties.CopyFcn='';


    for idx=1:numel(p)
        pi=p(idx);
        port=simmechanics.sli.internal.PortInfo(pi.Type,pi.Label,...
        pi.Side,pi.Id);
        blockInfo.addPorts(port);
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

    blockInfo.addMaskParameters(maskParams);

end

function bool=getBool(boolStr)
    bool=false;
    if(strcmpi(boolStr,'on')||strcmpi(boolStr,'true'))
        bool=true;
    end
end