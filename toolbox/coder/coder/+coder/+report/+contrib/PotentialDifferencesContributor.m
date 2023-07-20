


classdef(Sealed)PotentialDifferencesContributor<coder.report.Contributor

    properties(Constant)
        ID='coder-potentialDifferences'
        DATA_GROUP='potentialDifferences'
        DATA_KEY='messages'
    end

    properties
PotentialDifferences
    end

    methods
        function relevant=isRelevant(~,reportContext)
            relevant=(reportContext.IsEmlc||strcmp(reportContext.ClientType,"fiaccel"))&&...
            isfield(reportContext.Report,'summary')&&...
            isfield(reportContext.Report.summary,'potentialDifferences')&&...
            (isempty(reportContext.Config)||~isprop(reportContext.Config,'ReportPotentialDifferences')||...
            reportContext.Config.ReportPotentialDifferences);
        end

        function supported=isSupportsVirtualMode(~,~)
            supported=true;
        end

        function contribute(this,reportContext,contribContext)
            if contribContext.Filtered
                fcnFilter=contribContext.IncludedFunctionIds;
            else
                fcnFilter=[];
            end
            this.PotentialDifferences=this.categorizeMessages(fcnFilter,reportContext,contribContext);
            contribContext.addData(this.DATA_GROUP,this.DATA_KEY,this.PotentialDifferences);
        end

        function riContributor=getRIContributor(this,reportContext)
            if isempty(this.PotentialDifferences)
                fcnIds=codergui.evalprivate('getIncludedFunctions',reportContext.Report);
                this.PotentialDifferences=this.categorizeMessages(fcnIds,reportContext,[]);
            end
            riContributor=coder.reportinfo.PotentialDifferencesRIContributor(this,reportContext);
        end
    end

    methods(Access=protected)
        function out=categorizeMessages(~,fcnWhitelist,reportContext,contribContext)
            messages=reportContext.Report.summary.potentialDifferences;
            if~isempty(messages)
                messages=messages([messages.TextStart]>=0&[messages.TextLength]>=0);
            end
            msgLen=length(messages);
            out=cell2struct(cell(0,4),{'MsgID','MsgText','MsgTypeName','Occurrences'},2);

            if msgLen==0
                return;
            end






            records=cell(msgLen,5);

            for i=1:msgLen
                records{i,1}=messages(i).MsgID;
                records{i,2}=messages(i).FunctionID;
                records{i,3}=double(messages(i).TextStart);
                records{i,4}=double(messages(i).TextLength);
                records{i,5}=i;
            end
            sortrows(records,1:4);

            filterFuncs=nargin>1&&~isempty(fcnWhitelist);
            prevCat=records{1,1};
            prevFcnId=records{1,2};
            coordStart=1;
            startCategory(1);
            allFcns=reportContext.Report.inference.Functions;

            for i=1:msgLen
                cat=records{i,1};
                diffCat=~strcmp(cat,prevCat);

                if diffCat||records{i,2}~=prevFcnId
                    if i>=coordStart
                        flushFunction(coordStart,i-1);
                    end
                    coordStart=i;
                    if diffCat

                        startCategory(i);
                        prevCat=cat;
                    end
                end
                prevFcnId=records{i,2};
            end
            flushFunction(coordStart,msgLen);

            function startCategory(idx)
                sampleIndex=records{idx,5};
                out(end+1).MsgID=records{idx,1};
                out(end).MsgText=messages(sampleIndex).MsgText;
                out(end).MsgTypeName=messages(sampleIndex).MsgTypeName;
            end

            function flushFunction(startIdx,endIdx)
                fcnId=records{startIdx,2};
                if filterFuncs&&~ismembc(records{i,2},fcnWhitelist)
                    return;
                end
                out(end).Occurrences(end+1).FunctionID=fcnId;

                startCell=records(startIdx:endIdx,3);
                lenCell=records(startIdx:endIdx,4);
                lineNums=cell(numel(startCell),1);
                script=allFcns(fcnId).ScriptID;
                if~isempty(contribContext)
                    for lni=1:numel(lineNums)
                        lineNums{lni}=contribContext.positionToLine(script,startCell{lni}+1);
                    end
                end

                out(end).Occurrences(end).Locations=cell2struct([startCell,lenCell,lineNums],...
                {'TextStart','TextLength','TextLine'},2);
            end
        end
    end
end
