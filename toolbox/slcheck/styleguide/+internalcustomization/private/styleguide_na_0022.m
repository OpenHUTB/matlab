function conflictDetails=styleguide_na_0022(fcnBlocks)
    conflictDetails={};
    for i=1:length(fcnBlocks)
        conflictDetails=[conflictDetails;AnalyzeScript(fcnBlocks{i})];%#ok<AGROW>
    end
end


function conflictDetails=AnalyzeScript(fcnBlock)






    conflictDetails={};
    switch class(fcnBlock)
    case{'Stateflow.EMChart','Stateflow.EMFunction'}
        T=mtree(fcnBlock.Script,'-com','-cell','-comments');
    case 'struct'
        T=mtree(fcnBlock.FileName,'-com','-cell','-file','-comments');
    end

    [bValid,error]=Advisor.Utils.isValidMtree(T);
    if~bValid
        conflictDetails=[{Simulink.ID.getSID(fcnBlock)},{ModelAdvisor.Text(error.message,{'warn'})}];
        return;
    end

    cases=T.mtfind('Kind','CASE');
    if cases.isnull
        return;
    end

    args=mtfind(Full(Left(cases)),'Kind','ID');
    subTree=List(args);
    [switchArg,~,sIndbegin,sIndend]=Advisor.Utils.getMtreeNodeInfo(fcnBlock,subTree);


    fcns=T.mtfind('Kind','FUNCTION');
    fcnInputArgs=strings(List(Ins(fcns)));


    conflicts=ismember(switchArg,fcnInputArgs);
    switchArgConf=switchArg(conflicts);
    err_ind_start=sIndbegin(conflicts);
    err_ind_end=sIndend(conflicts);
    for i1=1:numel(switchArgConf)
        if isequal(class(fcnBlock),'struct')
            conflicts=ModelAdvisor.ResultDetail;
            ModelAdvisor.ResultDetail.setData(conflicts,'FileName',fcnBlock.FileName,'Expression',switchArgConf{i1},'TextStart',err_ind_start(i1),'TextEnd',err_ind_end(i1));
            conflictDetails=[conflictDetails;conflicts];%#ok<AGROW>
        else
            conflicts=ModelAdvisor.ResultDetail;
            ModelAdvisor.ResultDetail.setData(conflicts,'SID',Simulink.ID.getSID(fcnBlock),'Expression',switchArgConf{i1},'TextStart',err_ind_start(i1),'TextEnd',err_ind_end(i1));
            conflictDetails=[conflictDetails;conflicts];%#ok<AGROW>
        end
    end
end

