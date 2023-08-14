



function linkData(this,funSpec,argSpec,varargin)



    p=inputParser;
    p.addParameter('WorkspaceName','',...
    @(x)validateattributes(x,{'char'},{}));
    p.parse(varargin{:});


    type=this.convertDataType(funSpec,argSpec,'WorkspaceName',p.Results.WorkspaceName);

    if argSpec.Data.isExprArg()


        argSpec.Data.DataType=type;
    else

        dataSetName=[argSpec.DataKind,'s'];

        if isempty(this.(dataSetName).findItem(argSpec.Data.Id))

            this.(dataSetName).add(argSpec.Data);
            argSpec.Data.DataType=type;
        else


            data=this.(dataSetName).Items(argSpec.Data.Id);
            if~strcmp(data.Identifier,argSpec.Data.Identifier)||...
                (data.DataType~=type)||...
                (data.IsComplex~=argSpec.Data.IsComplex)||...
                ~isempty(setdiff(data.Dimensions,argSpec.Data.Dimensions))||...
                ~isequal(numel(data.DimsInfo),numel(argSpec.Data.DimsInfo))||...
                ~(data.DimsInfo==argSpec.Data.DimsInfo)


                desc=this.genMsgForCrossSpecError(argSpec.Data.Identifier,'ExprStartPos','Expression');
                origMsg=message('Simulink:tools:LCTErrorParseDifferentDataSpec');
                msg=message('Simulink:tools:LCTErrorRethrowErrorWithSpec',desc,getString(origMsg));
                throw(MException(msg));
            end


            argSpec.Data=data;
        end


        for ii=1:numel(argSpec.Data.DimsInfo)
            for jj=1:numel(argSpec.Data.DimsInfo(ii).Info)

                if argSpec.Data.DimsInfo(ii).IsInf
                    continue
                end

                exprInfo=argSpec.Data.DimsInfo(ii).Info(jj);
                if~ismember(exprInfo.Kind,{'s','n'})
                    continue
                end

                dataKind=legacycode.lct.spec.Common.Radix2RoleMap(exprInfo.Radix);
                dataKindSet=[dataKind,'s'];
                if~isempty(this.(dataKindSet).findItem(exprInfo.Id))
                    theData=this.(dataKindSet).Items(exprInfo.Id);
                    argSpec.Data.DimsInfo(ii).IsInf=argSpec.Data.DimsInfo(ii).IsInf||theData.IsDynamicArray;
                end
            end
        end


        if~this.Extra.hasNDArray
            this.Extra.hasNDArray=this.getNDArrayMarshalingInfo(argSpec.Data)>0;
        end
    end
