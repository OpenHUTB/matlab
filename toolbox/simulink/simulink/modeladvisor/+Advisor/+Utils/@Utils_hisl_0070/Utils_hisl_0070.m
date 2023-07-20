classdef Utils_hisl_0070


    methods(Static)

        component=getComponent_hisl_0070(system,varargin);


        failObj=getFailingComponent_hisl_0070(model,blocks,varargin);
    end
    methods(Static=true,Hidden=true)


        simComponent=getSimComponent_hisl_0070(system,opts)


        sfComponent=getSFComponent_hisl_0070(blocks,opts)


        mlComponent=getMLComponent_hisl_0070(system,opts)


        [violationML,ExceedLinkObjsML,ExceedLoCML]=getFailingMLFunctions_hisl_0070(mlfbObj,opt,fromCheck);


        failObj=getFailingSFObj_hisl_0070(sfObjs,opts);


        failObj=getFailingSimObj_hisl_0070(slBlock,opts);


        h=getHandleFromObject(Object)


        [slHs,sfHs]=getHandlesWithRequirements_hisl_0070(system);


        bRes=HandleHasReqLinks(obj)


        bResult=hasReqs(Obj,opt)


        bResult=isConditionallyExempt(Object,opt)


        bResult=isInExcludedBlockList(Object,opt)


        bResult=isObjExcluded_hisl_0070(Object,opt);


        bResult=isSFObjExcluded_hisl_0070(Object,opt,forReq);


        bResult=isSFChart(blockHandle)


        charts=FilterSFCharts(charts,lookUnderMask,followLinks)


        childBlks=getChildOfAnnotation(Object,opt)

    end
end