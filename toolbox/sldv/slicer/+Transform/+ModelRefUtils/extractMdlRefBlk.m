function[sliceMdlH,subSysH]=extractMdlRefBlk(MdlBlk,ssIOActivity)





    origRefMdl=get_param(MdlBlk,'ModelName');
    mdlPath=which(origRefMdl);
    [~,~,ext]=fileparts(mdlPath);
    tempFilePath=Sldv.utils.settingsFilename([origRefMdl,'_copy'],'on',ext,origRefMdl,false,true);
    [ok,msg]=copyfile(mdlPath,tempFilePath,'f');
    if~ok
        error('ModelSlicer:CannotWriteFile',getString(message('Sldv:ModelSlicer:ModelSlicer:CannotWriteModelFile',msg)));
    end
    [ok,msg]=fileattrib(tempFilePath,'+w');
    if~ok
        error('ModelSlicer:CannotWriteFile',getString(message('Sldv:ModelSlicer:ModelSlicer:CannotWriteModelFile',msg)));
    end
    [~,sliceMdl]=fileparts(tempFilePath);
    load_system(tempFilePath);
    sliceMdlH=get_param(sliceMdl,'handle');


    convert2subsys(sliceMdl);


    fixModelWorkspace();


    subSysH=find_system(sliceMdlH,'SearchDepth',1,'BlockType','SubSystem');
    set_param(subSysH,'TreatAsAtomicUnit','On');
    set_param(subSysH,'Name',get_param(MdlBlk,'Name'));


    addDswBlocks();


    save_system(sliceMdl);

    function convert2subsys(sys)
        blocks=find_system(sys,'SearchDepth',1);
        bh=[];
        for i=2:length(blocks)
            bh=[bh,get_param(blocks{i},'handle')];
        end
        Simulink.BlockDiagram.createSubSystem(bh);
    end

    function fixModelWorkspace()


        mws=get_param(sliceMdl,'ModelWorkspace');
        paramArgs=get_param(MdlBlk,'ParameterArgumentValues');
        if isstruct(paramArgs)
            varnames=fieldnames(paramArgs);
            for i=1:length(varnames)
                var=varnames{i};
                if mws.hasVariable(var)

                    value=slResolve(var,origRefMdl);
                    mws.assignin(var,value);
                end
            end
        end
    end

    function addDswBlocks()
        PortInfo.numOfInports=length(ssIOActivity.Inport);
        PortInfo.numOfOutports=length(ssIOActivity.Outport);

        dsmNames=ssIOActivity.DataStoreName.Active;
        posConsts=Sldv.SubSystemExtract.genPositionConstants(sliceMdlH,PortInfo);
        for i=1:length(dsmNames)
            dsName=dsmNames{i};
            Sldv.SubSystemExtract.addDSM(sliceMdlH,dsName,i,posConsts,true,true);
        end
    end
end
