function[outSize,outLinIdx,outIndexNames]=getSubsrefLinearStringOutputs(ExprLinIdx,exprSize,indexNames)













    if isempty(ExprLinIdx)

        outSize=size(ExprLinIdx);
        outLinIdx=[];
        outIndexNames=repmat({{}},1,numel(outSize));
        return;
    end


    ExprLinIdx=cellstr(ExprLinIdx);


    nsDim=find(exprSize~=1);

    nsDimIdx=size(ExprLinIdx)~=1;

    numNsDimIdx=sum(nsDimIdx);






    if numel(exprSize)==2&&(exprSize(1)==1||exprSize(2)==1)

        nsDimCheck=nsDim;
        if isempty(nsDimCheck)




            if any(strcmp(ExprLinIdx{1},indexNames{2}))

                nsDimCheck=2;
            else



                nsDimCheck=1;
            end
        end


        for k=1:numel(ExprLinIdx)
            if~any(strcmp(indexNames{nsDimCheck},ExprLinIdx{k}))
                throwAsCaller(MException(message('shared_adlib:operators:BadStringIdx',ExprLinIdx{k},nsDimCheck)));
            end
        end

    else

        throwAsCaller(MException(message('shared_adlib:operators:BadLinStringIdx')));
    end




    if isempty(nsDim)








        outSize=size(ExprLinIdx);

        outLinIdx=ones(numel(ExprLinIdx),1);

        outIndexNames=indexNames;
        nsDimIdx=find(nsDimIdx);
        nIdxNames=numel(outIndexNames);
        for i=nsDimIdx

            if i<=nIdxNames&&~isempty(outIndexNames{i})

                outIndexNames{i}=outIndexNames{i}(ones(1,outSize(i)));
            else

                outIndexNames=repmat({{}},1,nIdxNames);
            end
        end


    elseif(numNsDimIdx==1)||(numNsDimIdx==0)








        ExprLinIdx=ExprLinIdx(:);
        outSize=exprSize;
        outSize(nsDim)=numel(ExprLinIdx);
        outLinIdx=cellfun(@(name)find(strcmp(name,indexNames{nsDim}),1,'first'),ExprLinIdx);

        outIndexNames=indexNames;


        outIndexNames{nsDim}=ExprLinIdx';
    else




        outSize=size(ExprLinIdx);
        outLinIdx=cellfun(@(name)find(strcmp(name,indexNames{nsDim}),1,'first'),ExprLinIdx(:));

        outIndexNames=repmat({{}},1,numel(outSize));
    end

end