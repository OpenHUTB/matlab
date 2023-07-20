function[outputPortIndices,outputMaxValues,outputMinValues]=...
    getModelRequiredMinMaxOutputValues(h,blkObj)%#ok




    switch blkObj.winmode
    case 'Generate window'



        if strcmpi(blkObj.wintype,'User defined')

            blkPath=regexprep(blkObj.getFullName,'\n',' ');
            userFcnHandle=str2func(blkObj.UserWindow);
            fcnArg1=slResolve(blkObj.N,blkPath);
            try
                if strcmpi(blkObj.OptParams,'on')

                    fcnMoreArg=slResolve(blkObj.UserParams,blkPath);
                    winVals=userFcnHandle(fcnArg1,fcnMoreArg{:});
                else
                    winVals=userFcnHandle(fcnArg1);
                end
                outputPortIndices=1;
                outputMaxValues=max(winVals);
                outputMinValues=min(winVals);
            catch

                outputPortIndices=[];
                outputMaxValues=[];
                outputMinValues=[];
            end
        else


            outputPortIndices=1;
            outputMaxValues=1;
            outputMinValues=0;
        end
    case 'Generate and apply window'



        if strcmpi(blkObj.wintype,'User defined')
            outputPortIndices=[];
            outputMaxValues=[];
            outputMinValues=[];
        else


            outputPortIndices=2;
            outputMaxValues=1;
            outputMinValues=0;
        end
    otherwise

        outputPortIndices=[];
        outputMaxValues=[];
        outputMinValues=[];
    end


