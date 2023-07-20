function v=validateBlock(this,hC)



    v=hdlvalidatestruct;

    slbh=hC.SimulinkHandle;
    cpdt=get_param(slbh,'CompiledPortDataTypes');
    inDT=cpdt.Inport{1};
    blockname='Lookup Table (n-D)';
    for i=2:length(cpdt.Inport)
        if~strcmp(inDT,cpdt.Inport{i})
            v(end+1)=hdlvalidatestruct(1,...
            message('hdlcoder:validate:porttypemismatch',...
            blockname,int2str(i)));%#ok<*AGROW>
        end
    end

    if strcmp(get_param(slbh,'DataSpecification'),'Lookup table object')
        v(end+1)=hdlvalidatestruct(1,message('hdlcoder:validate:LUTObject',...
        blockname));
    end

    [table_data,bpType_ex,oType_ex,~,powerof2,interpVal,bp_data,~,rndMode,...
    ~,diag,extrap,spacing]=this.getBlockInfo(hC);
    nfpOptions=getNFPBlockInfo(this);

    if isempty(table_data)

        v(end+1)=hdlvalidatestruct(1,message('hdlcoder:validate:lookupinvalidtablesource'));
    end

    isOneInput=strcmp(get_param(slbh,'UseOneInputPortForAllInputData'),'on');

    for ii=1:numel(bpType_ex)
        if isfi(bpType_ex{ii})
            bpSign=bpType_ex{ii}.Signed;

            if isOneInput
                pirSigIdx=1;
            else
                pirSigIdx=ii;
            end
            inType=hC.PirInputSignals(pirSigIdx).Type.getLeafType;
            if~inType.isFloatType
                inSign=inType.Signed;
                if bpSign~=inSign
                    v(end+1)=hdlvalidatestruct(1,...
                    message('hdlcoder:validate:LUTBPSignMismatch',...
                    int2str(ii),blockname));
                end
                if inType.WordLength>127
                    v(end+1)=hdlvalidatestruct(1,message('hdlcoder:validate:unsupportedinputwordlengthlut'));
                end

            end
        end
    end

    inSigType=hC.PirInputSignals(1).Type;
    inSigLeafType=inSigType.getLeafType;
    dims=size(table_data);


    numDims=ndims(table_data);
    if numDims>2
        if numDims>=3&&~inSigLeafType.isFloatType
            v(end+1)=hdlvalidatestruct(1,message('hdlcoder:validate:toomanydimsfixedpoint',...
            blockname));
        end
    end

    if length(dims)==2&&dims(2)==1
        dims=dims(1);
    end

    for i=1:numel(dims)-1




        if dims(i)~=2^nextpow2(dims(i))&&any(cellfun(@(x)~isfloat(x),bpType_ex))

            v(end+1)=hdlvalidatestruct(2,message('hdlcoder:validate:notpoweroftwo',...
            int2str(i)));
        end
    end

    slobj=get_param(slbh,'object');
    indexMethods=slobj.getPropAllowedValues('IndexSearchMethod');
    switch slobj.BreakpointsSpecification
    case 'Explicit values'


        if~strcmpi(indexMethods{1},get_param(slbh,'IndexSearchMethod'))&&...
            any(cellfun(@(x)~isfloat(x),bpType_ex))
            v(end+1)=hdlvalidatestruct(1,message('hdlcoder:validate:searchmethod',...
            blockname,indexMethods{1}));

        end
    case 'Even spacing'

    end

    if isOneInput
        v(end+1)=hdlvalidatestruct(1,message('hdlcoder:validate:oneinput'));
    end

    interpMethods=slobj.getPropAllowedValues('interpMethod');
    interpMethod=get_param(slbh,'interpMethod');

    if~strcmp(interpMethod,interpMethods{1})&&...
        ~strcmp(interpMethod,interpMethods{3})
        v(end+1)=hdlvalidatestruct(1,message('hdlcoder:validate:interpolation',...
        interpMethod));
    end

    oType=hC.PirOutputSignals(1).Type;
    oLeafType=oType.getLeafType;
    iType=hC.PirInputSignals(1).Type;
    iLeafType=iType.getLeafType;

    isNFP=targetcodegen.targetCodeGenerationUtils.isNFPMode;


    if isNFP&&iLeafType.isFloatType&&~iLeafType.isEqual(oLeafType)
        v(end+1)=hdlvalidatestruct(1,...
        message('hdlcommon:nativefloatingpoint:IOTypeMismatch',blockname));
    end

    if isNFP&&~isempty(table_data)&&oLeafType.isFloatType&&~isa(table_data,class(oType_ex))


        v(end+1)=hdlvalidatestruct(1,...
        message('hdlcommon:nativefloatingpoint:LutOutTypeMismatch'));
    end

    if isNFP&&iLeafType.isFloatType
        if interpVal~=0
            if nfpOptions.PrecomputeCoefficients
                hdldriver=hdlcurrentdriver;
                v(end+1)=hdlvalidatestruct(2,...
                message('hdlcommon:nativefloatingpoint:LutMismatchNumerics',hdldriver.ModelName));
                if numDims>3
                    v(end+1)=hdlvalidatestruct(1,...
                    message('hdlcommon:nativefloatingpoint:UnsupportedPreComputeCoefficientsOn',blockname));
                end
            else


                if numDims>5
                    v(end+1)=hdlvalidatestruct(2,...
                    message('hdlcommon:nativefloatingpoint:SerialArchForHigherDims'));
                end
            end
        end
    end








    if isNFP&&iLeafType.isHalfType
        if interpVal~=0
            v(end+1)=hdlvalidatestruct(1,...
            message('hdlcommon:nativefloatingpoint:UnsupportedLinearInterpHalfTypes',blockname));
        end
    end


    if isNFP&&interpVal~=0&&(oLeafType.isFloatType&&~iLeafType.isFloatType)
        v(end+1)=hdlvalidatestruct(1,...
        message('hdlcommon:nativefloatingpoint:LutNoInterp'));
    end


    if interpVal~=0&&oType.isComplexType&&(~oLeafType.isFloatType||~iLeafType.isFloatType)
        v(end+1)=hdlvalidatestruct(1,message('hdlcoder:validate:complexinterpolation'));
    end


    if interpVal==1



        if~iLeafType.isFloatType
            allowedExtrapMethodsIndex=1;
        else
            allowedExtrapMethodsIndex=[1,2];
        end

        extrapMethods=slobj.getPropAllowedValues('extrapMethod');
        if~any(cellfun(@(x)strcmp(extrap,x),extrapMethods(allowedExtrapMethodsIndex)))
            v(end+1)=hdlvalidatestruct(1,message('hdlcoder:validate:extrapolation',extrap));
        elseif strcmp(extrap,extrapMethods{1})

            if strcmp(get_param(slbh,'UseLastTableValue'),'off')
                v(end+1)=hdlvalidatestruct(1,message('hdlcoder:validate:uselasttablevalue'));
            end
        end




        if~oLeafType.isFloatType&&...
            oLeafType.WordLength==128&&oLeafType.Signed==0
            v(end+1)=hdlvalidatestruct(1,message('hdlcoder:validate:ufix128interp'));
        end
    end

    if length(hC.PirInputSignals)~=1&&strcmp(get_param(slbh,'InputSameDT'),'off')
        v(end+1)=hdlvalidatestruct(1,message('hdlcoder:validate:oneinputdatatype'));
    end

    fracTypes=slobj.getPropAllowedValues('FractionDataTypeStr');
    intermediateTypes=slobj.getPropAllowedValues('IntermediateResultsDataTypeStr');
    if~(strcmp(interpMethod,interpMethods{1})||strcmp(interpMethod,interpMethods{2}))
        if~strcmp(get_param(slbh,'FractionDataTypeStr'),fracTypes{1})




            v(end+1)=hdlvalidatestruct(1,...
            message('hdlcoder:validate:fractype',fracTypes{1}));
        end

        if~strcmp(get_param(slbh,'IntermediateResultsDataTypeStr'),intermediateTypes{2})&&...
            iLeafType.isFloatType







            v(end+1)=hdlvalidatestruct(1,...
            message('hdlcoder:validate:intermediateresultstype',intermediateTypes{2}));
        end
    end


    rndModeVals=slobj.getPropAllowedValues('RndMeth');
    if~(strcmp(rndMode,rndModeVals{3})||...
        strcmp(rndMode,rndModeVals{6})||...
        strcmp(rndMode,rndModeVals{7}))
        v(end+1)=hdlvalidatestruct(1,message('hdlcoder:validate:rndmode',...
        rndMode,blockname));
    end

    for dim=1:numel(powerof2)
        bpDataStrParam=sprintf('BreakpointsForDimension%dDataTypeStr',dim);
        bpDataStr=get_param(slbh,bpDataStrParam);
        data=bp_data{dim};
        if isempty(data)

            v(end+1)=hdlvalidatestruct(1,message('hdlcoder:validate:lookupinvalidbreakpointsource',...
            int2str(dim)));
        end
        if~isfloat(bpType_ex{dim})

            if length(data)>1

                if powerof2(dim)==-9999
                    v(end+1)=hdlvalidatestruct(2,message('hdlcoder:validate:stridenonpow2',...
                    int2str(dim)));
                end
                if~strcmp(bpDataStr,'Inherit: Same as corresponding input')
                    bp_spacing=data(2)-data(1);



                    if bp_spacing==0
                        v(end+1)=hdlvalidatestruct(1,message('hdlcoder:validate:zerospacing',...
                        int2str(dim)));
                    end
                    if~any(spacing)

                        for ii=2:length(data)
                            this_spacing=data(ii)-data(ii-1);
                            if this_spacing~=bp_spacing
                                v(end+1)=hdlvalidatestruct(1,...
                                message('hdlcoder:validate:notevenspacing',...
                                int2str(dim)));
                                break;
                            end
                        end
                    end
                end
            end
        end
    end



    tableLimit=2^17;
    tableSize=numel(bp_data{1});
    if numel(bp_data)==2
        tableSize=tableSize*numel(bp_data{2});
    end
    if tableSize>tableLimit
        v(end+1)=hdlvalidatestruct(1,...
        message('hdlcoder:validate:LUTtoobig',int2str(tableLimit)));
    end


