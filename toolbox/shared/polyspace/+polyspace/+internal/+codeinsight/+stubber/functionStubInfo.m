

classdef functionStubInfo<handle
    properties
        Name(1,1)string
        Signature(1,1)string
        Body(1,1)string
extraGlobal
        useMemCpy(1,1)logical
    end

    methods
        function self=functionStubInfo(funInfo)
            functionName=funInfo.Name;
            returnType=funInfo.ReturnedType.Signature;
            returnUnderlayingType=funInfo.ReturnedType.UnderlayingType;
            returnStubTypeName=funInfo.ReturnedType.StubTypeName;
            argumentsTypeList=[funInfo.FormalArguments.Signature];
            argUnderlayingType=[funInfo.FormalArguments.UnderlayingType];
            argStubTypeName=[funInfo.FormalArguments.StubTypeName];
            argIsPassByPointer=strcmp([funInfo.FormalArguments.Kind],'PointerType');
            argIsArray=strcmp([funInfo.FormalArguments.Kind],'ArrayType');
            self.Name=functionName;
            self.extraGlobal=[];
            self.useMemCpy=false;


            self.Signature=returnType+" "+functionName+"(";

            nArgs=numel(argumentsTypeList);
            if nArgs>0
                argsName=strings(1,nArgs);
                argsName(:)=functionName+"_p";
                argsIdx=1:nArgs;
                argsName=argsName+argsIdx;
                argsTypeAndName=argStubTypeName;
                for idx=1:nArgs
                    argsTypeAndName(idx)=argsTypeAndName(idx).replace("$stubvar$",argsName(idx));
                end
                self.Signature=self.Signature+argsTypeAndName.join(", ");

                validargs=~strcmp(argUnderlayingType,'void');
                argStubTypeNameErased=erase(erase(argStubTypeName,"*")," const");
                extraGlobalSLStubIn=argStubTypeNameErased(validargs);
                extraGlobalNames="SLStubIn_"+argsName(validargs);
                for idx=1:numel(extraGlobalSLStubIn)
                    extraGlobalSLStubIn(idx)=extraGlobalSLStubIn(idx).replace("$stubvar$",extraGlobalNames(idx))+";";
                end
                self.extraGlobal=[self.extraGlobal,extraGlobalSLStubIn];
            else
                self.Signature=self.Signature+"void";
            end
            self.Signature=self.Signature+")";


            self.Body="";
            indent="  ";


            if nArgs>0
                assignParams=strings(1,nArgs);
                for idx=1:nArgs
                    if~strcmp(argUnderlayingType(idx),'void')
                        if argIsPassByPointer(idx)
                            assignParams(idx)=indent+"SLStubIn_"+argsName(idx)+" = *"+argsName(idx)+";";
                        else
                            if argIsArray(idx)
                                assignParams(idx)=indent+"memcpy( "+"SLStubIn_"+argsName(idx)+", "+argsName(idx)+...
                                ", sizeof("+argsName(idx)+") );";
                                self.useMemCpy=true;
                            else
                                assignParams(idx)=indent+"SLStubIn_"+argsName(idx)+" = "+argsName(idx)+";";
                            end
                        end
                    end
                end

                if~isempty(assignParams)
                    self.Body=self.Body+join(assignParams,newline);
                end
            end
            if returnUnderlayingType~="void"
                self.Body=self.Body+newline+...
...
                indent+"return "+"SLStubOut_"+functionName+";";
                returnTypeName=erase(erase(returnStubTypeName,"*")," const");
                extraGlobalReturnName="SLStubOut_"+functionName;
                returnTypeName=returnTypeName.replace("$stubvar$",extraGlobalReturnName);
                self.extraGlobal=[self.extraGlobal,returnTypeName+";"];
            end

        end

        function definition=getDefinition(self)


            definition=self.Signature+newline+...
            "{"+newline+...
            self.Body+newline+...
            "}"+newline;
        end
    end
end

