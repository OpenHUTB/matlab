function[normalblks,normalrefs,isloaded,allrefmdls,accelRefBlks,accelRefMdls]=getNormalModeBlocks(mdl,varargin)








    if nargin==1
        loadUnopenedModels=true;
    else
        loadUnopenedModels=varargin{1};
    end




    [~,~,aGraph]=find_mdlrefs(mdl,'MatchFilter',@Simulink.match.internal.filterOutCodeInactiveVariantSubsystemChoices);
    analyzer=Simulink.ModelReference.internal.GraphAnalysis.ModelRefGraphAnalyzer;
    result=analyzer.analyze(aGraph,'AnyNormal',...
    'IncludeTopModel',false,'ResultView','Instance');


    normalblks=result.BlockPath(2:end);
    normalrefs=result.RefModel(2:end);
    isloaded=result.IsLoaded(2:end);


    allrefmdls={};
    if nargout>=4
        resultAll=analyzer.analyze(aGraph,'All',...
        'IncludeTopModel',false,'ResultView','Instance');
        allrefmdls=resultAll.RefModel(2:end);
    end


    accelRefBlks={};
    accelRefMdls={};
    if nargout>=5
        resultAccel=setdiff(resultAll,result);
        accelRefBlks=resultAccel.BlockPath;
        accelRefMdls=resultAccel.RefModel;
    end


    if loadUnopenedModels
        cellfun(@load_system,normalrefs);
    end
end
