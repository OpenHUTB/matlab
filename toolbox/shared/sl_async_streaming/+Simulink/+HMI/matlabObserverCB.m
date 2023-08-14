function matlabObserverCB(cbData)




    if isempty(cbData)
        return;
    end

    for idx=1:length(cbData)


        if isempty(cbData(idx).cbFcn)
            return;
        end


        assert(isequal(cbData(idx).groupNum,0));

        try

            callbackFcn=str2func(cbData(idx).cbFcn);

            if~isempty(cbData(idx).cbParam)
                param=cbData(idx).cbParam;
                path=strsplit(cbData(idx).blkPath,'/');
                mdl=path{1};

                if is_simulink_loaded&&bdIsLoaded(mdl)
                    evaluatedParam=slResolve(param,cbData(idx).blkPath);
                else
                    evaluatedParam=evalin('base',param);
                end


                locCheckArgsAndInvokeFcn(cbData(idx).time,...
                cbData(idx).data,...
                cbData(idx).enumName,...
                callbackFcn,...
                evaluatedParam);
            else

                locCheckArgsAndInvokeFcn(cbData(idx).time,...
                cbData(idx).data,...
                cbData(idx).enumName,...
                callbackFcn);
            end

        catch ME
            switch ME.identifier
            case 'Simulink:Data:SlResolveNotResolve'
                throwAsCaller(MException(message('SimulinkHMI:errors:DataAccessInvalidCallbackParams',...
                cbData(idx).cbParam,cbData(idx).blkPath,cbData(idx).portIdx)));
            otherwise
                throwAsCaller(MException(message('SimulinkHMI:errors:DataAccessCallbackError',...
                cbData(idx).cbFcn,cbData(idx).blkPath,cbData(idx).portIdx,...
                ME.message)));
            end
        end
    end
end


function yEnumType=locConvertToEnumLiteral(data,enumName)
    for index=1:length(data)
        yEnumType(index,1)=feval(enumName,data(index));%#ok<AGROW>
    end
end


function locCheckArgsAndInvokeFcn(time,data,enumName,callbackFcn,params)


    if~isempty(enumName)
        if(iscell(enumName))
            for idx=1:size(enumName,1)
                signalPath=strcat('data','.',enumName{idx,1});
                oldData=eval(signalPath);
                convertedData=locConvertToEnumLiteral(oldData,enumName{idx,2});
                eval(strcat(signalPath,' = ','convertedData;'));
            end
        else
            data=locConvertToEnumLiteral(data,enumName);
        end
    end


    if nargin<5
        locInvokeWithoutUserParams(time,data,callbackFcn);
    else
        locInvokeWithUserParams(time,data,callbackFcn,params);
    end
end


function locInvokeWithUserParams(time,data,callbackFcn,params)

    if~isempty(time)
        locInvokeCallbackFcn(callbackFcn,data,time,params);
    else
        locInvokeCallbackFcn(callbackFcn,data,params);
    end
end


function locInvokeWithoutUserParams(time,data,callbackFcn)

    if~isempty(time)
        locInvokeCallbackFcn(callbackFcn,data,time);
    else
        locInvokeCallbackFcn(callbackFcn,data);
    end
end


function locInvokeCallbackFcn(callbackFcn,data,varargin)

    if(nargin==2)
        callbackFcn(data);
    elseif(nargin==3)
        callbackFcn(data,varargin{1});
    elseif(nargin==4)
        callbackFcn(data,varargin{1},varargin{2});
    else
        assert(false);
    end
end

