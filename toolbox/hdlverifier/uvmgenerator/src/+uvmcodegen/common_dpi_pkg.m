function common_dpi_pkg(varargin)
    p=inputParser;
    p.KeepUnmatched=true;
    addParameter(p,'ucfg','');
    addParameter(p,'mwcfg','');
    parse(p,varargin{:});
    ucfg=p.Results.ucfg;
    mwcfg=p.Results.mwcfg;

    UVMCodeInfo=mwcfg.sl2uvmtopo.DG.Nodes.UVMCodeInfo_Obj;
    if l_containNonFlatStructOrEnum(UVMCodeInfo)

        fileNameLoc=l_getCommonDpiPkgLoc(UVMCodeInfo,ucfg);
        l_generateCommonDpiPkg(fileNameLoc,UVMCodeInfo);
    end
end


function res=l_containNonFlatStructOrEnum(UVMCodeInfo)

    res=false;
    for idx=1:numel(UVMCodeInfo)
        thisPortInfo=UVMCodeInfo{idx}.CompPortInfo;
        if(thisPortInfo.ContainStruct&&thisPortInfo.StructEnabled)||thisPortInfo.ContainEnum
            res=true;
            break;
        end
    end
end

function str=l_getCommonDpiPkgLoc(UVMCodeInfo,ucfg)
    str=l_replaceBackS(fullfile(ucfg.component_paths('uvm_artifacts'),[UVMCodeInfo{1}.CompPortInfo.CommonDpiPkgName,'.sv']));
end

function str=l_replaceBackS(str_b)

    str=replace(str_b,'\','/');
end

function l_generateCommonDpiPkg(fileNameLoc,UVMCodeInfo)
    [~,fileName,~]=fileparts(fileNameLoc);
    genCommonDpiPkg=dpig.internal.GenSVCode(fileNameLoc);
    dpigenerator_disp(['Generating UVM module package ',dpigenerator_getfilelink(fileNameLoc)]);
    genCommonDpiPkg.addGeneratedBy('// ');
    genCommonDpiPkg.appendCode(dpig.internal.GetSVFcn.getPackageCode('DeclStart',fileName));
    genCommonDpiPkg.appendCode(l_getEnumPortDecl(UVMCodeInfo));
    genCommonDpiPkg.appendCode(l_getNonFlattenStructPortDef(UVMCodeInfo));
    genCommonDpiPkg.appendCode(dpig.internal.GetSVFcn.getPackageCode('DeclEnd',fileName));
end

function str=l_getEnumPortDecl(UVMCodeInfo)
    str='';

    EnumTypeMap=containers.Map;

    for compIdx=1:numel(UVMCodeInfo)
        thisCompPortInfo=UVMCodeInfo{compIdx}.CompPortInfo;
        if thisCompPortInfo.ContainEnum

            for idx=1:thisCompPortInfo.InportInfo.NumPorts
                [str,EnumTypeMap]=dpig.internal.GetSVFcn.getEnumDef(str,thisCompPortInfo.InportInfo.Port(idx),EnumTypeMap);
            end

            for idx=1:thisCompPortInfo.OutportInfo.NumPorts
                [str,EnumTypeMap]=dpig.internal.GetSVFcn.getEnumDef(str,thisCompPortInfo.OutportInfo.Port(idx),EnumTypeMap);
            end
        end
    end
end

function str=l_getNonFlattenStructPortDef(UVMCodeInfo)
    StructName2DefMap=containers.Map;
    StructName2StructDependencies=containers.Map;
    IsScalarizePortsEnabled=UVMCodeInfo{1}.CompPortInfo.ScalarizePortsEnabled;

    for compIdx=1:numel(UVMCodeInfo)
        thisCompPortInfo=UVMCodeInfo{compIdx}.CompPortInfo;

        if thisCompPortInfo.StructEnabled&&thisCompPortInfo.ContainStruct

            for idx=1:thisCompPortInfo.InportInfo.NumPorts
                if~isempty(thisCompPortInfo.InportInfo.Port(idx).StructInfo)
                    [StructName2DefMap,StructName2StructDependencies]=dpig.internal.GetSVFcn.getStructDef(thisCompPortInfo.InportInfo.Port(idx),'',StructName2DefMap,StructName2StructDependencies,IsScalarizePortsEnabled);
                end
            end

            for idx=1:thisCompPortInfo.OutportInfo.NumPorts
                if~isempty(thisCompPortInfo.OutportInfo.Port(idx).StructInfo)
                    [StructName2DefMap,StructName2StructDependencies]=dpig.internal.GetSVFcn.getStructDef(thisCompPortInfo.OutportInfo.Port(idx),'',StructName2DefMap,StructName2StructDependencies,IsScalarizePortsEnabled);
                end
            end
        end
    end

    str=dpig.internal.GetSVFcn.printStructDef(StructName2DefMap,StructName2StructDependencies);
end