function retVal=ddg_object_has_method(obj,methodName,numInputs,numOutputs)














    retVal=false;

    narginchk(4,4);

    if~isvarname(methodName)
        DAStudio.error('Simulink:Data:InvalidMethodNameForObjectHasMethod');
    end

    l_CheckNumArgs(numInputs,3);
    l_CheckNumArgs(numOutputs,4);

    if isobject(obj)

        hClass=metaclass(obj);
        hMethod=findobj(hClass.MethodList,...
        'Name',methodName,...
        'Access','public',...
        'Static',false);
        if~isempty(hMethod)
            assert(isscalar(hMethod));
            retVal=(l_NumArgsMatch(hMethod.InputNames,numInputs,'varargin')&&...
            l_NumArgsMatch(hMethod.OutputNames,numOutputs,'varargout'));
        end
    elseif isa(obj,'handle.handle')

        hClass=classhandle(obj);
        if~isempty(hClass.Methods)
            hMethod=find(hClass.Methods,...
            'Name',methodName,...
            'Static','off');%#ok
            if~isempty(hMethod)
                assert(isscalar(hMethod));
                for idx=1:length(hMethod.Signature)
                    hSignature=hMethod.Signature(idx);
                    inputArgs=hSignature.InputTypes;
                    outputArgs=hSignature.OutputTypes;
                    if(strcmp(hSignature.Varargin,'on')||...
                        strcmp(hSignature.Varargout,'on'))

                        continue;
                    end
                    if(l_NumArgsMatch(inputArgs,numInputs,'varargin')&&...
                        l_NumArgsMatch(outputArgs,numOutputs,'varargout'))

                        retVal=true;
                        return;
                    end
                end
            end
        end
    else
        DAStudio.error('Simulink:Data:InvalidObjectForObjectHasMethod');
    end

    function l_CheckNumArgs(numArgs,argNo)


        if isnumeric(numArgs)&&(numArgs>=0)&&(mod(numArgs,1)==0)

        else
            DAStudio.error('Simulink:Data:InvalidNumArgsForObjectHasMethod',argNo);
        end

        function retVal=l_NumArgsMatch(argList,numArgs,varArgName)


            if(numArgs==0)
                retVal=isempty(argList);
            else
                retVal=(((length(argList)==numArgs)&&~isequal(argList{end},varArgName))||...
                ((length(argList)==numArgs+1)&&isequal(argList{end},'varargin')));
            end


