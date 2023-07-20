function objVals=objectiveValues4Solver(obj)








    fnames=fieldnames(obj.ObjectiveSize);
    numFnames=numel(fnames);


    numVals=obj.NumValues;


    if numFnames>1




        numObj=numFnames;


        objVals=zeros(numVals,numObj);


        for i=1:numFnames
            objVals(:,i)=obj.Values.(fnames{i})';
        end
    else





        numObj=prod(obj.ObjectiveSize.(fnames{1}));


        objVals=obj.Values.(fnames{1});
        reshapeSize=[numObj,numVals];
        objVals=reshape(objVals,reshapeSize);


        objVals=objVals';

    end