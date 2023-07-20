classdef RangeTruncator1D<handle





    methods
        function newRange=truncate(this,functionWrapper,oldRange,dataTypes,options)
            gridStrat=FunctionApproximation.internal.gridcreator.QuantizedEvenSpacingCartesianGrid(dataTypes(1));
            wl=dataTypes(1).WordLength;


            if options.Interpolation=="Flat"
                correctionFactor=0.5;
            else
                correctionFactor=127/128;
            end
            correctionFactor=double(fi(correctionFactor,0,wl,wl,'RoundingMethod','Floor'));


            searchVectorCell=getGrid(gridStrat,oldRange,max(2^(min(wl,18))-1,2));
            contraintFunction=@(f)correctionFactor*max(options.AbsTol,abs(f)*options.RelTol);
            x=searchVectorCell{1}(:);
            x=x(x>=oldRange.Minimum&x<=oldRange.Maximum);


            y=functionWrapper.evaluate(x);
            nElements=numel(y);


            M=ceil(log2(nElements));
            powXGrid=fliplr([0,1,2,4:4:(M-4)]);


            index=1;
            indexInvalid=nElements-1;
            for k=1:numel(powXGrid)
                index=getIndex(this,index,indexInvalid,contraintFunction,y,powXGrid(k));
            end


            lowIndex=min(max(index,1),nElements);



            yFlip=flipud(y);
            index=1;
            indexInvalid=nElements-lowIndex;
            for k=1:numel(powXGrid)
                index=getIndex(this,index,indexInvalid,contraintFunction,yFlip,powXGrid(k));
            end


            highIndex=min(max(nElements-index+1,2),nElements);


            highIndex=max(lowIndex+1,highIndex);
            lowIndex=min(highIndex-1,lowIndex);


            xRangeLow=x(lowIndex);
            xRangeHigh=x(highIndex);


            newRange=FunctionApproximation.internal.Range(xRangeLow,xRangeHigh);
        end

        function newHead=getIndex(~,head,maxIndex,contraintFunction,y,powX)






            count=0;
            newHead=head;
            while(head<=maxIndex)&&(all(abs(y(1:head)-y(head))<=contraintFunction(y(1:head))))
                newHead=head;
                count=count+1;
                head=head+count*(2^powX);
            end
        end
    end
end