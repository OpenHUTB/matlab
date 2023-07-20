classdef BlockSliceObject<slci.results.SliceObject




    methods(Access=public,Hidden=true)

        function obj=BlockSliceObject(aKey,aName,aFunctionScope,aSourceObject)
            if nargin==0
                DAStudio.error('Slci:results:DefaultConstructorError',...
                'BLOCKSLICE');
            end
            slci.results.BlockSliceObject.validateKey(aKey);
            obj=obj@slci.results.SliceObject(aKey,aName,aFunctionScope);
            obj.addSourceObject(aSourceObject);
        end

    end

    methods(Access=public,Hidden=true)

        function checkContributingObject(obj,aSourceObj)%#ok
            if~isa(aSourceObj,'slci.results.ModelObject')
                DAStudio.error('Slci:results:ErrorContributingBlockObject');
            end
        end


        function computeStatus(obj,dataMgr,varargin)
            contribKeys=obj.getContributingSources();
            aStatus=obj.fReportConfig.defaultStatus;
            for k=1:numel(contribKeys)
                contribObj=dataMgr.getBlockObject(contribKeys{k});
                aStatus=Config.getHeaviestStatus(aStatus,contribObj.getStatus());
            end
            obj.setStatus(aStatus);
        end


        function addSourceObject(obj,aSourceObject)
            for k=1:numel(aSourceObject)
                srcObject=aSourceObject{k};


                if isa(srcObject,'slci.results.ModelObject')
                    aSourceKey=srcObject.getKey();
                    obj.addSourceKey(aSourceKey);
                else
                    DAStudio.error('Slci:results:ErrorBlockSliceSource');
                end
            end
        end

        function links=getLink(obj,datamgr)
            srcKeys=obj.getSourceObject();

            links=cell(numel(srcKeys,1));
            for k=1:numel(srcKeys)


                if datamgr.hasObject('BLOCK',srcKeys{k})
                    src=datamgr.getObject('BLOCK',srcKeys{k});
                    links{k}=src.getLink(datamgr);
                else
                    DAStudio.error('Slci:results:UnknownKey',srcKeys{k});
                end
            end
        end

        function callback=getCallback(obj,datamgr)


            links=obj.getLink(datamgr);


            link=links{1};
            if isempty(link)
                callback=obj.getDispName(datamgr);
            else
                modelFileName=datamgr.getMetaData('ModelFileName');
                encodedModelFileName=slci.internal.encodeString(...
                modelFileName,'all','encode');
                callback=slci.internal.ReportUtil.appendCallBack(...
                obj.getDispName(datamgr),encodedModelFileName,link);
            end
        end

        function dispName=getDispName(obj,datamgr)

            srcKeys=obj.getSourceObject();


            srcKey=srcKeys{1};

            fKey=obj.getFunctionScope();



            if datamgr.hasObject('BLOCK',srcKey)
                srcObj=datamgr.getObject('BLOCK',srcKey);
                srcDispName=srcObj.getDispName(datamgr);
                if isa(srcObj,'slci.results.RegistrationDataObject')
                    dispName=srcDispName;
                else

                    if datamgr.hasObject('FUNCTIONINTERFACE',fKey)
                        fObj=datamgr.getObject('FUNCTIONINTERFACE',fKey);
                        fnDisp=['model ',fObj.getType()];
                    else
                        fnDisp=fKey;
                    end

                    dispName=[fnDisp,' ',srcDispName];
                end
            else
                DAStudio.error('Slci:results:UnknownKey',srcKey);
            end

            dispName=[dispName,' (',obj.getName(),') '];
            dispName=slci.internal.encodeString(dispName,'all','encode');
        end

    end

    methods(Static=true,Access=protected,Hidden=true)
        function validateKey(aKey)
            if(isempty(aKey)||~ischar(aKey))
                DAStudio.error('Slci:results:InvalidKey',...
                'BLOCKSLICE');
            end
        end
    end

    methods(Access=protected)
        function checkTraceObj(obj,aTraceObj)%#ok            
            if~isa(aTraceObj,'slci.results.CodeSliceObject')
                DAStudio.error('Slci:results:ErrorTraceObjects',...
                'BLOCKSLICE',class(aTraceObj));
            end
        end
    end

end
