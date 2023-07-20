function createTBPackage(~,topN,hD,DUT)


    if hD.getParameter('isvhdl')
        hC=pirelab.getTBPackageComp(topN);
        hD.setParameter('vhdl_package_required',true);


        typeSet={};
        fpMode=targetcodegen.targetCodeGenerationUtils.isFloatingPointMode();
        gp=pir;
        sigs=[DUT.getInputSignals('data');DUT.getOutputSignals('data')];
        for ii=1:numel(sigs)
            hT=sigs(ii).Type;
            if(hT.isRecordType)
                hT1=hT.MemberTypesFlattened;
                for jj=1:numel(hT1)
                    if(iscell(hT1))
                        hT=hT1{jj};
                    else
                        hT=hT1(jj);
                    end
                    typeSet=addElementsToSet(typeSet,hT,topN,fpMode);
                end
            else
                typeSet=addElementsToSet(typeSet,hT,topN,fpMode);
            end
        end

        for hT=typeSet
            hC=pirelab.getTBToHexComp(topN,hT{:});
        end
    end
end






function typeSet=addToSet(typeSet,newT)
    found=false;
    leafType=newT.getLeafType;
    fpMode=targetcodegen.targetCodeGenerationUtils.isFloatingPointMode();
    if leafType.isBooleanType||leafType.isWordType(1)


        return;
    end
    for ii=1:numel(typeSet)
        hT=typeSet{ii};
        hTLeaf=hT.getLeafType;
        if(fpMode)


            typeSetCheck=(leafType.isEqual(hTLeaf)&&(newT.isArrayType==hT.isArrayType));
        else


            typeSetCheck=(leafType.isEqual(hTLeaf)...
            ||(leafType.isSingleType&&hTLeaf.isDoubleType)...
            ||(leafType.isDoubleType&&hTLeaf.isSingleType))...
            &&newT.isArrayType==hT.isArrayType;
        end
        if typeSetCheck
            [replacetype,ignoretype]=needTypeEntry(hT,newT);
            found=found||ignoretype||replacetype;
            if replacetype

                typeSet{ii}=newT;
            end
        elseif typesAreCompatibleFixptTypes(leafType,hTLeaf)
            [replacetype,ignoretype]=needTypeEntry(hT,newT);
            found=found||ignoretype||replacetype;
            if replacetype

                typeSet{ii}=newT;
            end
        end
        if found
            break;
        end
    end

    if~found

        typeSet{end+1}=newT;
    end
end



function result=typesAreCompatibleFixptTypes(hT1,hT2)
    result=false;
    if isFixptOrInt(hT1)&&isFixptOrInt(hT2)
        if hT1.Signed==hT2.Signed&&...
            hT1.WordLength==hT2.WordLength
            result=true;
        end
    end
end

function result=isFixptOrInt(hT)
    if isa(hT,'hdlcoder.tp_sfixpt')||isa(hT,'hdlcoder.tp_ufixpt')||...
        isa(hT,'hdlcoder.tp_signed')||isa(hT,'hdlcoder.tp_unsigned')
        result=true;
    else
        result=false;
    end
end

function[replacetype,ignoretype]=needTypeEntry(hT,newT)
    replacetype=false;
    ignoretype=false;



    if newT.isArrayType||hT.isArrayType
        if hT.isMatrix||newT.isMatrix


            if(hT.isMatrix&&newT.isMatrix)&&(hT.NumberOfDimensions==newT.NumberOfDimensions)
                if(prod(newT.Dimensions)>prod(hT.Dimensions))
                    replacetype=true;
                else
                    ignoretype=true;
                end
            end
        else

            if(prod(newT.Dimensions)>prod(hT.Dimensions))
                replacetype=true;
            else
                ignoretype=true;
            end
        end
    else



        ignoretype=true;
    end
end

function typeSet=addElementsToSet(typeSet,hT,topN,fpMode)
    gp=pir;
    if hT.isArrayType
        typeSet=addToSet(typeSet,hT);
        if hT.baseType.isEnumType
            typeSet=addToSet(typeSet,hT.baseType);
        end
    elseif hT.isFloatType
        if gp.getTargetCodeGenSuccess
            if hT.isDoubleType
                lLen=64;
            else
                lLen=32;
            end

            typeSet=addToSet(typeSet,topN.getType('Logic','WordLength',lLen));
        end
        if(~fpMode)

            typeSet=addToSet(typeSet,hT);
        end
    elseif hT.isEnumType
        typeSet=addToSet(typeSet,hT);

    end
end
