function[violationML,ExceedLinkObjsML,ExceedLoCML]=getFailingMLFunctions_hisl_0070(mlfbObj,opt,fromCheck)



    violationML={};
    ExceedLinkObjsML={};
    ExceedLoCML={};
    for k=1:length(mlfbObj)
        curObj=mlfbObj{k};
        if isa(curObj,'Stateflow.EMChart')||isa(curObj,'Stateflow.EMFunction')
            id=Simulink.ID.getSID(curObj);
            fileContent=curObj.Script;
            reqOnMLFB=Advisor.Utils.Utils_hisl_0070.HandleHasReqLinks(curObj);
            curObjPath=curObj.Path;
        else
            id=curObj.FileName;
            fileContent=fileread(id);
            reqOnMLFB=false;
            curObjPath=id;
        end
        reqInfo=rmiml.getReqTableData(id);


        mt=mtree(fileContent,'-com','-cell');
        functionNodes=mt.mtfind('Kind','FUNCTION');
        functionIndices=functionNodes.indices;




        if length(functionIndices)==1&&reqOnMLFB
            reqCountArray=1;
        else
            reqCountArray=analyzeMLLinkInfo(reqInfo,functionNodes);
        end
        for ireq=1:length(reqCountArray)
            reqCount=reqCountArray(ireq);
            curFcnNode=functionNodes.select(functionIndices(ireq));

            if(0==reqCount)




                if fromCheck
                    failObj=getViolationInfoFromNode(curObj,curFcnNode,DAStudio.message('ModelAdvisor:hism:hisl_0070_rec_actionML',opt.modelName));
                    failObj.Status=DAStudio.message('ModelAdvisor:hism:hisl_0070_warnML');
                    if isempty(violationML)
                        violationML=failObj;
                    else
                        violationML=[violationML;failObj];
                    end
                else


                    failObj.name=curFcnNode.Fname.string;
                    failObj.path=curObjPath;
                    violationML=[violationML;failObj];
                end

            else
                if fromCheck


                    if reqCount>opt.linkCntThreshold
                        failObj=getViolationInfoFromNode(curObj,curFcnNode,DAStudio.message('ModelAdvisor:hism:hisl_0070_rec_action2'));
                        failObj.CustomData={num2str(count)};
                        failObj.Status=DAStudio.message('ModelAdvisor:hism:hisl_0070_warn3',num2str(opt.linkCntThreshold));

                        if isempty(ExceedLinkObjsML)
                            ExceedLinkObjsML=failObj;
                        else
                            ExceedLinkObjsML=[ExceedLinkObjsML;failObj];
                        end
                    end


                    lineOfCode=getLineOfCode(curFcnNode);
                    if(lineOfCode>opt.childCntThresholdML)

                        failObj=getViolationInfoFromNode(curObj,curFcnNode,DAStudio.message('ModelAdvisor:hism:hisl_0070_rec_actionLOC'));
                        failObj.CustomData={[num2str(lineOfCode),' lines of code']};
                        failObj.Status=DAStudio.message('ModelAdvisor:hism:hisl_0070_warnLOC',num2str(opt.childCntThresholdML));

                        if isempty(ExceedLoCML)
                            ExceedLoCML=failObj;
                        else
                            ExceedLoCML=[ExceedLoCML;failObj];
                        end
                    end
                end
            end
        end

    end
end





function reqCountArray=analyzeMLLinkInfo(reqInfo,functionNodes)


    [numOfReq,~]=size(reqInfo);
    numFunctions=functionNodes.count;
    reqCountArray=zeros(numFunctions,1);
    functionIndices=functionNodes.indices;


    if 0==numOfReq
        return
    end
    for idx=1:length(functionIndices)
        curFcnNode=functionNodes.select(functionIndices(idx));
        lineNo=curFcnNode.lineno;


        reqLineNos=[];
        for ireq=1:numOfReq
            curReqLine=reqInfo{ireq,4};


            if curReqLine(1)<=lineNo&&lineNo<=curReqLine(2)
                reqCountArray(idx)=reqCountArray(idx)+1;
            end
            reqLineNos=[reqLineNos,(curReqLine(1):curReqLine(2))];
        end


        if reqCountArray(idx)==0
            reqCountArray(idx)=checkReqInFunctionBody(curFcnNode,reqLineNos);
        end

    end
end

function reqCount=checkReqInFunctionBody(curFcnNode,reqLineNos)
    reqCount=0;
    curTree=curFcnNode.Tree;
    noCodeNodes=curTree.mtfind('Kind',{'COMMENT','CELLMARK','BLKCOM'});
    codeNodes=curTree.mtfind('~Member',noCodeNodes);
    codeLines=unique(codeNodes.lineno);
    fBody=curFcnNode.Body;


    codeLines=[fBody.lineno:codeLines(end)];

    if all(ismember(codeLines,reqLineNos))
        reqCount=1;
    end
end

function lineOfCode=getLineOfCode(curFcnNode)
    curTree=curFcnNode.Tree;
    noCodeNodes=curTree.mtfind('Kind',{'COMMENT','CELLMARK','BLKCOM'});
    codeNodes=curTree.mtfind('~Member',noCodeNodes);
    lineOfCode=length(unique(codeNodes.lineno));
end

function violationObj=getViolationInfoFromNode(object,node,issue)









    violationObj=ModelAdvisor.ResultDetail;

    nodeStrCell=strsplit(node.tree2str,newline);

    if isa(object,'struct')
        ModelAdvisor.ResultDetail.setData(violationObj,'FileName',object.FileName,'Expression',[strtrim(nodeStrCell{1}),'...'],'TextStart',node.position,'TextEnd',node.endposition);
    else
        ModelAdvisor.ResultDetail.setData(violationObj,'SID',object,'Expression',[strtrim(nodeStrCell{1}),'...'],'TextStart',node.position-1,'TextEnd',node.endposition);
    end

    if~isempty(issue)
        violationObj.RecAction=issue;
    end

end