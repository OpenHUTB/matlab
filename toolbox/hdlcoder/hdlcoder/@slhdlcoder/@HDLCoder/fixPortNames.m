function fixPortNames(this)




    numModels=numel(this.AllModels);
    for mdlIdx=1:numModels
        this.mdlIdx=mdlIdx;
        mdlName=this.AllModels(mdlIdx).modelName;
        p=pir(mdlName);
        this.PirInstance=p;

        vN=p.Networks;
        for ii=1:length(vN)
            hN=vN(ii);

            if~isValidBlockNtwk(hN)
                continue;
            end

            numInports=hN.NumberOfPirInputPorts;
            vInports=hN.PirInputPorts;
            for i=1:numInports
                hP=vInports(i);
                fixPort(hN,hP,'OutputSignalNames');
            end


            numOutports=hN.NumberOfPirOutputPorts;
            vOutports=hN.PirOutputPorts;
            for i=1:numOutports
                hP=vOutports(i);
                fixPort(hN,hP,'InputSignalNames');
            end

        end
    end

end


function b=isValidBlockNtwk(hN)

    if(hN.SimulinkHandle<0)||(hN.isBusExpansionSubsystem)
        b=false;
        return;
    end

    fp=hN.FullPath;
    mdlName=strtok(fp,'/');
    [pathstr,name]=fileparts(fp);%#ok<ASGLU>

    blk=find_system(mdlName,...
    'MatchFilter',@Simulink.match.internal.activePlusStartupVariantSubsystem,...
    'FirstResultOnly',true,...
    'Name',name);

    if isempty(blk)
        b=false;
    else

        isSystemBlock=strcmp(get_param(hN.SimulinkHandle,'Type'),'block')&&...
        strcmp(get_param(hN.SimulinkHandle,'BlockType'),'MATLABSystem');
        b=~isSystemBlock;
    end

end


function fixPort(hN,hP,sigName)


    if isempty(hP.Signal)
        return;
    end
    if hP.Signal.SimulinkHandle<0
        return
    end
    if~hP.isData
        return;
    end


    srcPath=[hN.FullPath,'/',hP.Name];


    try
        blkType=get_param(srcPath,'BlockType');
    catch
        return;
    end
    if~strcmpi(blkType,'Inport')&&~strcmpi(blkType,'Outport')
        return;
    end

    ph=get_param(srcPath,'handle');
    icon=get_param(srcPath,'IconDisplay');
    if strcmpi(icon,'Signal name')||strcmpi(icon,'Port number and signal name')
        sname=get_param(ph,sigName);
        if~isempty(sname{1})
            hP.Name=sname{1};
        end
    end

end


