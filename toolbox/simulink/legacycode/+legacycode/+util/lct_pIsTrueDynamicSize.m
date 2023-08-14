function isDynSize=lct_pIsTrueDynamicSize(infoStruct,thisData,theDims)











    nbDims=length(thisData.Dimensions);


    narginchk(2,3);


    if nargin<3
        theDims=1:nbDims;
    end


    if any(~ismember(theDims,1:nbDims))
        DAStudio.error('Simulink:tools:LCTErrorBadDimToTest');
    end


    isDynSize=zeros(1,length(theDims));
    idx=1;


    for ii=theDims
        thisDim=thisData.Dimensions(ii);


        if thisDim~=-1
            isDyn=false;
        else

            thisDimInfo=thisData.DimsInfo.DimInfo(ii);




            if(thisData.DimsInfo.HasInfo(ii)==1)&&...
                strcmp(thisData.DimsInfo.DimInfo(ii).Type,'Parameter')

                isDyn=false;


            elseif(thisData.DimsInfo.HasInfo(ii)==1)&&...
                strcmp(thisData.DimsInfo.DimInfo(ii).Type,'Input')


                thisInput=infoStruct.Inputs.Input(thisData.DimsInfo.DimInfo(ii).DataId);


                isDyn=legacycode.util.lct_pIsTrueDynamicSize(infoStruct,thisInput,thisDimInfo.DimRef);


            else
                isDyn=true;
            end
        end

        isDynSize(idx)=isDyn;
        idx=idx+1;
    end

