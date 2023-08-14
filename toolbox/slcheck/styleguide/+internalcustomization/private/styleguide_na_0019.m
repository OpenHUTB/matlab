function conflictDetails=styleguide_na_0019(fcnBlocks)









    reservedNames=lower(Advisor.Utils.Naming.getReservedNames());
    conflictDetails={};
    for i=1:length(fcnBlocks)
        conflictDetails=[conflictDetails;AnalyzeScript(fcnBlocks{i},reservedNames)];%#ok<AGROW>
    end
end

function conflictDetails=AnalyzeScript(fcnBlock,reservedNames)











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


    fcns=T.mtfind('Kind','FUNCTION');
    [fcnIns,~,iIndbegin,iIndend]=Advisor.Utils.getMtreeNodeInfo(fcnBlock,fcns.Ins.Full);
    [fcnOuts,~,oIndbegin,oIndend]=Advisor.Utils.getMtreeNodeInfo(fcnBlock,fcns.Outs.Full);


    T=mtfind(T,'Kind','EQUALS');
    T=T.Left.Full.mtfind('Kind','ID');
    [names,~,vIndbegin,vIndend]=Advisor.Utils.getMtreeNodeInfo(fcnBlock,T);

    names=[fcnIns,fcnOuts,names];
    indBegin=[iIndbegin;oIndbegin;vIndbegin];
    indEnd=[iIndend;oIndend;vIndend];

    lowerNames=lower(names);

    errFlag=cellfun(@(x)Advisor.Utils.isaKeyword(x)||ismember(x,reservedNames),lowerNames);
    err_names=names(errFlag);
    err_ind_start=indBegin(errFlag);
    err_ind_end=indEnd(errFlag);
    conflictDetails=[];
    for i1=1:numel(err_names)
        if isequal(class(fcnBlock),'struct')
            conflicts=ModelAdvisor.ResultDetail;
            ModelAdvisor.ResultDetail.setData(conflicts,'FileName',fcnBlock.FileName,'Expression',err_names{i1},'TextStart',err_ind_start(i1),'TextEnd',err_ind_end(i1));
            conflictDetails=[conflictDetails;conflicts];%#ok<AGROW>
        else
            conflicts=ModelAdvisor.ResultDetail;
            ModelAdvisor.ResultDetail.setData(conflicts,'SID',Simulink.ID.getSID(fcnBlock),'Expression',err_names{i1},'TextStart',err_ind_start(i1),'TextEnd',err_ind_end(i1));
            conflictDetails=[conflictDetails;conflicts];%#ok<AGROW>
        end
    end
end


