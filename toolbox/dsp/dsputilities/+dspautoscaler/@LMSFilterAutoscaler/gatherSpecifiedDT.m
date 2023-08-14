function[DTConInfo,comments,paramNames]=gatherSpecifiedDT(h,blkObj,pathItem)




    comments={};
    specifiedDTStr='';

    [modeDlgStr,wlDlgStr,flDlgStr,skipThisSignal,unknownParam]=...
    getLMSFltMdWLFLDlgPrmInfo(h,pathItem,blkObj.stepflag,blkObj.Algo);

    if(strncmp(pathItem,'Error',5)||...
        strncmp(pathItem,'Output',6)||...
        strcmp(pathItem,'1'))


        paramNames.modeStr='';
        paramNames.wlStr='';
        paramNames.flStr='';
        specifiedDTStr='Same as first input';

    elseif unknownParam||skipThisSignal
        paramNames.modeStr='';
        paramNames.wlStr='';
        paramNames.flStr='';
        specifiedDTStr='';

    else
        paramNames.modeStr=modeDlgStr;
        paramNames.wlStr=wlDlgStr;
        paramNames.flStr=flDlgStr;

        if h.isDataTypeFullyInherited(blkObj,pathItem)



            [~,~,~,specifiedDTStr,flStr,modeStr,wlStr]=...
            h.getDataTypeInfoForPathItem(blkObj,pathItem);

            paramNames.wlStr=wlStr;
            paramNames.flStr=flStr;
            paramNames.modeStr=modeStr;

        else

            wlString=paramNames.wlStr;
            wlValueStr=blkObj.(wlString);


            if~isempty(wlValueStr)
                signValStr='Signed';
                if h.isDataTypeFracLengthOnlyInherited(blkObj,pathItem)

                    specifiedDTStr=h.getUDTStrFromFixPtInfo(blkObj,...
                    signValStr,wlValueStr);
                else

                    flString=paramNames.flStr;
                    flValueStr=blkObj.(flString);


                    if~isempty(flValueStr)
                        specifiedDTStr=h.getUDTStrFromFixPtInfo(blkObj,...
                        signValStr,wlValueStr,flValueStr);
                    end
                end
            end
        end
    end

    DTConInfo=SimulinkFixedPoint.DTContainerInfo(specifiedDTStr,blkObj);

end


