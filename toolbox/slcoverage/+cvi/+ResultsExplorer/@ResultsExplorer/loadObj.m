function loadObj(obj)




    try
        outputDir=obj.outputDir;
        fileName=fullfile(outputDir,obj.saveFileName);
        fullFileName=cvi.ReportUtils.appendFileExtAndPath(fileName,'.cvr');
        if exist(fullFileName,'file')
            var=load(fullFileName,'-mat');
            if~isfield(var,'version')||~strcmpi(var.version,SlCov.CoverageAPI.getVersion)
                return;
            end
            for idx=1:numel(var.data)
                data=cvi.ResultsExplorer.Data.createData(var.data(idx));
                obj.addDataToMaps(data);
            end
            for idx=1:numel(var.nodes)
                cn=var.nodes(idx);
                data=getDataByUniqueId(obj,cn.dataId);
                pnode=cvi.ResultsExplorer.Node.create(data,obj.root.passiveTree);
                obj.root.passiveTree.addNodeToRoot(pnode);

                for idxc=1:numel(cn.childDataIds)
                    uId=cn.childDataIds{idxc};
                    cdata=[];
                    if~isempty(uId)
                        cdata=getDataByUniqueId(obj,uId);
                    end
                    newNode=cvi.ResultsExplorer.Node.create(cdata,obj.root.passiveTree);
                    pnode.addChild(newNode);
                end
            end
            for idx=1:numel(var.chesksumMap)
                key=var.chesksumMap{idx}{1};
                chk=var.chesksumMap{idx}{2};
                modelName='';
                dbVersion='';
                if numel(var.chesksumMap{idx})>2
                    modelName=var.chesksumMap{idx}{3};
                end
                if numel(var.chesksumMap{idx})>3
                    dbVersion=var.chesksumMap{idx}{4};
                end
                strc=cvi.ResultsExplorer.ResultsExplorer.newChecksumInfo(key,chk,modelName,dbVersion);
                if isempty(obj.maps.checksumMap)
                    obj.maps.checksumMap=strc;
                else
                    obj.maps.checksumMap(end+1)=strc;
                end
            end
            obj.loadedfilterFileNames=[];
            if~isempty(obj.filterExplorer)
                obj.loadedfilterFileNames=var.filterFileName;
            else
                loadFilter(obj,var.filterFileName);
            end
        end
    catch MEx
        rethrow(MEx);
    end
end


