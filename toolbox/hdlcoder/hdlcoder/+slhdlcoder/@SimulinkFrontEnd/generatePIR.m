function generatePIR(this,configManager,checkhdl)






    hdrv=hdlcurrentdriver;
    slConnection=this.SimulinkConnection;


    startNodeName=slConnection.System;
    hdldisp(sprintf('Begin PIR Construction for : %s',startNodeName),3);



    if~slConnection.Model.isSampleTimeInherited||~this.TreatAsReferencedModel
        modelST=slConnection.Model.getSampleTimeValues;
        if any(isnan(modelST))
            error(message('hdlcoder:engine:unspecifiedsampletime',slConnection.ModelName));
        end


        modelST=modelST(~isnan(modelST)&~isinf(modelST)&modelST>=0);
        this.hPir.setModelSampleTimes(modelST);
    end




    algebraicLoopCheckFailed=hdlshared.algebraicLoopCheck(slConnection)==0;
    if algebraicLoopCheckFailed
        error(message('hdlcoder:engine:algebraicLoop'));
    end




    if~strcmp(slConnection.ModelName,startNodeName)
        portHandles=get_param(startNodeName,'PortHandles');
        for ph=[portHandles.Inport,portHandles.Outport]
            stime=get_param(ph,'CompiledSampleTime');
            if~iscell(stime)&&stime(1)==-1
                msgobj=message('hdlcoder:validate:DutInsideTrigger');
                this.updateChecks(startNodeName,'model',msgobj,'Error');
                break;
            end
        end
    end


    this.hParamArgMap=generateParamArgMap(startNodeName);


    this.BustoVectorBlocks=getBustoVectorBlocks(this,slConnection,startNodeName);


    if this.HDLCoder.AllowBlockAsDUT
        hTopNetwork=this.createNetworkforDirectBlock(startNodeName,configManager);
    else
        hTopNetwork=this.constructPIR(startNodeName,configManager);
    end



    if isprop(get_param(startNodeName,'Object'),'BlockType')&&...
        strcmp(get_param(startNodeName,'IsInSynchronousDomain'),'on')
        hTopNetwork.setHasSLHWFriendlySemantics(true);
    end


    this.hParamArgMap=containers.Map();


    this.toplevelMaskParamInfo(startNodeName,configManager,hTopNetwork);



    this.createNetworksForSF();

    vN=this.hPir.Networks;
    if~isempty(vN)
        this.hPir.setTopNetwork(vN(1));
    end

    this.postConstructionPhase;


    this.analyzeReusedSSBlks();


    WriteReusedSStoFile(this);



    slhdlcoder.SimulinkFrontEnd.annotatePIR(this.hPir);


    if this.AssertionCompPresent
        msg=message('hdlcoder:validate:AssertionCompInModel',startNodeName);
        this.updateChecks(startNodeName,'model',msg,'Warning');
    end



    if~checkhdl
        hdlDrv=hdlcurrentdriver();
        hdlDrv.reportMessages();
    end

    hdldisp(sprintf('End PIR Construction for : %s',startNodeName),3);

end

function paramArgMap=generateParamArgMap(refName)
    paramArgMap=containers.Map();
    slbh=get_param(refName,'Handle');
    if isprop(get_param(slbh,'Object'),'Type')&&strcmp(get_param(slbh,'Type'),'block_diagram')
        paramArgNames=get_param(slbh,'ParameterArgumentNames');
        if~isempty(paramArgNames)
            paramNames=regexp(paramArgNames,',','split');
            paramArgMap=containers.Map(paramNames,paramNames);
        end
    end
end


function blocks=getBustoVectorBlocks(~,slConnection,~)
    blocks=get_param(slConnection.ModelName,'BusInputIntoNonBusBlock');
end



function WriteReusedSStoFile(this)


    if~strcmp(hdlgetparameter('subsystemreuse'),'off')




        hDrv=hdlcurrentdriver;
        if~isempty(hDrv)&&hDrv.CalledFromMakehdl&&~isempty(hDrv.hdlGetCodegendir)
            if isempty(this.ReusedSSBlks)||isempty(this.ReusedSSReport)
                return
            end

            modelName=this.SimulinkConnection.ModelName;


            codegendir=hDrv.hdlGetCodegendir;
            folderName=fullfile(codegendir,'hdltmp');
            if~exist(folderName,'dir')
                mkdir(folderName)
            end


            reusedBlks_map=this.ReusedSSBlks;
            reusedBlks=table(reusedBlks_map.keys',reusedBlks_map.values');
            reusedBlks.Properties.VariableNames={'name','checksum'};
            reusedBlks=sortrows(reusedBlks,{'checksum','name'});


            groups=findgroups(reusedBlks.checksum);
            clonesIdx=false(height(reusedBlks),1);
            for ii=1:max(groups)
                cc=groups==ii;
                if sum(cc)>1
                    clonesIdx=clonesIdx|cc;
                end
            end
            reusedBlks=reusedBlks(clonesIdx,:);


            fileName=fullfile(folderName,[modelName,'_shared_SS.mat']);
            save(fileName,'reusedBlks','reusedBlks_map');


            fileName=fullfile(folderName,[modelName,'_shared_SS.txt']);
            fileID=fopen(fileName,'w');
            record=this.ReusedSSReport;
            for ii=1:length(record)
                grp=record{ii};
                fprintf(fileID,'Count - %d\n',length(grp));
                for jj=1:length(grp)
                    fprintf(fileID,'%s\n',grp{jj});
                end
                fprintf(fileID,'\n');
            end
            fclose(fileID);


            debug=this.HDLCoder.getParameter('debug')>=1;
            if debug
                disp(reusedBlks);
            end
        end
    end

end



