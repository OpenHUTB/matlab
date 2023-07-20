function generateSLBlock(this,hC,targetBlkPath)














    originalBlkPath=getfullname(hC.SimulinkHandle);

    inlineParams=true;
    [~,fcnText,~,TunableParamStrs,~,paramTypes,...
    nonTunableParamNames,ctrlPropertyNames]=...
    getMATLABScriptAndParams(this,hC,inlineParams);

    outDelay=hC.getOptimizationLatency;
    if outDelay>0
        if~isempty(TunableParamStrs)


            targetSystem=this.addSLBlockSubsystem(hC,originalBlkPath,targetBlkPath);
            targetBlkPath=[targetBlkPath,'/',hC.Name];
            outputBlkPosition=createMATLABFunctionBlock(hC,targetBlkPath,fcnText,paramTypes,...
            nonTunableParamNames,ctrlPropertyNames);
            connectInputs(hC,targetSystem);
            [turnhilitingon,color]=this.getHiliteInfo(hC);%#ok<ASGLU>
            this.addLatencyToOutports(hC,targetSystem,hC.Name,outputBlkPosition,color,outDelay);
        else
            generateSLBlockWithDelay(this,hC,originalBlkPath,targetBlkPath,outDelay);
        end
    else
        if~isempty(TunableParamStrs)


            createMATLABFunctionBlock(hC,targetBlkPath,fcnText,paramTypes,...
            nonTunableParamNames,ctrlPropertyNames);
        else

            addSLBlock(this,hC,originalBlkPath,targetBlkPath);
        end
    end

end

function outputBlkPosition=createMATLABFunctionBlock(hC,targetName,fcnText,paramTypes,...
    nonTunableParamNames,ctrlPropertyNames)


    nonTunableParamNamesForInput=strcat(nonTunableParamNames,'_prop');
    ctrlPropertyNames=strcat(ctrlPropertyNames,'_prop');

    originalSlbh=hC.SimulinkHandle;
    slHandle=add_block('eml_lib/MATLAB Function',targetName);
    set_param(slHandle,'Orientation','right');

    blockPosition=[160,75,245,115];
    set_param(slHandle,'Position',blockPosition);
    outputBlkPosition=[blockPosition(3),blockPosition(2)];

    chartID=sfprivate('block2chart',slHandle);
    r=sfroot;
    chartUddH=r.idToHandle(chartID);
    if~isempty(chartUddH)
        chartUddH.Script=fcnText;
    end
    if slHandle>0
        blkName=getfullname(slHandle);
        hdlfixblockname(blkName);


        maskObj=Simulink.Mask.create(slHandle);
        for ii=1:numel(paramTypes)
            paramName=nonTunableParamNamesForInput{ii};
            if any(strcmp(paramName,ctrlPropertyNames))


                value='off';
            else
                value=get_param(originalSlbh,nonTunableParamNames{ii});
            end
            if strcmp(paramTypes{ii},'boolean')
                maskObj.addParameter('Type','checkbox',...
                'Name',paramName,...
                'Prompt',paramName,'Value',value,...
                'Tunable','off');
            elseif strcmp(paramTypes{ii},'string')
                maskObj.addParameter('Name',paramName,...
                'Prompt',paramName,'Value',value,...
                'Tunable','off');
            else
                maskObj.addParameter('Type','popup','Name',paramName,...
                'Prompt',paramName,'Value',value,...
                'TypeOptions',{value},...
                'Tunable','off');
            end
        end


        chartInputs=chartUddH.find('-isa','Stateflow.Data','Scope','Input');
        numTunablePropStart=numel(chartInputs)-numel(nonTunableParamNames)+1;
        for ii=numTunablePropStart:numel(chartInputs)
            chartInputs(ii).Scope='Parameter';
        end


        chartParams=chartUddH.find('-isa','Stateflow.Data','Scope','Parameter');
        for ii=1:numel(chartParams)
            chartParams(ii).Tunable=0;
        end
    end
end

function connectInputs(hC,targetBlkPath)

    for ii=1:length(hC.PirInputPorts)
        oport=sprintf('In%i/1',ii);
        iport=sprintf('%s/%i',hC.Name,ii);
        add_line(targetBlkPath,oport,iport,'autorouting','on');
    end

end
