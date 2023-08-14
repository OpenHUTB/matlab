function isDynSize=isTrueDynamicSize(this,dataSpec,theDims)











    narginchk(2,3);
    nargoutchk(0,1);


    dataDims=dataSpec.Dimensions;
    nbDims=numel(dataDims);


    if nargin<3||isempty(theDims)||theDims==-1
        theDims=1:nbDims;
    end


    if any(~ismember(theDims,1:nbDims))
        error(message('Simulink:tools:LCTErrorBadDimToTest'));
    end


    isDynSize=false(1,numel(theDims));


    if isempty(dataSpec.DimsInfo)
        return
    end


    idx=1;
    for ii=theDims
        if dataSpec.DimsInfo(ii).Val~=-1

            isDyn=false;

        elseif dataSpec.DimsInfo(ii).HasInfo

            isDyn=false;
            for jj=1:numel(dataSpec.DimsInfo(ii).Info)
                exprInfo=dataSpec.DimsInfo(ii).Info(jj);
                if strcmpi(exprInfo.Radix,'u')
                    thisInput=this.Inputs.Items(exprInfo.Id);
                    if exprInfo.Kind=='s'

                        dimRef=exprInfo.Val;
                    else

                        dimRef=-1;
                    end
                    iDynInfo=this.isTrueDynamicSize(thisInput,dimRef);
                    isDyn=isDyn||any(iDynInfo==true);
                end


                if isDyn
                    break
                end
            end

        else

            isDyn=true;
        end


        isDynSize(idx)=isDyn;
        idx=idx+1;
    end
