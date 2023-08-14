




classdef ChartData<slci.common.BdObject

    properties(Access=protected)
        fSfId=-1;
        fDataType='';
        fWidth=1;
        fScope='';
        fPort=0;
        fComplex=0;
        fParent=[];
        fResolveToSignalObject=false;
        fUpdatedFromParsedInfo=false;
    end

    methods


        function aObj=ChartData(aDataUDDObj,aParent)
            aObj.fParent=aParent;
            aObj.fClassName=DAStudio.message('Slci:compatibility:ClassNameData');
            aObj.fClassNames=aObj.fClassName;
            aObj.setUDDObject(aDataUDDObj);
            aObj.fSfId=aDataUDDObj.Id;
            aObj.setName(aDataUDDObj.Name);
            aObj.setSID(Simulink.ID.getSID(aDataUDDObj));
            aObj.fScope=aDataUDDObj.Scope;
            aObj.fPort=aDataUDDObj.Port;
            aObj.fResolveToSignalObject=aDataUDDObj.Props.ResolveToSignalObject;
        end


        function out=getSfId(aObj)
            out=aObj.fSfId;
        end


        function setSfId(aObj,aSfId)
            aObj.fSfId=aSfId;
        end


        function updateFromParsedInfo(aObj)
            if~aObj.fUpdatedFromParsedInfo
                aObj.fUpdatedFromParsedInfo=true;
                chartSLHandle=aObj.ParentBlock.getHandle;
                dpi=sf('DataParsedInfo',aObj.fSfId,chartSLHandle);



                assert(~isempty(dpi));

                aObj.fDataType=dpi.compiled.type;
                aObj.fComplex=dpi.complexity;

                if isempty(dpi.compiled.size)
                    aObj.fWidth=1;
                else
                    dims=str2num(dpi.compiled.size);%#ok
                    aObj.fWidth=1;
                    for i=1:numel(dims)
                        aObj.fWidth=aObj.fWidth*dims(i);
                    end
                end
            end
        end

        function out=getDataType(aObj)
            updateFromParsedInfo(aObj);
            out=aObj.fDataType;
        end

        function out=getWidth(aObj)
            updateFromParsedInfo(aObj);
            out=aObj.fWidth;
        end

        function out=getComplex(aObj)
            updateFromParsedInfo(aObj);
            out=boolean(aObj.fComplex);
        end


        function out=getScope(aObj)
            out=aObj.fScope;
        end


        function out=getPort(aObj)
            out=aObj.fPort;
        end


        function out=isNanPortNum(aObj)
            out=isnan(aObj.getPort());
        end


        function out=getParent(aObj)
            out=aObj.fParent;
        end


        function out=getParentName(aObj)
            out=aObj.fParent.getName();
        end


        function out=isResolveToSignalObject(aObj)
            out=aObj.fResolveToSignalObject;
        end


        function out=ParentChart(aObj)
            out=aObj.fParent;
        end


        function out=ParentBlock(aObj)
            out=aObj.ParentChart().ParentBlock();
        end


        function out=ParentModel(aObj)
            out=aObj.ParentBlock().ParentModel();
        end

    end

end
