function lookupNDDirect(obj)







    blockType='LookupNDDirect';


    UseRowMajorAlgorithmParamExists=true;
    try
        rowMajorAlg=get_param(obj.modelName,'UseRowMajorAlgorithm');
    catch


        UseRowMajorAlgorithmParamExists=false;
    end




    if isR2018aOrEarlier(obj.ver)&&...
        UseRowMajorAlgorithmParamExists&&strcmp(rowMajorAlg,'on')

        LookupNdDirectBlks=slexportprevious.utils.findBlockType(obj.modelName,blockType);
        if(~isempty(LookupNdDirectBlks))

            for i=1:length(LookupNdDirectBlks)
                blk=LookupNdDirectBlks{i};
                if(strcmp(get_param(blk,'InputsSelectThisObjectFromTable'),'Vector')||...
                    strcmp(get_param(blk,'InputsSelectThisObjectFromTable'),'2-D Matrix'))


                    obj.replaceWithEmptySubsystem(blk);
                end
            end
        end
    end




    if isR2009aOrEarlier(obj.ver)

        maskType='LookupNDDirect';
        fcnName='sfun_nddirectlook';
        refRule='simulink/Lookup\nTables/Direct Lookup\nTable (n-D)';
        setFcn=@setupLookupNDDirect;
        preFcn=@preproLookupNDDirect;

        pre2009bRules=blockToSFunction(obj,blockType,...
        maskType,...
        fcnName,...
        refRule,...
        setFcn,...
        'PreProcessNewBlock',preFcn);

        obj.appendRules(pre2009bRules);

    end

end


function maskVarNames=setupLookupNDDirect(sfcn)
    set_param(sfcn,...
    'Parameters','numInputs,mxTable,clipFlag,tabIsInput,numTDims,samptime',...
    'MaskVariables','maskTabDims=@1;explicitNumDims=@2;outDims=@3;tabIsInput=@4;mxTable=@5;clipFlag=@6;samptime=@7');


    maskVarNames={'outDims',...
    'tabIsInput',...
    'mxTable',...
    'clipFlag',...
    'samptime'};
end


function[parameters,paramValues]=preproLookupNDDirect(blk)
    inumTDims=get_param(blk,'NumberOfTableDimensions');
    if(max(strcmp(inumTDims,{'1','2','3','4'}))==1)
        imaskTabDims=inumTDims;
        iexplicitNumDims='1';
    else
        imaskTabDims='More';
        iexplicitNumDims=inumTDims;
    end

    parameters={'maskTabDims','explicitNumDims'};
    paramValues={imaskTabDims,iexplicitNumDims};
end
