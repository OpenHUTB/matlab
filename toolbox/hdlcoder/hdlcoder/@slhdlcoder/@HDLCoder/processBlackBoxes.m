


function processBlackBoxes(this,hPir,blackBoxVHDLLibNames)
    vNetworks=hPir.Networks;
    numNetworks=length(vNetworks);


    groupByEntityName=containers.Map('KeyType','char','ValueType','any');
    groupByEntityName('*')=[];

    for iNet=1:numNetworks
        hN=vNetworks(iNet);

        if hN.SimulinkHandle<=0
            continue;
        end
        vComps=hN.Components;
        numComps=length(vComps);
        for jComp=1:numComps
            hC=vComps(jComp);
            if all([hC.isBlackBox(),~hC.Synthetic()])
                objs=this.findDocBlocks(hC);
                if~isempty(objs)

                    en=hdlget_param(getfullname(hC.SimulinkHandle),'EntityName');
                    if isempty(en)
                        groupByEntityName('*')=[groupByEntityName('*'),{{hC,hN}}];
                    else
                        if~isKey(groupByEntityName,en)
                            groupByEntityName(en)=[];
                        end
                        groupByEntityName(en)=[groupByEntityName(en),{{hC,hN}}];
                    end
                end



                if isprop(get_param(hC.SimulinkHandle,'Object'),'ProtectedModel')&&...
                    strcmp(get_param(hC.SimulinkHandle,'ProtectedModel'),'on')
                    blockPath=getfullname(hC.SimulinkHandle);
                    configManager=this.getConfigManager(this.ModelName);
                    impl=configManager.getImplementationForBlock(blockPath);
                    modelFile=get_param(hC.SimulinkHandle,'ModelFile');
                    [~,protectedModelName,~]=fileparts(modelFile);

                    dirPath=[this.hdlGetBaseCodegendir,filesep,protectedModelName];
                    matFile=[dirPath,filesep,'hdlcodegenstatus.mat'];
                    clear('ModelGenStatus');
                    load(matFile,'ModelGenStatus');
                    clear portInfo;

                    for ii=1:length(ModelGenStatus.TopNetworkPortInfo.outputPorts)
                        outPort=ModelGenStatus.TopNetworkPortInfo.outputPorts(ii);
                        portInfo(ii).Rate=outPort.Rate;
                        portInfo(ii).Latency=outPort.Latency;
                    end


                    if isa(impl,'hdldefaults.ModelReference')
                        hC.setOutputDelayForProtectedModel(portInfo);
                    end
                end

                if hC.getIsProtectedModel
                    modelFile=get_param(hC.SimulinkHandle,'ModelFile');
                    [~,modelName,~]=fileparts(modelFile);
                    blackBoxVHDLLibNames(modelName)=hC.ImplementationData.VHDLLibraryName;
                end
            end
        end
    end

    if isempty(groupByEntityName('*'))
        groupByEntityName.remove('*');
    end

    for key=groupByEntityName.keys()
        EntityName=key{1};






        defaultBlackBoxesMadeEquivalent=strcmpi(EntityName,'*');

        hNewNet=[];
        for nets=groupByEntityName(EntityName)
            hC=nets{1}{1};
            hN=nets{1}{2};

            if(isempty(hNewNet)||defaultBlackBoxesMadeEquivalent)
                hNewC=this.createBlackBoxVerbatimComps(hC,hN);
                hNewNet=hNewC.Owner;
            else
                params=struct('Name',hC.Name,...
                'EntityName',EntityName);



                verify_port_match(this,hC,hNewNet,params);
            end

        end
    end

end

function verify_port_match(this,hC,hNewC,params)
    port_mismatch=false;
    if(~isequal([length(hC.PirInputPort),length(hC.PirOutputPort)],[length(hNewC.PirInputPort),length(hNewC.PirOutputPort)]))
        port_mismatch=true;
    else


        for itr_in=1:length(hC.PirInputPort)
            if~strcmpi(hC.PirInputPort(itr_in).Kind,hNewC.PirInputPort(itr_in).Kind)
                port_mismatch=true;
            end
        end

        for itr_out=1:length(hC.PirOutputPort)
            if~strcmpi(hC.PirOutputPort(itr_out).Kind,hNewC.PirOutputPort(itr_out).Kind)
                port_mismatch=true;
            end
        end

    end

    path2blk=getfullname(hC.SimulinkHandle);
    function report_error(do_report)
        if~do_report
            return
        end

        msgObj=message('hdlcoder:validate:BBoxCommonEntityNamePortMismatch',path2blk,params.EntityName);
        this.addCheck(this.ModelName,'Error',msgObj,'model',path2blk);
        error(msgObj);
    end

    report_error(port_mismatch);
end


