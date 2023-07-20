function associateRecords=gatherAssociatedParam(h,blkObj)






    switch blkObj.BlockType
    case 'Constant'

        associateRecords=gatherParam(h,blkObj,'Value',[],1,{'ModelRequiredMax','ModelRequiredMin'});

    case 'InitialCondition'
        associateRecords=gatherParam(h,blkObj,'Value',1,[]);

    case 'UnitDelay'
        associateRecords=gatherParam(h,blkObj,'InitialCondition',1,[]);

    case 'Delay'
        if strcmp(blkObj.InitialConditionSource,'Dialog')
            associateRecords=gatherParam(h,blkObj,'InitialCondition',1,[]);
        else
            associateRecords=[];
        end
    case 'RealImagToComplex'
        if strcmp(blkObj.Input,'Imag')||strcmp(blkObj.Input,'Real')
            associateRecords=gatherParam(h,blkObj,'ConstantPart',1,[]);
        else
            associateRecords=[];
        end

    case 'Gain'
        associateRecords=gatherParam(h,blkObj,'Gain',[],[],{'ModelRequiredMax','ModelRequiredMin'});


    case 'Saturate'
        associateRecords=gatherParam(h,blkObj,'upperLimit',[],1);
        associateRecords=[associateRecords,gatherParam(h,blkObj,'lowerLimit',[],1)];

    case 'Relay'
        associateRecords=gatherParam(h,blkObj,'OnOutputValue',[],1);
        associateRecords=[associateRecords,gatherParam(h,blkObj,'OffOutputValue',[],1)];
        associateRecords=[associateRecords,gatherParam(h,blkObj,'OnSwitchValue',1,[])];
        associateRecords=[associateRecords,gatherParam(h,blkObj,'OffSwitchValue',1,[])];

    case 'Switch'
        if strcmp(blkObj.Criteria,'u2 ~= 0')

            associateRecords=gatherParam(h,blkObj,0,2,[]);
        else


            associateRecords=gatherParam(h,blkObj,'Threshold',2,[]);
        end
    case 'DiscreteIntegrator'
        if strcmp(blkObj.InitialConditionSource,'internal')
            associateRecords=gatherParam(h,blkObj,'InitialCondition',[],1);
        else
            associateRecords=[];
        end
        if strcmp(blkObj.LimitOutput,'on')
            associateRecords=[associateRecords,gatherParam(h,blkObj,'UpperSaturationLimit',[],1)];
            associateRecords=[associateRecords,gatherParam(h,blkObj,'LowerSaturationLimit',[],1)];
        end
    otherwise
        associateRecords=[];

    end


    function associateRecords=gatherParam(h,blk,paramName,inportSet,outportSet,fnames)


        if ischar(paramName)
            str=get_param(blk.Handle,paramName);
            [isValid,minVal,maxVal,pObj]=SimulinkFixedPoint.slfxpprivate('evalNumericParameterRange',blk,str);
        else
            isValid=true;
            [minVal,maxVal]=SimulinkFixedPoint.extractMinMax(paramName);
            pObj=[];
        end

        if~exist('fnames','var')
            fnames={'ModelRequiredMax','ModelRequiredMin'};
        end

        if isValid
            if isempty(inportSet)&&isempty(outportSet)

                associateRecords.blkObj=blk;
                associateRecords.pathItem=paramName;
                associateRecords.srcInfo=[];
                for iFName=1:length(fnames)
                    curFName=fnames{iFName};
                    valFinal=getMinMax(curFName,minVal,maxVal);
                    associateRecords.(curFName)=valFinal;
                end
                associateRecords.paramObj=pObj;

            else
                associateRecords=associateParamValForSpecifiedPorts(h,blk,inportSet,outportSet,minVal,maxVal,fnames,pObj);
            end
        else
            associateRecords=[];
        end



        function records=associateParamValForSpecifiedPorts(h,blk,inportSet,outportSet,minVal,maxVal,fnames,pObj)


            hPorts=get_param(blk.Handle,'PortHandles');

            nIn=length(inportSet);
            nOut=length(outportSet);

            records=[];



            for iIn1=1:nIn

                iInport1=inportSet(iIn1);

                portObj=get_param(hPorts.Inport(iInport1),'Object');

                [sourceBlk,sourceSignal,srcInfo]=h.getSourceSignal(portObj);

                if~isempty(sourceBlk)&&~isempty(sourceSignal)
                    records(iIn1).blkObj=sourceBlk;%#ok  %[sourceBlk1, ' : ', sourceSignal1];
                    records(iIn1).pathItem=sourceSignal;%#ok
                    records(iIn1).srcInfo=srcInfo;%#ok

                    for iFName=1:length(fnames)
                        curFName=fnames{iFName};
                        valFinal=getMinMax(curFName,minVal,maxVal);
                        records(iIn1).(curFName)=valFinal;
                    end
                    records(iIn1).paramObj=pObj;%#ok<AGROW>
                end
            end




            for iOut1=1:nOut

                iOutport1=outportSet(iOut1);
                records(nIn+iOut1).blkObj=blk;%#ok
                records(nIn+iOut1).pathItem=int2str(iOutport1);%#ok
                records(nIn+iOut1).srcInfo=[];%#ok
                for iFName=1:length(fnames)
                    curFName=fnames{iFName};
                    valFinal=getMinMax(curFName,minVal,maxVal);
                    records(nIn+iOut1).(curFName)=valFinal;
                end
                records(nIn+iOut1).paramObj=pObj;%#ok<AGROW>
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




