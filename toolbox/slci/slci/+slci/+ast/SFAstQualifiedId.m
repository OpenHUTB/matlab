



classdef SFAstQualifiedId<slci.ast.SFAst

    properties
        fRootIdentifier='';
        fElementPath='';
        fEnumConstant=[];
        fId=0;
        fIsEnumConstant=false;
    end

    methods


        function ComputeDataType(aObj)
            assert(~aObj.fComputedDataType);
            if aObj.IsStructElement()
                try %#ok
                    elementType='';
                    if aObj.fId>0





                        objHdl=idToHandle(sfroot,aObj.fId);

                        if strcmpi(objHdl.Scope,'Parameter')
                            elementType='struct';
                        else


                            chartSLHandle=aObj.ParentBlock.getHandle;
                            dpi=sf('DataParsedInfo',aObj.fId,chartSLHandle);
                            elementType=dpi.compiled.type;
                        end
                    end
                    aObj.fDataType=elementType;
                end
            end
        end


        function out=getValue(aObj)
            out=[];

            if strcmp(aObj.fDataType,'struct')

                sfBlkSID=aObj.ParentBlock.getSID();
                try

                    out=slResolve(aObj.fRootIdentifier,sfBlkSID);
                    assert(isstruct(out));
                catch
                    out=[];
                end
            end
        end


        function ComputeDataDim(aObj)
            assert(~aObj.fComputedDataDim);
            if aObj.IsStructElement()
                try %#ok
                    elementDim=1;
                    if aObj.fId>0



                        objHdl=idToHandle(sfroot,aObj.fId);

                        if strcmpi(objHdl.Scope,'Parameter')
                            elementDim=str2double(objHdl.compiledSize);
                        else


                            chartSLHandle=aObj.ParentBlock.getHandle;
                            dpi=sf('DataParsedInfo',aObj.fId,chartSLHandle);
                            elementDim=str2double(dpi.compiled.size);
                        end
                    end
                    aObj.fDataDim=elementDim;
                end
            end
        end


        function aObj=SFAstQualifiedId(aAstObj,aParent)
            aObj=aObj@slci.ast.SFAst(aAstObj,aParent);





            [aObj.fRootIdentifier,aObj.fElementPath]=...
            strtok(aAstObj.sourceSnippet,'.');
            aObj.fId=aAstObj.id;
            if Simulink.data.isSupportedEnumClass(aObj.fRootIdentifier)
                aObj.fDataType=aObj.fRootIdentifier;
                [enums,enumStrs]=enumeration(aObj.fRootIdentifier);


                aObj.fElementPath=aObj.fElementPath(2:end);
                thisEnum=enums(strcmp(aObj.fElementPath,enumStrs));
                if~isempty(thisEnum)
                    aObj.fIsEnumConstant=true;
                    aObj.fEnumConstant=double(thisEnum);
                end
            end
        end


        function out=getBaseName(aObj)
            assert(aObj.IsStructElement());

            out=aObj.getQualifiedName();
            if isempty(out)


                out=aObj.fRootIdentifier;
            end
        end


        function out=IsStructElement(aObj)
            out=isa(aObj.fParent,'slci.ast.SFAstStructMember');
        end


        function out=getElement(aObj)
            out=aObj.fElementPath;
        end


        function out=getEnumConstant(aObj)
            out=aObj.fEnumConstant;
        end


        function out=IsEnumConst(aObj)
            out=aObj.fIsEnumConstant;
        end


        function out=getId(aObj)
            out=aObj.fId;
        end


        function out=isBroadcastToState(aObj)
            out=false;
            if isa(aObj.fParent,'slci.ast.SFAstSendFunction')
                objHandle=idToHandle(sfroot,aObj.fId);
                out=isa(objHandle,'Stateflow.State');
            end
        end


        function out=IsUnsupportedAst(aObj)
            out=~aObj.IsStructElement()...
            &&~aObj.IsEnumConst()...
            &&~aObj.isBroadcastToState();
        end

    end

end


