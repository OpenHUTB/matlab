function fv=f2ffeature(f,new_fv)
    mlock;
    persistent pFeatureMap;
    if isempty(pFeatureMap)
        pFeatureMap=containers.Map();

        pFeatureMap('SingleCCellArraySupport')=false;
        pFeatureMap('EmitColonWarnings')=true;
        pFeatureMap('TransformLibraryFunctions')=true;
        pFeatureMap('AnalyzeConstants')=false;

        pFeatureMap('MLFBApplyStyle')='Variants';
        pFeatureMap('MEXLOGGING')=false;
        pFeatureMap('OverflowLogging')=false;


        pFeatureMap('RunningMLFBFBT')=false;
        pFeatureMap('EnableNonScalarDerivedAnalaysis')=false;
    end

    if strcmp(f,'-all')
        fv=containers.Map(pFeatureMap.keys,pFeatureMap.values);
        if nargin==2
            pFeatureMap=new_fv;
        end
    else
        assert(pFeatureMap.isKey(f));
        fv=pFeatureMap(f);

        if nargin==2
            pFeatureMap(f)=new_fv;
        end
    end
end
