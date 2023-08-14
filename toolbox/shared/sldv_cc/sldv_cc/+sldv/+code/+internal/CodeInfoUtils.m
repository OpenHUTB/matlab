





classdef CodeInfoUtils
    properties(Constant)
        LNK_START='#LNK_START#'
        LNK_END='#LNK_END#'
    end

    methods(Static,Hidden=true)




        function codeInfoStr=encodeCodeInfo(codeLnkInfo,codeFiltInfo)

            if isempty(codeLnkInfo)||~isstruct(codeLnkInfo)
                codeLnkInfo=struct();
            end
            if isempty(codeFiltInfo)||~isstruct(codeFiltInfo)
                codeFiltInfo=struct();
            end

            codeInfo=codeFiltInfo;
            fnames=fieldnames(codeLnkInfo);
            for ii=1:numel(fnames)
                codeInfo.(fnames{ii})=codeLnkInfo.(fnames{ii});
            end

            codeInfoStr=sprintf([...
            sldv.code.internal.CodeInfoUtils.LNK_START,...
            '%s',...
            sldv.code.internal.CodeInfoUtils.LNK_END...
            ],...
            jsonencode(codeInfo));
        end




        function[goalLabel,codeInfoStr]=extractGoalInfo(encodedStr)
            encodedStr=convertStringsToChars(encodedStr);
            codeInfoStr=[];
            goalLabel=encodedStr;
            if isempty(encodedStr)
                return
            end

            try

                idxS=regexp(encodedStr,sldv.code.internal.CodeInfoUtils.LNK_START,'once');
                if isempty(idxS)
                    return
                end


                goalLabel=strtrim(encodedStr(1:idxS-1));


                idxE=regexp(encodedStr,sldv.code.internal.CodeInfoUtils.LNK_END,'once');
                if isempty(idxE)
                    return
                end


                codeInfoStr=strtrim(encodedStr(idxS+numel(sldv.code.internal.CodeInfoUtils.LNK_START):idxE-1));
            catch Mex %#ok<NASGU>
            end
        end




        function[codeInfo,oldCodeInfo]=extractCodeInfo(encodedStr)
            encodedStr=convertStringsToChars(encodedStr);
            codeInfo=[];
            oldCodeInfo='';
            if isempty(encodedStr)
                return
            end

            try

                if sldv.code.internal.CodeInfoUtils.isOldCodeLinkFormat(encodedStr)
                    oldCodeInfo=encodedStr;
                    return
                end


                codeInfo=jsondecode(encodedStr);
            catch Me %#ok<NASGU>
            end
        end




        function codeFilterInfo=extractCodeFilterInfo(encodedStr,ssid)
            if nargin<2
                ssid=[];
            end
            codeFilterInfo=[];
            codeInfo=sldv.code.internal.CodeInfoUtils.extractCodeInfo(encodedStr);
            if~isempty(codeInfo)&&isstruct(codeInfo)
                try
                    filterInfo={...
                    codeInfo.fileName,...
                    codeInfo.funName,...
                    codeInfo.expr,...
                    codeInfo.exprIdx,...
                    codeInfo.kind...
                    };


                    if~isempty(ssid)&&ischar(ssid)&&...
                        (count(ssid,':')==1)&&...
                        (get_param(ssid,'BlockType')=="S-Function")

                        codeFilterInfo.codeCovInfo=filterInfo;
                        codeFilterInfo.ssid=ssid;
                    else
                        codeFilterInfo=filterInfo;
                    end
                catch Me %#ok<NASGU>

                end
            end
        end




        function objectiveDescr=makeRptCodeLink(objective,createLink)
            persistent lnkDisp;
            if isempty(lnkDisp)
                lnkDisp=getString(message('sldv_sfcn:sldv_sfcn:rptLnkViewSource'));
            end

            if nargin<2
                createLink=0;
            end


            objectiveDescr=objective.descr;
            if createLink~=0&&isfield(objective,'codeLnk')&&~isempty(objective.codeLnk)
                [codeInfo,oldCodeInfo]=sldv.code.internal.CodeInfoUtils.extractCodeInfo(objective.codeLnk);
                if~isempty(oldCodeInfo)


                    codeLnkUrl=oldCodeInfo;
                elseif isempty(codeInfo)||...
                    ~isfield(codeInfo,'topModelName')||...
                    ~isfield(codeInfo,'moduleName')||...
                    ~isfield(codeInfo,'fileId')||...
                    ~isfield(codeInfo,'line')

                    return
                else
                    try
                        codeLnkUrl=sprintf([...
                        'matlab:sldv_hilite(''hilite_code'', ',...
'urldecode(''%s''), urldecode(''%s''), ''%s'', %d);'...
                        ],...
                        urlencode(codeInfo.topModelName),...
                        urlencode(codeInfo.moduleName),...
                        codeInfo.fileId,...
                        codeInfo.line);
                    catch
                        return
                    end
                end
                codeUrl=struct(...
                'url',codeLnkUrl,...
                'disp',lnkDisp,...
                'type','url'...
                );
                objectiveDescr=[{objectiveDescr},{codeUrl}];
            end
        end
    end

    methods(Static,Hidden=true)
        function status=isOldCodeLinkFormat(encodedStr)
            if~isempty(encodedStr)
                status=~isempty(regexp(encodedStr,'matlab\s*:\s*sldv_hilite\s*\(','once'));
            else
                status=false;
            end
        end
    end
end


