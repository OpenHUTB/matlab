function conflictDetails=styleguide_na_0021(fcnBlocks)









    conflictDetails={};
    for i=1:length(fcnBlocks)
        conflictDetails=[conflictDetails;AnalyzeScript(fcnBlocks{i})];%#ok<AGROW>
    end

end


function conflictDetails=AnalyzeScript(fcnBlock)






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


    subTree=T.mtfind('Kind','CASE').Left;
    subTree=subTree.mtfind('Kind','CHARVECTOR');
    [snames,~,sIndbegin,sIndend]=Advisor.Utils.getMtreeNodeInfo(fcnBlock,subTree);


    subTree=T.mtfind('Kind','EQUALS','Right.Kind','CHARVECTOR');
    subTree=subTree.Left.Full.mtfind('Kind','ID');
    [vnames,~,vIndbegin,vIndend]=Advisor.Utils.getMtreeNodeInfo(fcnBlock,subTree);

    err_str=[snames,vnames];
    indBegin=[sIndbegin;vIndbegin];
    indEnd=[sIndend;vIndend];

    conflictDetails=[];
    for i1=1:numel(err_str)
        if isequal(class(fcnBlock),'struct')
            conflicts=ModelAdvisor.ResultDetail;
            ModelAdvisor.ResultDetail.setData(conflicts,'FileName',fcnBlock.FileName,'Expression',err_str{i1},'TextStart',indBegin(i1),'TextEnd',indEnd(i1));
            conflictDetails=[conflictDetails;conflicts];%#ok<AGROW>
        else
            conflicts=ModelAdvisor.ResultDetail;
            ModelAdvisor.ResultDetail.setData(conflicts,'SID',Simulink.ID.getSID(fcnBlock),'Expression',err_str{i1},'TextStart',indBegin(i1),'TextEnd',indEnd(i1));
            conflictDetails=[conflictDetails;conflicts];%#ok<AGROW>
        end
    end
end


