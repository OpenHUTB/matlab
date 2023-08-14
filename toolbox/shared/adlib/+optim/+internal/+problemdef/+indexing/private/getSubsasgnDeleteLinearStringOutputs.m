function[outSize,outLinIdx,outIndexNames]=getSubsasgnDeleteLinearStringOutputs(ExprLinIdx,exprSize,indexNames)














    nsDim=exprSize~=1;

    if isempty(ExprLinIdx)

        if(sum(nsDim)==1)

            outSize=exprSize;
        else

            outSize=[1,prod(exprSize)];
        end
        outLinIdx=[];
        outIndexNames=indexNames;
        return;
    end



    ExprLinIdx=cellstr(ExprLinIdx);







    if numel(exprSize)==2&&~all(nsDim)

        nsDimcheck=find(nsDim);
        if isempty(nsDimcheck)



            indexNames={[indexNames{1:2}]};
            nsDimcheck=1;
        end


        newIndexNames=~cellfun(@(name)any(strcmp(name,indexNames{nsDimcheck})),ExprLinIdx);
        if any(newIndexNames)
            badIdx=find(newIndexNames,1,'first');
            throwAsCaller(MException(message('shared_adlib:operators:BadStringIdx',ExprLinIdx{badIdx},nsDimcheck)));
        end
    else


        throwAsCaller(MException(message('shared_adlib:operators:BadLinStringIdx')));
    end








    if any(nsDim)

        outSize=exprSize;
        outSize(nsDim)=outSize(nsDim)-optim.internal.problemdef.numUniqueNames(ExprLinIdx);
        outLinIdx=cellfun(@(name)find(strcmp(name,indexNames{nsDim}),1,'first'),ExprLinIdx);
        outIndexNames=indexNames;
        outIndexNames{nsDim}(outLinIdx)=[];
    else

        outSize=[1,0];
        outIndexNames={{},{}};

        outLinIdx=1;
    end

end