classdef HiliteBase<handle




    properties(SetObservable=true)
        objToTextMap=[]
        coloring=[]
        covStyleSession=[]
    end

    methods
        function this=HiliteBase
            this.objToTextMap=containers.Map('KeyType','double','ValueType','char');
        end

        function insertText(this,blkEntry,htmlStr,overwriteExisting)
            if nargin<4
                overwriteExisting=false;
            end
            if isfield(blkEntry,'filterText')
                htmlStr=[htmlStr,blkEntry.filterText];
            end
            cvId=blkEntry.cvId;
            if~overwriteExisting&&this.objToTextMap.isKey(cvId)
                if isfield(blkEntry,'postFix')&&blkEntry.postFix
                    htmlStr=[this.objToTextMap(cvId),'<br><br>',htmlStr];
                else
                    htmlStr=[htmlStr,'<br><br>',this.objToTextMap(cvId)];
                end
            end
            this.objToTextMap(cvId)=htmlStr;
        end

        function htmlStr=getText(this,blkEntry)
            if isstruct(blkEntry)
                cvId=blkEntry.cvId;
            else
                cvId=blkEntry;
            end
            if this.objToTextMap.isKey(cvId)
                htmlStr=this.objToTextMap(cvId);
            else
                htmlStr='';
            end
        end

        function infMap=addToStorage(this,infMap)

            keys=this.objToTextMap.keys;
            for idx=1:numel(keys)
                cvId=keys{idx};
                [hndl,origin]=cv('get',cvId,'.handle','.origin');

                switch(origin)
                case 1
                    udiObj=get_param(hndl,'Object');
                case 2
                    root=sfroot;
                    udiObj=root.idToHandle(hndl);
                otherwise
                    udiObj=[];
                end
                mv=[];
                if any(this.coloring.full==cvId)
                    mv.color='full';
                elseif any(this.coloring.missing==cvId)
                    mv.color='missing';
                elseif any(this.coloring.filtered==cvId)
                    mv.color='filtered';
                end

                if ishandle(udiObj)
                    sid=Simulink.ID.getSID(udiObj);
                    mv.text=this.objToTextMap(cvId);
                    infMap(sid)=mv;
                end
            end
        end



        storeColoring(this,fullCovObjs,justifiedCovObjs,missingCovObjs,filteredCovObjs)
        [markRed,covTxt,partialCovSFObjs]=installInformerText(this,blkEntry,cvstruct,metricNames,toMetricNames,options)
        displayOnModel(this,cvstruct,metricNames,toMetricNames,options,hasFilter)
        mapSignalRanges(informerObj,modelH,covdata)

        function[udiObj,hndl]=getUdiObj(~,cvId)
            [hndl,origin]=cv('get',cvId,'.handle','.origin');
            switch(origin)
            case 1
                udiObj=get_param(hndl,'Object');
            case 2
                root=sfroot;
                udiObj=root.idToHandle(hndl);
            otherwise
                udiObj=[];
            end
        end

    end
    methods(Static=true)

        SFLibInstanceHighlighting(informerObj,sfInstanceStruct);
        SFLibInstanceHighlighting_SLinSF(informerObj,sfInstanceStruct,modelH);
        [toHighlight,informerObj,sfInstanceStruct]=SFLibInstanceHighlightingChecks(blockH);
        colorTable=getHighlightingColorTable

    end
end
