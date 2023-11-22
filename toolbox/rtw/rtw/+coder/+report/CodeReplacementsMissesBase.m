classdef CodeReplacementsMissesBase<coder.report.ReportPageBase
    properties(Access=protected,Transient=true)
        TargetRegistry={};
        CodeReplacementLibraryHandle={};
    end
    properties(Access=protected)
        LibName='';
        TableInfo={};
    end
    methods
        function obj=CodeReplacementsMissesBase(aTfl)
            obj=obj@coder.report.ReportPageBase;
            if~isempty(aTfl)
                obj.LibName=aTfl.LoadedLibrary;
                obj.CodeReplacementLibraryHandle=aTfl;
                for idx=1:length(aTfl.TflTables)
                    aTbl=aTfl.TflTables(idx);
                    obj.TableInfo(idx).Name=aTbl.Name;
                    obj.TableInfo(idx).Inhouse=aTbl.Inhouse;
                    if~aTbl.Inhouse
                        numTraces=1;
                        for idy=1:length(aTbl.AllEntries)
                            thisEntry=aTbl.AllEntries(idy);
                            if isprop(thisEntry,'TraceManager')&&~isempty(thisEntry.TraceManager)
                                if isprop(thisEntry,'Implementation')&&~isempty(thisEntry.Implementation)
                                    obj.TableInfo(idx).Entries{numTraces}.Impl=thisEntry.Implementation.getPreview;
                                elseif isprop(thisEntry,'ImplementationVector')&&~isempty(thisEntry.ImplementationVector)
                                    obj.TableInfo(idx).Entries{numTraces}.Impl=thisEntry.ImplementationVector{end}.getPreview;
                                end
                                obj.TableInfo(idx).Entries{numTraces}.Key=thisEntry.Key;
                                obj.TableInfo(idx).Entries{numTraces}.UID=thisEntry.UID;
                                obj.TableInfo(idx).Entries{numTraces}.CPV=thisEntry.getConceptualPreview;
                                MissSources=thisEntry.TraceManager.MissSourceLocations;
                                numMissSources=length(MissSources);
                                for idz=1:numMissSources
                                    thisMiss=MissSources{idz};
                                    obj.TableInfo(idx).Entries{numTraces}.Misses{idz}.CSO=thisMiss.CSOID;
                                    obj.TableInfo(idx).Entries{numTraces}.Misses{idz}.SIDs=thisMiss.SIDs;
                                    obj.TableInfo(idx).Entries{numTraces}.Misses{idz}.MissInfos=thisMiss.MissInfos;
                                end
                                numTraces=numTraces+1;
                            end
                        end
                    end
                end
            end
        end
        function out=getDefaultReportFileName(~)
            out='missedreplacements.html';
        end
        function out=getLicenseRequirement(~)
            out='RTW_Embedded_Coder';
        end
        function out=getJavaScriptOnLoad(~)
            out=coder.internal.coderReport('getOnloadJS','rtwIdMissedCodeReplacements');
        end
        function out=getConfigOption(~)
            out='GenerateMissedCodeReplacementReport';
        end
    end

    methods(Access=protected)

        function addCodeReplacementSection(obj)

            addedContent(1)=obj.addFunctionReplacementSection;
            addedContent(2)=obj.addOperatorReplacementSection('RTW_OP_ADD','AddMissReplacementTitle',obj.getAddReplacementIntro());
            addedContent(3)=obj.addOperatorReplacementSection('RTW_OP_MINUS','SubMissReplacementTitle',obj.getSubReplacementIntro());
            addedContent(4)=obj.addOperatorReplacementSection('RTW_OP_MUL','MulMissReplacementTitle',obj.getMulReplacementIntro());
            addedContent(5)=obj.addOperatorReplacementSection('RTW_OP_DIV','DivMissReplacementTitle',obj.getDivReplacementIntro());
            addedContent(6)=obj.addOperatorReplacementSection('RTW_OP_CAST','CastMissReplacementTitle',obj.getCastReplacementIntro());
            addedContent(7)=obj.addOperatorReplacementSection('RTW_OP_SL','SLMissReplacementTitle',obj.getSLReplacementIntro());
            addedContent(8)=obj.addOperatorReplacementSection('RTW_OP_SR','SRMissReplacementTitle',obj.getSRReplacementIntro());
            addedContent(9)=obj.addOperatorReplacementSection('RTW_OP_ELEM_MUL','EMMissReplacementTitle',obj.getEMReplacementIntro());
            addedContent(10)=obj.addOperatorReplacementSection('RTW_OP_TRANS','TransMissReplacementTitle',obj.getTransReplacementIntro());
            addedContent(11)=obj.addOperatorReplacementSection('RTW_OP_CONJUGATE','ConjMissReplacementTitle',obj.getConjReplacementIntro());
            addedContent(12)=obj.addOperatorReplacementSection('RTW_OP_HERMITIAN','HermMissReplacementTitle',obj.getHermReplacementIntro());
            addedContent(13)=obj.addOperatorReplacementSection('RTW_OP_TRMUL','TRMMissReplacementTitle',obj.getTRReplacementIntro());
            addedContent(14)=obj.addOperatorReplacementSection('RTW_OP_HMMUL','HMMissReplacementTitle',obj.getHMReplacementIntro());
            addedContent(15)=obj.addOperatorReplacementSection('RTW_OP_GREATER_THAN','GTMissReplacementTitle',obj.getGTReplacementIntro());
            addedContent(16)=obj.addOperatorReplacementSection('RTW_OP_GREATER_THAN_OR_EQ','GTEMissReplacementTitle',obj.getGTEReplacementIntro());
            addedContent(17)=obj.addOperatorReplacementSection('RTW_OP_LESS_THAN','LTMissReplacementTitle',obj.getLTReplacementIntro());
            addedContent(18)=obj.addOperatorReplacementSection('RTW_OP_LESS_THAN_OR_EQ','LTEMissReplacementTitle',obj.getLTEReplacementIntro());
            addedContent(19)=obj.addOperatorReplacementSection('RTW_OP_EQUAL','EQMissReplacementTitle',obj.getEQReplacementIntro());
            addedContent(20)=obj.addOperatorReplacementSection('RTW_OP_NOT_EQUAL','NEQMissReplacementTitle',obj.getNEQReplacementIntro());
            addedContent(21)=obj.addSimdReplacementSection();
            contentAdded=any(addedContent);
            if~contentAdded
                p=Advisor.Paragraph;
                p.addItem([obj.getMessage('CodeReplacementEmptyReport'),' <br />']);
                obj.addItem(p)
            end
        end


        function hasMatch=addFunctionReplacementSection(obj)
            [mapping,hasMatch]=obj.getUsedFunctions('');
            if hasMatch
                [contents,legend]=obj.createRepTable(mapping);
                p=Advisor.Paragraph;
                p.addItem([obj.getCodeReplacmentsIntro,' <br />']);
                p.addItem(['<br>',legend,'<br>']);
                obj.addSection('sec_function_replacements',obj.getFunctionReplacmentTitle,p,contents)
            end
        end

        function hasMatch=addOperatorReplacementSection(obj,op,titleMsgId,introMsg)
            [mapping,hasMatch]=obj.getUsedFunctions(op);
            if hasMatch
                [contents,legend]=obj.createRepTable(mapping);
                p=Advisor.Paragraph;
                p.addItem([introMsg,' <br />']);
                p.addItem(['<br>',legend,'<br>']);
                obj.addSection('sec_operator_replacements',obj.getMessage(titleMsgId),...
                p,contents)
            end
        end

        function hasMatch=addSimdReplacementSection(obj)
            [mapping,hasMatch]=obj.getUsedFunctions('SIMD');
            if hasMatch
                [contents,legend]=obj.createRepTable(mapping);
                p=Advisor.Paragraph;
                p.addItem([obj.getSimdReplacmentsIntro,' <br />']);
                p.addItem(['<br>',legend,'<br>']);
                obj.addSection('sec_simd_replacements',obj.getSimdReplacmentTitle,p,contents)
            end
        end

        function[mapping,hasMatch]=getUsedFunctions(obj,op)
            hasMatch=false;
            mapping={};
            infos=obj.TableInfo;
            for idx=1:length(infos)
                thisTbl=infos(idx);
                mapping{idx}.EntryIdx={};
                for idy=1:length(thisTbl.Entries)
                    thisEnt=thisTbl.Entries{idy};
                    if obj.isDesiredOp(thisEnt.Key,op)
                        mapping{idx}.EntryIdx{end+1}=idy;
                        hasMatch=true;
                    end
                end
            end
        end

        function htmlStr=getSourcelocationFromSID(obj,sid)
            htmlStr=sid;
            try
                [~,blockSID,~,~,~,~]=obj.util_sid(sid);
                htmlStr=obj.getHyperlink(blockSID);
            catch me %#ok<NASGU>
            end
        end

        function[tflList,tflName]=getLibraryContents(obj)
            tflList=[];
            tflName=obj.LibName;
            crls=coder.internal.getCRLs(obj.getTargetRegistry,obj.LibName);
            if~isempty(crls)
                tflList=Advisor.List;
                tflList.setType('Bulleted');
                n=length(crls);
                for i=1:n
                    aTfl=crls(i);
                    if isempty(aTfl)
                        continue;
                    end

                    tflName=aTfl.Name;
                    tflList=obj.addLibraryContentsToList(tflName,tflList);
                    baseTfl=aTfl.BaseTfl;
                    while~isempty(baseTfl)
                        tflList=obj.addLibraryContentsToList(baseTfl,tflList);
                        baseTfl=coder.internal.getTfl(obj.getTargetRegistry,baseTfl).BaseTfl;
                    end
                end
            end
        end

        function tflList=addLibraryContentsToList(obj,aSingleLibrary,tflList)
            aTfl=coder.internal.getTfl(obj.getTargetRegistry,aSingleLibrary);
            if~isempty(aTfl)
                tflName=aTfl.Name;
                thisList=aTfl.TableList;
                cnt=0;
                tflSubList=Advisor.List;
                tflSubList.setType('Bulleted');
                for idx=1:length(thisList)
                    for idx2=1:length(obj.TableInfo)
                        if strcmp(obj.TableInfo(idx2).Name,thisList{idx})
                            if~obj.TableInfo(idx2).Inhouse
                                tflSubList.addItem(thisList{idx});
                                cnt=cnt+1;
                            end
                            break;
                        end
                    end
                end
                if cnt>0
                    tflList.addItem([Advisor.Text(tflName),tflSubList]);
                else
                    tflList.addItem(tflName);
                end
            end
        end

        function[contents,legendText]=createRepTable(obj,mapping)
            persistent conceptText;
            persistent implText;
            persistent missLegendText;
            legend=containers.Map;
            if isempty(conceptText)
                conceptText=DAStudio.message('CoderFoundation:report:CRConceptualText');
            end
            if isempty(implText)
                implText=DAStudio.message('CoderFoundation:report:CRImplText');
            end
            if isempty(missLegendText)
                missLegendText=DAStudio.message('CoderFoundation:report:CRMissLegendText');
            end
            tableCol1={obj.getTableColumnHeader1};
            csoCol={' '};
            option.HasHeaderRow=true;
            option.HasBorder=true;
            for idx=1:length(mapping)
                if~isempty(mapping{idx}.EntryIdx)
                    for idy=1:length(mapping{idx}.EntryIdx)
                        entryIdx=mapping{idx}.EntryIdx{idy};
                        thisEnt=obj.TableInfo(idx).Entries{entryIdx};
                        alink=obj.getHyperlinkForCrtoolHighlightEntry(thisEnt);
                        text=[conceptText,'<br>',thisEnt.CPV,'<br><br>',implText,'<br>',alink{1},thisEnt.Impl,alink{2}];
                        tableCol1{end+1}=text;

                        tableCol2={obj.getTableColumnHeader2};
                        tableCol3={obj.getTableColumnHeader3};
                        tableCol4={obj.getTableColumnHeader4};
                        for idz=1:length(thisEnt.Misses)
                            thisMiss=thisEnt.Misses{idz};
                            tableCol2{end+1}=thisMiss.CSO;
                            text=[];
                            for idxSID=1:length(thisMiss.SIDs)
                                text=[text,obj.getSourcelocationFromSID(thisMiss.SIDs{idxSID}),'<br>'];
                            end
                            tableCol3{end+1}=text;

                            [tableCol4{end+1},aLegend]=obj.createTableForMissReasons(thisMiss.MissInfos);
                            legend=[legend;aLegend];
                        end
                        csoTbl=obj.createTable({tableCol2,tableCol3,tableCol4},option,[2,1,2],{'left','left','left'});
                        csoCol{end+1}=csoTbl;
                    end
                end
            end
            contents=obj.createTable({tableCol1,csoCol},option,[1,3],{'left','left'});
            legendText=[];
            if~isempty(legend)
                legendText=missLegendText;
                legendKeys=keys(legend);
                legendVals=values(legend);
                [~,sortedIdxs]=sortrows(cell2mat(legendVals'));
                for idx=1:length(legend)
                    thisKey=legendKeys{sortedIdxs(idx)};
                    thisMsg=DAStudio.message(['CoderFoundation:tflTrace:',thisKey]);
                    thisVal=legendVals{sortedIdxs(idx)};
                    legendText=[legendText,'<br>',num2str(thisVal),'. ',thisMsg];
                end
            end

        end

        function[tbl,legend]=createTableForMissReasons(obj,reasons)
            tbl=[];
            if~isempty(reasons)
                option.HasHeaderRow=false;
                option.HasBorder=false;
                legend=containers.Map;
                tableCol1={};
                tableCol2={};
                uniqIdxs=[];
                numReasons=length(reasons);

                uniqIdxs(1)=1;
                if numReasons>1
                    currentID=reasons{1}.ID;
                    for jdx=2:numReasons
                        if~strcmp(currentID,reasons{jdx}.ID)
                            currentID=reasons{jdx}.ID;
                            uniqIdxs(end+1)=jdx;
                        end
                    end
                end
                numUniqIDs=length(uniqIdxs);
                MissReasonTable=Advisor.Table(numUniqIDs,2);
                MissReasonTable.setBorder(0);
                for jdx=1:numUniqIDs
                    startIdx=uniqIdxs(jdx);
                    if jdx~=numUniqIDs
                        endIdx=uniqIdxs(jdx+1)-1;
                    else
                        endIdx=numReasons;
                    end
                    if~isKey(legend,reasons{startIdx}.ID)
                        reasonIdx=reasons{startIdx}.idIndex;
                        legend(reasons{startIdx}.ID)=reasonIdx;
                    else
                        reasonIdx=legend(reasons{startIdx}.ID);
                    end
                    tableCol1{end+1}=[num2str(reasonIdx),'.'];
                    reasonsHtml=[];
                    for kdx=startIdx:endIdx
                        thisReason=reasons{kdx};
                        reasonStr=thisReason.toString;
                        if~isempty(reasonStr)
                            if isempty(reasonsHtml)
                                reasonsHtml=reasonStr;
                            else
                                reasonsHtml=[reasonsHtml,'<br>',reasonStr];
                            end
                        end
                    end
                    tableCol2{end+1}=reasonsHtml;
                end
                tbl=obj.createTable({tableCol1,tableCol2},option,[1,6],{'left','left'});
            end

        end
    end

    methods(Static)
        function isDesired=isDesiredOp(key,desiredOp)
            persistent simdKeys;
            if isempty(simdKeys)
                simdKeys={'VADD';'VBROADCAST';'VMUL';'VMAC';'VCAST';...
                'VLOAD';'VSTORE';'VSUB';'VDIV';'VMAS';...
                'VCEIL';'VFLOOR';'VMINIMUM';'VMAXIMUM';'VSQRT'};
            end
            switch key
            case{'RTW_OP_SRL',...
                'RTW_OP_SRA'}
                isDesired=strcmp(desiredOp,'RTW_OP_SR');
            case{'RTW_OP_ADD',...
                'RTW_OP_MINUS',...
                'RTW_OP_MUL',...
                'RTW_OP_DIV',...
                'RTW_OP_CAST',...
                'RTW_OP_SL',...
                'RTW_OP_ELEM_MUL',...
                'RTW_OP_TRANS',...
                'RTW_OP_CONJUGATE',...
                'RTW_OP_HERMITIAN',...
                'RTW_OP_TRMUL',...
                'RTW_OP_HMMUL',...
                'RTW_OP_GREATER_THAN',...
                'RTW_OP_GREATER_THAN_OR_EQ',...
                'RTW_OP_LESS_THAN',...
                'RTW_OP_LESS_THAN_OR_EQ',...
                'RTW_OP_EQUAL',...
'RTW_OP_NOT_EQUAL'...
                }
                isDesired=strcmp(key,desiredOp);
            otherwise
                if ismember(upper(key),simdKeys)
                    isDesired=strcmp(desiredOp,'SIMD');
                else
                    isDesired=isempty(desiredOp);
                end
            end
        end
    end
end




