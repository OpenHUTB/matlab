function ancs=getAncestors(this,ssid)



    try
        ancs={};


        [isForCode,codeFiltInfo]=SlCov.FilterEditor.isForCode(ssid);
        if isForCode
            ancs=getCodeAncestors(this,codeFiltInfo);
            ancs=fliplr(ancs(:)');
            return
        end

        o=SlCov.FilterEditor.getObject(ssid);
        if isempty(o)
            return;
        end
        while true
            po=getParent(o);
            if isa(po,'Simulink.Root')
                break;
            end
            pssid=SlCov.FilterEditor.getSSID(po);
            ancs=[ancs,pssid];%#ok<AGROW>
            o=po;
        end
    catch MEx
        rethrow(MEx);
    end




    function refo=getParent(o)
        refo=[];







        if isempty(refo)
            if isa(o,'Stateflow.Chart')||isa(o,'Stateflow.LinkChart')||isa(o,'Simulink.SubSystem')




                refo=Stateflow.SLINSF.SubchartMan.getSubchartState(o);
            end
        end
        if isempty(refo)
            refo=o.getParent;
        end


        function ancs=getCodeAncestors(this,codeFiltInfo)
            ancs={};

            if SlCov.FilterEditor.isCodeFilterFileInfo(codeFiltInfo.codeCovInfo)
                return
            end

            if SlCov.FilterEditor.isCodeFilterFunInfo(codeFiltInfo.codeCovInfo)
                ancCodeInfo=codeFiltInfo;
                ancCodeInfo.codeCovInfo=codeFiltInfo.codeCovInfo(1);
                ancs{1}=ancCodeInfo;
                return
            end

            if SlCov.FilterEditor.isCodeFilterDecInfo(codeFiltInfo.codeCovInfo)
                ancCodeInfo=codeFiltInfo;
                ancCodeInfo.codeCovInfo=codeFiltInfo.codeCovInfo(1:2);
                ancs=getCodeAncestors(this,ancCodeInfo);
                ancs{end+1}=ancCodeInfo;

                if numel(codeFiltInfo.codeCovInfo{4})>1
                    ancCodeInfo=codeFiltInfo;
                    ancCodeInfo.codeCovInfo{4}=ancCodeInfo.codeCovInfo{4}(1);
                    ancCodeInfo.codeCovInfo{5}=1;
                    ancs{end+1}=ancCodeInfo;
                end
                return
            end

            if SlCov.FilterEditor.isCodeFilterCondInfo(codeFiltInfo.codeCovInfo)
                numIdx=numel(codeFiltInfo.codeCovInfo{4});
                if numIdx==1

                    ancCodeInfo=codeFiltInfo;
                    ancCodeInfo.codeCovInfo=codeFiltInfo.codeCovInfo(1:2);
                    ancs=getCodeAncestors(this,ancCodeInfo);
                    ancs{end+1}=ancCodeInfo;
                elseif numIdx==2

                    ancCodeInfo=codeFiltInfo;
                    ancCodeInfo.codeCovInfo{4}=ancCodeInfo.codeCovInfo{4}(1);
                    ancCodeInfo.codeCovInfo{5}=0;
                    ancs=getCodeAncestors(this,ancCodeInfo);
                    ancs{end+1}=ancCodeInfo;
                elseif numIdx==3

                    ancCodeInfo=codeFiltInfo;
                    ancCodeInfo.codeCovInfo{4}=ancCodeInfo.codeCovInfo{4}(end);
                    ancCodeInfo.codeCovInfo{5}=1;
                    ancs=getCodeAncestors(this,ancCodeInfo);
                    ancs{end+1}=ancCodeInfo;
                end
                return
            end

            if SlCov.FilterEditor.isCodeFilterMCDCInfo(codeFiltInfo.codeCovInfo)
                ancCodeInfo=codeFiltInfo;
                ancCodeInfo.codeCovInfo{4}=ancCodeInfo.codeCovInfo{4}(1);
                ancCodeInfo.codeCovInfo{5}=1;
                ancs=getCodeAncestors(this,ancCodeInfo);
                ancs{end+1}=ancCodeInfo;
                return
            end

            if SlCov.FilterEditor.isCodeFilterRelBoundInfo(codeFiltInfo.codeCovInfo)
                ancCodeInfo=codeFiltInfo;
                ancCodeInfo.codeCovInfo{4}=ancCodeInfo.codeCovInfo{4}(1);
                ancCodeInfo.codeCovInfo{5}=1;
                ancs=getCodeAncestors(this,ancCodeInfo);
                ancs{end+1}=ancCodeInfo;
                return
            end


