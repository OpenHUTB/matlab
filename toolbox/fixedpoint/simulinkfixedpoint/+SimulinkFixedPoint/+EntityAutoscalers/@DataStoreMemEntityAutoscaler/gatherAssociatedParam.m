function associateRecords=gatherAssociatedParam(~,blkObj)






    if~strcmp(blkObj.InitialValue,'[]')
        associateRecords=gatherParam(blkObj,'InitialValue',1,{'ModelRequiredMax','ModelRequiredMin'});
    else
        associateRecords=[];
    end


    function associateRecords=gatherParam(blk,paramName,outportSet,fnames)

        pObj=[];
        if ischar(paramName)


            str=blk.(paramName);
            [isValid,minVal,maxVal,pObj]=...
            SimulinkFixedPoint.slfxpprivate('evalNumericParameterRange',blk,str);
        else
            isValid=true;
            [minVal,maxVal]=SimulinkFixedPoint.extractMinMax(paramName);
        end

        if~exist('fnames','var')
            fnames={'ModelRequiredMax','ModelRequiredMin'};
        end

        if isValid
            associateRecords=...
            associateParamValForSpecifiedPorts(blk,outportSet,minVal,maxVal,fnames,pObj);



        else
            associateRecords=[];
        end



        function records=associateParamValForSpecifiedPorts(blk,outportSet,minVal,maxVal,fnames,pObj)


            hPorts=get_param(blk.getFullName,'PortHandles');


            outportSet=cleanPortSet(outportSet,hPorts.Outport);


            nOut=length(outportSet);

            records=[];



            for iOut1=1:nOut

                iOutport1=outportSet(iOut1);
                records(iOut1).blkObj=blk;%#ok
                records(iOut1).pathItem=int2str(iOutport1);%#ok

                for iFName=1:length(fnames)
                    curFName=fnames{iFName};
                    valFinal=getMinMax(curFName,minVal,maxVal);
                    records(iOut1).(curFName)=valFinal;
                end
                records(iOut1).paramObj=pObj;%#ok<AGROW>
            end


            function portSet=cleanPortSet(portSet,actualPortInfo)


                if isequal(-1,portSet)

                    portSet=1:length(actualPortInfo);

                elseif ischar(portSet)



                    temp=1:length(actualPortInfo);%#ok used in call to eval 

                    try
                        portSet=eval(sprintf('temp(%s)',portSet));
                    catch %#ok<CTCH>

                        portSet=[];
                    end
                end


                function netValue=getMinMax(curFName,minVal,maxVal)


                    netValue=[];

                    isMax=contains(curFName,'Max');

                    isMin=contains(curFName,'Min');

                    if~isMax&&~isMin

                        return
                    end

                    if isMax

                        netValue=maxVal;
                    else
                        netValue=minVal;
                    end




